package chaincode

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

// SmartContract structure
type SmartContract struct {
	contractapi.Contract
}

// =========================================================
// 1. CẤU TRÚC DỮ LIỆU (DATA MODELS)
// =========================================================

// User: Đại diện cho ví tiền của người dùng
type User struct {
	DocType string `json:"docType"` // "user"
	ID      string `json:"id"`
	Name    string `json:"name"`
	Balance int    `json:"balance"` // Số dư tài khoản
}

// Apartment: Thông tin căn hộ
type Apartment struct {
	DocType      string `json:"docType"` // "apartment"
	ID           string `json:"id"`
	OwnerID      string `json:"ownerId"`      // ID của User chủ nhà
	Price        int    `json:"price"`        // Giá thuê
	Status       string `json:"status"`       // "AVAILABLE", "BOOKED", "OCCUPIED"
	PasswordHash string `json:"passwordHash"` // Hash mật khẩu cửa
}

// Booking: Đơn đặt phòng (Đóng vai trò là "Biến tạm" giữ tiền)
type Booking struct {
	DocType      string `json:"docType"` // "booking"
	ID           string `json:"id"`
	ApartmentID  string `json:"apartmentId"`
	TenantID     string `json:"tenantId"`     // ID của User khách
	CheckInTime  int64  `json:"checkInTime"`  // Unix Timestamp
	CheckOutTime int64  `json:"checkOutTime"` // Unix Timestamp

	// --- CƠ CHẾ GIỮ TIỀN (ESCROW) ---
	// Đây chính là "Biến tạm" ông yêu cầu.
	// Tiền sẽ nằm ở đây, bị khóa lại, không thuộc về ai cho đến khi Checkout.
	EscrowAmount int `json:"escrowAmount"`

	Status string `json:"status"` // "CREATED", "ACTIVE", "COMPLETED"
}

// =========================================================
// 2. HÀM TẠO USER
// =========================================================
// CreateUser: Tạo user mới với số dư ban đầu
func (s *SmartContract) CreateUser(ctx contractapi.TransactionContextInterface, id string, name string, balance int) error {
	// Kiểm tra user đã tồn tại chưa
	existingUser, err := ctx.GetStub().GetState(id)
	if err != nil {
		return fmt.Errorf("Lỗi kiểm tra user: %v", err)
	}
	if existingUser != nil {
		return fmt.Errorf("User với ID %s đã tồn tại", id)
	}

	user := User{
		DocType: "user",
		ID:      id,
		Name:    name,
		Balance: balance,
	}

	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, userJSON)
}

// =========================================================
// 3. CÁC CHỨC NĂNG CHÍNH (LOGIC FLOW)
// =========================================================
// BƯỚC 1: Chủ nhà A tạo căn hộ với mật khẩu hash ban đầu (VD: hash của "12345")
func (s *SmartContract) CreateApartment(ctx contractapi.TransactionContextInterface, id string, ownerId string, price int, initPassHash string) error {
	// (Bỏ qua bước check Owner tồn tại cho ngắn gọn)

	apt := Apartment{
		DocType:      "apartment",
		ID:           id,
		OwnerID:      ownerId,
		Price:        price,
		Status:       "AVAILABLE",
		PasswordHash: initPassHash,
	}
	aptJSON, _ := json.Marshal(apt)
	return ctx.GetStub().PutState(id, aptJSON)
}

// BƯỚC 2: Khách B đặt phòng -> Blockchain RÚT TIỀN của B và GIỮ LẠI
func (s *SmartContract) BookApartment(ctx contractapi.TransactionContextInterface, bookingId string, aptId string, tenantId string, checkIn int64, checkOut int64) error {
	// --- A. Đọc dữ liệu ---
	aptBytes, _ := ctx.GetStub().GetState(aptId)
	var apartment Apartment
	json.Unmarshal(aptBytes, &apartment)

	if apartment.Status != "AVAILABLE" {
		return fmt.Errorf("Căn hộ không sẵn sàng!")
	}

	userBytes, _ := ctx.GetStub().GetState(tenantId)
	var tenant User
	json.Unmarshal(userBytes, &tenant)

	// --- B. Kiểm tra số dư ---
	if tenant.Balance < apartment.Price {
		return fmt.Errorf("Không đủ tiền! Cần %d nhưng chỉ có %d", apartment.Price, tenant.Balance)
	}

	// --- C. LOGIC GIỮ TIỀN (ESCROW) ---
	// 1. Trừ tiền trong ví khách
	tenant.Balance = tenant.Balance - apartment.Price

	// 2. Tạo Booking và nhét tiền vào "Biến tạm" (EscrowAmount)
	// Lúc này tiền đang treo lơ lửng trên Blockchain, Chủ nhà chưa nhận được.
	booking := Booking{
		DocType:      "booking",
		ID:           bookingId,
		ApartmentID:  aptId,
		TenantID:     tenantId,
		CheckInTime:  checkIn,
		CheckOutTime: checkOut,
		EscrowAmount: apartment.Price, // <--- TIỀN BỊ KHÓA Ở ĐÂY
		Status:       "CREATED",
	}

	// 3. Cập nhật trạng thái căn hộ
	apartment.Status = "BOOKED"

	// --- D. Lưu tất cả xuống Ledger ---
	tenantJSON, _ := json.Marshal(tenant)
	bookingJSON, _ := json.Marshal(booking)
	aptJSON, _ := json.Marshal(apartment)

	ctx.GetStub().PutState(tenantId, tenantJSON)
	ctx.GetStub().PutState(bookingId, bookingJSON)
	ctx.GetStub().PutState(aptId, aptJSON)

	return nil
}

// BƯỚC 3: Đến giờ Check-in -> Hệ thống gọi update mật khẩu (VD: hash của "123456")
func (s *SmartContract) CheckIn(ctx contractapi.TransactionContextInterface, bookingId string, newPassHash string) error {
	// Đọc Booking & Apartment
	bookBytes, _ := ctx.GetStub().GetState(bookingId)
	var booking Booking
	json.Unmarshal(bookBytes, &booking)

	aptBytes, _ := ctx.GetStub().GetState(booking.ApartmentID)
	var apartment Apartment
	json.Unmarshal(aptBytes, &apartment)

	// Kiểm tra thời gian (Lấy giờ từ Transaction Timestamp)
	txTime, _ := ctx.GetStub().GetTxTimestamp()
	currentTime := txTime.Seconds

	// Logic If/Else chặn mở cửa sớm
	if currentTime < booking.CheckInTime {
		return fmt.Errorf("Chưa đến giờ Check-in! Hiện tại: %d, Giờ vào: %d", currentTime, booking.CheckInTime)
	}

	// --- CẬP NHẬT MẬT KHẨU ---
	apartment.PasswordHash = newPassHash
	apartment.Status = "OCCUPIED"
	booking.Status = "ACTIVE"

	// Lưu
	aptJSON, _ := json.Marshal(apartment)
	bookJSON, _ := json.Marshal(booking)
	ctx.GetStub().PutState(booking.ApartmentID, aptJSON)
	ctx.GetStub().PutState(bookingId, bookJSON)

	return nil
}

// BƯỚC 4: Đến giờ Check-out -> Đổi mật khẩu (VD: "1234567") -> TRẢ TIỀN CHO CHỦ
func (s *SmartContract) CheckOut(ctx contractapi.TransactionContextInterface, bookingId string, resetPassHash string) error {
	// Đọc Booking
	bookBytes, _ := ctx.GetStub().GetState(bookingId)
	var booking Booking
	json.Unmarshal(bookBytes, &booking)

	// Kiểm tra xem tiền còn trong "Biến tạm" không?
	if booking.EscrowAmount <= 0 {
		return fmt.Errorf("Giao dịch này đã thanh toán xong hoặc không có tiền")
	}

	// Đọc Apartment & Owner
	aptBytes, _ := ctx.GetStub().GetState(booking.ApartmentID)
	var apartment Apartment
	json.Unmarshal(aptBytes, &apartment)

	ownerBytes, _ := ctx.GetStub().GetState(apartment.OwnerID)
	var owner User
	json.Unmarshal(ownerBytes, &owner)

	// Kiểm tra thời gian
	// (Thực tế có thể cho checkout sớm, nhưng ở đây ví dụ kiểm tra đúng giờ)
	// txTime, _ := ctx.GetStub().GetTxTimestamp()
	// if txTime.Seconds < booking.CheckOutTime { ... }

	// --- A. LOGIC GIẢI PHÓNG TIỀN (RELEASE ESCROW) ---
	// 1. Lấy tiền từ biến tạm cộng vào ví Chủ nhà
	amountToRelease := booking.EscrowAmount
	owner.Balance = owner.Balance + amountToRelease

	// 2. Xóa tiền trong biến tạm (Để đảm bảo không rút được lần 2)
	booking.EscrowAmount = 0
	booking.Status = "COMPLETED"

	// --- B. ĐỔI MẬT KHẨU & TRẠNG THÁI ---
	apartment.PasswordHash = resetPassHash
	apartment.Status = "AVAILABLE"

	// --- C. Lưu tất cả ---
	ownerJSON, _ := json.Marshal(owner)
	bookJSON, _ := json.Marshal(booking)
	aptJSON, _ := json.Marshal(apartment)

	ctx.GetStub().PutState(apartment.OwnerID, ownerJSON)
	ctx.GetStub().PutState(bookingId, bookJSON)
	ctx.GetStub().PutState(booking.ApartmentID, aptJSON)

	return nil
}

// =========================================================
// 4. CÁC HÀM TRỢ GIÚP (HELPER FUNCTIONS)
// =========================================================

// --- HÀM MỚI (LEVELDB COMPATIBLE): Lấy danh sách tất cả Booking ---
func (s *SmartContract) GetAllBookings(ctx contractapi.TransactionContextInterface) ([]*Booking, error) {

	// Thay vì dùng QueryString, ta dùng GetStateByRange("", "") để lấy TẤT CẢ dữ liệu trong Ledger
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var bookings []*Booking

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		// Mẹo: Vì Ledger chứa cả User, Apartment, Booking...
		// Ta phải đọc thử xem nó có phải là Booking không.

		// 1. Unmarshal vào một Map tạm để check docType
		var dataMap map[string]interface{}
		err = json.Unmarshal(queryResponse.Value, &dataMap)
		if err != nil {
			continue // Nếu lỗi format thì bỏ qua
		}

		// 2. Chỉ lấy nếu docType là "booking"
		if val, ok := dataMap["docType"]; ok && val == "booking" {
			var booking Booking
			// Unmarshal lại vào struct chuẩn
			json.Unmarshal(queryResponse.Value, &booking)
			bookings = append(bookings, &booking)
		}
	}

	return bookings, nil
}

// GIAI ĐOẠN 3: IoT gọi hàm này để kiểm tra mật khẩu
func (s *SmartContract) VerifyAccess(ctx contractapi.TransactionContextInterface, aptId string, inputPassword string) (bool, error) {

	// 1. Lấy thông tin căn hộ
	aptBytes, err := ctx.GetStub().GetState(aptId)
	if err != nil {
		return false, fmt.Errorf("Không tìm thấy căn hộ")
	}
	if aptBytes == nil {
		return false, fmt.Errorf("Căn hộ không tồn tại")
	}

	var apartment Apartment
	err = json.Unmarshal(aptBytes, &apartment)
	if err != nil {
		return false, err
	}

	// 3. So sánh trực tiếp 2 cái Hash
	if inputPassword == apartment.PasswordHash {
		return true, nil
	}

	return false, nil
}

// Helper: Xem số dư
func (s *SmartContract) GetUser(ctx contractapi.TransactionContextInterface, id string) (*User, error) {
	bytes, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, err
	}
	if bytes == nil {
		return nil, fmt.Errorf("User with ID %s does not exist", id)
	}
	var user User
	err = json.Unmarshal(bytes, &user)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// Helper: Lấy thông tin apartment
func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Apartment, error) {
	bytes, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state: %v", err)
	}
	if bytes == nil {
		return nil, fmt.Errorf("Apartment with ID %s does not exist", id)
	}

	var apartment Apartment
	err = json.Unmarshal(bytes, &apartment)
	if err != nil {
		return nil, err
	}

	return &apartment, nil
}
