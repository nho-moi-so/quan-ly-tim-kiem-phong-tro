# 🏠 Hướng Dẫn Khởi Động Dự Án - Quản Lý Tìm Kiếm Phòng Trọ

> **Hệ thống**: Room Rental Management với Hyperledger Fabric Blockchain  
> **Môi trường yêu cầu**: WSL2 (Ubuntu) hoặc Linux, Docker, Node.js, Flutter

---

## 📋 Mục Lục

1. [Tổng Quan Hệ Thống](#1-tổng-quan-hệ-thống)
2. [Yêu Cầu Môi Trường](#2-yêu-cầu-môi-trường)
3. [Thứ Tự Khởi Động](#3-thứ-tự-khởi-động)
4. [Bước 1: Khởi Động Hyperledger Fabric](#4-bước-1-khởi-động-hyperledger-fabric)
5. [Bước 2: Deploy Chaincode](#5-bước-2-deploy-chaincode)
6. [Bước 3: Sync Dữ Liệu Firebase → Fabric](#6-bước-3-sync-dữ-liệu-firebase--fabric)
7. [Bước 4: Khởi Động Blockchain Explorer](#7-bước-4-khởi-động-blockchain-explorer)
8. [Bước 5: Khởi Động Admin Server](#8-bước-5-khởi-động-admin-server)
9. [Bước 6: Expose Server ra Internet (ngrok/pinggy)](#9-bước-6-expose-server-ra-internet-ngrokpinggy)
10. [Bước 7: Khởi Động App Mobile (Flutter)](#10-bước-7-khởi-động-app-mobile-flutter)
11. [Bước 8: Khởi Động IoT (ESP32)](#11-bước-8-khởi-động-iot-esp32)
12. [Quản Lý Hàng Ngày](#12-quản-lý-hàng-ngày)
13. [Troubleshooting](#13-troubleshooting)
14. [Sơ Đồ Port](#14-sơ-đồ-port)

---

## 1. Tổng Quan Hệ Thống

```
┌─────────────────── KIẾN TRÚC HỆ THỐNG ───────────────────┐
│                                                            │
│  [Flutter Mobile App]  ←──────────────────────────────┐   │
│         ↕ REST API / Socket.io                        │   │
│  [Admin Server - Next.js :3000]                       │   │
│    ├─ server_socket.js  (Next.js + Socket.io)         │   │
│    └─ server_blockchain.js (Express :3001)            │   │
│              ↕ Fabric Gateway SDK                     │   │
│  [Hyperledger Fabric Network]                         │   │
│    ├─ Orderer  :7050                                  │   │
│    ├─ peer0.org1 :7051                                │   │
│    ├─ peer0.org2 :9051                                │   │
│    └─ Channel: rentingchannel                         │   │
│              ↕ Sync                                   │   │
│  [Firebase Firestore] ←── [IoT ESP32 Devices]─────────┘   │
│                                                            │
│  [Blockchain Explorer :8080] ←── Monitor network          │
└────────────────────────────────────────────────────────────┘
```

### Các thành phần:
| Component | Thư mục | Port | Mô tả |
|-----------|---------|------|-------|
| Hyperledger Fabric | `blockchain-fabric-v2/` | 7050, 7051, 9051 | Blockchain network |
| Admin Server (Socket) | `quan-ly-tim-kiem-phong-tro-admin/` | 3000 | Next.js + Socket.io |
| Admin Server (Blockchain) | `quan-ly-tim-kiem-phong-tro-admin/` | 3001 | Express + Fabric Gateway |
| Blockchain Explorer | `blockchain-fabric-explorer/` | 8080 | Dashboard giám sát |
| Mobile App | `quan_ly_tim_kiem_phong_tro_fe/` | — | Flutter Android/iOS |
| IoT | `iot/main/` | — | Arduino/ESP32 firmware |

---

## 2. Yêu Cầu Môi Trường

### Cài đặt cần có:
```bash
# Kiểm tra Docker
docker --version          # >= 20.x (test: 28.5.1)
docker-compose --version  # >= 1.29.x hoặc docker compose v2

# Kiểm tra Node.js
node --version    # >= 18.x (test: v18.20.8)
npm --version     # >= 9.x  (test: 10.8.2)

# Kiểm tra Go (cho chaincode)
go version        # >= go1.21.x linux/amd64

# Kiểm tra jq (decode block)
jq --version      # >= 1.6

# Kiểm tra Flutter (cho mobile)
flutter --version # >= 3.x
flutter doctor    # Đảm bảo không có lỗi

# Kiểm tra ts-node (cho admin server)
npx ts-node --version
```

> **⚠️ Lưu ý**: Toàn bộ lệnh Fabric phải chạy trong **WSL2 (Ubuntu)** hoặc **Linux**, KHÔNG chạy trên Windows PowerShell/CMD.

---

## 3. Thứ Tự Khởi Động

```
[1] Fabric Network (Docker containers)
      ↓
[2] Deploy Chaincode (nếu lần đầu hoặc sau khi down)
      ↓
[3] Sync dữ liệu Firebase → Fabric (lần đầu)
      ↓
[4] Blockchain Explorer (tuỳ chọn - giám sát)
      ↓
[5] Admin Server (server_socket.js + server_blockchain.js)
      ↓
[6] Expose server ra Internet (ngrok + pinggy)
      ↓
[7] Cập nhật URL vào .env của Mobile App
      ↓
[8] Chạy App Mobile (Flutter)
      ↓
[9] Nạp firmware IoT (ESP32) - đã được nạp sẵn
```

---

## 4. Bước 1: Khởi Động Hyperledger Fabric

> **Thư mục làm việc**: `blockchain-fabric-v2/test-network/`  
> **Môi trường**: WSL2 hoặc Linux

---

### 🧹 Dọn dẹp trước khi chạy (reset hoàn toàn)

```bash
# Đảm bảo đang đứng ở thư mục test-network
cd blockchain-fabric-v2/test-network

# Hạ toàn bộ container và xóa volume
docker-compose -f compose/compose-test-net.yaml -f compose/compose-ca.yaml down --volumes --remove-orphans

# Quét sạch network rác của Fabric
docker network prune -f

# (Tùy chọn) Xóa triệt để hơn
docker rm -f $(docker ps -aq) 2>/dev/null
docker volume prune -f

# Xóa thư mục chứng chỉ cũ
rm -rf organizations/peerOrganizations
rm -rf organizations/ordererOrganizations

# Xóa dữ liệu Fabric CA
rm -rf organizations/fabric-ca/org1/msp
rm -rf organizations/fabric-ca/org1/tls-cert.pem
rm -rf organizations/fabric-ca/org1/fabric-ca-server.db
rm -rf organizations/fabric-ca/org2/msp
rm -rf organizations/fabric-ca/ordererOrg/msp

# Xóa channel artifacts và file tar cũ
rm -rf channel-artifacts/*.block channel-artifacts/*.tx
rm -f *.tar.gz

# Reset biến môi trường
unset FABRIC_CFG_PATH CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH
unset CORE_PEER_LOCALMSPID PACKAGE_ID
```

---

### 4.1 Sinh chứng chỉ bằng cryptogen

```bash
# Đảm bảo đang đứng ở: blockchain-fabric-v2/test-network/
export PATH=${PWD}/../bin:$PATH

# 1. Sinh chứng chỉ cho Org1
cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"

# 2. Sinh chứng chỉ cho Org2
cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"

# 3. Sinh chứng chỉ cho Orderer
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
```

> ✅ Tạo ra `organizations/peerOrganizations/` và `organizations/ordererOrganizations/`

---

### 4.2 Sinh genesis block

```bash
export FABRIC_CFG_PATH=${PWD}/configtx

mkdir -p channel-artifacts

configtxgen -profile ChannelUsingRaft \
  -outputBlock ./channel-artifacts/rentingchannel.block \
  -channelID rentingchannel
```

> ✅ Tạo ra file `channel-artifacts/rentingchannel.block`

> **⚠️ Lưu ý VPS**: Mở `configtx/configtx.yaml`, đảm bảo `OrdererEndpoints` dùng hostname thật:
> ```yaml
> OrdererEndpoints:
>   - orderer.example.com:7050   # Phải là hostname, không phải localhost
> ```

---

### 4.3 Khởi động Fabric Network

#### 🖥️ Chạy LOCAL (tất cả trong 1 máy)

Chạy tất cả services (orderer + 2 peers + CAs) cùng lúc bằng docker compose:

```bash
# Đứng ở: blockchain-fabric-v2/test-network/
docker compose -f compose/compose-test-net.yaml -f compose/compose-ca.yaml up -d

# Kiểm tra tất cả containers đang chạy
docker ps
```

> ✅ Kết quả: Thấy `orderer.example.com`, `peer0.org1.example.com`, `peer0.org2.example.com`, `ca_org1`, `ca_org2` đang `Up`

---

#### 🌐 Chạy trên VPS (tách ra nhiều máy)

**Chuẩn bị VPS** — Thêm vào `/etc/hosts` của mỗi VPS:
```bash
sudo nano /etc/hosts
# Thêm vào:
123.45.67.81  orderer.example.com
123.45.67.81  peer0.org1.example.com
123.45.67.83  peer0.org2.example.com
```

**Mở firewall VPS 1** (Orderer + Org1):
```bash
sudo ufw allow 22 7050 7053 7051 9443 9444 3000 3001 && sudo ufw enable
```

**Mở firewall VPS 2** (Org2 + Explorer):
```bash
sudo ufw allow 22 9051 9445 8080 && sudo ufw enable
```

**Phân phối chứng chỉ Org2 từ VPS 1 sang VPS 2:**
```bash
# Trên VPS 1, đóng gói
cd blockchain-fabric-v2/test-network
tar -czf org2-materials.tar.gz \
  organizations/peerOrganizations/org2.example.com/ \
  channel-artifacts/rentingchannel.block

# Copy sang VPS 2
scp org2-materials.tar.gz USER@123.45.67.83:~/

# Trên VPS 2, giải nén
cd blockchain-fabric-v2/test-network
tar -xzf ~/org2-materials.tar.gz
```

**VPS 1 — Tạo `docker-compose-orderer.yaml`:**

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

**VPS 1 — Khởi động Orderer:**
```bash
docker-compose -f docker-compose-orderer.yaml up -d
docker logs orderer.example.com --tail 20
```

**VPS 1 — Tạo `docker-compose-org1.yaml`:**

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

**VPS 2 — Tạo `docker-compose-org2.yaml`:**

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

**VPS 1 — Khởi động Org1 peer:**
```bash
docker-compose -f docker-compose-org1.yaml up -d
```

**VPS 2 — Khởi động Org2 peer:**
```bash
docker-compose -f docker-compose-org2.yaml up -d
```

---

### 4.4 Orderer join vào channel (chỉ cần khi tạo mới)

> Bước này cần thiết khi tạo network lần đầu. **Chạy trên máy có Orderer** (VPS 1 hoặc local).

```bash
# Đảm bảo đang đứng ở: blockchain-fabric-v2/test-network/

export ORDERER_ADMIN_TLS_CA_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
export ORDERER_ADMIN_CLIENT_CERT_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_CLIENT_KEY_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

# Orderer join channel
osnadmin channel join \
  --channelID rentingchannel \
  --config-block ./channel-artifacts/rentingchannel.block \
  -o localhost:7053 \
  --ca-file $ORDERER_ADMIN_TLS_CA_FILE \
  --client-cert $ORDERER_ADMIN_CLIENT_CERT_FILE \
  --client-key $ORDERER_ADMIN_CLIENT_KEY_FILE
```

> ✅ Kết quả mong đợi: Trả về JSON xác nhận join thành công

```bash
# Kiểm tra danh sách channel — thấy rentingchannel là OK
osnadmin channel list \
  -o localhost:7053 \
  --ca-file $ORDERER_ADMIN_TLS_CA_FILE \
  --client-cert $ORDERER_ADMIN_CLIENT_CERT_FILE \
  --client-key $ORDERER_ADMIN_CLIENT_KEY_FILE
```

---

### 4.5 Khởi động lại sau khi tắt máy

Nếu trước khi tắt đã `docker stop` (không down):

```bash
# Khởi động lại tất cả containers đã có sẵn (giữ nguyên ledger data)
docker start $(docker ps -aq)

# Kiểm tra trạng thái
docker ps
```

> **⚠️ Trước khi tắt máy**: Chạy `docker stop $(docker ps -aq)` thay vì down — tránh mất dữ liệu ledger.

---

## 5. Bước 2: Deploy Chaincode

> **Thư mục**: `blockchain-fabric-v2/test-network/`

### 5.1 Thiết lập biến môi trường chung

```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

---

### 5.2 Peer Org1 join channel + Install + Approve

**Thiết lập identity Org1 Admin:**
```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

**Join channel:**
```bash
peer channel join -b ./channel-artifacts/rentingchannel.block
```

**Đóng gói chaincode:**
```bash
peer lifecycle chaincode package renting.tar.gz \
  --path ../chaincode-go \
  --lang golang \
  --label renting_1.0
```

**Install chaincode lên Peer Org1:**
```bash
peer lifecycle chaincode install renting.tar.gz
```

```bash
# Lấy Package ID
peer lifecycle chaincode queryinstalled | grep -oP 'renting_1.0:\w+'
# Ví dụ: renting_1.0:fdf097f77d1ac9b443b9f0b7cf51a81c49b979f21da6500fb9e32a9cf09ff666
```

**Approve cho Org1:**
```bash
export PACKAGE_ID=renting_1.0:fdf097f77d1ac9b443b9f0b7cf51a81c49b979f21da6500fb9e32a9cf09ff666
```

#### 🖥️ Local:
```bash
peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 \
  --tls --cafile $ORDERER_CA
```

#### 🌐 VPS 1:
```bash
peer lifecycle chaincode approveformyorg \
  -o orderer.example.com:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 \
  --tls --cafile $ORDERER_CA
```

**Kiểm tra approve — kỳ vọng Org1MSP: true:**
```bash
peer lifecycle chaincode checkcommitreadiness \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA --output json
```

---

### 5.3 Peer Org2 join channel + Install + Approve

**Thiết lập identity Org2 Admin:**
```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

**Join channel:**
```bash
peer channel join -b ./channel-artifacts/rentingchannel.block
```

**Install chaincode lên Peer Org2:**
```bash
peer lifecycle chaincode install renting.tar.gz

# Lấy Package ID (phải trùng với Org1)
peer lifecycle chaincode queryinstalled | grep -oP 'renting_1.0:\w+'
```

**Approve cho Org2:**

#### 🖥️ Local:
```bash
peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 \
  --tls --cafile $ORDERER_CA
```

#### 🌐 VPS 2:
```bash
peer lifecycle chaincode approveformyorg \
  -o orderer.example.com:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 \
  --tls --cafile $ORDERER_CA
```

**Kiểm tra approve — kỳ vọng CẢ 2 org đều true:**
```bash
peer lifecycle chaincode checkcommitreadiness \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA --output json
```

---

### 5.4 Commit chaincode ("chốt đơn")

> Commit có thể chạy bằng identity của **bất kỳ org nào**, nhưng phải liên kết tới cả 2 peer.  
> Thường chạy sau khi cả 2 org đã approve.

#### 🖥️ Local (cả Orderer + 2 peers đều ở localhost):
```bash
peer lifecycle chaincode commit \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

#### 🌐 VPS (chạy từ VPS 2, trỏ tới peer Org1 ở VPS 1):
```bash
peer lifecycle chaincode commit \
  -o orderer.example.com:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA \
  --peerAddresses peer0.org1.example.com:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

**Kiểm tra chaincode đã committed:**
```bash
peer lifecycle chaincode querycommitted \
  --channelID rentingchannel --name renting \
  --tls --cafile $ORDERER_CA
```

> ✅ Thấy chaincode `renting` sequence 1, Org1MSP và Org2MSP đều approved là OK!

---

### 5.5 Test nhanh chaincode

**Thiết lập lại biến Org1 (hoặc Org2 tuỳ ý):**
```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

**Query (đọc dữ liệu):**
```bash
# Query user theo ID (thay ID thực tế từ Firebase)
peer chaincode query -C rentingchannel -n renting \
  -c '{"function":"GetUserById","Args":["dSbOpLyc0IO3Be9Ci9DMidE8i7b2"]}'

# Query tất cả contracts
peer chaincode query -C rentingchannel -n renting \
  -c '{"function":"GetAllContracts","Args":[]}'
```

**Invoke tạo dữ liệu mẫu:**

#### 🖥️ Local:
```bash
# Tạo user Owner
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile $ORDERER_CA -C rentingchannel -n renting \
  --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"function":"CreateUser","Args":["OWNER_01","Chu Nha","0","OWNER"]}'

# Tạo user Guest (balance 20000)
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile $ORDERER_CA -C rentingchannel -n renting \
  --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"function":"CreateUser","Args":["TENANT_01","Khach Hang","20000","GUEST"]}'

# Tạo căn hộ
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile $ORDERER_CA -C rentingchannel -n renting \
  --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"function":"CreateApartment","Args":["APT_01","OWNER_01","5000","hash123"]}'
```

#### 🌐 VPS (thay `localhost:7050` → `orderer.example.com:7050`, `localhost:7051` → `peer0.org1.example.com:7051`):
```bash
peer chaincode invoke -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile $ORDERER_CA -C rentingchannel -n renting \
  --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"function":"CreateUser","Args":["OWNER_01","Chu Nha","0","OWNER"]}'
```

**Fetch block mới nhất:**
```bash
# Local
peer channel fetch newest newest_block.pb -c rentingchannel \
  --orderer localhost:7050 --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Decode (cần jq)
configtxlator proto_decode --input newest_block.pb --type common.Block | \
  jq '.data.data[0].payload.header.signature_header.creator'
```

---

### 5.6 Nâng cấp chaincode (khi thay đổi code)

> Thực hiện trên **cả 2 org**: install lại → approve (tăng sequence) → commit.  
> Ví dụ từ v1.0/seq1 lên v2.0/seq2:

```bash
# 1. Đóng gói lại với label mới
peer lifecycle chaincode package renting_v2.tar.gz \
  --path ../chaincode-go --lang golang --label renting_2.0

# 2. Install trên Org1
peer lifecycle chaincode install renting_v2.tar.gz

# 3. Lấy Package ID mới
peer lifecycle chaincode queryinstalled | grep -oP 'renting_2.0:\w+'
export PACKAGE_ID=renting_2.0:HASH_MỚI

# 4. Approve Org1 (sequence 2)
# [Local] -o localhost:7050  /  [VPS] -o orderer.example.com:7050
peer lifecycle chaincode approveformyorg -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 2.0 \
  --package-id $PACKAGE_ID --sequence 2 --tls --cafile $ORDERER_CA

# 5. Chuyển sang Org2, install + approve tương tự

# 6. Commit
# [Local]
peer lifecycle chaincode commit -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 2.0 --sequence 2 \
  --tls --cafile $ORDERER_CA \
  --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

---

## 6. Bước 3: Sync Dữ Liệu Firebase → Fabric

> **Mục đích**: Đồng bộ users và apartments từ Firebase Firestore lên Hyperledger Fabric  
> **Thư mục**: `quan-ly-tim-kiem-phong-tro-admin/`  
> **Chạy trên**: Windows hoặc WSL2

### 6.1 Cài đặt dependencies (lần đầu)

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm install
```

### 6.2 Kiểm tra kết nối Fabric (Health Check)

```bash
npm run fabric:health
```

### 6.3 Enroll Admin (lần đầu setup)

```bash
# Đăng ký admin identity vào wallet
npm run fabric:setup-admin
```

### 6.4 Tạo certificates cho users

```bash
npm run fabric:create-users
```

### 6.5 Sync toàn bộ dữ liệu Firebase → Fabric

```bash
# Đọc danh sách users từ Firebase → gọi CreateUser trên blockchain cho từng user
npm run fabric:sync-users
```

### 6.6 Chạy full pipeline

```bash
npm run fabric:demo    # setup-admin → create-users → health-check
npm run fabric:backup  # Backup wallet
npm run fabric:clean   # Reset wallet
npm run test           # Chạy unit tests
```

---

## 7. Bước 4: Khởi Động Blockchain Explorer

> **Thư mục**: `blockchain-fabric-explorer/`  
> **Yêu cầu**: Fabric network phải đang chạy  
> **Trên VPS 2**: Explorer kết nối vào peer0.org2

### 7.1 Lấy tên private key (bắt buộc làm mỗi lần tạo network mới)

```bash
# Trên máy chạy Explorer — lấy tên file _sk thực tế
ls ../blockchain-fabric-v2/test-network/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/
# Ví dụ output: abcxyz123_sk
```

> ⚠️ Tên file thay đổi mỗi lần chạy `cryptogen` → phải cập nhật lại.

### 7.2 Cập nhật `connection-profile/network-config.json`

Nội dung mẫu đầy đủ:

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

> ⚠️ Thay `abcxyz123_sk` bằng tên file thực tế trong keystore.  
> ⚠️ Trên VPS 2: Cần copy cả folder chứng chỉ Org1 từ VPS 1 sang để Explorer hiển thị đầy đủ network.

### 7.3 Khởi động Explorer

```bash
cd blockchain-fabric-explorer

# Xoá data cũ (khuyến nghị khi vừa reset network)
./explorer.sh clean

# Khởi động
./explorer.sh start
```

### 7.4 Các lệnh quản lý Explorer

```bash
./explorer.sh start    # Khởi động Explorer + PostgreSQL DB
./explorer.sh stop     # Dừng Explorer
./explorer.sh status   # Kiểm tra trạng thái
./explorer.sh logs     # Xem logs realtime
./explorer.sh restart  # Khởi động lại
./explorer.sh clean    # Xoá sạch database, reset

# Hoặc dùng docker-compose trực tiếp
docker-compose up -d
docker-compose ps
docker-compose logs -f explorer.example.com
docker-compose down
```

### 7.5 Truy cập Explorer

Mở trình duyệt: **http://localhost:8080** (local) hoặc **http://123.45.67.83:8080** (VPS 2)

- **Username**: `exploreradmin`  
- **Password**: `exploreradminpw`

> ⚠️ Explorer dùng Docker network `fabric_test` (external) — network này được tạo khi Fabric khởi động. Nếu lỗi, kiểm tra Fabric có đang chạy không.

---

## 8. Bước 5: Khởi Động Admin Server

> **Thư mục**: `quan-ly-tim-kiem-phong-tro-admin/`  
> **Môi trường**: Windows hoặc WSL2  
> **Yêu cầu**: Fabric phải đang chạy

Admin server gồm **2 process chạy song song**:
- `server_socket.js` — Port **3000**: Next.js app + Socket.io (IoT events, OTP)
- `server_blockchain.js` — Port **3001**: Express API (Fabric Gateway, Clocker auto check-in/out)

### 8.1 Cài đặt (lần đầu)

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm install
```

### 8.2 Kiểm tra file `.env`

```bash
# Fabric Network Configuration
FABRIC_CHANNEL_NAME=rentingchannel
FABRIC_CHAINCODE_NAME=renting
FABRIC_MSP_ID=Org1MSP
FABRIC_CRYPTO_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com
FABRIC_USER_NAME=User1@org1.example.com
FABRIC_PEER_NAME=peer0.org1.example.com
FABRIC_PEER_ENDPOINT=localhost:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com

# Server ports
PORT=3000          # Socket + Next.js
BLOCKCHAIN_PORT=3001  # Express + Fabric API
```

> ⚠️ `FABRIC_CRYPTO_PATH` là đường dẫn **tuyệt đối** trên Linux/WSL2.  
> Trên WSL2: thay `/root/` bằng `/mnt/d/nguyen/daihoc/HK7/DoAn3/quan-ly-tim-kiem-phong-tro/...`

### 8.3 Khởi động (mở 2 terminal riêng biệt)

**Terminal 1 — Socket Server (Next.js + Socket.io):**
```bash
cd quan-ly-tim-kiem-phong-tro-admin
node server_socket.js
```

**Terminal 2 — Blockchain Server (Express + Fabric):**
```bash
cd quan-ly-tim-kiem-phong-tro-admin
node server_blockchain.js
```

### 8.4 Hoặc chạy cả 2 cùng lúc

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm run dev
# Tương đương: node server_socket.js & node server_blockchain.js
```

### 8.5 Kiểm tra server hoạt động

```bash
# Test Socket server (port 3000)
curl http://localhost:3000

# Test Blockchain server (port 3001)
curl -X POST http://localhost:3001/api/verify \
  -H "Content-Type: application/json" \
  -d '{"apartmentId":"apt_001","password":"123456"}'

# Test API lấy password từ roomCode
curl -X POST http://localhost:3001/api/get-password \
  -H "Content-Type: application/json" \
  -d '{"roomCode":"P001"}'
```

### 8.6 Hiểu Clocker System

`server_blockchain.js` có hệ thống **Clocker** tự động chạy mỗi 60 giây:

```
Clocker quét tất cả contracts trên Fabric:
├─ Contract Status=CREATED và StartDate <= now
│   → Auto CHECK-IN: random password 6 chữ số
│   → Cập nhật Fabric: contract ACTIVE
│   → Cập nhật Firebase: apartment OCCUPIED, password mới
│
└─ Contract Status=ACTIVE và EndDate <= now
    → Auto CHECK-OUT: random password reset
    → Cập nhật Fabric: contract COMPLETED
    → Cập nhật Firebase: apartment AVAILABLE, giải ngân cho owner
```

---

## 9. Bước 6: Expose Server ra Internet (ngrok/pinggy)

> **Mục đích**: Cho phép mobile app và IoT kết nối tới admin server khi chạy trên local

### 9.1 Terminal 3 — Expose Socket Server (port 3000)

```bash
# Dùng ngrok (cần đăng ký tài khoản miễn phí tại ngrok.com)
ngrok http 3000

# Kết quả: https://xxxxx.ngrok-free.app → copy URL này
```

### 9.2 Terminal 4 — Expose Blockchain Server (port 3001)

```bash
# Dùng pinggy (không cần đăng ký)
ssh -p 443 -R0:localhost:3001 a.pinggy.io

# Kết quả: https://xxxxx.a.pinggy.io → copy URL này
```

> ⚠️ URL ngrok/pinggy thay đổi mỗi lần chạy → luôn phải cập nhật `.env` mobile sau khi có URL mới.

### 9.3 Cập nhật URL vào Mobile App

```bash
# File: quan_ly_tim_kiem_phong_tro_fe/.env
HOST_SERVER=https://xxxxx.ngrok-free.app   # URL từ ngrok (cho port 3000)
```

---

## 10. Bước 7: Khởi Động App Mobile (Flutter)

> **Thư mục**: `quan_ly_tim_kiem_phong_tro_fe/`

```bash
# Cài đặt dependencies (lần đầu)
cd quan_ly_tim_kiem_phong_tro_fe
flutter pub get

# Kiểm tra thiết bị kết nối
flutter devices

# Chạy trên device/emulator mặc định
flutter run

# Chạy debug với hot reload
flutter run --debug

# Chạy trên Android cụ thể
flutter run -d emulator-5554

# Build APK (nếu cần cài đặt trực tiếp)
flutter build apk --release

# Các lệnh tiện ích
flutter doctor       # Kiểm tra môi trường
flutter clean        # Clean build cache
flutter pub get      # Cài lại dependencies
flutter logs         # Xem logs realtime
```

---

## 11. Bước 8: Khởi Động IoT (ESP32)

> **Thư mục**: `iot/main/` — Firmware Arduino sketch (`main.ino`)

### 11.1 Cấu hình firmware trước khi nạp

Sửa các biến trong `iot/main/main.ino`:

```cpp
// Cấu hình WiFi
// Lưu ý: mật khẩu WiFi chỉ dùng số và ký tự a, b, c, d
const char* ssid = "TEN_WIFI";
const char* password = "MAT_KHAU_WIFI";

// URL Blockchain Server (URL từ pinggy - port 3001)
const char* server_url = "https://xxxxx.a.pinggy.io";

// Mã phòng của thiết bị này (phải match với Firebase)
const String roomCode = "P001";

// Device ID (unique cho mỗi thiết bị)
const String deviceId = "ESP32_001";
```

### 11.2 Nạp firmware

1. Mở Arduino IDE
2. Mở file `iot/main/main.ino`
3. Chọn **Board**: `ESP32 Dev Module`
4. Chọn **Port**: COM port của ESP32
5. Click **Upload**

### 11.3 Luồng hoạt động IoT

```
IoT khởi động
    → Kết nối WiFi
    → Gửi POST /api/iot/connect-room {roomCode, deviceId}
    → Server tạo OTP → gửi qua Socket.io đến mobile app
    → Mobile app hiển thị OTP cho người dùng
    → Hoặc IoT gọi POST /api/verify {apartmentId, password}
    → Nếu đúng → mở khóa cửa
```

### 11.4 Test IoT APIs thủ công

```bash
# Kết nối phòng (tạo OTP)
curl -X POST http://localhost:3000/api/iot/connect-room \
  -H "Content-Type: application/json" \
  -d '{"roomCode":"P001","type_iot":"smart_lock","deviceId":"ESP32_001"}'

# Verify OTP
curl -X POST http://localhost:3000/api/iot/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"otpCode":"123456","roomCode":"P001"}'

# Verify password
curl -X POST http://localhost:3000/api/iot/verify-password \
  -H "Content-Type: application/json" \
  -d '{"password":"123456","roomCode":"P001"}'

# Kiểm tra thiết bị online
curl -X POST http://localhost:3000/api/iot/devices/P001/check \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"ESP32_001"}'

# Lấy PingCode (IoT dùng để heartbeat)
curl "http://localhost:3000/api/iot/devices/P001/ping?deviceId=ESP32_001"
```

---

## 12. Quản Lý Hàng Ngày

### Buổi sáng - Khởi động

```bash
# 1. Khởi động lại Fabric containers (nếu đã stop trước đó)
docker start $(docker ps -aq)

# 2. Kiểm tra containers đang chạy
docker ps

# 3. Khởi động Explorer (tuỳ chọn)
cd blockchain-fabric-explorer
./explorer.sh start

# 4. Khởi động Admin Server (2 terminal)
# Terminal 1:
cd quan-ly-tim-kiem-phong-tro-admin && node server_socket.js
# Terminal 2:
cd quan-ly-tim-kiem-phong-tro-admin && node server_blockchain.js

# 5. Expose ra Internet
# Terminal 3: ngrok http 3000
# Terminal 4: ssh -p 443 -R0:localhost:3001 a.pinggy.io

# 6. Cập nhật URL mới vào .env của mobile app
```

### Buổi tối - Tắt máy

```bash
# Lưu trạng thái Fabric — KHÔNG dùng docker-compose down (sẽ mất data ledger)
docker stop $(docker ps -aq)

# Dừng Explorer
cd blockchain-fabric-explorer && ./explorer.sh stop

# Ctrl+C các terminal ngrok, pinggy, server
```

### Reset hoàn toàn Fabric (khi mọi thứ hỏng)

```bash
cd blockchain-fabric-v2/test-network

# Xoá sạch containers
docker-compose -f compose/compose-test-net.yaml -f compose/compose-ca.yaml down --volumes --remove-orphans
docker network prune -f
docker rm -f $(docker ps -aq) 2>/dev/null
docker volume prune -f

# Xoá chứng chỉ cũ
rm -rf organizations/peerOrganizations
rm -rf organizations/ordererOrganizations
rm -rf organizations/fabric-ca/org1/msp organizations/fabric-ca/org1/tls-cert.pem
rm -rf organizations/fabric-ca/org2/msp
rm -rf channel-artifacts/*.block *.tar.gz

# Xoá Explorer data  
cd ../../blockchain-fabric-explorer && ./explorer.sh clean

# --- Chạy lại từ đầu: Bước 4.1 → 4.2 → 4.3 → 4.4 → Bước 5 ---
```

---

## 13. Troubleshooting

### ❌ Fabric containers không chạy

```bash
docker logs peer0.org1.example.com --tail 50
docker logs orderer.example.com --tail 50
# Nếu lỗi permission:
sudo docker start $(docker ps -aq)
```

### ❌ `osnadmin` / Orderer báo lỗi kết nối

```bash
# Kiểm tra orderer lắng nghe port 7053
docker logs orderer.example.com | grep "7053"
# Kiểm tra biến TLS đã set đúng chưa
echo $ORDERER_ADMIN_TLS_CA_FILE
```

### ❌ `peer channel join` thất bại

```bash
# Kiểm tra file block tồn tại
ls channel-artifacts/rentingchannel.block

# Kiểm tra peer đang chạy và network OK
docker exec peer0.org1.example.com ping orderer.example.com
```

### ❌ `checkcommitreadiness` cả 2 org vẫn false

```bash
# Kiểm tra PACKAGE_ID đúng không
peer lifecycle chaincode queryinstalled

# Kiểm tra sequence (phải bắt đầu từ 1)
peer lifecycle chaincode checkcommitreadiness \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA --output json
```

### ❌ `Failed to create wallet` hoặc `certificate error`

```bash
# Kiểm tra đường dẫn crypto materials
ls blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com/users/

# Kiểm tra FABRIC_CRYPTO_PATH trong .env
cat quan-ly-tim-kiem-phong-tro-admin/.env | grep FABRIC
```

### ❌ Explorer container exit code 1

```bash
# Xem log chi tiết
docker-compose logs explorer.example.com | tail -50

# Lấy tên file private key ĐÚNG của Org2
ls ../blockchain-fabric-v2/test-network/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/

# Cập nhật vào network-config.json rồi restart
./explorer.sh clean && ./explorer.sh start
```

### ❌ Explorer lỗi ECONNRESET hoặc peer không kết nối

```bash
# Kiểm tra peer đang chạy
docker ps | grep peer

# Kiểm tra Docker network
docker network ls | grep fabric_test
docker network inspect fabric_test

# Ping từ Explorer tới peer
docker exec -it explorer.example.com ping peer0.org2.example.com
```

### ❌ Admin server không kết nối Fabric

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm run fabric:health    # Health check
cat .env | grep FABRIC   # Kiểm tra biến môi trường
# Đảm bảo FABRIC_PEER_ENDPOINT=localhost:7051 (local)
```

### ❌ Mobile app không kết nối server

```bash
cat quan_ly_tim_kiem_phong_tro_fe/.env   # Kiểm tra HOST_SERVER

# Test curl trực tiếp
curl https://xxxxx.ngrok-free.app/api/users/guests
```

### ❌ IoT không kết nối WiFi / server

- Mật khẩu WiFi **chỉ dùng số và ký tự a, b, c, d**
- Kiểm tra `ssid`, `password`, `server_url` trong firmware
- Kiểm tra ESP32 cùng mạng WiFi và server_url đúng

---

## 14. Sơ Đồ Port

| Service | Port | Protocol | Ghi chú |
|---------|------|----------|---------|
| Orderer | 7050 | gRPC+TLS | Fabric orderer |
| Orderer Admin | 7053 | gRPC+TLS | `osnadmin` |
| Orderer Metrics | 9443 | HTTP | Prometheus |
| peer0.org1 | 7051 | gRPC+TLS | Org1 peer |
| peer0.org1 Metrics | 9444 | HTTP | Prometheus |
| peer0.org2 | 9051 | gRPC+TLS | Org2 peer |
| peer0.org2 Metrics | 9445 | HTTP | Prometheus |
| CA Org1 | 7054 | HTTPS | Certificate Authority |
| CA Org2 | 8054 | HTTPS | Certificate Authority |
| Admin Socket Server | 3000 | HTTP | Next.js + Socket.io |
| Admin Blockchain Server | 3001 | HTTP | Express + Fabric API |
| Blockchain Explorer | 8080 | HTTP | Web dashboard |
| Explorer DB | 5432 | PostgreSQL | Internal Docker only |

---

## 📚 Tham Khảo Thêm

- [blockchain-fabric-v2/README.md](./blockchain-fabric-v2/README.md) — Chi tiết Fabric network & Smart Contract API
- [blockchain-fabric-v2/SIMPLE_DEPLOYMENT.md](./blockchain-fabric-v2/SIMPLE_DEPLOYMENT.md) — Hướng dẫn deploy lên VPS chi tiết
- [blockchain-fabric-explorer/README.md](./blockchain-fabric-explorer/README.md) — Chi tiết Explorer
- [quan-ly-tim-kiem-phong-tro-admin/README.md](./quan-ly-tim-kiem-phong-tro-admin/README.md) — API documentation
- [iot/CIRCUIT_DIAGRAM.md](./iot/CIRCUIT_DIAGRAM.md) — Sơ đồ mạch IoT

---

*Tài liệu được tổng hợp từ toàn bộ source code và README của các module trong dự án.*  
*Cập nhật lần cuối: 2026-04-14*
