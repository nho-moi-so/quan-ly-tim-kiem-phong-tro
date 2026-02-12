# Smart Contract API Documentation

This document provides a complete API reference for the Hyperledger Fabric chaincode that manages apartment rental operations. Use this guide to implement server-side integration with the blockchain.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Data Structures](#data-structures)
3. [API Reference](#api-reference)
4. [Business Flows](#business-flows)
5. [Server Integration](#server-integration)
6. [Error Handling](#error-handling)

---

## Architecture Overview

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Mobile App    │      │   Admin Panel    │      │   IoT Device    │
│   (Flutter)     │      │   (Next.js)      │      │   (ESP32)       │
└────────┬────────┘      └────────┬─────────┘      └────────┬────────┘
         │                        │                         │
         └────────────────────────┼─────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────┐
                    │      REST API Server    │
                    │    (Node.js / Go)       │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │   Fabric Gateway SDK    │
                    │  (fabric-gateway)       │
                    └────────────┬────────────┘
                                 │
                                 ▼
         ┌───────────────────────────────────────────────┐
         │           Hyperledger Fabric Network          │
         │  ┌─────────────────────────────────────────┐  │
         │  │           Smart Contract                │  │
         │  │  - User Management                      │  │
         │  │  - Apartment Management                 │  │
         │  │  - Booking & Payment (Escrow)          │  │
         │  │  - Access Control (IoT)                │  │
         │  └─────────────────────────────────────────┘  │
         └───────────────────────────────────────────────┘
```

---

## Data Structures

### User

Represents a system user (Guest, Owner, or Admin).

```json
{
  "docType": "user",
  "id": "user_uuid_123",
  "FullName": "Nguyen Van A",
  "Balance": 1000000,
  "LockedBalance": 0,
  "Status": "ACTIVE",
  "Role": "GUEST"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `docType` | string | Always `"user"` - used for filtering in queries |
| `id` | string | Unique identifier (UUID recommended) |
| `FullName` | string | User's display name |
| `Balance` | int | Available balance (in VND or smallest currency unit) |
| `LockedBalance` | int | Balance locked during withdrawal process |
| `Status` | string | `"ACTIVE"`, `"PENDING"`, `"LOCKED"`, `"APPROVED"` |
| `Role` | string | `"ADMIN"`, `"OWNER"`, `"GUEST"` |

### Apartment

Represents a rental property.

```json
{
  "docType": "apartment",
  "id": "apt_uuid_456",
  "OwnerID": "user_uuid_owner",
  "DailyRate": 500000,
  "Status": "AVAILABLE",
  "PasswordHash": "sha256_hashed_password"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `docType` | string | Always `"apartment"` |
| `id` | string | Unique identifier |
| `OwnerID` | string | Reference to owner's User ID |
| `DailyRate` | int | Price per day (in VND) |
| `Status` | string | `"AVAILABLE"`, `"BOOKED"`, `"OCCUPIED"` |
| `PasswordHash` | string | Hashed password for IoT door access |

### Contract (Booking)

Represents a rental agreement between guest and apartment.

```json
{
  "docType": "contract",
  "id": "contract_uuid_789",
  "ApartmentID": "apt_uuid_456",
  "GuestID": "user_uuid_123",
  "StartDate": 1739318400,
  "EndDate": 1739577600,
  "EscrowAmount": 1500000,
  "Status": "CREATED"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `docType` | string | Always `"contract"` |
| `id` | string | Unique identifier |
| `ApartmentID` | string | Reference to Apartment ID |
| `GuestID` | string | Reference to Guest's User ID |
| `StartDate` | int64 | Unix timestamp - check-in time |
| `EndDate` | int64 | Unix timestamp - check-out time |
| `EscrowAmount` | int | Locked payment amount (released on checkout) |
| `Status` | string | `"CREATED"`, `"ACTIVE"`, `"COMPLETED"`, `"CANCELED"` |

---

## API Reference

### User Management

#### CreateUser

Creates a new user in the system.

```
Function: CreateUser
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Unique user ID |
| `fullName` | string | Yes | User's full name |
| `balance` | int | Yes | Initial balance |
| `role` | string | Yes | `"ADMIN"`, `"OWNER"`, or `"GUEST"` |

**Returns:** `error` (nil on success)

**Errors:**
- `"User voi ID {id} da ton tai"` - User already exists
- `"Loi kiem tra user: {error}"` - Database error

**Server Example (Node.js):**
```javascript
const result = await contract.submitTransaction(
  'CreateUser',
  'user_001',           // id
  'Nguyen Van A',       // fullName
  '1000000',            // balance (as string)
  'GUEST'               // role
);
```

---

#### GetUserById

Retrieves a user by their ID.

```
Function: GetUserById
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | User ID to fetch |

**Returns:** `User` object or `error`

**Server Example:**
```javascript
const userBytes = await contract.evaluateTransaction('GetUserById', 'user_001');
const user = JSON.parse(userBytes.toString());
console.log(user.FullName, user.Balance);
```

---

#### UpdateUserById

Updates user information (name, status, role).

```
Function: UpdateUserById
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userId` | string | Yes | User ID to update |
| `fullName` | string | Yes | New full name |
| `status` | string | Yes | New status |
| `role` | string | Yes | New role |

**Returns:** Updated `User` object or `error`

**Note:** This does NOT update balance. Use `Deposit` for balance changes.

---

#### Deposit

Adds funds to a user's balance.

```
Function: Deposit
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userId` | string | Yes | User ID |
| `amount` | int | Yes | Amount to add |

**Returns:** `error` (nil on success)

**Business Logic:**
```
user.Balance = user.Balance + amount
```

**Server Example:**
```javascript
// After payment gateway confirms payment
await contract.submitTransaction('Deposit', 'user_001', '500000');
```

---

#### RequestWithDraw

Initiates a withdrawal request (locks funds).

```
Function: RequestWithDraw
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userId` | string | Yes | User ID |
| `amount` | int | Yes | Amount to withdraw |

**Returns:** `error` (nil on success)

**Business Logic:**
```
user.Balance = user.Balance - amount
user.LockedBalance = user.LockedBalance + amount
```

**Flow:**
1. User requests withdrawal → `RequestWithDraw`
2. Admin processes bank transfer
3. Admin confirms → `FinishWithDraw`

---

#### FinishWithDraw

Completes a withdrawal (removes locked funds from system).

```
Function: FinishWithDraw
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userId` | string | Yes | User ID |
| `amount` | int | Yes | Amount to finalize |

**Returns:** `error` (nil on success)

**Business Logic:**
```
user.LockedBalance = user.LockedBalance - amount
// Money has been transferred externally
```

---

### Apartment Management

#### CreateApartment

Creates a new apartment listing.

```
Function: CreateApartment
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Unique apartment ID |
| `ownerId` | string | Yes | Owner's user ID |
| `dailyRate` | int | Yes | Price per day |

**Returns:** `error` (nil on success)

**Note:** Apartment is created with `Status: "AVAILABLE"` and empty `PasswordHash`.

---

#### GetApartmentById

Retrieves apartment details.

```
Function: GetApartmentById
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apartmentId` | string | Yes | Apartment ID |

**Returns:** `Apartment` object or `error`

**Security Note:** The `PasswordHash` is included in response. Your server should NOT expose this to clients.

---

#### UpdatePasswordApartment

Updates the door access password for an apartment.

```
Function: UpdatePasswordApartment
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apartmentID` | string | Yes | Apartment ID |
| `passwordHash` | string | Yes | New hashed password |

**Returns:** `error` (nil on success)

**Important:** Always hash passwords before storing:
```javascript
const crypto = require('crypto');
const passwordHash = crypto.createHash('sha256')
  .update(plainPassword)
  .digest('hex');

await contract.submitTransaction('UpdatePasswordApartment', 'apt_001', passwordHash);
```

---

#### VerifyAccess

Verifies if a password hash matches the apartment's stored hash (for IoT door access).

```
Function: VerifyAccess
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apartmentId` | string | Yes | Apartment ID |
| `passwordHash` | string | Yes | Hash to verify |

**Returns:** `(bool, error)` - true if password matches

**IoT Integration Example:**
```javascript
// ESP32 sends hashed password to server
// Server verifies against blockchain

const result = await contract.evaluateTransaction(
  'VerifyAccess', 
  'apt_001', 
  receivedPasswordHash
);
const isValid = JSON.parse(result.toString());

if (isValid) {
  // Send unlock signal to IoT device
  mqtt.publish('apartment/apt_001/door', 'UNLOCK');
}
```

---

### Booking Management

#### BookApartment

Creates a new booking and locks payment in escrow.

```
Function: BookApartment
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contractId` | string | Yes | Unique contract ID |
| `apartmentId` | string | Yes | Apartment to book |
| `guestId` | string | Yes | Guest's user ID |
| `startDate` | int64 | Yes | Unix timestamp - check-in |
| `endDate` | int64 | Yes | Unix timestamp - check-out |

**Returns:** `error` (nil on success)

**Business Logic:**
```
1. Validate apartment status == "AVAILABLE"
2. Calculate: days = (endDate - startDate) / 86400
3. Calculate: totalPrice = apartment.DailyRate * days
4. Validate: guest.Balance >= totalPrice
5. Deduct: guest.Balance -= totalPrice
6. Create contract with EscrowAmount = totalPrice
7. Update: apartment.Status = "BOOKED"
```

**Errors:**
- `"Can ho khong san sang"` - Apartment not available
- `"So ngay thue khong hop le"` - Invalid date range (end <= start)

**Server Example:**
```javascript
const startDate = Math.floor(new Date('2026-02-15').getTime() / 1000);
const endDate = Math.floor(new Date('2026-02-18').getTime() / 1000);

await contract.submitTransaction(
  'BookApartment',
  'contract_001',
  'apt_001',
  'user_guest_001',
  startDate.toString(),
  endDate.toString()
);
```

---

#### CancelBooking

Cancels a booking and releases the apartment.

```
Function: CancelBooking
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contractId` | string | Yes | Contract ID to cancel |

**Returns:** `error` (nil on success)

**Business Logic:**
```
1. Set contract.Status = "CANCELED"
2. Set apartment.Status = "AVAILABLE"
```

**Note:** This implementation does NOT refund the escrow amount to the guest. You may want to add refund logic:
```go
// Suggested enhancement:
guest.Balance += contract.EscrowAmount
contract.EscrowAmount = 0
```

---

#### CheckIn

Activates a booking when guest arrives (updates door password).

```
Function: CheckIn
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contractId` | string | Yes | Contract ID |
| `newPasswordHash` | string | Yes | New door password hash |

**Returns:** `error` (nil on success)

**Business Logic:**
```
1. Get current blockchain time (transaction timestamp)
2. Validate: currentTime >= contract.StartDate
3. Set apartment.PasswordHash = newPasswordHash
4. Set apartment.Status = "OCCUPIED"
5. Set contract.Status = "ACTIVE"
```

**Errors:**
- `"Chưa đến giờ Check-in! Hiện tại: {current}, Giờ vào: {start}"` - Too early

**Time Validation:** Uses blockchain transaction timestamp, not client time. This prevents time manipulation.

---

#### CheckOut

Completes a booking, releases escrow to owner, and resets door password.

```
Function: CheckOut
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contractId` | string | Yes | Contract ID |
| `resetPasswordHash` | string | Yes | New door password (for security reset) |

**Returns:** `error` (nil on success)

**Business Logic:**
```
1. Validate: contract.EscrowAmount > 0
2. Transfer: owner.Balance += contract.EscrowAmount
3. Clear: contract.EscrowAmount = 0
4. Set: contract.Status = "COMPLETED"
5. Set: apartment.PasswordHash = resetPasswordHash
6. Set: apartment.Status = "AVAILABLE"
```

**Errors:**
- `"Giao dịch này đã thanh toán xong hoặc không có tiền"` - Already paid

**Important:** This is where the owner gets paid. The escrow system ensures:
- Guest can't cancel after check-in without losing money
- Owner only gets paid after service is delivered

---

### Query Functions

#### GetAllContracts

Retrieves all contracts from the ledger.

```
Function: GetAllContracts
```

**Parameters:** None

**Returns:** `[]*Contract` array or `error`

**Note:** This scans ALL data in the ledger and filters by `docType == "contract"`. For production, consider adding pagination or using CouchDB rich queries.

**Server Example:**
```javascript
const contractsBytes = await contract.evaluateTransaction('GetAllContracts');
const contracts = JSON.parse(contractsBytes.toString());

// Filter active contracts
const activeContracts = contracts.filter(c => c.Status === 'ACTIVE');
```

---

## Business Flows

### Complete Rental Flow

```
                    GUEST                           BLOCKCHAIN                         OWNER
                      │                                  │                               │
    ┌─────────────────┼──────────────────────────────────┼───────────────────────────────┤
    │ 1. BOOKING      │                                  │                               │
    │                 │                                  │                               │
    │   Deposit money ├──────► Deposit() ────────────────┤                               │
    │   (via payment) │        Balance += amount         │                               │
    │                 │                                  │                               │
    │   Select dates  ├──────► BookApartment() ──────────┤                               │
    │   & apartment   │        - Deduct guest balance    │                               │
    │                 │        - Create contract         │                               │
    │                 │        - Lock escrow             │                               │
    │                 │        - Set apt = BOOKED        │                               │
    ├─────────────────┼──────────────────────────────────┼───────────────────────────────┤
    │ 2. CHECK-IN     │                                  │                               │
    │                 │                                  │                               │
    │   Arrive at     ├──────► CheckIn() ────────────────┤                               │
    │   start time    │        - Verify time >= start    │                               │
    │                 │        - Set new door password   │                               │
    │                 │        - Set apt = OCCUPIED      │                               │
    │                 │        - Set contract = ACTIVE   │                               │
    │                 │                                  │                               │
    │   Enter door    ├──────► VerifyAccess() ───────────┤                               │
    │   password      │        - Compare hash            │                               │
    │   (via IoT)     │        - Return true/false       │                               │
    ├─────────────────┼──────────────────────────────────┼───────────────────────────────┤
    │ 3. CHECK-OUT    │                                  │                               │
    │                 │                                  │                               │
    │   Leave         ├──────► CheckOut() ───────────────┼──────► owner.Balance +=      │
    │   apartment     │        - Release escrow to owner │        escrowAmount           │
    │                 │        - Reset door password     │                               │
    │                 │        - Set apt = AVAILABLE     │                               │
    │                 │        - Set contract=COMPLETED  │                               │
    ├─────────────────┼──────────────────────────────────┼───────────────────────────────┤
    │ 4. WITHDRAWAL   │                                  │                               │
    │                 │                                  ├──────► RequestWithDraw()      │
    │                 │                                  │        Lock funds              │
    │                 │                                  │                               │
    │                 │                                  │        (Admin transfers $)    │
    │                 │                                  │                               │
    │                 │                                  ├──────► FinishWithDraw()       │
    │                 │                                  │        Remove from system     │
    └─────────────────┴──────────────────────────────────┴───────────────────────────────┘
```

### Status Transitions

#### Contract Status

```
           BookApartment()           CheckIn()              CheckOut()
CREATED ──────────────────► CREATED ──────────► ACTIVE ──────────────► COMPLETED
    │                                              │
    │        CancelBooking()                       │
    └──────────────────────► CANCELED ◄────────────┘
                             (optional)
```

#### Apartment Status

```
              BookApartment()              CheckIn()
AVAILABLE ──────────────────► BOOKED ────────────────► OCCUPIED
    ▲                            │                        │
    │      CancelBooking()       │                        │
    └────────────────────────────┘                        │
    │                                                     │
    │                     CheckOut()                      │
    └─────────────────────────────────────────────────────┘
```

---

## Server Integration

### Using Fabric Gateway SDK (Node.js)

```javascript
const { Gateway, Wallets } = require('@hyperledger/fabric-gateway');
const grpc = require('@grpc/grpc-js');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

class BlockchainService {
  constructor() {
    this.gateway = null;
    this.contract = null;
  }

  async connect() {
    // Load connection profile
    const ccpPath = path.resolve(__dirname, 'connection-org1.json');
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

    // Create identity
    const walletPath = path.join(__dirname, 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    const identity = await wallet.get('admin');

    // Connect gateway
    const client = new grpc.Client(
      ccp.peers['peer0.org1.example.com'].url,
      grpc.credentials.createInsecure()
    );

    this.gateway = connect({
      client,
      identity: {
        mspId: 'Org1MSP',
        credentials: identity.credentials.certificate,
      },
      signer: signers.newPrivateKeySigner(identity.credentials.privateKey),
    });

    const network = this.gateway.getNetwork('mychannel');
    this.contract = network.getContract('asset-transfer-basic');
  }

  // ============ USER OPERATIONS ============

  async createUser(id, fullName, balance, role) {
    await this.contract.submitTransaction(
      'CreateUser', id, fullName, balance.toString(), role
    );
    return { success: true, userId: id };
  }

  async getUser(id) {
    const result = await this.contract.evaluateTransaction('GetUserById', id);
    return JSON.parse(result.toString());
  }

  async deposit(userId, amount) {
    await this.contract.submitTransaction(
      'Deposit', userId, amount.toString()
    );
    return { success: true };
  }

  // ============ APARTMENT OPERATIONS ============

  async createApartment(id, ownerId, dailyRate) {
    await this.contract.submitTransaction(
      'CreateApartment', id, ownerId, dailyRate.toString()
    );
    return { success: true, apartmentId: id };
  }

  async getApartment(id) {
    const result = await this.contract.evaluateTransaction('GetApartmentById', id);
    const apartment = JSON.parse(result.toString());
    // Remove sensitive data before returning to client
    delete apartment.PasswordHash;
    return apartment;
  }

  async updateDoorPassword(apartmentId, plainPassword) {
    const passwordHash = crypto.createHash('sha256')
      .update(plainPassword)
      .digest('hex');
    
    await this.contract.submitTransaction(
      'UpdatePasswordApartment', apartmentId, passwordHash
    );
    return { success: true };
  }

  async verifyDoorAccess(apartmentId, plainPassword) {
    const passwordHash = crypto.createHash('sha256')
      .update(plainPassword)
      .digest('hex');
    
    const result = await this.contract.evaluateTransaction(
      'VerifyAccess', apartmentId, passwordHash
    );
    return JSON.parse(result.toString());
  }

  // ============ BOOKING OPERATIONS ============

  async bookApartment(contractId, apartmentId, guestId, startDate, endDate) {
    await this.contract.submitTransaction(
      'BookApartment',
      contractId,
      apartmentId,
      guestId,
      Math.floor(startDate.getTime() / 1000).toString(),
      Math.floor(endDate.getTime() / 1000).toString()
    );
    return { success: true, contractId };
  }

  async checkIn(contractId, newPassword) {
    const passwordHash = crypto.createHash('sha256')
      .update(newPassword)
      .digest('hex');
    
    await this.contract.submitTransaction('CheckIn', contractId, passwordHash);
    return { success: true, temporaryPassword: newPassword };
  }

  async checkOut(contractId) {
    // Generate random reset password
    const resetPassword = crypto.randomBytes(4).toString('hex');
    const passwordHash = crypto.createHash('sha256')
      .update(resetPassword)
      .digest('hex');
    
    await this.contract.submitTransaction('CheckOut', contractId, passwordHash);
    return { success: true };
  }

  async getAllContracts() {
    const result = await this.contract.evaluateTransaction('GetAllContracts');
    return JSON.parse(result.toString());
  }

  async disconnect() {
    if (this.gateway) {
      this.gateway.close();
    }
  }
}

module.exports = BlockchainService;
```

### Express API Example

```javascript
const express = require('express');
const BlockchainService = require('./blockchain-service');

const app = express();
app.use(express.json());

const blockchain = new BlockchainService();

// Initialize connection
blockchain.connect().then(() => {
  console.log('Connected to Fabric network');
});

// ============ USER ROUTES ============

app.post('/api/users', async (req, res) => {
  try {
    const { id, fullName, balance, role } = req.body;
    const result = await blockchain.createUser(id, fullName, balance, role);
    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await blockchain.getUser(req.params.id);
    res.json(user);
  } catch (error) {
    res.status(404).json({ error: error.message });
  }
});

app.post('/api/users/:id/deposit', async (req, res) => {
  try {
    const { amount } = req.body;
    await blockchain.deposit(req.params.id, amount);
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// ============ APARTMENT ROUTES ============

app.post('/api/apartments', async (req, res) => {
  try {
    const { id, ownerId, dailyRate } = req.body;
    const result = await blockchain.createApartment(id, ownerId, dailyRate);
    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.get('/api/apartments/:id', async (req, res) => {
  try {
    const apartment = await blockchain.getApartment(req.params.id);
    res.json(apartment);
  } catch (error) {
    res.status(404).json({ error: error.message });
  }
});

// ============ BOOKING ROUTES ============

app.post('/api/bookings', async (req, res) => {
  try {
    const { contractId, apartmentId, guestId, startDate, endDate } = req.body;
    const result = await blockchain.bookApartment(
      contractId, 
      apartmentId, 
      guestId,
      new Date(startDate),
      new Date(endDate)
    );
    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.post('/api/bookings/:id/checkin', async (req, res) => {
  try {
    const { password } = req.body;
    const result = await blockchain.checkIn(req.params.id, password);
    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.post('/api/bookings/:id/checkout', async (req, res) => {
  try {
    const result = await blockchain.checkOut(req.params.id);
    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// ============ IOT ROUTES ============

app.post('/api/iot/verify-access', async (req, res) => {
  try {
    const { apartmentId, password } = req.body;
    const isValid = await blockchain.verifyDoorAccess(apartmentId, password);
    res.json({ 
      valid: isValid,
      action: isValid ? 'UNLOCK' : 'DENY'
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

---

## Error Handling

### Chaincode Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `User voi ID {id} da ton tai` | Duplicate user ID | Generate unique UUID |
| `Loi kiem tra user` | Ledger read failed | Retry or check network |
| `Can ho khong san sang` | Apartment already booked | Show unavailable message |
| `So ngay thue khong hop le` | End date <= Start date | Validate dates client-side |
| `Chưa đến giờ Check-in` | Guest trying to check-in early | Wait until start time |
| `Giao dịch này đã thanh toán xong` | Double checkout attempt | Already completed |
| `Khong tim thay can ho` | Invalid apartment ID | Verify ID exists |
| `Căn hộ không tồn tại` | Apartment not found | Check apartment ID |
| `User with ID {id} does not exist` | User not found | Register user first |
| `Apartment with ID {id} does not exist` | Apartment not found | Create apartment first |

### Server-Side Error Handling

```javascript
try {
  await blockchain.checkIn(contractId, password);
} catch (error) {
  const message = error.message;
  
  if (message.includes('Chưa đến giờ Check-in')) {
    // Extract times from error message
    const match = message.match(/Hiện tại: (\d+), Giờ vào: (\d+)/);
    if (match) {
      const currentTime = new Date(parseInt(match[1]) * 1000);
      const startTime = new Date(parseInt(match[2]) * 1000);
      return res.status(400).json({
        error: 'TOO_EARLY',
        currentTime: currentTime.toISOString(),
        allowedTime: startTime.toISOString()
      });
    }
  }
  
  if (message.includes('khong san sang')) {
    return res.status(409).json({ error: 'APARTMENT_UNAVAILABLE' });
  }
  
  // Generic error
  return res.status(500).json({ error: message });
}
```

---

## Security Considerations

1. **Password Hashing**: Always hash passwords before sending to chaincode
2. **PasswordHash Exposure**: Never return `PasswordHash` field to clients
3. **Transaction vs Query**: Use `submitTransaction` for writes, `evaluateTransaction` for reads
4. **Time Validation**: Chaincode uses blockchain time, not client time
5. **Escrow Safety**: Funds are locked in contract, not directly transferred
6. **ID Generation**: Use UUIDs to prevent ID collision attacks

---

## Performance Tips

1. **Batch Reads**: Use `GetAllContracts` sparingly; implement caching
2. **Pagination**: For large datasets, implement pagination in chaincode
3. **Connection Pooling**: Reuse Gateway connections
4. **Async Processing**: Use message queues for non-critical updates

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-11 | Initial release with core functions |
