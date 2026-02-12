package chaincode

import (
	"encoding/json"
	"errors"
	"testing"

	"github.com/hyperledger/fabric-chaincode-go/v2/pkg/cid"
	"github.com/hyperledger/fabric-chaincode-go/v2/shim"
	"github.com/hyperledger/fabric-protos-go-apiv2/ledger/queryresult"
	"github.com/hyperledger/fabric-protos-go-apiv2/peer"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ==================== MOCK CLASSES ====================

// MockStub is a mock implementation of ChaincodeStubInterface
type MockStub struct {
	mock.Mock
	State map[string][]byte
}

func NewMockStub() *MockStub {
	return &MockStub{
		State: make(map[string][]byte),
	}
}

func (m *MockStub) GetState(key string) ([]byte, error) {
	args := m.Called(key)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]byte), args.Error(1)
}

func (m *MockStub) PutState(key string, value []byte) error {
	args := m.Called(key, value)
	return args.Error(0)
}

func (m *MockStub) DelState(key string) error {
	args := m.Called(key)
	return args.Error(0)
}

func (m *MockStub) GetTxTimestamp() (*timestamppb.Timestamp, error) {
	args := m.Called()
	return args.Get(0).(*timestamppb.Timestamp), args.Error(1)
}

func (m *MockStub) GetStateByRange(startKey, endKey string) (shim.StateQueryIteratorInterface, error) {
	args := m.Called(startKey, endKey)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(shim.StateQueryIteratorInterface), args.Error(1)
}

// Stub methods that are not used but required by interface
func (m *MockStub) GetArgs() [][]byte                            { return nil }
func (m *MockStub) GetStringArgs() []string                      { return nil }
func (m *MockStub) GetFunctionAndParameters() (string, []string) { return "", nil }
func (m *MockStub) GetArgsSlice() ([]byte, error)                { return nil, nil }
func (m *MockStub) GetTxID() string                              { return "test-tx-id" }
func (m *MockStub) GetChannelID() string                         { return "test-channel" }
func (m *MockStub) InvokeChaincode(name string, args [][]byte, channel string) *peer.Response {
	return &peer.Response{Status: 200}
}
func (m *MockStub) SetStateValidationParameter(string, []byte) error   { return nil }
func (m *MockStub) GetStateValidationParameter(string) ([]byte, error) { return nil, nil }
func (m *MockStub) GetStateByPartialCompositeKey(string, []string) (shim.StateQueryIteratorInterface, error) {
	return nil, nil
}
func (m *MockStub) CreateCompositeKey(string, []string) (string, error)             { return "", nil }
func (m *MockStub) SplitCompositeKey(string) (string, []string, error)              { return "", nil, nil }
func (m *MockStub) GetQueryResult(string) (shim.StateQueryIteratorInterface, error) { return nil, nil }
func (m *MockStub) GetQueryResultWithPagination(string, int32, string) (shim.StateQueryIteratorInterface, *peer.QueryResponseMetadata, error) {
	return nil, nil, nil
}
func (m *MockStub) GetHistoryForKey(string) (shim.HistoryQueryIteratorInterface, error) {
	return nil, nil
}
func (m *MockStub) GetPrivateData(string, string) ([]byte, error)                    { return nil, nil }
func (m *MockStub) GetPrivateDataHash(string, string) ([]byte, error)                { return nil, nil }
func (m *MockStub) PutPrivateData(string, string, []byte) error                      { return nil }
func (m *MockStub) DelPrivateData(string, string) error                              { return nil }
func (m *MockStub) SetPrivateDataValidationParameter(string, string, []byte) error   { return nil }
func (m *MockStub) GetPrivateDataValidationParameter(string, string) ([]byte, error) { return nil, nil }
func (m *MockStub) GetPrivateDataByRange(string, string, string) (shim.StateQueryIteratorInterface, error) {
	return nil, nil
}
func (m *MockStub) GetPrivateDataByPartialCompositeKey(string, string, []string) (shim.StateQueryIteratorInterface, error) {
	return nil, nil
}
func (m *MockStub) GetPrivateDataQueryResult(string, string) (shim.StateQueryIteratorInterface, error) {
	return nil, nil
}
func (m *MockStub) GetCreator() ([]byte, error)                      { return nil, nil }
func (m *MockStub) GetTransient() (map[string][]byte, error)         { return nil, nil }
func (m *MockStub) GetBinding() ([]byte, error)                      { return nil, nil }
func (m *MockStub) GetDecorations() map[string][]byte                { return nil }
func (m *MockStub) GetSignedProposal() (*peer.SignedProposal, error) { return nil, nil }
func (m *MockStub) SetEvent(string, []byte) error                    { return nil }
func (m *MockStub) GetStateByRangeWithPagination(string, string, int32, string) (shim.StateQueryIteratorInterface, *peer.QueryResponseMetadata, error) {
	return nil, nil, nil
}
func (m *MockStub) GetStateByPartialCompositeKeyWithPagination(string, []string, int32, string) (shim.StateQueryIteratorInterface, *peer.QueryResponseMetadata, error) {
	return nil, nil, nil
}
func (m *MockStub) PurgePrivateData(collection string, key string) error { return nil }

// MockTransactionContext is a mock implementation of TransactionContextInterface
type MockTransactionContext struct {
	mock.Mock
	stub *MockStub
}

func (m *MockTransactionContext) GetStub() shim.ChaincodeStubInterface {
	return m.stub
}

func (m *MockTransactionContext) GetClientIdentity() cid.ClientIdentity {
	return nil
}

// MockIterator for testing GetAllContracts
type MockIterator struct {
	Records      []*queryresult.KV
	CurrentIndex int
}

func (m *MockIterator) HasNext() bool {
	return m.CurrentIndex < len(m.Records)
}

func (m *MockIterator) Next() (*queryresult.KV, error) {
	if m.CurrentIndex >= len(m.Records) {
		return nil, errors.New("no more items")
	}
	result := m.Records[m.CurrentIndex]
	m.CurrentIndex++
	return result, nil
}

func (m *MockIterator) Close() error {
	return nil
}

// ==================== TEST FUNCTIONS ====================

// Test CreateUser
func TestCreateUser_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	// Mock: user không tồn tại
	stub.On("GetState", "user1").Return(nil, nil)
	stub.On("PutState", "user1", mock.Anything).Return(nil)

	err := contract.CreateUser(ctx, "user1", "Nguyen Van A", 1000, "GUEST")

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

func TestCreateUser_AlreadyExists(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	existingUser := User{ID: "user1", FullName: "Existing User"}
	userJSON, _ := json.Marshal(existingUser)
	stub.On("GetState", "user1").Return(userJSON, nil)

	err := contract.CreateUser(ctx, "user1", "Nguyen Van A", 1000, "GUEST")

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "da ton tai")
}

func TestCreateUser_GetStateError(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	stub.On("GetState", "user1").Return(nil, errors.New("database error"))

	err := contract.CreateUser(ctx, "user1", "Nguyen Van A", 1000, "GUEST")

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "Loi kiem tra user")
}

// Test CreateApartment
func TestCreateApartment_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	stub.On("PutState", "apt1", mock.Anything).Return(nil)

	err := contract.CreateApartment(ctx, "apt1", "owner1", 500000)

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

// Test UpdatePasswordApartment
func TestUpdatePasswordApartment_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	apartment := Apartment{ID: "apt1", OwnerID: "owner1", Status: "AVAILABLE"}
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "apt1").Return(aptJSON, nil)
	stub.On("PutState", "apt1", mock.Anything).Return(nil)

	err := contract.UpdatePasswordApartment(ctx, "apt1", "newHashedPassword123")

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

func TestUpdatePasswordApartment_NotFound(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	stub.On("GetState", "apt1").Return(nil, nil)

	err := contract.UpdatePasswordApartment(ctx, "apt1", "newHashedPassword123")

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "Khong tim thay can ho")
}

// Test BookApartment
func TestBookApartment_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	apartment := Apartment{ID: "apt1", OwnerID: "owner1", DailyRate: 100000, Status: "AVAILABLE"}
	guest := User{ID: "guest1", FullName: "Guest User", Balance: 1000000, Role: "GUEST"}

	aptJSON, _ := json.Marshal(apartment)
	guestJSON, _ := json.Marshal(guest)

	stub.On("GetState", "apt1").Return(aptJSON, nil)
	stub.On("GetState", "guest1").Return(guestJSON, nil)
	stub.On("PutState", "guest1", mock.Anything).Return(nil)
	stub.On("PutState", "contract1", mock.Anything).Return(nil)
	stub.On("PutState", "apt1", mock.Anything).Return(nil)

	// Book for 3 days: 100000 * 3 = 300000
	startDate := int64(1739318400) // Feb 12, 2025
	endDate := int64(1739577600)   // Feb 15, 2025 (3 days later)

	err := contract.BookApartment(ctx, "contract1", "apt1", "guest1", startDate, endDate)

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

func TestBookApartment_ApartmentNotAvailable(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	apartment := Apartment{ID: "apt1", OwnerID: "owner1", DailyRate: 100000, Status: "BOOKED"}
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "apt1").Return(aptJSON, nil)

	err := contract.BookApartment(ctx, "contract1", "apt1", "guest1", 1739318400, 1739577600)

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "khong san sang")
}

func TestBookApartment_InvalidDays(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	contract := SmartContract{}

	apartment := Apartment{ID: "apt1", OwnerID: "owner1", DailyRate: 100000, Status: "AVAILABLE"}
	guest := User{ID: "guest1", FullName: "Guest User", Balance: 1000000, Role: "GUEST"}

	aptJSON, _ := json.Marshal(apartment)
	guestJSON, _ := json.Marshal(guest)

	stub.On("GetState", "apt1").Return(aptJSON, nil)
	stub.On("GetState", "guest1").Return(guestJSON, nil)

	// End date before start date
	err := contract.BookApartment(ctx, "contract1", "apt1", "guest1", 1739577600, 1739318400)

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "khong hop le")
}

// Test CancelBooking
func TestCancelBooking_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	contract := Contract{ID: "contract1", ApartmentID: "apt1", Status: "CREATED"}
	apartment := Apartment{ID: "apt1", Status: "BOOKED"}

	contractJSON, _ := json.Marshal(contract)
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "contract1").Return(contractJSON, nil)
	stub.On("GetState", "apt1").Return(aptJSON, nil)
	stub.On("PutState", "contract1", mock.Anything).Return(nil)
	stub.On("PutState", "apt1", mock.Anything).Return(nil)

	err := sc.CancelBooking(ctx, "contract1")

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

// Test CheckIn
func TestCheckIn_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	startDate := int64(1739318400)
	contract := Contract{ID: "contract1", ApartmentID: "apt1", StartDate: startDate, Status: "CREATED"}
	apartment := Apartment{ID: "apt1", Status: "BOOKED"}

	contractJSON, _ := json.Marshal(contract)
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "contract1").Return(contractJSON, nil)
	stub.On("GetState", "apt1").Return(aptJSON, nil)
	stub.On("GetTxTimestamp").Return(&timestamppb.Timestamp{Seconds: startDate + 3600}, nil) // 1 hour after start
	stub.On("PutState", "apt1", mock.Anything).Return(nil)
	stub.On("PutState", "contract1", mock.Anything).Return(nil)

	err := sc.CheckIn(ctx, "contract1", "newPassword123")

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

func TestCheckIn_TooEarly(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	startDate := int64(1739318400)
	contract := Contract{ID: "contract1", ApartmentID: "apt1", StartDate: startDate, Status: "CREATED"}
	apartment := Apartment{ID: "apt1", Status: "BOOKED"}

	contractJSON, _ := json.Marshal(contract)
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "contract1").Return(contractJSON, nil)
	stub.On("GetState", "apt1").Return(aptJSON, nil)
	stub.On("GetTxTimestamp").Return(&timestamppb.Timestamp{Seconds: startDate - 86400}, nil) // 1 day before

	err := sc.CheckIn(ctx, "contract1", "newPassword123")

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "Chưa đến giờ Check-in")
}

// Test CheckOut
func TestCheckOut_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	contract := Contract{ID: "contract1", ApartmentID: "apt1", EscrowAmount: 300000, Status: "ACTIVE"}
	apartment := Apartment{ID: "apt1", OwnerID: "owner1", Status: "OCCUPIED"}
	owner := User{ID: "owner1", Balance: 500000, Role: "OWNER"}

	contractJSON, _ := json.Marshal(contract)
	aptJSON, _ := json.Marshal(apartment)
	ownerJSON, _ := json.Marshal(owner)

	stub.On("GetState", "contract1").Return(contractJSON, nil)
	stub.On("GetState", "apt1").Return(aptJSON, nil)
	stub.On("GetState", "owner1").Return(ownerJSON, nil)
	stub.On("PutState", "owner1", mock.Anything).Return(nil)
	stub.On("PutState", "contract1", mock.Anything).Return(nil)
	stub.On("PutState", "apt1", mock.Anything).Return(nil)

	err := sc.CheckOut(ctx, "contract1", "resetPassword456")

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

func TestCheckOut_AlreadyPaid(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	contract := Contract{ID: "contract1", ApartmentID: "apt1", EscrowAmount: 0, Status: "COMPLETED"}
	contractJSON, _ := json.Marshal(contract)

	stub.On("GetState", "contract1").Return(contractJSON, nil)

	err := sc.CheckOut(ctx, "contract1", "resetPassword456")

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "đã thanh toán xong")
}

// Test Deposit
func TestDeposit_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	user := User{ID: "user1", Balance: 500000}
	userJSON, _ := json.Marshal(user)

	stub.On("GetState", "user1").Return(userJSON, nil)
	stub.On("PutState", "user1", mock.Anything).Return(nil)

	err := sc.Deposit(ctx, "user1", 200000)

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

// Test RequestWithDraw
func TestRequestWithDraw_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	user := User{ID: "user1", Balance: 500000, LockedBalance: 0}
	userJSON, _ := json.Marshal(user)

	stub.On("GetState", "user1").Return(userJSON, nil)
	stub.On("PutState", "user1", mock.Anything).Return(nil)

	err := sc.RequestWithDraw(ctx, "user1", 100000)

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

// Test FinishWithDraw
func TestFinishWithDraw_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	user := User{ID: "user1", Balance: 400000, LockedBalance: 100000}
	userJSON, _ := json.Marshal(user)

	stub.On("GetState", "user1").Return(userJSON, nil)
	stub.On("PutState", "user1", mock.Anything).Return(nil)

	err := sc.FinishWithDraw(ctx, "user1", 100000)

	assert.NoError(t, err)
	stub.AssertExpectations(t)
}

// Test VerifyAccess
func TestVerifyAccess_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	apartment := Apartment{ID: "apt1", PasswordHash: "correctHash123"}
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "apt1").Return(aptJSON, nil)

	result, err := sc.VerifyAccess(ctx, "apt1", "correctHash123")

	assert.NoError(t, err)
	assert.True(t, result)
}

func TestVerifyAccess_WrongPassword(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	apartment := Apartment{ID: "apt1", PasswordHash: "correctHash123"}
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "apt1").Return(aptJSON, nil)

	result, err := sc.VerifyAccess(ctx, "apt1", "wrongHash456")

	assert.NoError(t, err)
	assert.False(t, result)
}

func TestVerifyAccess_ApartmentNotFound(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	stub.On("GetState", "apt1").Return(nil, nil)

	result, err := sc.VerifyAccess(ctx, "apt1", "anyHash")

	assert.Error(t, err)
	assert.False(t, result)
	assert.Contains(t, err.Error(), "không tồn tại")
}

// Test GetUserById
func TestGetUserById_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	user := User{ID: "user1", FullName: "Nguyen Van A", Balance: 1000000}
	userJSON, _ := json.Marshal(user)

	stub.On("GetState", "user1").Return(userJSON, nil)

	result, err := sc.GetUserById(ctx, "user1")

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "user1", result.ID)
	assert.Equal(t, "Nguyen Van A", result.FullName)
}

func TestGetUserById_NotFound(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	stub.On("GetState", "user1").Return(nil, nil)

	result, err := sc.GetUserById(ctx, "user1")

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "does not exist")
}

// Test UpdateUserById
func TestUpdateUserById_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	user := User{ID: "user1", FullName: "Old Name", Status: "PENDING", Role: "GUEST"}
	userJSON, _ := json.Marshal(user)

	stub.On("GetState", "user1").Return(userJSON, nil)
	stub.On("PutState", "user1", mock.Anything).Return(nil)

	result, err := sc.UpdateUserById(ctx, "user1", "New Name", "ACTIVE", "OWNER")

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "New Name", result.FullName)
	assert.Equal(t, "ACTIVE", result.Status)
	assert.Equal(t, "OWNER", result.Role)
}

// Test GetApartmentById
func TestGetApartmentById_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	apartment := Apartment{ID: "apt1", OwnerID: "owner1", DailyRate: 500000, Status: "AVAILABLE"}
	aptJSON, _ := json.Marshal(apartment)

	stub.On("GetState", "apt1").Return(aptJSON, nil)

	result, err := sc.GetApartmentById(ctx, "apt1")

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "apt1", result.ID)
	assert.Equal(t, "owner1", result.OwnerID)
	assert.Equal(t, 500000, result.DailyRate)
}

func TestGetApartmentById_NotFound(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	stub.On("GetState", "apt1").Return(nil, nil)

	result, err := sc.GetApartmentById(ctx, "apt1")

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "does not exist")
}

// Test GetAllContracts
func TestGetAllContracts_Success(t *testing.T) {
	stub := NewMockStub()
	ctx := &MockTransactionContext{stub: stub}
	sc := SmartContract{}

	contract1 := Contract{DocType: "contract", ID: "c1", ApartmentID: "apt1", Status: "ACTIVE"}
	contract2 := Contract{DocType: "contract", ID: "c2", ApartmentID: "apt2", Status: "COMPLETED"}
	user := User{DocType: "user", ID: "user1"} // Should be filtered out

	c1JSON, _ := json.Marshal(contract1)
	c2JSON, _ := json.Marshal(contract2)
	userJSON, _ := json.Marshal(user)

	iterator := &MockIterator{
		Records: []*queryresult.KV{
			{Key: "c1", Value: c1JSON},
			{Key: "c2", Value: c2JSON},
			{Key: "user1", Value: userJSON},
		},
	}

	stub.On("GetStateByRange", "", "").Return(iterator, nil)

	result, err := sc.GetAllContracts(ctx)

	assert.NoError(t, err)
	assert.Len(t, result, 2)
	assert.Equal(t, "c1", result[0].ID)
	assert.Equal(t, "c2", result[1].ID)
}
