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

| Method | Endpoint | Body/Params | Mô tả |
|--------|----------|-------------|-------|
| GET | `/api/iot/test` | - | Test endpoint |
| POST | `/api/iot/connect-room` | `roomCode, type_iot, deviceId` | Tạo OTP và gửi qua Socket.io |
| POST | `/api/iot/verify-otp` | `otpCode, roomCode` | Xác thực OTP để mở khóa |
| POST | `/api/iot/verify-password` | `password, roomCode` | Xác thực password để mở khóa |
| GET | `/api/iot/devices/:roomCode/ping?deviceId=xxx` | Query: `deviceId` | Lấy PingCode hiện tại của thiết bị |
| POST | `/api/iot/devices/:roomCode/ping` | `deviceId, pingReply` | Thiết bị gửi PingReply để cập nhật lên server |
| POST | `/api/iot/devices/:roomCode/check` | `deviceId` | Kiểm tra trạng thái kết nối/thiết bị |
| DELETE | `/api/iot/devices/:roomCode/delete?deviceId=xxx` | Query: `deviceId` | Xóa thiết bị khỏi phòng |

**Ghi chú:**
- Mỗi phòng có thể có nhiều thiết bị, do đó cần truyền `deviceId` để xác định thiết bị cụ thể.
- Document ID trong Firestore sử dụng format: `{roomCode}_{deviceId}`
- Website dùng POST `/api/iot/devices/:roomCode/check` với `deviceId` trong body để kiểm tra thiết bị còn online không.
- Firmware/thiết bị dùng GET `/api/iot/devices/:roomCode/ping?deviceId=xxx` để lấy PingCode và POST `/api/iot/devices/:roomCode/ping` với `deviceId` và `pingReply` trong body để trả lời.

## 🛠️ Utility APIs

| Method | Endpoint | Body | Mô tả |
|--------|----------|------|-------|
| POST | `/api/util/upload` | `file` (FormData) | Upload file lên server, trả về URL |


---

## 📡 Socket.io Events

| Event | Direction | Data | Mô tả |
|-------|-----------|------|-------|
| `otp_received` | Server → Client | `{ otp, roomCode, deviceId }` | Gửi OTP đến mobile app cho thiết bị cụ thể |
| `iot-verified` | Server → Client | `{ roomCode, status, message }` | Thông báo xác thực thành công |