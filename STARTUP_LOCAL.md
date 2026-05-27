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
[1] Dọn rác + Reset Firebase
      ↓
[2] Bật CAs (fabric-ca-server) lên trước
      ↓
[3] Chạy registerEnroll.sh để sinh chứng chỉ từ CA
      ↓
[4] Tạo Genesis Block (configtxgen)
      ↓
[5] Bật Orderer + Peers
      ↓
[6] Orderer/Peers join channel → Deploy chaincode
      ↓
[7] Sync dữ liệu Firebase → Fabric
      ↓
[8] Blockchain Explorer (tuỳ chọn)
      ↓
[9] Admin Server (2 terminal)
      ↓
[10] Expose ngrok + pinggy
      ↓
[11] Cập nhật .env Mobile → flutter run
      ↓
[12] IoT (ESP32) - nạp firmware một lần
```

---

## 2. Bước 1: Khởi Động Fabric Network (CA-Based)

> **Thư mục**: `blockchain-fabric-v2/test-network/`
> 
> ⭐ **Phương pháp này sử dụng CA Server (registerEnroll.sh) thay vì cryptogen cũ**
> - ✅ CA mới sinh chứng chỉ với NodeOUs (client, peer, admin, orderer) chính xác
> - ✅ User credentials được ký bởi CA → Peer tin tưởng 100%
> - ✅ Genesis Block được CA sign → Không bao giờ bị reject

### 1.1 Dọn dẹp hoàn toàn (reset khi cần)

```bash
cd blockchain-fabric-v2/test-network

# BƯỚC 1: Hạ toàn bộ containers và xóa volumes
docker compose -f compose/compose-test-net.yaml -f compose/compose-ca.yaml down --volumes --remove-orphans && docker rm -f $(docker ps -aq) &&docker volume rm $(docker volume ls -q) && docker network prune -f

# BƯỚC 2: Xóa tất cả crypto artifacts cũ
rm -rf organizations/peerOrganizations 
rm -rf organizations/ordererOrganizations
rm -rf organizations/fabric-ca
rm -rf channel-artifacts/*.block 
rm -rf channel-artifacts/*.tx
rm -f *.tar.gz

# BƯỚC 3: Reset biến môi trường
unset FABRIC_CFG_PATH CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH CORE_PEER_LOCALMSPID PACKAGE_ID
```

### 1.2 Khởi động chỉ CA Servers lên (chưa bật Peers/Orderers)

```bash
# Đứng ở: blockchain-fabric-v2/test-network/
# Bước 1: Bật CHỈ các CA containers (không bật peers/orderers)
docker compose -f compose/compose-ca.yaml up -d && sleep 10 && docker ps | grep ca_
```

> ✅ **Kỳ vọng thấy 3 CA containers**:
> - `ca_org1` (port 7054)
> - `ca_org2` (port 8054)
> - `ca_orderer` (port 9054)

### 1.3 Chạy registerEnroll.sh để sinh chứng chỉ từ CA (QUAN TRỌNG)

> ⚠️ **ĐÂY LÀ BƯỚC QUAN TRỌNG**: File này gọi CA Server đang chạy và sinh chứng chỉ với NodeOUs đúng định dạng.
> 
> **Lợi ích**:
> - Chứng chỉ được CA ký → Peer trust 100%
> - NodeOUs (client, peer, admin, orderer) được định nghĩa chính xác trong config.yaml
> - Genesis Block sẽ được tạo với chữ ký CA hợp lệ
> - User credentials sẽ khớp hoàn toàn với CA hiện tại

```bash
# Đứng ở: blockchain-fabric-v2/test-network/
export PATH=${PWD}/../bin:$PATH
```
```bash
# Chạy registerEnroll.sh để tạo chứng chỉ cho Org1
source organizations/fabric-ca/registerEnroll.sh
createOrg1

# Chạy registerEnroll.sh để tạo chứng chỉ cho Org2
createOrg2

# Chạy registerEnroll.sh để tạo chứng chỉ cho Orderer
createOrderer
```

> ✅ **Nếu thấy các dòng output như**:
> ```
> Creating Org1 identities...
> 2024-05-27 02:31:34 [fabric-ca] Enrolled admin...
> Creating Org1 identities... done
> ```
> → Chứng chỉ đã được tạo thành công!

> **Kết quả**: Tạo ra các thư mục:
> - `organizations/peerOrganizations/org1.example.com/`
> - `organizations/peerOrganizations/org2.example.com/`
> - `organizations/ordererOrganizations/example.com/`

### 1.4 Tạo Genesis Block bằng configtxgen

```bash
export FABRIC_CFG_PATH=${PWD}/configtx
```
```bash
mkdir -p channel-artifacts
```
```bash
configtxgen -profile ChannelUsingRaft \
  -outputBlock ./channel-artifacts/rentingchannel.block \
  -channelID rentingchannel
```

> ✅ Tạo ra `channel-artifacts/rentingchannel.block` (được CA Server ký)

### 1.5 Khởi động Orderer + Peers

```bash
# Bây giờ mới bật Orderer + Peers (lúc trước chỉ bật CAs)
docker compose -f compose/compose-test-net.yaml up -d && docker ps
```

> ✅ **Kỳ vọng thấy 9 containers**:
> - Orderer: `orderer.example.com`
> - Peers: `peer0.org1.example.com`, `peer0.org2.example.com`
> - CAs: `ca_org1`, `ca_org2`, `ca_orderer`
> - Chaincodes: `dev-peer0.org1...`, `dev-peer0.org2...`

### 1.6 Orderer join channel

```bash
export ORDERER_ADMIN_TLS_CA_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
export ORDERER_ADMIN_CLIENT_CERT_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_CLIENT_KEY_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
```

```bash
osnadmin channel join \
  --channelID rentingchannel \
  --config-block ./channel-artifacts/rentingchannel.block \
  -o localhost:7053 \
  --ca-file $ORDERER_ADMIN_TLS_CA_FILE \
  --client-cert $ORDERER_ADMIN_CLIENT_CERT_FILE \
  --client-key $ORDERER_ADMIN_CLIENT_KEY_FILE
```
```bash
# Kiểm tra — thấy rentingchannel là OK
osnadmin channel list \
  -o localhost:7053 \
  --ca-file $ORDERER_ADMIN_TLS_CA_FILE \
  --client-cert $ORDERER_ADMIN_CLIENT_CERT_FILE \
  --client-key $ORDERER_ADMIN_CLIENT_KEY_FILE
```

✅ **Xác nhận**: peer0.org1.example.com đang Up, Orderer đã join channel

### 1.7 ⚠️ QUAN TRỌNG: Tạo connection-org1.json

```bash
# Tạo file connection profile để Node.js kết nối
bash organizations/ccp-generate.sh
```

> ✅ Tạo ra `organizations/peerOrganizations/org1.example.com/connection-org1.json`  
> File này sẽ được Node.js sử dụng để gọi CA enroll users

### 1.8 ⭐ Tại sao cách này khác biệt?

| Tiêu chí | Cách cũ (cryptogen) | Cách mới (registerEnroll.sh) |
|---------|------------------|--------------------------|
| **Sinh chứng chỉ từ** | Công cụ offline | CA Server đang chạy (7054, 8054, 9054) |
| **NodeOUs** | ❌ Không được định nghĩa trong config.yaml | ✅ `--id.type client`, `--id.type admin` chính xác |
| **Genesis Block** | Sinh từ artifacts offline | Được CA Server ký, Peer tin tưởng 100% |
| **User enrollment** | ❌ Khi ông gọi `ca.register()`, lại sinh chứng chỉ mới (mismatch!) | ✅ Cùng CA Server, chứng chỉ match hoàn toàn |
| **Kết quả** | ❌ `No valid responses from any peers` | ✅ Transactions pass mà không bị reject |

> **Con đường chứng chỉ**:
> ```
> registerEnroll.sh → CA (7054) → ca-cert.pem → Peer MSP
>                                                    ↓
> Node.js → ca.register() → CA (7054) ← chứng chỉ khớp 100%
> ```

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
```
```bash
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
```
```bash
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
```
```bash
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
```
```bash
bash scripts/setAnchorPeer.sh 1 rentingchannel
```

```bash
# Set anchor peer cho Org2
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:9051
```
```bash
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

> ⚠️ **QUAN TRỌNG**: Bước này PHẢI chạy TRƯỚC khi khởi động Admin Server hoặc gọi API.  
> **Thứ tự bắt buộc**: 
> 1. Setup Master Admin (lấy chứng chỉ admin từ registerEnroll.sh vào Firebase) 
> 2. Sync Users (enroll từ CA) 
> 3. Sync Apartments 
> 4. Sau đó mới khởi động Admin Server

> **Điểm khác biệt so với cách cũ**:
> - Admin credentials đã được tạo bởi registerEnroll.sh trong `organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/`
> - setupMasterAdmin.ts sẽ tự động tìm và import chứng chỉ này vào Firebase
> - User credentials sẽ được tạo động từ CA Server khi gọi `ca.register()` (cùng CA, nên match 100%)

```bash
cd quan-ly-tim-kiem-phong-tro-admin
npm install   # Lần đầu
npm install -D tsx
```

### 3.1 Enroll Admin (BẮT BUỘC lần đầu)

> ⚠️ Nếu bỏ qua bước này, API sẽ trả lỗi `access denied` khi gọi.

```bash
cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
npx tsx src/script-fabric-blockchain/setupMasterAdmin.ts
```

✅ **Xác nhận**: Master admin đã sẵn sàng để register users

### 3.2 Sync Users từ Firebase lên Fabric (ENROLL từ CA)

> ⚠️ **BẮT BUỘC** trước khi gọi API `/api/book`
> Bước này sẽ:
> - Lấy users từ Firebase
> - Enroll mỗi user từ CA → tạo certificates
> - Lưu credentials vào Firebase `walletBlockchains` collection
> - Submit user transactions tới blockchain

```bash
npx tsx src/script-fabric-blockchain/syncFirebaseToFabricUser.ts
```

✅ **Nếu thấy**: "User voi ID ... da ton tai" → Bình thường, user đã enroll rồi

### 3.3 Sync Apartments từ Firebase lên Fabric

```bash
npx tsx src/script-fabric-blockchain/syncFirebaseToFabricApartment.ts
```

### 3.4 Kiểm tra kết nối Fabric (tùy chọn)

```bash
npm run fabric:health
```

✅ **Nếu thấy các dữ liệu được sync** → Sẵn sàng khởi động Admin Server (Bước 5)

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
NODE_OPTIONS="--dns-result-order=ipv4first" npm run dev
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

### Buổi sáng (Khi chỉ restart containers)

```bash
# Khởi động lại containers (giữ nguyên CAs, tidak reset crypto)
docker start $(docker ps -aq)
sleep 10 && docker ps

cd blockchain-fabric-explorer && ./explorer.sh start   # Explorer

# Terminal 1: cd quan-ly-tim-kiem-phong-tro-admin && node server_socket.js
# Terminal 2: cd quan-ly-tim-kiem-phong-tro-admin && node server_blockchain.js
# Terminal 3: ngrok http 3000
# Terminal 4: ssh -p 443 -R0:localhost:3001 a.pinggy.io
```

> ✅ **Lưu ý**: Khi chỉ restart containers (docker start), chứng chỉ vẫn match vì CA server định danh không thay đổi.

### Buổi sáng (Khi RESET TOÀN BỘ network)

Nếu bạn chạy step 1.1-1.5 lại (reset cryptogen, tạo CA mới):

```bash
# Sau khi chạy xong step 1.5 (docker compose tất cả lên)
cd quan-ly-tim-kiem-phong-tro-admin

# ⚠️ QUAN TRỌNG: Reset user certificates cũ từ Firebase
npm run ts-node src/script-fabric-blockchain/resetUserWalletsAfterRestart.ts

# Tạo lại certificates mới từ CA hiện tại
npm run ts-node src/script-fabric-blockchain/createUserCertificates.ts
```

> ✅ **Tại sao cần reset?**
> - Khi reset network (tạo CA mới), old certificates không match new CA
> - Phải xóa old certificates → tạo new certificates từ CA mới
> - Nhân vật này được giải thích kỹ ở bước 1.8 ⭐

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
| `Error: No valid responses from any peers` | User credentials cũ không match CA mới (sau reset) | Chạy `resetUserWalletsAfterRestart.ts` → `createUserCertificates.ts` |
| `No valid responses from any peers` (lần đầu) | User chưa enroll từ CA | Chạy `npx tsx src/script-fabric-blockchain/syncFirebaseToFabricUser.ts` |
| `Channel:rentingchannel received discovery error:access denied` | Admin credentials hết hạn | Chạy `setupMasterAdmin.ts` để renew |
| `x509: certificate signed by unknown authority` | **Không xảy ra** (registerEnroll.sh tự xử lý) | Nếu vẫn xảy ra, kiểm tra CA certificate chain trong Peer MSP |
| CA container `Exited (1)` | Crypto artifacts thiếu hoặc corrupt | Chạy step 1.1 (xóa toàn bộ), rồi 1.2 → 1.3 → 1.4 → 1.5 |
| `peer channel join` fail | Block file không tồn tại | Kiểm tra `ls channel-artifacts/rentingchannel.block` |
| registerEnroll.sh fail | CA server chưa ready | Chạy `docker ps \| grep ca_` để xác nhận CA đã up |
| Container không chạy | Permission / port conflict | `docker logs peer0.org1.example.com --tail 50` |
| `checkcommitreadiness` false | PACKAGE_ID sai hoặc chưa approve | `peer lifecycle chaincode queryinstalled` rồi set lại `PACKAGE_ID` |
| Explorer exit code 1 | Sai tên private key | `ls .../keystore/` rồi cập nhật `network-config.json` |
| Admin server lỗi Fabric | `FABRIC_CRYPTO_PATH` sai | Đảm bảo là đường dẫn tuyệt đối trên Linux/WSL2 |
| Mobile không connect | URL ngrok thay đổi | Cập nhật `HOST_SERVER` trong `.env` flutter |
| IoT không kết nối WiFi | Password WiFi có ký tự lạ | Chỉ dùng số và `a`, `b`, `c`, `d` |


