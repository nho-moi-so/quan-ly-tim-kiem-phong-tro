# 🏠 Hướng Dẫn Khởi Động Dự Án - Quản Lý Tìm Kiếm Phòng Trọ

> **Hệ thống**: Room Rental Management với Hyperledger Fabric Blockchain

---

## Chọn môi trường chạy:

### 🖥️ [LOCAL — Phát triển trên máy cá nhân (WSL2)](./docs/STARTUP_LOCAL.md)
> Dùng khi: Phát triển, test, debug trên máy tính cá nhân qua WSL2/Linux.  
> Docker chạy tất cả trong 1 máy với `compose/compose-test-net.yaml`.

### 🌐 [PRODUCTION — Triển khai lên VPS](./docs/STARTUP_VPS.md)
> Dùng khi: Deploy thật lên 2 VPS riêng biệt (VPS 1: Orderer + Org1 + Server, VPS 2: Org2 + Explorer).  
> Mỗi component chạy file `docker-compose` riêng.

---

## Kiến trúc hệ thống

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

## Các thành phần

| Component | Thư mục | Port | Mô tả |
|-----------|---------|------|-------|
| Hyperledger Fabric | `blockchain-fabric-v2/` | 7050, 7051, 9051 | Blockchain network |
| Admin Server (Socket) | `quan-ly-tim-kiem-phong-tro-admin/` | 3000 | Next.js + Socket.io |
| Admin Server (Blockchain) | `quan-ly-tim-kiem-phong-tro-admin/` | 3001 | Express + Fabric Gateway |
| Blockchain Explorer | `blockchain-fabric-explorer/` | 8080 | Dashboard giám sát |
| Mobile App | `quan_ly_tim_kiem_phong_tro_fe/` | — | Flutter Android/iOS |
| IoT | `iot/main/` | — | Arduino/ESP32 firmware |
