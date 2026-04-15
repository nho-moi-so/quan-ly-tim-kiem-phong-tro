# 🌐 Hướng Dẫn Triển Khai - PRODUCTION (2 VPS)

> 2 VPS riêng biệt, mỗi component chạy file `docker-compose` riêng.
>
> | VPS | IP ví dụ | Chạy |
> |-----|---------|------|
> | VPS 1 | `123.45.67.81` | Orderer + peer0.org1 + Admin Server |
> | VPS 2 | `123.45.67.83` | peer0.org2 + Explorer |

---

## 📋 Mục Lục

1. [Thứ Tự Triển Khai](#1-thứ-tự-triển-khai)
2. [Chuẩn Bị Cả 2 VPS](#2-chuẩn-bị-cả-2-vps)
3. [VPS 1 — Orderer](#3-vps-1--orderer)
4. [VPS 1 — Peer Org1](#4-vps-1--peer-org1)
5. [VPS 2 — Peer Org2](#5-vps-2--peer-org2)
6. [Commit Chaincode (VPS 2)](#6-commit-chaincode-vps-2)
7. [VPS 1 — Admin Server](#7-vps-1--admin-server)
8. [VPS 2 — Explorer](#8-vps-2--explorer)
9. [Mobile & IoT (Local)](#9-mobile--iot-local)
10. [Quản Lý Hàng Ngày](#10-quản-lý-hàng-ngày)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Thứ Tự Triển Khai

```
VPS 1:
  [A] Sinh chứng chỉ (cryptogen) + Genesis block (configtxgen)
  [B] Phân phối chứng chỉ Org2 + block sang VPS 2
  [C] Khởi động Orderer → osnadmin join channel
  [D] Khởi động peer0.org1 → join channel → install → approve
        ↓
VPS 2:
  [E] Khởi động peer0.org2 → join channel → install → approve
  [F] Commit chaincode ← "chốt đơn" trên cả 2 org
        ↓
VPS 1:
  [G] Sync Firebase → Fabric
  [H] Khởi động Admin Server
        ↓
VPS 2:
  [I] Khởi động Explorer
        ↓
Local:
  [J] Chạy Mobile app + IoT
```

---

## 2. Chuẩn Bị Cả 2 VPS

### 2.1 Cài đặt dependencies (cả 2 VPS)

```bash
# Git, Docker, Go, Node.js, jq
sudo apt-get update
sudo apt-get install -y git jq
# Cài Docker: https://docs.docker.com/engine/install/ubuntu/
# Cài Go 1.21: https://go.dev/dl/
# Cài Node.js 18: https://nodejs.org/
```

### 2.2 Cấu hình `/etc/hosts` (cả 2 VPS)

```bash
sudo nano /etc/hosts
```

Thêm vào (thay IP thực tế):
```
123.45.67.81  orderer.example.com
123.45.67.81  peer0.org1.example.com
123.45.67.83  peer0.org2.example.com
```

### 2.3 Mở firewall

```bash
# VPS 1 (Orderer + Org1 + Server)
sudo ufw allow 22 && sudo ufw allow 7050 && sudo ufw allow 7053
sudo ufw allow 7051 && sudo ufw allow 9443 && sudo ufw allow 9444
sudo ufw allow 3000 && sudo ufw allow 3001 && sudo ufw enable

# VPS 2 (Org2 + Explorer)
sudo ufw allow 22 && sudo ufw allow 9051
sudo ufw allow 9445 && sudo ufw allow 8080 && sudo ufw enable
```

### 2.4 Clone source code (cả 2 VPS)

```bash
git clone https://github.com/nho-moi-so/quan-ly-tim-kiem-phong-tro.git
cd quan-ly-tim-kiem-phong-tro
git checkout feature/owner
```

---

## 3. VPS 1 — Orderer

### 3.1 Sửa `configtx.yaml` (chỉ VPS)

Mở `blockchain-fabric-v2/test-network/configtx/configtx.yaml`, đảm bảo:

```yaml
OrdererEndpoints:
  - orderer.example.com:7050   # ← Hostname thật, KHÔNG dùng localhost
```

### 3.2 Sinh chứng chỉ

```bash
cd blockchain-fabric-v2/test-network
export PATH=${PWD}/../bin:$PATH

cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"
cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
```

### 3.3 Sinh genesis block

```bash
export FABRIC_CFG_PATH=${PWD}/configtx
mkdir -p channel-artifacts

configtxgen -profile ChannelUsingRaft \
  -outputBlock ./channel-artifacts/rentingchannel.block \
  -channelID rentingchannel
```

### 3.4 Phân phối chứng chỉ Org2 sang VPS 2

```bash
# Trên VPS 1
tar -czf org2-materials.tar.gz \
  organizations/peerOrganizations/org2.example.com/ \
  channel-artifacts/rentingchannel.block

scp org2-materials.tar.gz USER@123.45.67.83:~/
```

```bash
# Trên VPS 2 — giải nén vào đúng thư mục
cd /path/to/blockchain-fabric-v2/test-network
tar -xzf ~/org2-materials.tar.gz
```

### 3.5 Docker Compose cho Orderer

Tạo file `blockchain-fabric-v2/test-network/docker-compose-orderer.yaml`:

```yaml
version: '3.7'

volumes:
  orderer.example.com:

networks:
  test:
    name: fabric_test

services:
  orderer.example.com:
    container_name: orderer.example.com
    image: hyperledger/fabric-orderer:latest
    environment:
      - FABRIC_LOGGING_SPEC=INFO
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_LISTENPORT=7050
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
      - ORDERER_GENERAL_TLS_ENABLED=true
      - ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_CLUSTER_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_GENERAL_BOOTSTRAPMETHOD=none
      - ORDERER_CHANNELPARTICIPATION_ENABLED=true
      - ORDERER_ADMIN_TLS_ENABLED=true
      - ORDERER_ADMIN_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_ADMIN_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_ADMIN_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_ADMIN_TLS_CLIENTROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_ADMIN_LISTENADDRESS=0.0.0.0:7053
      - ORDERER_OPERATIONS_LISTENADDRESS=0.0.0.0:9443
    working_dir: /root
    command: orderer
    volumes:
      - ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp
      - ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/:/var/hyperledger/orderer/tls
      - orderer.example.com:/var/hyperledger/production/orderer
    ports:
      - 7050:7050
      - 7053:7053
      - 9443:9443
    extra_hosts:
      - "peer0.org1.example.com:123.45.67.81"   # VPS 1
      - "peer0.org2.example.com:123.45.67.83"   # VPS 2
    networks:
      - test
```

### 3.6 Khởi động Orderer

```bash
cd blockchain-fabric-v2/test-network
docker-compose -f docker-compose-orderer.yaml up -d
docker logs orderer.example.com --tail 20
```

### 3.7 Orderer join channel

```bash
export ORDERER_ADMIN_TLS_CA_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
export ORDERER_ADMIN_CLIENT_CERT_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_CLIENT_KEY_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

osnadmin channel join \
  --channelID rentingchannel \
  --config-block ./channel-artifacts/rentingchannel.block \
  -o localhost:7053 \
  --ca-file $ORDERER_ADMIN_TLS_CA_FILE \
  --client-cert $ORDERER_ADMIN_CLIENT_CERT_FILE \
  --client-key $ORDERER_ADMIN_CLIENT_KEY_FILE

# Kiểm tra — thấy rentingchannel là OK
osnadmin channel list \
  -o localhost:7053 \
  --ca-file $ORDERER_ADMIN_TLS_CA_FILE \
  --client-cert $ORDERER_ADMIN_CLIENT_CERT_FILE \
  --client-key $ORDERER_ADMIN_CLIENT_KEY_FILE
```

---

## 4. VPS 1 — Peer Org1

### 4.1 Docker Compose cho Org1

Tạo file `blockchain-fabric-v2/test-network/docker-compose-org1.yaml`:

```yaml
version: '3.7'

volumes:
  peer0.org1.example.com:

networks:
  test:
    name: fabric_test

services:
  peer0.org1.example.com:
    container_name: peer0.org1.example.com
    image: hyperledger/fabric-peer:latest
    environment:
      - FABRIC_CFG_PATH=/etc/hyperledger/peercfg
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=false
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      - CORE_PEER_ID=peer0.org1.example.com
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
      - CORE_PEER_CHAINCODEADDRESS=0.0.0.0:7052
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
      - CORE_OPERATIONS_LISTENADDRESS=0.0.0.0:9444
    volumes:
      - ../organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com:/etc/hyperledger/fabric
      - peer0.org1.example.com:/var/hyperledger/production
    working_dir: /root
    command: peer node start
    ports:
      - 7051:7051
      - 9444:9444
    extra_hosts:
      - "orderer.example.com:123.45.67.81"      # Cùng VPS 1
      - "peer0.org2.example.com:123.45.67.83"   # VPS 2
    networks:
      - test
```

### 4.2 Khởi động Peer Org1

```bash
docker-compose -f docker-compose-org1.yaml up -d
docker logs peer0.org1.example.com --tail 20
```

### 4.3 Thiết lập môi trường + Join + Install + Approve (Org1)

```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Join channel
peer channel join -b ./channel-artifacts/rentingchannel.block

# Đóng gói
peer lifecycle chaincode package renting.tar.gz \
  --path ../chaincode-go --lang golang --label renting_1.0

# Install
peer lifecycle chaincode install renting.tar.gz
peer lifecycle chaincode queryinstalled | grep -oP 'renting_1.0:\w+'

export PACKAGE_ID=renting_1.0:fdf097f77d1ac9b443b9f0b7cf51a81c49b979f21da6500fb9e32a9cf09ff666

# Approve (VPS: dùng hostname orderer.example.com:7050)
peer lifecycle chaincode approveformyorg \
  -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

# Kiểm tra — kỳ vọng Org1MSP: true
peer lifecycle chaincode checkcommitreadiness \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA --output json
```

---

## 5. VPS 2 — Peer Org2

### 5.1 Docker Compose cho Org2

Tạo file `blockchain-fabric-v2/test-network/docker-compose-org2.yaml`:

```yaml
version: '3.7'

volumes:
  peer0.org2.example.com:

networks:
  test:
    name: fabric_test

services:
  peer0.org2.example.com:
    container_name: peer0.org2.example.com
    image: hyperledger/fabric-peer:latest
    environment:
      - FABRIC_CFG_PATH=/etc/hyperledger/peercfg
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=false
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      - CORE_PEER_ID=peer0.org2.example.com
      - CORE_PEER_ADDRESS=peer0.org2.example.com:9051
      - CORE_PEER_LISTENADDRESS=0.0.0.0:9051
      - CORE_PEER_CHAINCODEADDRESS=0.0.0.0:9052
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:9052
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org2.example.com:9051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:9051
      - CORE_PEER_LOCALMSPID=Org2MSP
      - CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
      - CORE_OPERATIONS_LISTENADDRESS=0.0.0.0:9445
    volumes:
      - ../organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com:/etc/hyperledger/fabric
      - peer0.org2.example.com:/var/hyperledger/production
    working_dir: /root
    command: peer node start
    ports:
      - 9051:9051
      - 9445:9445
    extra_hosts:
      - "orderer.example.com:123.45.67.81"       # VPS 1
      - "peer0.org1.example.com:123.45.67.81"    # VPS 1
    networks:
      - test
```

### 5.2 Khởi động + Join + Install + Approve (Org2)

```bash
docker-compose -f docker-compose-org2.yaml up -d

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

# Join channel
peer channel join -b ./channel-artifacts/rentingchannel.block

# Install
peer lifecycle chaincode install renting.tar.gz
peer lifecycle chaincode queryinstalled | grep -oP 'renting_1.0:\w+'

export PACKAGE_ID=renting_1.0:fdf097f77d1ac9b443b9f0b7cf51a81c49b979f21da6500fb9e32a9cf09ff666

# Approve (VPS: hostname orderer.example.com:7050)
peer lifecycle chaincode approveformyorg \
  -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

# Kiểm tra — kỳ vọng CẢ 2 org đều true
peer lifecycle chaincode checkcommitreadiness \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA --output json
```

---

## 6. Commit Chaincode (VPS 2)

> Lệnh "chốt đơn" — chạy từ VPS 2, liên kết đến peer Org1 ở VPS 1.

```bash
peer lifecycle chaincode commit \
  -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA \
  --peerAddresses peer0.org1.example.com:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# Xác nhận
peer lifecycle chaincode querycommitted \
  --channelID rentingchannel --name renting --tls --cafile $ORDERER_CA
```

> ✅ Thấy chaincode `renting` với sequence 1, cả 2 org approved là thành công!

---

## 7. VPS 1 — Admin Server

### 7.1 Sinh connection profile

```bash
# Chạy trên VPS 1
cd blockchain-fabric-v2/test-network
./organizations/ccp-generate.sh
# Tạo ra: connection-org1.json, connection-org1.yaml

# Sửa các 'localhost' trong connection-org1.json thành IP Public của VPS 1
sed -i 's/localhost/123.45.67.81/g' organizations/ccp/connection-org1.json
```

### 7.2 Cài đặt và cấu hình

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm install
```

Cấu hình `.env`:
```bash
FABRIC_CHANNEL_NAME=rentingchannel
FABRIC_CHAINCODE_NAME=renting
FABRIC_MSP_ID=Org1MSP
FABRIC_CRYPTO_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com
FABRIC_PEER_ENDPOINT=localhost:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com
PORT=3000
BLOCKCHAIN_PORT=3001
```

### 7.3 Sync Firebase → Fabric

```bash
npm run fabric:setup-admin  # Lần đầu
npm run fabric:sync-users   # Đồng bộ dữ liệu
```

### 7.4 Khởi động Server

```bash
# Terminal 1:
node server_socket.js

# Terminal 2:
node server_blockchain.js
```

---

## 8. VPS 2 — Explorer

### 8.1 Lấy tên private key Org2

```bash
ls ../blockchain-fabric-v2/test-network/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/
# Ví dụ: abcxyz123_sk
```

### 8.2 Cập nhật `connection-profile/network-config.json`

```json
{
    "name": "fabric-network",
    "version": "1.0.0",
    "client": {
        "tlsEnable": true,
        "adminCredential": { "id": "exploreradmin", "password": "exploreradminpw" },
        "enableAuthentication": false,
        "organization": "Org2",
        "connection": { "timeout": { "peer": { "endorser": "300" }, "orderer": "300" } }
    },
    "channels": {
        "rentingchannel": { "peers": { "peer0.org2.example.com": {} } }
    },
    "organizations": {
        "Org2": {
            "mspid": "Org2MSP",
            "peers": ["peer0.org2.example.com"],
            "adminPrivateKey": {
                "path": "/tmp/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/abcxyz123_sk"
            },
            "signedCert": {
                "path": "/tmp/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem"
            }
        }
    },
    "peers": {
        "peer0.org2.example.com": {
            "url": "grpcs://peer0.org2.example.com:9051",
            "tlsCACerts": {
                "path": "/tmp/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
            },
            "grpcOptions": { "ssl-target-name-override": "peer0.org2.example.com" }
        }
    }
}
```

> ⚠️ Thay `abcxyz123_sk` bằng tên file thực tế vừa `ls` ở trên.

### 8.3 Khởi động Explorer

```bash
cd blockchain-fabric-explorer
./explorer.sh clean   # Reset data cũ
./explorer.sh start

# Truy cập: http://123.45.67.83:8080
# Username: exploreradmin / Password: exploreradminpw
```

---

## 9. Mobile & IoT (Local)

### Mobile (Flutter)

```bash
# Cập nhật .env với URL của VPS 1
# quan_ly_tim_kiem_phong_tro_fe/.env
HOST_SERVER=http://123.45.67.81:3000   # IP VPS 1

cd quan_ly_tim_kiem_phong_tro_fe
flutter pub get
flutter run
```

### IoT (ESP32)

Sửa `iot/main/main.ino`:
```cpp
const char* ssid = "TEN_WIFI";           // Mật khẩu chỉ dùng số và a,b,c,d
const char* password = "MAT_KHAU_WIFI";
const char* server_url = "http://123.45.67.81:3001";  // IP VPS 1
const String roomCode = "P001";
const String deviceId = "ESP32_001";
```

---

## 10. Quản Lý Hàng Ngày

### Khởi động lại sau khi restart VPS

```bash
# VPS 1
docker start $(docker ps -aq)   # Khởi động Orderer + Peer Org1
cd quan-ly-tim-kiem-phong-tro-admin
node server_socket.js &
node server_blockchain.js &

# VPS 2
docker start $(docker ps -aq)   # Khởi động Peer Org2
cd blockchain-fabric-explorer && ./explorer.sh start
```

### Nâng cấp chaincode

```bash
# Trên VPS 1 (Org1): install + approve với version mới
peer lifecycle chaincode install renting_v2.tar.gz
export PACKAGE_ID_V2=renting_2.0:HASH_MỚI
peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 2.0 \
  --package-id $PACKAGE_ID_V2 --sequence 2 --tls --cafile $ORDERER_CA

# Trên VPS 2 (Org2): install + approve tương tự

# Commit từ VPS 2
peer lifecycle chaincode commit -o orderer.example.com:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 2.0 --sequence 2 \
  --tls --cafile $ORDERER_CA \
  --peerAddresses peer0.org1.example.com:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

---

## 11. Troubleshooting

| Lỗi | Cách xử lý |
|-----|-----------|
| Peer không kết nối được Orderer | Kiểm tra `/etc/hosts` và firewall. `docker exec peer0.org1.example.com ping orderer.example.com` |
| `osnadmin` lỗi TLS | Kiểm tra biến `$ORDERER_ADMIN_TLS_CA_FILE` đúng path |
| `peer channel join` fail | Đảm bảo `rentingchannel.block` đã được copy đúng vào VPS |
| Commit fail | Đảm bảo cả 2 org đã approve. Kiểm tra `checkcommitreadiness --output json` |
| Explorer không thấy peer | Copy chứng chỉ Org1 sang VPS 2. Kiểm tra tên file `_sk` đúng |
| Admin server không kết nối Fabric | Kiểm tra `FABRIC_CRYPTO_PATH` là đường dẫn tuyệt đối trên Linux |
