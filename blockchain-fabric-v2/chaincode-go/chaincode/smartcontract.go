// 1. Cấu trúc dữ liệu
// 	User: ID, FullName, Balane, LockedBalance, Status ("ACTIVE", "PENDING", "LOCKED", "APPROVED"), Role ("ADMIN", "OWNER", "GUEST")
// 	Apartment: ID, OwnerID, DailyRate, Status ("AVAILABLE", "BOOKED", "OCCUPIED"), PasswordHash
// 	Contract: ID, ApartmentID, GuestID, StartDate, EndDate, EscrowAmount, Status ("CREATED", "ACTIVE", "COMPLETED")

// 2. Các chức năng chính
// 	CreateUser(id, fullName, balance)
// 	CreateApartment(id, ownerId, dailyRate) // mới tạo căn hộ, chưa có kết nối IoT nên không có mật khẩu
// 	UpdatePasswordApartment(id, passwordHash)
// 	BookApartment(contractId, aptId, guestId, startDate, endDate) => tiền của guest để vào biến EscrowAmount
// 	CancelBooking(contractId)
// 	CheckIn(contractId, newPassword)
// 	CheckOut(contractId, resetPassword) => giải phóng tiền từ biến EscrowAmount vào cho ownerId
// 	Deposit(userId, amount) => Cộng tiền vào Balance
// 	RequestWithdraw(userId, amount) => Trừ Balance, cộng vào LockedBalance.
// 	FinishWithdraw(userId, amount): Trừ LockedBalance (Xóa tiền khỏi hệ thống).
	
// 3. Các hàm hỗ trợ
// 	GetAllContracts()
// 	GetContractById(contractId)
// 	UpdateContractById()
	
// 	GetAllUser()
// 	GetUserById(userId)
// 	UpdateUser(userId)
	
// 	GetAllApartment()
// 	GetApartmentById(apartmentId)
// 	UpdateApartment()
	
// 	VerifyAccess(apartmentId, passwordHash)