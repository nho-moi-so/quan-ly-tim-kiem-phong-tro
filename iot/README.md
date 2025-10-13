- Mật khẩu wifi với mã phòng phải là số với chỉ các ký tự (a,b,c,d)
- respond phải có dạng:
```json
{
  "status": "success",
}
```
- các ký tự phải là `lowercase`

---

Có các API bên hệ thống cần triển khai:
1. POST `/api/iot/connect-room`
    - body: `{ "roomCode": "MÃ PHÒNG" }`
    - header: `{ "Content-Type": "application/json" }`
    - response: `{ "status": "success" }` hoặc `{ "status": "error", "message": "LÝ DO LỖI" }`

---

2. POST `/api/iot/verify-otp`
    - body: `{ "otpCode": "MÃ OTP" }`
    - header: `{ "Content-Type": "application/json" }`
    - response: `{ "status": "success" }` hoặc `{ "status": "error", "message": "LÝ DO LỖI" }`

---

3. POST `/api/iot/room/verify-password`
    - body: `{ "password": "MẬT KHẨU", "roomId": "MÃ PHÒNG" }`
    - header: `{ "Content-Type": "application/json" }`
    - response: `{ "status": "success" }` hoặc `{ "status": "error", "message": "LÝ DO LỖI" }`

