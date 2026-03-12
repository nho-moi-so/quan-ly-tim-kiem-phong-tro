# Fabric Wallet & Certificate Management

Thư mục này chứa các scripts và utilities để quản lý **Hyperledger Fabric Wallet** và **Certificate Management** cho hệ thống blockchain.

## 📖 Tổng quan

Hệ thống này cung cấp:
- **Certificate Authority (CA) Management**: Đăng ký và enroll users
- **Wallet Repository**: Lưu trữ identity certificates trong Firebase  
- **Identity Service**: Tạo và quản lý user identities
- **Transaction Service**: Submit và query blockchain transactions
- **Security Features**: Certificate validation, rotation, backup

## 🗂️ Cấu trúc thư mục

```
script-fabric-blockchain/
├── README.md                    # Documentation này
├── FABRIC_WALLET_GUIDE.md      # Chi tiết kiến thức và implementation
├── QUICKSTART.md               # Quick start guide  
├── wallet-manager.sh           # Management script utilities
├── healthCheck.ts              # System health verification
├── enrollAdmin.js              # Master admin enrollment
├── createUserCertificates.ts   # User certificate creation
├── syncFirebaseToFabricUser.ts # Sync Firebase users
├── caClient.js                 # Certificate Authority client
└── logs/                       # Script execution logs
```

## 🚀 Quick Start

### 1. Kiểm tra hệ thống
```bash
# Cấp quyền execute cho script
chmod +x wallet-manager.sh

# Check prerequisites và system health  
./wallet-manager.sh health-check
```

### 2. Setup admin (chỉ chạy 1 lần)
```bash
# Enroll master admin với CA
./wallet-manager.sh setup-admin
```

### 3. Tạo user certificates
```bash
# Tạo certificates cho tất cả Firebase users
./wallet-manager.sh create-users

# Hoặc tạo cho specific user
./wallet-manager.sh create-user <user_id>
```

### 4. Test system
```bash
# Test transaction với user ID
./wallet-manager.sh test-transaction <user_id>
```

## 📚 Tài liệu học tập

### 🎯 [FABRIC_WALLET_GUIDE.md](./FABRIC_WALLET_GUIDE.md)
**Comprehensive guide** bao gồm:
- **Kiến thức nền tảng**: X.509, PKI, Fabric concepts
- **Architecture**: System design và components
- **Implementation**: Code examples và patterns  
- **Security**: Best practices và troubleshooting
- **Advanced topics**: Multi-org, performance optimization

### ⚡ [QUICKSTART.md](./QUICKSTART.md) 
**Quick reference** cho:
- 5-minute setup process
- Common operations
- Troubleshooting common issues
- Useful commands và shortcuts

## 🛠️ Available Scripts

### Management Script
```bash
# System operations
./wallet-manager.sh health-check          # Verify system health
./wallet-manager.sh check-prereq          # Check prerequisites  

# Certificate operations
./wallet-manager.sh setup-admin           # Setup master admin
./wallet-manager.sh create-users          # Create all user certs
./wallet-manager.sh create-user <id>      # Create specific user cert
./wallet-manager.sh sync-users            # Sync Firebase to Fabric

# Testing & debugging
./wallet-manager.sh test-transaction <id> # Test transaction
./wallet-manager.sh list-identities       # List all identities

# Maintenance  
./wallet-manager.sh backup               # Backup wallet data
./wallet-manager.sh clean                # Clean wallet data
./wallet-manager.sh logs                 # Show recent logs
```

### NPM Scripts (trong package.json)
```bash
# Development
npm run fabric:health          # Run health check
npm run fabric:setup-admin     # Setup master admin  
npm run fabric:create-users    # Create user certificates
npm run fabric:sync-users      # Sync Firebase users

# Testing
npm run fabric:test            # Run test suite
npm run fabric:demo            # Run demonstration

# Maintenance
npm run fabric:backup          # Backup identities
npm run fabric:clean           # Clean and reset
```

## ⚙️ Configuration

### Environment Variables (.env)
```bash
# Fabric Network
FABRIC_CA_URL=https://localhost:7054
FABRIC_CA_NAME=ca-org1
MSP_ID=Org1MSP
CHANNEL_NAME=rentingchannel
CHAINCODE_NAME=renting

# Firebase  
FIREBASE_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=./path/to/service-account.json

# Security
WALLET_ENCRYPTION_KEY=your-encryption-key
```

### Network Configuration
- **Connection Profile**: `../connection-profile/network-config.json`
- **TLS Certificates**: `../crypto-config/peerOrganizations/...`
- **CA Certificates**: Referenced in connection profile

## 🔧 Core Components

### 1. **Certificate Authority Client** (`caClient.js`)
- Interface với Fabric CA để register/enroll users
- Handle TLS connections và certificate validation
- Provide admin và user enrollment functionality

### 2. **Wallet Repository** (`WalletBlockchainRepository`)  
- Firebase integration cho persistent storage
- Identity CRUD operations (Create, Read, Update, Delete)
- In-memory wallet creation for transactions

### 3. **Identity Service** (`IdentityService`)
- High-level identity management
- User registration và enrollment workflow  
- Certificate lifecycle management

### 4. **Transaction Service** (`TransactionService`)
- Gateway connection management
- Submit transactions (invoke chaincode)
- Evaluate queries (read-only operations)

## 🐛 Common Issues & Solutions

### CA Connection Failed
```bash
❌ Error: connect ECONNREFUSED 127.0.0.1:7054
✅ Fix: Check if CA container is running
docker ps | grep ca
```

### Identity Not Found  
```bash
❌ Error: identity for user 'xyz' not found
✅ Fix: Create user certificate
./wallet-manager.sh create-user xyz
```

### Certificate Expired
```bash
❌ Error: certificate has expired  
✅ Fix: Rotate certificates
npm run fabric:rotate-certs
```

### Firebase Permission Denied
```bash
❌ Error: permission denied
✅ Fix: Check service account key và permissions
```

## 📊 Monitoring & Logs

### Log Locations
- **Script logs**: `./logs/wallet-manager.log`
- **Application logs**: `./logs/fabric-wallet.log`
- **Error logs**: `./logs/error.log`

### Health Monitoring
```bash
# Comprehensive health check
./wallet-manager.sh health-check

# Check specific component  
npm run fabric:check-ca        # CA connectivity
npm run fabric:check-firebase  # Firebase connectivity
npm run fabric:check-network   # Network connectivity
```

## 🚀 Development Workflow

### Setup Development Environment
```bash
# 1. Install dependencies
npm install

# 2. Setup environment
cp .env.example .env
# Edit .env với actual values

# 3. Initialize system
./wallet-manager.sh check-prereq
./wallet-manager.sh setup-admin
./wallet-manager.sh create-users

# 4. Verify setup
./wallet-manager.sh health-check
```

### Adding New Features
1. **Read**: [FABRIC_WALLET_GUIDE.md](./FABRIC_WALLET_GUIDE.md) để hiểu architecture
2. **Implement**: Add new functionality following patterns  
3. **Test**: Create tests và update health check
4. **Document**: Update guides và README

### Testing  
```bash
# Unit tests
npm run test

# Integration tests  
npm run test:integration

# End-to-end testing
npm run test:e2e

# Manual testing
./wallet-manager.sh test-transaction test-user
```

## 🛡️ Security Considerations

### Production Deployment
- **TLS**: Enable certificate verification in production
- **Key Storage**: Use HSM hoặc Cloud KMS cho private keys
- **Access Control**: Implement proper RBAC
- **Monitoring**: Setup alerting cho certificate expiration

### Development Security
- **Never commit**: Private keys hoặc certificates
- **Environment isolation**: Separate dev/staging/prod environments  
- **Regular rotation**: Rotate certificates regularly
- **Backup strategy**: Secure backup của critical certificates

## 📞 Support & Resources

### Getting Help
1. **Quick issues**: Xem [QUICKSTART.md](./QUICKSTART.md)
2. **Deep dive**: Đọc [FABRIC_WALLET_GUIDE.md](./FABRIC_WALLET_GUIDE.md)  
3. **Health check**: Chạy `./wallet-manager.sh health-check`
4. **Logs**: Check `./logs/` directory

### External Resources
- [Hyperledger Fabric SDK Documentation](https://hyperledger.github.io/fabric-sdk-node/)
- [Firebase Admin SDK Guide](https://firebase.google.com/docs/admin)
- [X.509 Certificate Standards](https://tools.ietf.org/html/rfc5280)

---

## 🎯 Next Steps

1. **Explore**: Đọc FABRIC_WALLET_GUIDE.md để hiểu sâu concepts
2. **Practice**: Chạy các scripts và experiment với features
3. **Customize**: Modify theo requirements của project
4. **Deploy**: Setup production environment với proper security

**Happy Coding!** 🚀