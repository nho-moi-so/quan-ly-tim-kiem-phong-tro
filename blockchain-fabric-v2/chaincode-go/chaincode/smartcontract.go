package chaincode

import (
	"encoding/json"
	"fmt"
	"math"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

// ======================CAU TRUC DU LIEU=====================
// ///user
type User struct {
	DocType       string `json:"docType"`
	ID            string `json:"id"`
	FullName      string `json:"FullName"`
	Balance       int    `json:"Balance"`
	LockedBalance int    `json:"LockedBalance"`
	Status        string `json:"Status"` //"ACTIVE", "PENDING", "LOCKED", "APPROVED"
	Role          string `json:"Role"`   //"ADMIN", "OWNER", "GUEST"
}

// ////apartment
type Apartment struct {
	DocType      string `json:"docType"`
	ID           string `json:"id"`
	OwnerID      string `json:"OwnerID"`
	DailyRate    int    `json:"DailyRate"`
	Status       string `json:"Status"` //"AVAILABLE", "BOOKED", "OCCUPIED"
	PasswordHash string `json:"PasswordHash"`
}

// ////contract
type Contract struct {
	DocType      string `json:"docType"`
	ID           string `json:"id"`
	ApartmentID  string `json:"ApartmentID"`
	GuestID      string `json:"GuestID"`
	StartDate    int64  `json:"StartDate"`
	EndDate      int64  `json:"EndDate"`
	EscrowAmount int    `json:"EscrowAmount"` //bien giu tien
	Status       string `json:"Status"`       //"CREATED", "ACTIVE", "COMPLETED", "CANCELED"

}

// ======================CAC HAM CHINH================
// tao nguoi dung
func (s *SmartContract) CreateUser(ctx contractapi.TransactionContextInterface, id string, fullName string, balance int, role string) error {
	existingUser, err := ctx.GetStub().GetState(id)
	if err != nil {
		return fmt.Errorf("Loi kiem tra user: %v", err)
	}
	if existingUser != nil {
		return fmt.Errorf("User voi ID %s da ton tai", id)
	}

	user := User{
		DocType:  "user",
		ID:       id,
		FullName: fullName,
		Balance:  balance,
		Status:   "ACTIVE",
		Role:     role,
	}
	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, userJSON)
}

// tao can ho khi chua co mat khau
func (s *SmartContract) CreateApartment(ctx contractapi.TransactionContextInterface, id string, ownerid string, dailyRate int) error {
	apt := Apartment{
		DocType:   "apartment",
		ID:        id,
		OwnerID:   ownerid,
		DailyRate: dailyRate,
		Status:    "AVAILABLE",
		//password chưa gán thì sẽ là ""
	}

	aptJSON, _ := json.Marshal(apt)
	return ctx.GetStub().PutState(id, aptJSON)
}

// update mat khau cho can ho
func (s *SmartContract) UpdatePasswordApartment(ctx contractapi.TransactionContextInterface, apartmentID string, passwordHash string) error {
	//tim can ho
	apartmentBytes, err := ctx.GetStub().GetState(apartmentID)
	if err != nil {
		return fmt.Errorf("Loi lay can ho: %v", err)
	}
	if apartmentBytes == nil {
		return fmt.Errorf("Khong tim thay can ho %s", apartmentID)
	}
	var apartment Apartment
	if err := json.Unmarshal(apartmentBytes, &apartment); err != nil {
		return fmt.Errorf("Loi doc JSON can ho: %v", err)
	}
	json.Unmarshal(apartmentBytes, &apartment)

	apartment.PasswordHash = passwordHash
	apartmentJSON, _ := json.Marshal(apartment)
	if err != nil {
		return fmt.Errorf("Loi tao JSON can ho: %v", err)
	}
	return ctx.GetStub().PutState(apartmentID, apartmentJSON)
}

// dat phong
func (s *SmartContract) BookApartment(ctx contractapi.TransactionContextInterface, contractId string, apartmentId string, guestId string, startDate int64, endDate int64) error {
	//tim apartment
	apartmentBytes, _ := ctx.GetStub().GetState(apartmentId)
	var apartment Apartment
	json.Unmarshal(apartmentBytes, &apartment)
	if apartment.Status != "AVAILABLE" {
		return fmt.Errorf("Can ho khong san sang")
	}

	//tim guest
	userBytes, _ := ctx.GetStub().GetState(guestId)
	var guest User
	json.Unmarshal(userBytes, &guest)

	//tinh tien
	start := time.Unix(startDate, 0)
	end := time.Unix(endDate, 0)
	diffSeconds := end.Sub(start).Seconds()
	if diffSeconds <= 0 {
		return fmt.Errorf("So ngay thue khong hop le")
	}
	days := int(math.Ceil(diffSeconds / 86400))
	if days < 1 {
		days = 1
	}
	var totalPrice = apartment.DailyRate * days
	if guest.Balance < totalPrice {
		return fmt.Errorf("Không đủ tiền! Cần %d nhưng chỉ có %d", totalPrice, guest.Balance)
	}

	//logic tru tien
	//1. tru tien trong guest
	guest.Balance = guest.Balance - totalPrice
	//2. tao contract va dua tien vao bien tam
	contract := Contract{
		DocType:      "contract",
		ID:           contractId,
		ApartmentID:  apartmentId,
		GuestID:      guestId,
		StartDate:    startDate,
		EndDate:      endDate,
		EscrowAmount: totalPrice, //tien bi khoa o day
		Status:       "CREATED",
	}
	//3. cap nhat trang thai can ho
	apartment.Status = "BOOKED"

	//luu xuong so cai
	guestJSON, _ := json.Marshal(guest)
	contractJSON, _ := json.Marshal(contract)
	apartmentJSON, _ := json.Marshal(apartment)

	ctx.GetStub().PutState(guestId, guestJSON)
	ctx.GetStub().PutState(contractId, contractJSON)
	ctx.GetStub().PutState(apartmentId, apartmentJSON)

	return nil
}

// cancel contract
func (s *SmartContract) CancelBooking(ctx contractapi.TransactionContextInterface, contractId string) error {
	//tim kiem contract
	contractBytes, _ := ctx.GetStub().GetState(contractId)
	var contract Contract
	json.Unmarshal(contractBytes, &contract)

	//sua trang thai hop dong
	contract.Status = "CANCELED"
	//tim kiem va sua trang thai can ho
	apartmentBytes, _ := ctx.GetStub().GetState(contract.ApartmentID)
	var apartment Apartment
	json.Unmarshal(apartmentBytes, &apartment)
	apartment.Status = "AVAILABLE"

	//luu xuong so cai
	contractJSON, _ := json.Marshal(contract)
	apartmentJSON, _ := json.Marshal(apartment)
	ctx.GetStub().PutState(contractId, contractJSON)
	ctx.GetStub().PutState(contract.ApartmentID, apartmentJSON)

	return nil

}

// checkin
func (s *SmartContract) CheckIn(ctx contractapi.TransactionContextInterface, contractId string, newPasswordHash string) error {
	//tim kiem du lieu
	contractBytes, _ := ctx.GetStub().GetState(contractId)
	var contract Contract
	json.Unmarshal(contractBytes, &contract)

	apartmentBytes, _ := ctx.GetStub().GetState(contract.ApartmentID)
	var apartment Apartment
	json.Unmarshal(apartmentBytes, &apartment)

	//kiem tra thoi gian (Lấy giờ từ Transaction Timestamp)
	txTime, _ := ctx.GetStub().GetTxTimestamp()
	currentTime := txTime.Seconds

	// Logic If/Else chặn mở cửa sớm
	if currentTime < contract.StartDate {
		return fmt.Errorf("Chưa đến giờ Check-in! Hiện tại: %d, Giờ vào: %d", currentTime, contract.StartDate)
	}
	// cap nhat thong tin
	apartment.PasswordHash = newPasswordHash
	apartment.Status = "OCCUPIED"
	contract.Status = "ACTIVE"

	//luu xuong so cai
	apartmentJSON, _ := json.Marshal(apartment)
	contractJSON, _ := json.Marshal(contract)
	ctx.GetStub().PutState(contract.ApartmentID, apartmentJSON)
	ctx.GetStub().PutState(contractId, contractJSON)

	return nil

}

// checkout
func (s *SmartContract) CheckOut(ctx contractapi.TransactionContextInterface, contractId string, resetPasswordHash string) error {
	//tim kiem contract
	contractBytes, _ := ctx.GetStub().GetState(contractId)
	var contract Contract
	json.Unmarshal(contractBytes, &contract)
	// Kiểm tra xem tiền còn trong "Biến tạm" không?
	if contract.EscrowAmount <= 0 {
		return fmt.Errorf("Giao dịch này đã thanh toán xong hoặc không có tiền")
	}

	//tim kiem apartment
	apartmentBytes, _ := ctx.GetStub().GetState(contract.ApartmentID)
	var apartment Apartment
	json.Unmarshal(apartmentBytes, &apartment)
	//tim kiem owner
	ownerBytes, _ := ctx.GetStub().GetState(apartment.OwnerID)
	var owner User
	json.Unmarshal(ownerBytes, &owner)

	//co the check som hon

	//giai phonng tien
	////1.lay tien tu bien tam cong vao owner
	amountToRelease := contract.EscrowAmount
	owner.Balance = owner.Balance + amountToRelease
	////2. xoa tien trong bien tam
	contract.EscrowAmount = 0
	contract.Status = "COMPLETED"

	//doi mat khau va trang thai can ho
	apartment.PasswordHash = resetPasswordHash
	apartment.Status = "AVAILABLE"

	//luu xuong so cai ledger
	ownerJSON, _ := json.Marshal(owner)
	contractJSON, _ := json.Marshal(contract)
	apartmentJSON, _ := json.Marshal(apartment)
	ctx.GetStub().PutState(apartment.OwnerID, ownerJSON)
	ctx.GetStub().PutState(contractId, contractJSON)
	ctx.GetStub().PutState(contract.ApartmentID, apartmentJSON)
	return nil

}

// deposit
func (s *SmartContract) Deposit(ctx contractapi.TransactionContextInterface, userId string, amount int) error {
	//tim user
	userBytes, _ := ctx.GetStub().GetState(userId)
	var user User
	json.Unmarshal(userBytes, &user)

	//cong tien
	user.Balance = user.Balance + amount

	//luu xuong so cai
	userJSON, _ := json.Marshal(user)
	ctx.GetStub().PutState(userId, userJSON)
	return nil
}

// requestWithdraw
func (s *SmartContract) RequestWithDraw(ctx contractapi.TransactionContextInterface, userId string, amount int) error {
	//tim user
	userBytes, _ := ctx.GetStub().GetState(userId)
	var user User
	json.Unmarshal(userBytes, &user)

	//tru balance, cong vao lockedBalance
	user.Balance = user.Balance - amount
	user.LockedBalance = user.LockedBalance + amount

	//luu xuong so cai
	userJSON, _ := json.Marshal(user)
	ctx.GetStub().PutState(userId, userJSON)
	return nil
}

// finishWithDraw
func (s *SmartContract) FinishWithDraw(ctx contractapi.TransactionContextInterface, userId string, amount int) error {
	//tim user
	userBytes, _ := ctx.GetStub().GetState(userId)
	var user User
	json.Unmarshal(userBytes, &user)

	//tru lockedbalance (xoa khoi he thong)
	user.LockedBalance = user.LockedBalance - amount

	//luu xuong so cai
	userJSON, _ := json.Marshal(user)
	ctx.GetStub().PutState(userId, userJSON)
	return nil
}

// verifyAccess
func (s *SmartContract) VerifyAccess(ctx contractapi.TransactionContextInterface, apartmentId string, passwordHash string) (bool, error) {
	//tim kiem can ho
	apartmentBytes, err := ctx.GetStub().GetState(apartmentId)
	if err != nil {
		return false, fmt.Errorf("Không tìm thấy căn hộ")
	}
	if apartmentBytes == nil {
		return false, fmt.Errorf("Căn hộ không tồn tại")
	}
	var apartment Apartment
	err = json.Unmarshal(apartmentBytes, &apartment)
	if err != nil {
		return false, err
	}

	//so sanh 2 cai hash
	if passwordHash == apartment.PasswordHash {
		return true, nil
	}
	return false, nil
}

// ===================cac ham helper=============
// GetAllContracts
func (s *SmartContract) GetAllContracts(ctx contractapi.TransactionContextInterface) ([]*Contract, error) {
	// Thay vì dùng QueryString, ta dùng GetStateByRange("", "") để lấy TẤT CẢ dữ liệu trong Ledger
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()
	var contracts []*Contract
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// 1. Unmarshal vào một Map tạm để check docType
		var dataMap map[string]interface{}
		err = json.Unmarshal(queryResponse.Value, &dataMap)
		if err != nil {
			continue // Nếu lỗi format thì bỏ qua
		}
		// 2. Chỉ lấy nếu docType là "booking"
		if val, ok := dataMap["docType"]; ok && val == "contract" {
			var contract Contract
			json.Unmarshal(queryResponse.Value, &contract)
			contracts = append(contracts, &contract)
		}
	}
	return contracts, nil
}

// getcontractbyid
func (s *SmartContract) GetContractById(ctx contractapi.TransactionContextInterface, contractId string) (*Contract, error) {
	bytes, err := ctx.GetStub().GetState(contractId)
	if err != nil {
		return nil, err
	}
	if bytes == nil {
		return nil, fmt.Errorf("Contract with ID %s does not exist", contractId)
	}
	var contract Contract
	err = json.Unmarshal(bytes, &contract)
	if err != nil {
		return nil, err
	}
	return &contract, nil
}

// getUserById
func (s *SmartContract) GetUserById(ctx contractapi.TransactionContextInterface, id string) (*User, error) {
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
func (s *SmartContract) UpdateUserById(ctx contractapi.TransactionContextInterface, userId string, fullName string, status string, role string) (*User, error) {
	user, err := s.GetUserById(ctx, userId)
	if err != nil {
		return nil, err
	}

	user.FullName = fullName
	user.Status = status
	user.Role = role

	//luu xuong so cai
	userJSON, err := json.Marshal(user)
	if err != nil {
		return nil, err
	}

	if err := ctx.GetStub().PutState(userId, userJSON); err != nil {
		return nil, err
	}

	return user, nil
}

// getApartmentById
func (s *SmartContract) GetApartmentById(ctx contractapi.TransactionContextInterface, apartmentId string) (*Apartment, error) {
	bytes, err := ctx.GetStub().GetState(apartmentId)
	if err != nil {
		return nil, err
	}
	if bytes == nil {
		return nil, fmt.Errorf("Apartment with ID %s does not exist", apartmentId)
	}
	var apartment Apartment
	err = json.Unmarshal(bytes, &apartment)
	if err != nil {
		return nil, err
	}
	return &apartment, nil
}
