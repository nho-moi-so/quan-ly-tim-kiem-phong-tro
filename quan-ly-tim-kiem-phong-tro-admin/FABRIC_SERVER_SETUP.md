# Server (Org1 + Nghiệp vụ) - Fabric Integration Guide

## Overview
This guide describes the current implementation of Hyperledger Fabric integration in the `quan-ly-tim-kiem-phong-tro-admin` server, including wallet management, identity provisioning, and blockchain API services.

---

## 1. Prerequisites & Dependencies

### Installed Libraries
```bash
# Core Fabric SDK (v1.7.1 - recommended for Fabric v2.4+)
npm install @hyperledger/fabric-gateway

# Certificate Authority Client
npm install fabric-ca-client

# Legacy Fabric SDK (for CA enrollment support)
npm install fabric-network

# Additional dependencies
npm install firebase-admin  # Wallet storage backend
npm install dotenv          # Environment configuration
npm install express         # REST API server
npm install socket.io       # Real-time communication
```

### Current Versions (from package.json)
- `@hyperledger/fabric-gateway`: ^1.7.1
- `fabric-ca-client`: ^2.2.20
- `fabric-network`: ^2.2.20
- `firebase-admin`: ^13.5.0

---

## 2. Environment Configuration

All Fabric configuration is stored in `.env` file:

```bash
# Channel & Chaincode
FABRIC_CHANNEL_NAME=rentingchannel
FABRIC_CHAINCODE_NAME=renting
FABRIC_MSP_ID=Org1MSP

# Network paths (crypto materials)
FABRIC_CRYPTO_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com
FABRIC_USER_NAME=User1@org1.example.com
FABRIC_PEER_NAME=peer0.org1.example.com

# Peer endpoint (can be localhost for dev, or public IP for production)
FABRIC_PEER_ENDPOINT=localhost:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com

# Server ports
BLOCKCHAIN_PORT=3001  # Blockchain REST API
```

### For Production Deployment
Replace `localhost` in `FABRIC_PEER_ENDPOINT` with your Org1 VPS public IP:
```bash
FABRIC_PEER_ENDPOINT=<ORG1_PUBLIC_IP>:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com
```

---

## 3. Project Structure

```bash
/quan-ly-tim-kiem-phong-tro-admin/
├── server_blockchain.js                # Main Blockchain API server
├── server_socket.js                    # WebSocket server
├── .env                                # Configuration (see .env.example)
│
├── src/
│   ├── lib/fabric/
│   │   ├── fabricClient.ts            # Core Fabric Gateway connection
│   │   └── caClient.ts                # Certificate Authority client
│   │
│   ├── script-fabric-blockchain/
│   │   ├── enrollAdmin.js             # Admin enrollment setup
│   │   ├── createUserCertificates.ts  # User identity provisioning
│   │   ├── syncFirebaseToFabricUser.ts # Firebase↔Fabric sync
│   │   ├── healthCheck.ts             # System health verification
│   │   ├── FABRIC_WALLET_GUIDE.md     # Comprehensive documentation
│   │   ├── QUICKSTART.md              # Quick setup guide
│   │   └── wallet-manager.sh          # Management CLI tool
│   │
│   ├── repositories/
│   │   ├── walletBlockchainRepository.ts # Identity storage (Firebase)
│   │   ├── apartmentRepository.ts     # Apartment data operations
│   │   ├── contractRepository.ts      # Smart contract interactions
│   │   └── userRepository.ts          # User management
│   │
│   └── test-wallet-blockchain/        # Test wallet storage
│
└── test/                              # Test files
    ├── test-socket-client.js
    └── test-multiple-rooms.js
```

---

## 4. Fabric Gateway Connection (fabricClient.ts)

The `createFabricClient()` function handles all blockchain connectivity:

### Core Flow
```typescript
import { connect, Gateway, signers } from '@hyperledger/fabric-gateway';
import * as grpc from '@grpc/grpc-js';

export const createFabricClient = async (
    overrides: Partial<FabricConfig> = {}
): Promise<FabricClient> => {
    const config = { ...loadConfigFromEnv(), ...overrides };
    
    // 1. Setup gRPC connection with TLS
    const client = await newGrpcConnection(config);
    
    // 2. Load identity (X.509 certificate)
    const identity = await newIdentity(config);
    
    // 3. Load signer (private key)
    const signer = await newSigner(config);
    
    // 4. Connect to Fabric Gateway
    const gateway = connect({
        client,
        identity,
        signer,
    });
    
    // 5. Get network and contract
    const network = gateway.getNetwork(config.channelName);      // 'rentingchannel'
    const contract = network.getContract(config.chaincodeName);  // 'renting'
    
    return { contract, gateway, client, close: () => {...} };
};
```

### Key Components
- **gRPC Connection**: Secure communication with peer node using TLS certificates
- **Identity**: User's X.509 certificate from wallet
- **Signer**: Private key for signature generation
- **Gateway**: Entry point to Fabric network
- **Network**: Channel connection ('rentingchannel')
- **Contract**: Smart contract interface ('renting')

---

## 5. Certificate Authority (CA) Setup (caClient.ts)

### Connection Profile
The CA client reads from `connection-org1.json`:
```typescript
const ccpPath = path.resolve(
    process.env.FABRIC_CRYPTO_PATH,
    'connection-org1.json'
);
const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
const caInfo = ccp.certificateAuthorities['ca.org1.example.com'];
```

### CA Client Initialization
```typescript
import FabricCAServices from 'fabric-ca-client';

const ca = new FabricCAServices(
    caInfo.url,                          // https://localhost:7054
    { trustedRoots: caTLSCACerts, verify: false },
    caInfo.caName                        // 'ca-org1'
);
```

---

## 6. Wallet & Identity Management

### Identity Storage (Firebase)
All user identities are stored in Firebase Firestore under `walletBlockchains/`:
```
walletBlockchains/
├── master-admin/
│   ├── UserID: "master-admin"
│   ├── MSPID: "Org1MSP"
│   ├── Type: "X.509"
│   ├── CredentialsCertificate: "-----BEGIN CERTIFICATE-----\n..."
│   └── CredentialsPrivateKey: "-----BEGIN PRIVATE KEY-----\n..."
│
├── user-001/
│   ├── UserID: "user-001"
│   ├── CredentialsCertificate: "..."
│   └── CredentialsPrivateKey: "..."
└── ...
```

### Admin Enrollment
Run once to setup master admin:
```bash
npm run fabric:setup-admin
# or
npm run fabric:demo  # This runs setup-admin + create-users + health check
```

**What it does:**
1. Checks if master-admin exists on CA and Firebase
2. Enrolls admin on Fabric CA (if needed)
3. Stores credentials in Firebase Firestore

### User Certificate Creation
Create certificates for new users:
```bash
npm run fabric:create-users
```

**What it does:**
1. Reads user list from Firebase (users collection)
2. Creates new identities on CA for each user
3. Stores identities in `walletBlockchains` Firebase collection

### Firebase Sync
Synchronize Firebase user data with Fabric identities:
```bash
npm run fabric:sync-users
```

---

## 7. REST API Server (server_blockchain.js)

### Starting the Server
```bash
# Development mode (runs both socket and blockchain servers)
npm run dev

# Or run separately
node server_blockchain.js  # Listens on port 3001 by default
```

### Core API Endpoints

#### POST `/api/verify`
Verify access with password (for IoT door lock integration)
```javascript
// Request
{
    "apartmentId": "APT_001",
    "password": "123456"
}

// Response
{
    "status": "success",
    "access": true,
    "message": "Mở cửa thành công"
}
```

**Implementation:**
```javascript
app.post('/api/verify', async (req, res) => {
    const { apartmentId, password } = req.body;
    const passwordHashToSend = hashPassword(password);
    
    try {
        const resultBytes = await withFabricContract((contract) =>
            contract.evaluateTransaction('VerifyAccess', apartmentId, passwordHashToSend)
        );
        const resultString = decoder.decode(resultBytes);
        
        if (resultString === 'true') {
            return res.json({ status: 'success', access: true });
        }
        return res.json({ status: 'success', access: false });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
```

### Utility Function: withFabricContract()
```javascript
async function withFabricContract(handler) {
    const { contract, close } = await createFabricClient();
    try {
        return await handler(contract);
    } finally {
        close();  // Important: always close the connection
    }
}
```

This ensures:
- Fresh connection for each request
- Proper resource cleanup
- Error handling

---

## 8. Smart Contract Interactions

### Evaluate Transaction (Read-only)
```typescript
const result = await contract.evaluateTransaction(
    'GetApartmentData',  // Chaincode function
    apartmentId
);
```

### Submit Transaction (Write)
```typescript
await contract.submitTransaction(
    'CreateApartment',  // Chaincode function
    apartmentId,
    ownerName,
    rentalPrice
);
```

### Example: Apartment Management Operations
All operations go through `ApartmentRepository` which handles Fabric contract interaction:

```typescript
// Create apartment
await ApartmentRepository.createApartment({
    id: 'APT_001',
    owner: 'owner123',
    price: 5000
});

// Get apartment
const apt = await ApartmentRepository.getApartmentData(apartmentId);

// Update apartment
await ApartmentRepository.updateApartmentStatus(apartmentId, 'available');

// Verify access
const isValid = await ApartmentRepository.verifyAccess(apartmentId, passwordHash);
```

---

## 9. Health Check & Diagnostics

### Run Health Check
```bash
npm run fabric:health
```

**Checks:**
- ✅ Environment variables configured
- ✅ Fabric network connectivity
- ✅ Certificate Authority (CA) availability
- ✅ Master admin identity exists
- ✅ Channel and chaincode accessible
- ✅ Smart contract functions callable
- ✅ Firebase connectivity

### Manual Health Check
```typescript
import { createFabricClient } from '@/lib/fabric/fabricClient';

const { contract, close } = await createFabricClient();
try {
    const result = await contract.evaluateTransaction('GetApartmentData', 'test-id');
    console.log('Health check passed:', result);
} finally {
    close();
}
```

---

## 10. Wallet Management CLI

Comprehensive management tool for wallet operations:

```bash
./src/script-fabric-blockchain/wallet-manager.sh [command] [options]
```

### Available Commands
```bash
# Health check
./wallet-manager.sh health-check

# Setup admin
./wallet-manager.sh setup-admin

# Create user certificates
./wallet-manager.sh create-users

# Test transaction
./wallet-manager.sh test-transaction user-001

# Backup wallet
./wallet-manager.sh backup

# Restore from backup
./wallet-manager.sh restore <backup-file>

# List all identities
./wallet-manager.sh list-identities

# Export identity
./wallet-manager.sh export-identity user-001 /path/to/export
```

---

## 11. Troubleshooting

### Connection Issues
```bash
# Check if peer is accessible
curl -v https://localhost:7051

# Check if CA is accessible
curl -v https://localhost:7054/cainfo

# Verify peer host alias
ping peer0.org1.example.com
```

### Certificate Issues
```bash
# List available certificates
ls -la ${FABRIC_CRYPTO_PATH}/users/User1@org1.example.com/msp/signcerts/

# Verify certificate
openssl x509 -in <cert-file> -text -noout

# Check private key permissions
chmod 600 ${FABRIC_CRYPTO_PATH}/users/User1@org1.example.com/msp/keystore/priv_sk
```

### Firebase Access
```bash
# Check if firebase credentials are loaded
npm run fabric:health

# Verify Firebase connection in Node.js
node -e "require('firebase-admin/app').initializeApp(); console.log('Firebase OK')"
```

### CA Enrollment Issues
Check user enrollment status with:
```bash
node src/script-fabric-blockchain/checkMasterAdmin.ts
```

---

## 12. Setup Workflow Summary

### First-time Setup (Development)
```bash
# 1. Install dependencies
npm install

# 2. Configure .env
cp .env.example .env
# Edit .env with your paths and configuration

# 3. Setup master admin (one-time)
npm run fabric:setup-admin

# 4. Create user certificates (for test users)
npm run fabric:create-users

# 5. Verify everything works
npm run fabric:health

# 6. Start servers
npm run dev
```

### Production Deployment
```bash
# 1. Update .env with production values
# - FABRIC_PEER_ENDPOINT: <ORG1_PUBLIC_IP>:7051
# - FABRIC_CRYPTO_PATH: absolute path on VPS
# - FABRIC_PEER_HOST_ALIAS: DNS name or IP

# 2. Setup admin
npm run fabric:setup-admin

# 3. Setup users
npm run fabric:create-users

# 4. Run health check
npm run fabric:health

# 5. Start server with PM2 or similar
pm2 start server_blockchain.js
pm2 start server_socket.js
```

---

## 13. Key Differences from Documents

| Aspect | Previous Approach | Current Implementation |
|--------|-------------------|----------------------|
| **SDK** | fabric-network | @hyperledger/fabric-gateway (v1.7.1) |
| **Connection** | Custom implementation | gRPC with TLS |
| **Wallet Storage** | File-based | Firebase Firestore |
| **Identity Management** | Manual | Automated scripts |
| **Configuration** | Hardcoded | Environment variables (.env) |
| **Server** | N/A | Express REST API + WebSocket |
| **API Pattern** | N/A | Repositories pattern |
| **Health Monitor** | N/A | npm run fabric:health |
| **Management** | N/A | wallet-manager.sh CLI |

---

## 14. Complete Example: Submit Transaction

```typescript
// File: src/repositories/apartmentRepository.ts
import { createFabricClient } from '@/lib/fabric/fabricClient';

export class ApartmentRepository {
    static async createApartment(apt: ApartmentData) {
        const { contract, close } = await createFabricClient();
        try {
            await contract.submitTransaction(
                'CreateApartment',
                apt.id,
                apt.owner,
                apt.price.toString()
            );
            console.log(`✅ Apartment ${apt.id} created on blockchain`);
        } catch (error) {
            console.error(`❌ Error creating apartment: ${error.message}`);
            throw error;
        } finally {
            close();
        }
    }

    static async getApartmentData(apartmentId: string) {
        const { contract, close } = await createFabricClient();
        try {
            const resultBytes = await contract.evaluateTransaction(
                'GetApartmentData',
                apartmentId
            );
            const resultString = new TextDecoder().decode(resultBytes);
            return JSON.parse(resultString);
        } finally {
            close();
        }
    }
}
```

Usage in server:
```javascript
// From server_blockchain.js
app.post('/api/apartments', async (req, res) => {
    const { id, owner, price } = req.body;
    try {
        await ApartmentRepository.createApartment({ id, owner, price });
        res.json({ status: 'success', message: 'Apartment created' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
```

---

## 15. Next Steps & Documentation

For more detailed information:
- 📖 [FABRIC_WALLET_GUIDE.md](./src/script-fabric-blockchain/FABRIC_WALLET_GUIDE.md) - Comprehensive 50+ page guide
- ⚡ [QUICKSTART.md](./src/script-fabric-blockchain/QUICKSTART.md) - Quick reference  
- 🔧 [README.md](./src/script-fabric-blockchain/README.md) - Script reference

---

**Last Updated**: March 2026
**Current Version**: Fabric v2.4.x + Gateway SDK v1.7.1
