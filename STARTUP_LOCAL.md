# 🖥️ Hướng Dẫn Khởi Động - LOCAL (WSL2 / 1 máy)

> Tất cả services (Orderer + 2 Peers + CAs) chạy cùng nhau trên 1 máy.  
> **Yêu cầu**: WSL2 Ubuntu hoặc Linux, Docker, Node.js >= 18, Go >= 1.21, Flutter >= 3.

---

## 📋 Mục Lục

1. [Thứ Tự Khởi Động](#1-thứ-tự-khởi-động)
2. [Bước 1: Khởi Động Fabric Network](#2-bước-1-khởi-động-fabric-network)
3. [Bước 2: Deploy Chaincode](#3-bước-2-deploy-chaincode)
4. [Bước 3: Sync Firebase → Fabric](#4-bước-3-sync-firebase--fabric)
5. [Bước 4: Khởi Động Explorer](#5-bước-4-khởi-động-explorer)
6. [Bước 5: Khởi Động Admin Server](#6-bước-5-khởi-động-admin-server)
7. [Bước 6: Expose ra Internet](#7-bước-6-expose-ra-internet)
8. [Bước 7: Flutter Mobile](#8-bước-7-flutter-mobile)
9. [Bước 8: IoT (ESP32)](#9-bước-8-iot-esp32)
10. [Quản Lý Hàng Ngày](#10-quản-lý-hàng-ngày)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Thứ Tự Khởi Động

```
[1] Khởi động Fabric (cryptogen → configtxgen → docker compose up)
      ↓
[2] Orderer join channel → Peer join → Install/Approve/Commit chaincode
      ↓
[3] Sync dữ liệu Firebase → Fabric (lần đầu)
      ↓
[4] Blockchain Explorer (tuỳ chọn)
      ↓
[5] Admin Server (2 terminal)
      ↓
[6] Expose ngrok + pinggy
      ↓
[7] Cập nhật .env Mobile → flutter run
      ↓
[8] IoT (ESP32) - nạp firmware một lần
```

---

## 2. Bước 1: Khởi Động Fabric Network

> **Thư mục**: `blockchain-fabric-v2/test-network/`

### 1.1 Dọn dẹp (reset hoàn toàn khi cần)

```bash
cd blockchain-fabric-v2/test-network

# Hạ containers và xóa volume
docker-compose -f compose/compose-test-net.yaml -f compose/compose-ca.yaml down --volumes --remove-orphans
docker network prune -f

# (Tùy chọn) Xóa triệt để
docker rm -f $(docker ps -aq) 2>/dev/null
docker volume prune -f

# Xóa chứng chỉ cũ
rm -rf organizations/peerOrganizations
rm -rf organizations/ordererOrganizations
rm -rf organizations/fabric-ca/org1/msp organizations/fabric-ca/org1/tls-cert.pem organizations/fabric-ca/org1/fabric-ca-server.db
rm -rf organizations/fabric-ca/org2/msp
rm -rf organizations/fabric-ca/ordererOrg/msp
rm -rf channel-artifacts/*.block channel-artifacts/*.tx
rm -f *.tar.gz

# Reset biến môi trường
unset FABRIC_CFG_PATH CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH CORE_PEER_LOCALMSPID PACKAGE_ID
```

### 1.2 Sinh chứng chỉ bằng cryptogen

```bash
# Đứng ở: blockchain-fabric-v2/test-network/
export PATH=${PWD}/../bin:$PATH

```
```bash
cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"
```
```bash
cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"
```
```bash
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
```

### 1.3 Sinh genesis block

```bash
export FABRIC_CFG_PATH=${PWD}/configtx
mkdir -p channel-artifacts

configtxgen -profile ChannelUsingRaft \
  -outputBlock ./channel-artifacts/rentingchannel.block \
  -channelID rentingchannel
```

> ✅ Tạo ra `channel-artifacts/rentingchannel.block`

### 1.4 Khởi động tất cả containers

```bash
# Chạy Orderer + 2 Peers + 2 CAs cùng lúc
docker compose -f compose/compose-test-net.yaml -f compose/compose-ca.yaml up -d

# Kiểm tra
docker ps
```

> ✅ Thấy `orderer.example.com`, `peer0.org1.example.com`, `peer0.org2.example.com`, `ca_org1`, `ca_org2` đang `Up`

### 1.5 Orderer join channel

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

### 1.6 Khởi động lại sau khi tắt máy

```bash
# KHÔNG dùng docker-compose down — sẽ mất data ledger
docker start $(docker ps -aq)
docker ps
```

---

## 3. Bước 2: Deploy Chaincode

### Biến môi trường chung (thiết lập một lần)

```bash
# Đứng ở: blockchain-fabric-v2/test-network/
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

---

### A. Org1 — Join + Install + Approve

```bash
# Thiết lập identity Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Join channel
peer channel join -b ./channel-artifacts/rentingchannel.block

# Đóng gói chaincode
peer lifecycle chaincode package renting.tar.gz \
  --path ../chaincode-go --lang golang --label renting_1.0

# Install
peer lifecycle chaincode install renting.tar.gz

# Lấy Package ID
peer lifecycle chaincode queryinstalled | grep -oP 'renting_1.0:\w+'
# Ví dụ: renting_1.0:fdf097f77d1ac9b443b9f0b7cf51a81c49b979f21da6500fb9e32a9cf09ff666

export PACKAGE_ID=renting_1.0:fdf097f77d1ac9b443b9f0b7cf51a81c49b979f21da6500fb9e32a9cf09ff666

# Approve
peer lifecycle chaincode approveformyorg \
  -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

# Kiểm tra — kỳ vọng Org1MSP: true
peer lifecycle chaincode checkcommitreadiness \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA --output json
```

---

### B. Org2 — Join + Install + Approve

```bash
# Chuyển sang identity Org2
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
export FABRIC_CFG_PATH=${PWD}/../config

# Join channel
peer channel join -b ./channel-artifacts/rentingchannel.block

# Install (dùng lại file .tar.gz đã tạo)
peer lifecycle chaincode install renting.tar.gz

# Approve
peer lifecycle chaincode approveformyorg \
  -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 \
  --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

# Kiểm tra — kỳ vọng CẢ 2 đều true
peer lifecycle chaincode checkcommitreadiness \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA --output json
```

---

### C. Commit chaincode ("chốt đơn")

```bash
peer lifecycle chaincode commit \
  -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 1.0 --sequence 1 \
  --tls --cafile $ORDERER_CA \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# Xác nhận
peer lifecycle chaincode querycommitted \
  --channelID rentingchannel --name renting --tls --cafile $ORDERER_CA
```

> ✅ Thấy chaincode `renting` với sequence 1, cả 2 org approved là OK!

---
### Chạy `setAnchorPeer.sh` cho mỗi org (tùy chọn nhưng khuyến nghị để tối ưu routing)
```bash
cd /root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network

# Set anchor peer cho Org1
export FABRIC_CFG_PATH=${PWD}/../config
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051

bash scripts/setAnchorPeer.sh 1 rentingchannel
```

```bash
# Set anchor peer cho Org2
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:9051

bash scripts/setAnchorPeer.sh 2 rentingchannel
```


### Tạo connection.json: sẽ được dùng để kết nối admin server → Fabric network.
```bash
bash organizations/ccp-generate.sh
```

### D. Test Chaincode

```bash
# Dùng identity Org1 (hoặc Org2 tùy ý)
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=localhost:7051
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

# Query (đọc)
peer chaincode query -C rentingchannel -n renting \
  -c '{"function":"GetAllContracts","Args":[]}'

# Invoke (ghi) — tạo user mẫu
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile $ORDERER_CA -C rentingchannel -n renting \
  --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"function":"CreateUser","Args":["OWNER_01","Chu Nha","0","OWNER"]}'
```

---

### E. Nâng cấp Chaincode (khi thay đổi code)

```bash
# Đóng gói lại với label mới
peer lifecycle chaincode package renting_v2.tar.gz \
  --path ../chaincode-go --lang golang --label renting_2.0

# --- Org1: install + approve với sequence 2 ---
export CORE_PEER_ADDRESS=localhost:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

peer lifecycle chaincode install renting_v2.tar.gz
peer lifecycle chaincode queryinstalled | grep -oP 'renting_2.0:\w+'
export PACKAGE_ID_V2=renting_2.0:HASH_MỚI_Ở_ĐÂY

peer lifecycle chaincode approveformyorg \
  -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 2.0 \
  --package-id $PACKAGE_ID_V2 --sequence 2 --tls --cafile $ORDERER_CA

# --- Org2: install + approve tương tự ---
export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_LOCALMSPID="Org2MSP"
# ... (tương tự Org1 nhưng đổi path org2)

# --- Commit ---
peer lifecycle chaincode commit \
  -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --channelID rentingchannel --name renting --version 2.0 --sequence 2 \
  --tls --cafile $ORDERER_CA \
  --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

---

## 4. Bước 3: Sync Firebase → Fabric

> **Chỉ cần chạy lần đầu** hoặc sau khi reset Fabric network.

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm install   # Lần đầu
npm install -D tsx
```

**Bước 1 — Enroll Admin** (lần đầu setup):
```bash
cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
npx tsx src/script-fabric-blockchain/setupMasterAdmin.ts
```

**Bước 2 — Sync Users** từ Firebase lên Fabric:
```bash
cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
npx tsx src/script-fabric-blockchain/syncFirebaseToFabricUser.ts
```

**Bước 3 — Sync Apartments** từ Firebase lên Fabric:
```bash
npx tsx src/script-fabric-blockchain/syncFirebaseToFabricApartment.ts
```

**Kiểm tra kết nối Fabric (tùy chọn):**
```bash
npm run fabric:health
```

---

## 5. Bước 4: Khởi Động Explorer

```bash
# Bước 1: Lấy tên file private key (thay đổi sau mỗi lần reset network)
ls blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/
# Ví dụ: priv_sk hoặc abc123def456_sk (tên file có thể khác, nhưng luôn kết thúc _sk)

# Bước 2: Cập nhật tên file vào connection-profile/network-config.json
# (phần adminPrivateKey.path)

# Bước 3: Khởi động
cd blockchain-fabric-explorer
./explorer.sh clean   # Xóa data cũ (khuyến nghị khi vừa reset network)
./explorer.sh start

# Truy cập: http://localhost:8080
# Username: exploreradmin / Password: exploreradminpw
```

Các lệnh quản lý:
```bash
./explorer.sh start    # Khởi động
./explorer.sh stop     # Dừng
./explorer.sh status   # Trạng thái
./explorer.sh logs     # Logs realtime
./explorer.sh restart  # Restart
./explorer.sh clean    # Reset database
```

---

## 6. Bước 5: Khởi Động Admin Server

Kiểm tra `.env`:
```bash
FABRIC_CHANNEL_NAME=rentingchannel
FABRIC_CHAINCODE_NAME=renting
FABRIC_MSP_ID=Org1MSP
FABRIC_CRYPTO_PATH=/mnt/d/nguyen/.../blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com
FABRIC_PEER_ENDPOINT=localhost:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com
PORT=3000
BLOCKCHAIN_PORT=3001
```

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm run dev
# Tương đương: node server_socket.js & node server_blockchain.js
```

> Nếu muốn xem log từng process riêng, có thể tách ra 2 terminal:
> ```bash
> # Terminal 1: node server_socket.js
> # Terminal 2: node server_blockchain.js
> ```

---

## 7. Bước 6: Expose ra Internet

**Terminal 3** — Socket server (port 3000):
```bash
ngrok http 3000
# Lấy URL: https://xxxxx.ngrok-free.app
```

**Terminal 4** — Blockchain server (port 3001):
```bash
ssh -p 443 -R0:localhost:3001 a.pinggy.io
# Lấy URL: https://xxxxx.a.pinggy.io
```

Cập nhật URL vào mobile app:
```bash
# quan_ly_tim_kiem_phong_tro_fe/.env
HOST_SERVER=https://xxxxx.ngrok-free.app
```

---

## 8. Bước 7: Flutter Mobile

```bash
cd quan_ly_tim_kiem_phong_tro_fe
flutter pub get
flutter devices
flutter run
```

---

## 9. Bước 8: IoT (ESP32)

Sửa `iot/main/main.ino`:
```cpp
const char* ssid = "TEN_WIFI";           // Mật khẩu chỉ dùng số và a,b,c,d
const char* password = "MAT_KHAU_WIFI";
const char* server_url = "https://xxxxx.a.pinggy.io";
const String roomCode = "P001";
const String deviceId = "ESP32_001";
```

Nạp firmware qua Arduino IDE (Board: ESP32 Dev Module).

---

## 10. Quản Lý Hàng Ngày

### Buổi sáng

```bash
docker start $(docker ps -aq)      # Khởi động lại Fabric
docker ps                           # Kiểm tra

cd blockchain-fabric-explorer && ./explorer.sh start   # Explorer

# Terminal 1: cd quan-ly-tim-kiem-phong-tro-admin && node server_socket.js
# Terminal 2: cd quan-ly-tim-kiem-phong-tro-admin && node server_blockchain.js
# Terminal 3: ngrok http 3000
# Terminal 4: ssh -p 443 -R0:localhost:3001 a.pinggy.io
```

### Buổi tối

```bash
docker stop $(docker ps -aq)       # Lưu state Fabric (KHÔNG dùng down)
cd blockchain-fabric-explorer && ./explorer.sh stop
# Ctrl+C các terminal còn lại
```

---

## 11. Troubleshooting

| Lỗi | Nguyên nhân | Cách xử lý |
|-----|------------|------------|
| Container không chạy | Permission / port conflict | `docker logs peer0.org1.example.com --tail 50` |
| `peer channel join` fail | Block file không tồn tại | Kiểm tra `ls channel-artifacts/rentingchannel.block` |
| `checkcommitreadiness` false | PACKAGE_ID sai hoặc chưa approve | `peer lifecycle chaincode queryinstalled` rồi set lại `PACKAGE_ID` |
| Explorer exit code 1 | Sai tên private key | `ls .../keystore/` rồi cập nhật `network-config.json` |
| Admin server lỗi Fabric | `FABRIC_CRYPTO_PATH` sai | Đảm bảo là đường dẫn tuyệt đối trên Linux/WSL2 |
| Mobile không connect | URL ngrok thay đổi | Cập nhật `HOST_SERVER` trong `.env` flutter |
| IoT không kết nối WiFi | Password WiFi có ký tự lạ | Chỉ dùng số và `a`, `b`, `c`, `d` |


