# Manual Implementation Runbook - Hyperledger Fabric v2 (5 Phases)

Tài liệu này là runbook thao tác thủ công, chỉ ra rõ từng bước bạn phải làm. Tài liệu KHÔNG tự động sửa code.

## 1) Mục tiêu, phạm vi, và mapping

Mapping node:
1. Peer1 = peer0.org1.example.com.
2. Peer2 = peer0.org2.example.com.
3. Channel = rentingchannel.
4. Chaincode = renting.

Mục tiêu theo giai đoạn:
1. Phase 1: Deploy tất cả thành phần lên 1 VPS.
2. Phase 2: Tách Peer1 sang VPS-2.
3. Phase 3: Đưa Peer2 về Local.
4. Phase 4: Cho Admin kết nối vào Peer2 local.
5. Phase 5: Tích hợp full network (VPS-1 + VPS-2 + Local), giao dịch endorse và commit thành công.

Khuyến nghị route:
1. Ưu tiên WireGuard/VPN để ổn định endpoint và TLS SAN.
2. Chỉ dùng Public IP trực tiếp nếu bắt buộc.

## 2) Checklist trước khi bắt đầu (Phase 0)

Checklist:
1. [ ] Backup toàn bộ [blockchain-fabric-v2](blockchain-fabric-v2).
2. [ ] Chốt endpoint matrix cho orderer, 2 peer, 2 CA.
3. [ ] Chốt firewall policy (chỉ mở cổng cần thiết).
4. [ ] Kiểm tra đầy đủ tool: docker, docker compose, cryptogen, configtxgen, peer, jq.
5. [ ] Chốt chính sách phân phối TLS cert và private key.

Lệnh kiểm tra nhanh:

~~~bash
cd blockchain-fabric-v2/test-network
which cryptogen configtxgen peer jq
docker --version
docker compose version
~~~

## 3) Danh sách file bạn sẽ sửa thủ công

Fabric scripts và config:
1. [test-network/scripts/envVar.sh](test-network/scripts/envVar.sh)
2. [test-network/scripts/setAnchorPeer.sh](test-network/scripts/setAnchorPeer.sh)
3. [test-network/scripts/ccutils.sh](test-network/scripts/ccutils.sh)
4. [test-network/setOrgEnv.sh](test-network/setOrgEnv.sh)
5. [test-network/organizations/ccp-template.json](test-network/organizations/ccp-template.json)
6. [test-network/organizations/ccp-template.yaml](test-network/organizations/ccp-template.yaml)
7. [test-network/organizations/ccp-generate.sh](test-network/organizations/ccp-generate.sh)
8. [test-network/organizations/cryptogen/crypto-config-orderer.yaml](test-network/organizations/cryptogen/crypto-config-orderer.yaml)
9. [test-network/organizations/cryptogen/crypto-config-org1.yaml](test-network/organizations/cryptogen/crypto-config-org1.yaml)
10. [test-network/organizations/cryptogen/crypto-config-org2.yaml](test-network/organizations/cryptogen/crypto-config-org2.yaml)
11. [test-network/compose/compose-test-net.yaml](test-network/compose/compose-test-net.yaml)
12. [test-network/configtx/configtx.yaml](test-network/configtx/configtx.yaml)

Admin app:
1. [../quan-ly-tim-kiem-phong-tro-admin/src/lib/fabric/fabricClient.ts](../quan-ly-tim-kiem-phong-tro-admin/src/lib/fabric/fabricClient.ts)

## 4) Baseline refactor: bỏ hardcode localhost

### 4.1 Mục tiêu

Tất cả endpoint orderer, peer, anchor peer, và connection profile phải đọc từ biến môi trường. Khi không có override, hệ thống vẫn fallback localhost để không vô luân local cũ.

### 4.2 Tạo file endpoint profile cho từng phase

Bạn tự tạo file [test-network/.fabric-endpoints.env](test-network/.fabric-endpoints.env).

Mẫu chung:

~~~bash
ORDERER_ENDPOINT=localhost:7050
ORG1_PEER_ENDPOINT=localhost:7051
ORG2_PEER_ENDPOINT=localhost:9051
ORG3_PEER_ENDPOINT=localhost:11051

ORG1_ANCHOR_HOST=peer0.org1.example.com
ORG1_ANCHOR_PORT=7051
ORG2_ANCHOR_HOST=peer0.org2.example.com
ORG2_ANCHOR_PORT=9051

ORG1_PEER_CCP_HOST=localhost
ORG1_CA_CCP_HOST=localhost
ORG2_PEER_CCP_HOST=localhost
ORG2_CA_CCP_HOST=localhost
~~~

### 4.3 Sửa envVar.sh

File: [test-network/scripts/envVar.sh](test-network/scripts/envVar.sh)

Bổ sung đầu file (sau khi source utils):

~~~bash
ENDPOINT_ENV_FILE=${ENDPOINT_ENV_FILE:-${TEST_NETWORK_HOME}/.fabric-endpoints.env}
if [ -f "${ENDPOINT_ENV_FILE}" ]; then
  . "${ENDPOINT_ENV_FILE}"
fi

export ORDERER_ENDPOINT=${ORDERER_ENDPOINT:-localhost:7050}
export ORG1_PEER_ENDPOINT=${ORG1_PEER_ENDPOINT:-localhost:7051}
export ORG2_PEER_ENDPOINT=${ORG2_PEER_ENDPOINT:-localhost:9051}
export ORG3_PEER_ENDPOINT=${ORG3_PEER_ENDPOINT:-localhost:11051}
~~~

Trong hàm setGlobals, thay hardcode:

~~~bash
export CORE_PEER_ADDRESS=${ORG1_PEER_ENDPOINT}
export CORE_PEER_ADDRESS=${ORG2_PEER_ENDPOINT}
export CORE_PEER_ADDRESS=${ORG3_PEER_ENDPOINT}
~~~

### 4.4 Sửa setAnchorPeer.sh

File: [test-network/scripts/setAnchorPeer.sh](test-network/scripts/setAnchorPeer.sh)

Bổ sung đầu file:

~~~bash
ENDPOINT_ENV_FILE=${ENDPOINT_ENV_FILE:-${TEST_NETWORK_HOME}/.fabric-endpoints.env}
if [ -f "${ENDPOINT_ENV_FILE}" ]; then
  . "${ENDPOINT_ENV_FILE}"
fi

ORDERER_ENDPOINT=${ORDERER_ENDPOINT:-localhost:7050}
ORG1_ANCHOR_HOST=${ORG1_ANCHOR_HOST:-peer0.org1.example.com}
ORG1_ANCHOR_PORT=${ORG1_ANCHOR_PORT:-7051}
ORG2_ANCHOR_HOST=${ORG2_ANCHOR_HOST:-peer0.org2.example.com}
ORG2_ANCHOR_PORT=${ORG2_ANCHOR_PORT:-9051}
~~~

Trong createAnchorPeerUpdate:

~~~bash
HOST="${ORG1_ANCHOR_HOST}"; PORT=${ORG1_ANCHOR_PORT}
HOST="${ORG2_ANCHOR_HOST}"; PORT=${ORG2_ANCHOR_PORT}
~~~

Trong updateAnchorPeer, thay:

~~~bash
peer channel update -o "${ORDERER_ENDPOINT}" --ordererTLSHostnameOverride orderer.example.com ...
~~~

### 4.5 Sửa ccp-template.json và ccp-template.yaml

File: [test-network/organizations/ccp-template.json](test-network/organizations/ccp-template.json)

~~~json
"url": "grpcs://${PEERHOST}:${P0PORT}"
"url": "https://${CAHOST}:${CAPORT}"
~~~

File: [test-network/organizations/ccp-template.yaml](test-network/organizations/ccp-template.yaml)

~~~yaml
url: grpcs://${PEERHOST}:${P0PORT}
url: https://${CAHOST}:${CAPORT}
~~~

### 4.6 Sửa ccp-generate.sh

File: [test-network/organizations/ccp-generate.sh](test-network/organizations/ccp-generate.sh)

Bổ sung đầu file:

~~~bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TEST_NETWORK_HOME=$(cd "${SCRIPT_DIR}/.." && pwd)
ENDPOINT_ENV_FILE=${ENDPOINT_ENV_FILE:-${TEST_NETWORK_HOME}/.fabric-endpoints.env}
if [ -f "${ENDPOINT_ENV_FILE}" ]; then
  . "${ENDPOINT_ENV_FILE}"
fi
~~~

Bổ sung placeholder vào sed json/yaml:

~~~bash
-e "s/\${PEERHOST}/$6/" \
-e "s/\${CAHOST}/$7/" \
~~~

Khi generate org1:

~~~bash
PEERHOST=${ORG1_PEER_CCP_HOST:-localhost}
CAHOST=${ORG1_CA_CCP_HOST:-localhost}
~~~

Khi generate org2:

~~~bash
PEERHOST=${ORG2_PEER_CCP_HOST:-localhost}
CAHOST=${ORG2_CA_CCP_HOST:-localhost}
~~~

### 4.7 Sửa ccutils.sh và setOrgEnv.sh

File: [test-network/scripts/ccutils.sh](test-network/scripts/ccutils.sh)

Thay tất cả:

~~~bash
-o localhost:7050
~~~

Bằng:

~~~bash
-o ${ORDERER_ENDPOINT:-localhost:7050}
~~~

Áp dụng cho approveformyorg, commit, invoke init, invoke test.

File: [test-network/setOrgEnv.sh](test-network/setOrgEnv.sh)

Thay:

~~~bash
CORE_PEER_ADDRESS=localhost:7051
CORE_PEER_ADDRESS=localhost:9051
~~~

Bằng:

~~~bash
CORE_PEER_ADDRESS=${ORG1_PEER_ENDPOINT:-localhost:7051}
CORE_PEER_ADDRESS=${ORG2_PEER_ENDPOINT:-localhost:9051}
~~~

## 5) TLS SAN và regenerate crypto (bắt buộc)

### 5.1 Sửa SAN trong các file cryptogen

File: [test-network/organizations/cryptogen/crypto-config-orderer.yaml](test-network/organizations/cryptogen/crypto-config-orderer.yaml)

~~~yaml
SANS:
  - localhost
  - 127.0.0.1
  - orderer.example.com
  - 10.10.0.1
  - YOUR_PUBLIC_IP
~~~

File: [test-network/organizations/cryptogen/crypto-config-org1.yaml](test-network/organizations/cryptogen/crypto-config-org1.yaml)

~~~yaml
SANS:
  - localhost
  - 127.0.0.1
  - peer0.org1.example.com
  - 10.10.0.2
  - YOUR_PUBLIC_IP
~~~

File: [test-network/organizations/cryptogen/crypto-config-org2.yaml](test-network/organizations/cryptogen/crypto-config-org2.yaml)

~~~yaml
SANS:
  - localhost
  - 127.0.0.1
  - peer0.org2.example.com
  - 10.10.0.3
  - YOUR_PUBLIC_IP
~~~

### 5.2 Regenerate và verify cert

~~~bash
cd blockchain-fabric-v2/test-network
rm -rf organizations/peerOrganizations organizations/ordererOrganizations channel-artifacts

../bin/cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"
../bin/cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"
../bin/cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"

openssl x509 -in organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt -text -noout | grep -A2 "Subject Alternative"
~~~

## 6) Phase-by-phase checklist và lệnh

### Phase 1 - Deploy all lên 1 VPS

Checklist:
1. [ ] Upload source + organizations + bin + config lên VPS-1.
2. [ ] Tạo compose phase1 từ [test-network/compose/compose-test-net.yaml](test-network/compose/compose-test-net.yaml).
3. [ ] Mở cổng tối thiểu: 7050, 7051, 9051, 7054, 8054.
4. [ ] Generate CCP profile.
5. [ ] Up network, create channel, deploy chaincode.

Lệnh:

~~~bash
cd blockchain-fabric-v2/test-network
./organizations/ccp-generate.sh

./network.sh up createChannel -c rentingchannel -ca
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go
~~~

PASS criteria:
1. [ ] createChannel thành công.
2. [ ] deployCC thành công.
3. [ ] query từ Org1 và Org2 thành công.

### Phase 2 - Tách Peer1 sang VPS-2

Checklist:
1. [ ] Stop peer0.org1 và ca_org1 trên VPS-1.
2. [ ] Copy material Org1 sang VPS-2.
3. [ ] Up stack Org1 trên VPS-2.
4. [ ] Cập nhật endpoint profile phase2 và generate CCP.
5. [ ] Test invoke endorse 2 peer.

Lệnh mẫu:

~~~bash
# VPS-1
docker compose -f compose/compose-vps-phase1.yaml stop peer0.org1.example.com ca_org1

# VPS-2
docker compose -f docker-compose-org1-phase2.yaml up -d
~~~

PASS criteria:
1. [ ] query từ Org1 trên VPS-2 thành công.
2. [ ] invoke có cả 2 peer thành công.

### Phase 3 - Đưa Peer2 về Local

Checklist:
1. [ ] Stop peer0.org2 và ca_org2 trên VPS-1.
2. [ ] Up stack Org2 trên local.
3. [ ] Cập nhật endpoint profile phase3 và generate CCP.
4. [ ] Đảm bảo VPS-1/VPS-2 resolve được peer0.org2.example.com.

Lệnh mẫu:

~~~bash
# VPS-1
docker compose -f compose/compose-vps1-phase2.yaml stop peer0.org2.example.com ca_org2

# Local
docker compose -f compose/compose-local-org2-phase3.yaml up -d
~~~

PASS criteria:
1. [ ] Peer2 local nhận block mới.
2. [ ] invoke từ remote đến peer2 local thành công.

### Phase 4 - Admin kết nối Peer2 local

Checklist:
1. [ ] Sửa default Fabric client cho org2 + rentingchannel + renting.
2. [ ] Cập nhật env của admin app.
3. [ ] Health check API + test submit/query giao dịch.

File sửa: [../quan-ly-tim-kiem-phong-tro-admin/src/lib/fabric/fabricClient.ts](../quan-ly-tim-kiem-phong-tro-admin/src/lib/fabric/fabricClient.ts)

Snippet tối thiểu:

~~~ts
channelName: process.env.FABRIC_CHANNEL_NAME || 'rentingchannel'
chaincodeName: process.env.FABRIC_CHAINCODE_NAME || 'renting'
mspId: process.env.FABRIC_MSP_ID || 'Org2MSP'
peerEndpoint: process.env.FABRIC_PEER_ENDPOINT || 'localhost:9051'
~~~

Lệnh:

~~~bash
cd ../quan-ly-tim-kiem-phong-tro-admin
npm install
npm run dev
~~~

PASS criteria:
1. [ ] Admin API submit/query blockchain thành công.

### Phase 5 - Full network integration

Checklist:
1. [ ] Full mesh kết nối VPS-1, VPS-2, Local.
2. [ ] Các node resolve hostname nhất quán.
3. [ ] Endorse 2 peer + orderer commit.
4. [ ] Block height đồng nhất.

Lệnh test invoke:

~~~bash
peer chaincode invoke -o ${ORDERER_ENDPOINT} \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile "$ORDERER_CA" \
  -C rentingchannel -n renting \
  --peerAddresses ${ORG1_PEER_ENDPOINT} --tlsRootCertFiles "$PEER0_ORG1_CA" \
  --peerAddresses ${ORG2_PEER_ENDPOINT} --tlsRootCertFiles "$PEER0_ORG2_CA" \
  -c '{"function":"CreateUser","Args":["integration-user","Integration User","1000","GUEST"]}'
~~~

PASS criteria:
1. [ ] Endorse 2 peer thành công.
2. [ ] Commit block thành công.
3. [ ] Block height đồng nhất trên tất cả node.

## 7) Mạng, firewall, và extra_hosts

Gợi ý firewall:
1. VPS-1: mở 22, 7050; chặn 7053/9443 nếu không dùng.
2. VPS-2: mở 22, 7051, 7054.
3. Local: chỉ mở 9051/8054 nếu bắt buộc route public.

Lệnh mẫu:

~~~bash
sudo ufw allow 22
sudo ufw allow 7050
sudo ufw allow 7051
sudo ufw allow 7054
~~~

Lưu ý extra_hosts:
1. orderer.example.com phải resolve về VPS-1.
2. peer0.org1.example.com phải resolve về VPS-2.
3. peer0.org2.example.com phải resolve về local (phase 3 trở đi).

## 8) Phân phối TLS cert và quy tắc bảo mật

Nguyên tắc:
1. Chỉ copy root TLS cert cần thiết cho máy tiêu thụ.
2. Không copy private key của orderer/peer sang máy khác.
3. Admin app chỉ giữ user cert/key tối thiểu + TLS CA cần kết nối.

Checklist TLS:
1. [ ] VPS-2 có orderer TLS CA.
2. [ ] Local có orderer TLS CA.
3. [ ] VPS-1/VPS-2 có Org2 TLS CA khi Org2 chạy local.
4. [ ] Admin có TLS CA đúng với endpoint đang dùng.

## 9) Rollback nhanh

~~~bash
cd blockchain-fabric-v2/test-network
./network.sh down

# khôi phục backup thủ công, sau đó bring-up lại local baseline
./network.sh up createChannel -c rentingchannel -ca
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go
~~~

## 10) Ghi chú vận hành

1. Tài liệu này ưu tiên thao tác thủ công và kiểm soát thay đổi.
2. Mỗi phase phải đạt PASS criteria trước khi sang phase tiếp theo.
3. Nếu route qua Public IP, bạn bắt buộc cập nhật SAN cho đúng endpoint thực tế.
4. Nếu sử dụng WireGuard, ưu tiên endpoint private để ổn định TLS và gossip.
