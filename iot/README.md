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
- [x]: setup route
- []: setup service
- []: test BE
- []: test FE + BE
    - body: `{ "roomCode": "MÃ PHÒNG" }`
    - header: `{ "Content-Type": "application/json" }`
    - response: `{ "status": "success", "message": "Connected to Ma_phong }` hoặc `{ "status": "fail", "message": "LÝ DO LỖI" }`

---

2. POST `/api/iot/verify-otp`
- [x]: setup route
- []: setup service
- []: test BE
- []: test FE + BE
    - body: `{ "otpCode": "MÃ OTP", "roomCode": "Ma_Phong" }`
    - header: `{ "Content-Type": "application/json" }`
    - response: `{ "status": "success", "message": "verified success to roomCode is Ma_phong" }` hoặc `{ "status": "fail", "message": "LÝ DO LỖI" }`

---

3. POST `/api/iot/verify-password`
- [x]: setup route
- []: setup service
- []: test BE
- []: test FE + BE
    - body: `{ "password": "MẬT KHẨU", "roomCode": "001"}`
    - header: `{ "Content-Type": "application/json" }`
    - response: `{ "status": "success", "message": "unlock the password" }` hoặc `{ "status": "fail", "message": "byebye iot" }`

