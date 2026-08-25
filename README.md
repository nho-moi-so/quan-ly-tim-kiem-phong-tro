<h1 align="center">🏠 Quản Lý & Tìm Kiếm Phòng Trọ</h1>

<p align="center">
  Nền tảng kết nối chủ căn hộ và người thuê phòng, tích hợp <strong>Blockchain</strong>, <strong>IoT</strong> và <strong>ứng dụng di động</strong>.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Next.js-14-000000?style=for-the-badge&logo=next.js&logoColor=white" />
  <img src="https://img.shields.io/badge/Hyperledger_Fabric-2.x-FF6D00?style=for-the-badge&logo=hyperledger&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/ESP32_IoT-333333?style=for-the-badge&logo=arduino&logoColor=white" />
</p>

<p align="center">
  <strong>Tác giả:</strong> Mỹ Ngọc &amp; Trường Nguyên &nbsp;|&nbsp; Đồ án 3 — HK7 — 2026
</p>

---

## 📌 Giới Thiệu

**Quản Lý & Tìm Kiếm Phòng Trọ** là hệ thống toàn diện giải quyết bài toán thực tế trong lĩnh vực cho thuê nhà ở, với 3 nhóm người dùng chính: **Người thuê**, **Chủ căn hộ** và **Quản trị viên**.

Điểm nổi bật của hệ thống là sự tích hợp đa công nghệ:

| Công nghệ | Ứng dụng trong hệ thống |
|-----------|------------------------|
| 🔗 **Hyperledger Fabric** | Lưu trữ hợp đồng thuê, lịch sử giao dịch minh bạch và bất biến trên blockchain |
| 📱 **Flutter** | Ứng dụng di động đa nền tảng (Android/iOS) cho người thuê & chủ căn hộ |
| 🌐 **Next.js** | Dashboard quản trị, quản lý toàn bộ hệ thống |
| 🤖 **IoT (ESP32)** | Khóa cửa thông minh, xác thực OTP không cần chìa khóa vật lý |
| ☁️ **Firebase** | Xác thực người dùng, lưu trữ dữ liệu realtime, đồng bộ với blockchain |

---

## 🎯 Tính Năng Chính

### 👤 Người Thuê
- Tìm kiếm & xem chi tiết phòng trọ trên bản đồ
- Đặt phòng, theo dõi yêu cầu, xem hợp đồng (lưu trên blockchain)
- Quản lý hóa đơn, nạp / rút tiền trong ví
- Nhắn tin trực tiếp với chủ căn hộ

### 🏡 Chủ Căn Hộ
- Đăng bài và quản lý danh sách căn hộ
- Duyệt / từ chối yêu cầu đặt phòng
- Quản lý thiết bị IoT (khóa cửa thông minh) theo từng phòng
- Xem thống kê doanh thu, rút tiền

### 🛡️ Quản Trị Viên
- Duyệt bài đăng, xác minh tài khoản chủ căn hộ
- Quản lý giao dịch & yêu cầu rút tiền
- Giám sát mạng blockchain qua Hyperledger Explorer
- Xem thống kê toàn hệ thống

---

## 🏗️ Kiến Trúc Hệ Thống

```
  [Flutter Mobile App]
         ↕ REST API / Socket.io
  [Admin Server — Next.js :3000 | Express :3001]
         ↕ Fabric Gateway SDK
  [Hyperledger Fabric Network]
    ├─ Orderer  :7050
    ├─ peer0.org1  :7051
    └─ peer0.org2  :9051  (channel: rentingchannel)
         ↕ Sync
  [Firebase Firestore] ←── [IoT ESP32]
  [Blockchain Explorer :8080]
```

---

## 🛠️ Công Nghệ Sử Dụng

| Layer | Công nghệ |
|-------|-----------|
| Mobile | Flutter 3.x · Dart SDK ^3.8.1 · Provider · Socket.IO Client |
| Admin UI | Next.js 14 · TypeScript · Ant Design 5.x · Recharts |
| Backend | Node.js · Express 5.x · Socket.IO 4.x |
| Blockchain | Hyperledger Fabric 2.x · Chaincode (Go) · Fabric Gateway SDK |
| Database | Firebase Firestore · Firebase Auth · Firebase Storage |
| Maps | flutter_map · Geolocator |
| IoT | Arduino / ESP32 · WiFi OTP Authentication |
| DevOps | Docker · Docker Compose · Hyperledger Explorer |

---

## 📁 Cấu Trúc Dự Án

```
quan-ly-tim-kiem-phong-tro/
├── quan_ly_tim_kiem_phong_tro_fe/      # 📱 Flutter Mobile App
├── quan-ly-tim-kiem-phong-tro-admin/   # 🌐 Next.js Admin + Backend Server
├── blockchain-fabric-v2/               # ⛓️  Hyperledger Fabric Network
├── blockchain-fabric-explorer/         # 🔍 Blockchain Explorer (port 8080)
├── contracts/                          # 📜 Hardhat Smart Contracts (Solidity)
├── iot/                                # 🤖 ESP32 Firmware
├── diagrams/                           # 📐 PlantUML Diagrams
├── STARTUP_LOCAL.md                    # Hướng dẫn chạy LOCAL (WSL2)
└── STARTUP_VPS.md                      # Hướng dẫn deploy VPS
```

---

## 🚀 Khởi Động Nhanh

Xem hướng dẫn chi tiết theo môi trường:

- 🖥️ **[Chạy LOCAL (WSL2)](./STARTUP_LOCAL.md)** — Phát triển & test trên máy cá nhân
- 🌐 **[Deploy VPS](./STARTUP_VPS.md)** — Triển khai production lên 2 VPS riêng biệt

---

## 📐 Sơ Đồ Hệ Thống

Các sơ đồ UML được lưu trong thư mục [`diagrams/`](./diagrams/):

| Sơ đồ | File |
|-------|------|
| Use Case tổng quan | `usecase.puml` |
| Use Case — Người thuê | `usecase_guest.puml` |
| Use Case — Chủ căn hộ | `usecase_owner.puml` |
| Use Case — Quản trị viên | `usecase_admin.puml` |
| Class Diagram | `class.puml` |
| Database Diagram | `database.puml` |
| Activity Diagram | `activity.puml` |
| Sequence Diagrams | `sequences/` |

---

<p align="center">
  Made with ❤️ by <strong>Mỹ Ngọc</strong> &amp; <strong>Trường Nguyên</strong>
</p>