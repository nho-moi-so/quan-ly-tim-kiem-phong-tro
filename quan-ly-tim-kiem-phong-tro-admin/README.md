# Cách khởi động 
1. `node server.js` để khởi động server với Socket.io
2. Mở một terminal khác, chạy `node test-socket-client.js` để kiểm tra kết nối Socket.io từ client => này sẽ implement lên app flutter sau

---

# 📚 API Documentation

## 🔗 Blockchain APIs

| Method | Endpoint | Body | Mô tả |
|--------|----------|------|-------|
| POST | `/api/blockchain/hash` | `bookingId, apartmentId, price, ownerId, guestId, password` | Tạo hash SHA-256 từ booking |
| POST | `/api/blockchain/confirm` | `contract_hash, checkin, checkout` | Xác nhận contract lên blockchain (tốn gas) |
| POST | `/api/blockchain/verify` | `contract_hash` | Đọc thông tin contract (miễn phí) |
| POST | `/api/blockchain/cancelled` | `contract_hash` | Hủy contract (tốn gas) |

## 👥 User APIs

| Method | Endpoint | Params | Mô tả |
|--------|----------|--------|-------|
| GET | `/api/users/guests` | - | Lấy danh sách guests |
| GET | `/api/users/guests/:id` | `id` | Lấy thông tin guest theo ID |
| GET | `/api/users/owners` | - | Lấy danh sách owners |
| GET | `/api/users/owners/:id` | `id` | Lấy thông tin owner theo ID |

## 📝 Post APIs

| Method | Endpoint | Params | Mô tả |
|--------|----------|--------|-------|
| GET | `/api/posts` | - | Lấy tất cả bài đăng |
| GET | `/api/posts/:id` | `id` | Lấy chi tiết bài đăng |

## 🏠 IoT APIs (Smart Lock)

| Method | Endpoint | Body | Mô tả |
|--------|----------|------|-------|
| GET | `/api/iot/test` | - | Test endpoint |
| POST | `/api/iot/connect-room` | `roomCode` | Tạo OTP và gửi qua Socket.io |
| POST | `/api/iot/verify-otp` | `otpCode, roomCode` | Xác thực OTP để mở khóa |
| POST | `/api/iot/verify-password` | `password, roomCode` | Xác thực password để mở khóa |

---

## 📡 Socket.io Events

| Event | Direction | Data | Mô tả |
|-------|-----------|------|-------|
| `otp_received` | Server → Client | `{ otp, roomCode }` | Gửi OTP đến mobile app |
| `iot-verified` | Server → Client | `{ roomCode, status, message }` | Thông báo xác thực thành công |