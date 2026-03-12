# Fabric Wallet Quick Start

## 🚀 Quick Setup (5 phút)

### 1. Prerequisites Check
```bash
# Check Node.js version
node --version  # Cần >= 14.x

# Check if you have the required files
ls -la script-fabric-blockchain/
```

### 2. Install Dependencies (if needed)
```bash
npm install fabric-network fabric-ca-client firebase-admin
```

### 3. Environment Setup
```bash
# Tạo .env file
cp .env.example .env

# Cập nhật các values cần thiết:
FABRIC_CA_URL=https://localhost:7054
FABRIC_CA_NAME=ca-org1
MSP_ID=Org1MSP
```

### 4. Quick Test
```bash
# Test CA connection
node test-ca-connection.js

# Setup master admin (chỉ chạy 1 lần)
npm run setup-admin

# Create user certificates
npm run create-users
```

## 📖 Quick Concepts

### Wallet là gì?
- **Storage** cho user certificates và private keys
- **Identity management** để interact với Fabric network
- **Security layer** cho blockchain operations

### Flow cơ bản:
```
1. Admin Enrollment → Master Admin Certificate
2. User Registration → User gets enrolled → User Certificate  
3. Store Certificate in Wallet (Firebase/File)
4. Use Certificate để submit transactions
```

### Key Components:
- **Certificate Authority (CA)**: Phát hành certificates
- **Wallet Repository**: Lưu trữ identity data (Firebase)
- **Gateway Service**: Connection tới Fabric network
- **Transaction Service**: Submit/Query chaincode

## 🛠️ Common Operations

### Create User Certificate
```typescript
// Tạo certificate cho user mới
const identityService = new IdentityService(caClient);
await identityService.createUserIdentity(userId, adminIdentity);
```

### Load User Identity
```typescript
// Load identity từ Firebase
const identity = await WalletBlockchainRepository.getIdentityFromFirebase(userId);
```

### Submit Transaction
```typescript
// Submit transaction với user identity
const result = await transactionService.submitTransaction(
    userId,
    'rentingchannel',
    'renting',
    'CreateRoom', 
    ['room1', 'Room data']
);
```

### Query Blockchain
```typescript
// Query data (read-only)
const result = await transactionService.evaluateTransaction(
    userId,
    'rentingchannel', 
    'renting',
    'GetRoom',
    ['room1']
);
```

## 🐛 Common Issues & Quick Fixes

### CA Connection Failed
```bash
❌ Error: connect ECONNREFUSED 127.0.0.1:7054

✅ Fix:
# Check if CA container is running
docker ps | grep ca
# Start if not running
docker-compose up -d ca_org1
```

### Identity Not Found
```bash
❌ Error: identity for user 'user123' not found

✅ Fix:
# Recreate user certificate
npm run create-user user123
# Or check Firebase collection 'fabric_identities'
```

### Certificate Expired
```bash
❌ Error: certificate has expired

✅ Fix:
# Regenerate certificates
npm run rotate-certs user123
# Or setup new admin and recreate users
```

### Transaction Failed
```bash
❌ Error: failed to submit transaction

✅ Fix:
# Check network connectivity
npm run health-check
# Verify user has valid certificate  
# Check chaincode is installed and running
```

## 📝 Quick Scripts

### Health Check
```bash
# Check system health
npm run health-check

# Expected output:
# ✅ CA Connection: OK
# ✅ Firebase: OK  
# ✅ Master Admin: EXISTS
# ✅ Network: ACCESSIBLE
```

### Bulk User Creation
```bash
# Create certificates for all Firebase users
npm run sync-users

# Create single user
npm run create-user <userId>

# List existing identities
npm run list-identities
```

### Debug Tools
```bash
# View wallet contents
npm run wallet-debug <userId>

# Test transaction
npm run test-transaction <userId>

# Clean and recreate
npm run clean-start
```

## 🔍 Debugging Tips

### 1. Check Logs
```bash
# Application logs
tail -f logs/wallet.log

# Docker container logs
docker logs ca_org1
docker logs peer0_org1
```

### 2. Verify Configuration
```bash
# Check connection profile
cat connection-profile/network-config.json

# Verify certificates exist
ls -la crypto-config/peerOrganizations/org1.example.com/ca/
```

### 3. Test Connectivity 
```bash
# Test CA directly
curl -k https://localhost:7054/cainfo

# Test peer connection
docker exec peer0_org1 peer --version
```

## 🚀 Next Steps

1. **Read**: [FABRIC_WALLET_GUIDE.md](./FABRIC_WALLET_GUIDE.md) cho detailed knowledge
2. **Practice**: Chạy example scripts trong `examples/` folder  
3. **Customize**: Modify theo requirements của project
4. **Deploy**: Setup production environment với proper security

## 📱 Useful Commands

```bash
# Development
npm run dev              # Start development server
npm run test            # Run test suite
npm run lint            # Check code quality

# Wallet Operations  
npm run setup-admin     # Initialize master admin (once only)
npm run create-users    # Create certificates for all users
npm run list-users      # List all identities 
npm run health-check    # System health verification

# Blockchain Operations
npm run submit <func>   # Submit transaction
npm run query <func>    # Query blockchain data
npm run events         # Listen to blockchain events

# Maintenance
npm run clean          # Clean temporary files
npm run reset-wallet   # Reset wallet (careful!)  
npm run backup         # Backup identities
npm run restore        # Restore from backup
```

---
🎯 **Pro Tip**: Luôn chạy `npm run health-check` trước khi debug issues. 80% problems sẽ được identify ngay!

📚 **Learning Path**: Quick Start → [Detailed Guide](./FABRIC_WALLET_GUIDE.md) → Advanced Implementation → Production Deployment