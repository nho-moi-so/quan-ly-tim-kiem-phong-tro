# Hyperledger Fabric Wallet Management Guide

## 📋 Mục lục
1. [Tổng quan Fabric Wallet](#tổng-quan-fabric-wallet)
2. [Kiến thức nền tảng](#kiến-thức-nền-tảng)
3. [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
4. [Cách tiếp cận Implementation](#cách-tiếp-cận-implementation)
5. [Quy trình Setup và Development](#quy-trình-setup-và-development)
6. [Code Examples và Patterns](#code-examples-và-patterns)
7. [Security và Best Practices](#security-và-best-practices)
8. [Troubleshooting](#troubleshooting)
9. [Kiến thức mở rộng](#kiến-thức-mở-rộng)

## 🎯 Tổng quan Fabric Wallet

### Wallet là gì?
**Fabric Wallet** là storage mechanism để quản lý digital identities (X.509 certificates & private keys) cho việc tương tác với Hyperledger Fabric network.

```
User Application ↔️ Wallet ↔️ Fabric Network
     ↳ Stores: Certificates, Private Keys, Identity Metadata
```

### Tại sao cần Wallet?
1. **Identity Management**: Lưu trữ và quản lý user certificates
2. **Security**: Bảo vệ private keys một cách an toàn
3. **Convenience**: Tự động handling của cryptographic operations
4. **Scalability**: Quản lý multiple identities cho different roles

### Types của Wallets
- **File System Wallet**: Lưu trữ trên local file system
- **Memory Wallet**: Lưu trữ trong RAM (temporary)
- **CouchDB Wallet**: Lưu trữ trong CouchDB
- **Custom Wallet**: Custom implementation (VD: Firebase Wallet)

## 🧠 Kiến thức nền tảng

### 1. **X.509 Certificates và PKI**
```typescript
interface Identity {
    mspId: string;           // Organization identifier  
    type: string;            // Identity type (X.509)
    credentials: {
        certificate: string;  // Public key certificate (PEM format)
        privateKey: string;   // Private key (PEM format)
    };
}
```

**Kiến thức cần biết**:
- **Certificate Authority (CA)**: Tổ chức phát hành certificates
- **Public Key Infrastructure (PKI)**: Hệ thống quản lý keys và certificates
- **PEM Format**: Text encoding for certificates và keys
- **MSP (Membership Service Provider)**: Define organization policies

### 2. **Fabric Network Components**
- **Peers**: Maintain ledger và execute chaincode
- **Orderers**: Order transactions into blocks
- **CA (Certificate Authority)**: Issue và manage certificates  
- **Channels**: Private communication subnets

### 3. **Enrollment vs Registration Process**

#### **Registration Process**:
```typescript
// Admin đăng ký user mới trên CA
const secret = await ca.register({
    affiliation: 'org1.department1',
    enrollmentID: 'user123',
    role: 'client'  // client, peer, orderer, admin
}, adminUser);
```

#### **Enrollment Process**:
```typescript
// User enrolled để lấy certificates
const enrollment = await ca.enroll({
    enrollmentID: 'user123',
    enrollmentSecret: secret
});
```

### 4. **Wallet Operations**
```typescript
// Load wallet
const wallet = await Wallets.newFileSystemWallet('./wallet');

// Put identity
await wallet.put(userId, identity);

// Get identity  
const identity = await wallet.get(userId);

// List identities
const identities = await wallet.list();

// Remove identity
await wallet.remove(userId);
```

## 🏗️ Kiến trúc hệ thống

### High-Level Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────┐
│   Frontend      │    │   Backend        │    │   Fabric Network  │
│   (React/Vue)   │◄──►│   (Node.js)      │◄──►│   (Peers/CA)      │
└─────────────────┘    └──────────────────┘    └───────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   Firebase       │
                       │   (Wallet Store) │
                       └──────────────────┘
```

### Detailed Components
```
Application Layer
├── User Management (Registration/Login)
├── Wallet Operations (Create/Load/Store)  
├── Transaction Submission
└── Query Operations

Service Layer  
├── CA Client (Certificate Authority interactions)
├── Wallet Repository (Firebase integration)
├── Identity Management
└── Network Gateway

Infrastructure Layer
├── Fabric SDK (fabric-network)
├── Firebase Admin SDK
├── Storage (File System/Firebase)
└── Logging/Monitoring
```

### Data Flow
```
1. User Registration:
   Firebase User → CA Registration → Certificate Generation → Wallet Storage

2. Transaction Flow:
   Load Identity → Create Gateway → Submit Transaction → Response

3. Query Flow:  
   Load Identity → Create Gateway → Evaluate Transaction → Response
```

## 🛠️ Cách tiếp cận Implementation

### 1. **Layered Architecture Approach**
```typescript
// Infrastructure Layer
class CAClient {
    async register(enrollmentID: string, role: string) { }
    async enroll(enrollmentID: string, secret: string) { }
}

// Repository Layer  
class WalletBlockchainRepository {
    async saveIdentityToFirebase(userId: string, identity: Identity) { }
    async getIdentityFromFirebase(userId: string): Promise<Identity> { }
}

// Service Layer
class IdentityService {
    async createUserIdentity(userId: string) { }
    async loadUserIdentity(userId: string) { }
}

// Application Layer
class TransactionService {
    async submitTransaction(userId: string, chaincode: string, func: string, args: string[]) { }
}
```

### 2. **Error Handling Strategy**
```typescript
enum WalletError {
    IDENTITY_NOT_FOUND = 'IDENTITY_NOT_FOUND',
    CA_CONNECTION_FAILED = 'CA_CONNECTION_FAILED', 
    ENROLLMENT_FAILED = 'ENROLLMENT_FAILED',
    INVALID_CERTIFICATE = 'INVALID_CERTIFICATE'
}

class WalletException extends Error {
    constructor(
        public type: WalletError,
        message: string,
        public details?: any
    ) {
        super(message);
    }
}
```

### 3. **Configuration Management**
```typescript
interface FabricConfig {
    ca: {
        url: string;
        caName: string;
        tlsCerts: string;
    };
    mspId: string;
    walletPath: string;
    connectionProfile: object;
}
```

## 🚀 Quy trình Setup và Development

### Phase 1: Environment Setup

#### 1.1 Prerequisites
```bash
# Node.js và npm
node --version  # >= 14.x
npm --version

# TypeScript development
npm install -g typescript ts-node

# Fabric binaries (optional for development)
curl -sSL https://bit.ly/2ysbOFE | bash -s
```

#### 1.2 Project Dependencies
```bash
# Fabric SDK
npm install fabric-network fabric-ca-client

# Firebase
npm install firebase-admin

# Development tools  
npm install @types/node dotenv path tsconfig-paths
```

### Phase 2: Core Implementation

#### 2.1 CA Client Setup
```typescript
// caClient.ts
import { FabricCAServices } from 'fabric-ca-client';
import { readFileSync } from 'fs';
import path from 'path';

export class CAClient {
    private ca: FabricCAServices;
    
    constructor(caUrl: string, caName: string, tlsCertPath?: string) {
        const tlsOptions = tlsCertPath ? {
            trustedRoots: readFileSync(tlsCertPath, 'utf8'),
            verify: false
        } : { verify: false };
        
        this.ca = new FabricCAServices(caUrl, tlsOptions, caName);
    }
    
    async register(enrollmentID: string, role: string = 'client', adminUser: User): Promise<string> {
        try {
            const registerRequest = {
                affiliation: 'org1.department1',
                enrollmentID,
                role
            };
            
            return await this.ca.register(registerRequest, adminUser);
        } catch (error) {
            throw new WalletException(
                WalletError.ENROLLMENT_FAILED, 
                `Failed to register ${enrollmentID}: ${error.message}`
            );
        }
    }
    
    async enroll(enrollmentID: string, enrollmentSecret: string) {
        try {
            return await this.ca.enroll({
                enrollmentID,
                enrollmentSecret
            });
        } catch (error) {
            throw new WalletException(
                WalletError.ENROLLMENT_FAILED,
                `Failed to enroll ${enrollmentID}: ${error.message}`
            );
        }
    }
}
```

#### 2.2 Wallet Repository Implementation  
```typescript
// walletBlockchainRepository.ts
import { Wallets, Wallet, Identity } from 'fabric-network';
import { getFirestore } from 'firebase-admin/firestore';

export class WalletBlockchainRepository {
    private static readonly COLLECTION_NAME = 'fabric_identities';
    
    /**
     * Save identity to Firebase Firestore
     */
    static async saveIdentityToFirebase(userId: string, identity: Identity): Promise<void> {
        try {
            const db = getFirestore();
            
            const identityData = {
                mspId: identity.mspId,
                type: identity.type,
                certificate: identity.credentials.certificate,
                privateKey: identity.credentials.privateKey,
                createdAt: new Date(),
                updatedAt: new Date()
            };
            
            await db.collection(this.COLLECTION_NAME)
                   .doc(userId)
                   .set(identityData);
                   
            console.log(`✅ Identity saved for user: ${userId}`);
        } catch (error) {
            throw new WalletException(
                WalletError.STORAGE_FAILED,
                `Failed to save identity: ${error.message}`
            );
        }
    }
    
    /**
     * Load identity from Firebase Firestore
     */
    static async getIdentityFromFirebase(userId: string): Promise<Identity | null> {
        try {
            const db = getFirestore();
            const doc = await db.collection(this.COLLECTION_NAME)
                               .doc(userId)
                               .get();
                               
            if (!doc.exists) {
                return null;
            }
            
            const data = doc.data()!;
            return {
                mspId: data.mspId,
                type: data.type,
                credentials: {
                    certificate: data.certificate,
                    privateKey: data.privateKey
                }
            };
        } catch (error) {
            throw new WalletException(
                WalletError.STORAGE_FAILED,
                `Failed to load identity: ${error.message}`
            );
        }
    }
    
    /**
     * Create in-memory wallet with user identity
     */
    static async createInMemoryWalletWithUser(userId: string): Promise<Wallet> {
        const identity = await this.getIdentityFromFirebase(userId);
        
        if (!identity) {
            throw new WalletException(
                WalletError.IDENTITY_NOT_FOUND,
                `Identity not found for user: ${userId}`
            );
        }
        
        const wallet = await Wallets.newInMemoryWallet();
        await wallet.put(userId, identity);
        
        return wallet;
    }
}
```

#### 2.3 Identity Service
```typescript
// identityService.ts  
export class IdentityService {
    constructor(
        private caClient: CAClient,
        private mspId: string = 'Org1MSP'
    ) {}
    
    /**
     * Create new user identity through CA
     */
    async createUserIdentity(userId: string, adminIdentity: Identity): Promise<Identity> {
        try {
            // 1. Check if identity already exists
            const existing = await WalletBlockchainRepository.getIdentityFromFirebase(userId);
            if (existing) {
                console.log(`⚠️ Identity already exists for user: ${userId}`);
                return existing;
            }
            
            // 2. Create temporary admin wallet
            const adminWallet = await Wallets.newInMemoryWallet();
            await adminWallet.put('admin', adminIdentity);
            
            // 3. Get admin user context 
            const provider = adminWallet.getProviderRegistry().getProvider(adminIdentity.type);
            const adminUser = await provider.getUserContext(adminIdentity, 'admin');
            
            // 4. Register user with CA
            console.log(`🔑 Registering user ${userId} with CA...`);
            const secret = await this.caClient.register(userId, 'client', adminUser);
            
            // 5. Enroll user to get certificates
            console.log(`📜 Enrolling user ${userId}...`);
            const enrollment = await this.caClient.enroll(userId, secret);
            
            // 6. Create identity object
            const identity: Identity = {
                mspId: this.mspId,
                type: 'X.509',
                credentials: {
                    certificate: enrollment.certificate,
                    privateKey: enrollment.key.toBytes()
                }
            };
            
            // 7. Save to Firebase
            await WalletBlockchainRepository.saveIdentityToFirebase(userId, identity);
            
            console.log(`✅ Identity created for user: ${userId}`);
            return identity;
            
        } catch (error) {
            console.error(`❌ Failed to create identity for ${userId}:`, error);
            throw error;
        }
    }
    
    /**
     * Load existing user identity
     */
    async loadUserIdentity(userId: string): Promise<Identity> {
        const identity = await WalletBlockchainRepository.getIdentityFromFirebase(userId);
        
        if (!identity) {
            throw new WalletException(
                WalletError.IDENTITY_NOT_FOUND,
                `No identity found for user: ${userId}`
            );
        }
        
        return identity;
    }
}
```

### Phase 3: Transaction Service

#### 3.1 Gateway Service
```typescript
// gatewayService.ts
import { Gateway, Network, Contract } from 'fabric-network';

export class GatewayService {
    private gateway: Gateway;
    private network: Network;
    
    constructor() {
        this.gateway = new Gateway();
    }
    
    /**
     * Connect to Fabric network with user identity  
     */
    async connect(userId: string, connectionProfile: any): Promise<void> {
        try {
            // Load user wallet
            const wallet = await WalletBlockchainRepository.createInMemoryWalletWithUser(userId);
            
            // Connect to gateway
            await this.gateway.connect(connectionProfile, {
                wallet,
                identity: userId,
                discovery: { enabled: true, asLocalhost: true }
            });
            
            console.log(`🌐 Connected to Fabric network as ${userId}`);
            
        } catch (error) {
            throw new WalletException(
                WalletError.CONNECTION_FAILED,
                `Failed to connect: ${error.message}`
            );
        }
    }
    
    /**
     * Get channel network
     */
    async getNetwork(channelName: string): Promise<Network> {
        if (!this.network) {
            this.network = await this.gateway.getNetwork(channelName);
        }
        return this.network;
    }
    
    /**
     * Get contract (chaincode)
     */
    async getContract(channelName: string, contractName: string): Promise<Contract> {
        const network = await this.getNetwork(channelName);
        return network.getContract(contractName);
    }
    
    /**
     * Disconnect from network
     */
    async disconnect(): Promise<void> {
        if (this.gateway) {
            await this.gateway.disconnect();
            console.log('🔌 Disconnected from Fabric network');
        }
    }
}
```

#### 3.2 Transaction Service  
```typescript
// transactionService.ts
export class TransactionService {
    constructor(private gatewayService: GatewayService) {}
    
    /**
     * Submit transaction (invoke chaincode function)
     */
    async submitTransaction(
        userId: string,
        channelName: string, 
        contractName: string,
        functionName: string,
        args: string[]
    ): Promise<any> {
        try {
            // Connect to network
            await this.gatewayService.connect(userId, connectionProfile);
            
            // Get contract
            const contract = await this.gatewayService.getContract(channelName, contractName);
            
            // Submit transaction
            console.log(`📤 Submitting transaction: ${functionName}(${args.join(', ')})`);
            const result = await contract.submitTransaction(functionName, ...args);
            
            console.log('✅ Transaction submitted successfully');
            return JSON.parse(result.toString());
            
        } catch (error) {
            console.error('❌ Transaction submission failed:', error);
            throw error;
        } finally {
            await this.gatewayService.disconnect();
        }
    }
    
    /**
     * Evaluate transaction (query chaincode - read-only)
     */
    async evaluateTransaction(
        userId: string,
        channelName: string,
        contractName: string, 
        functionName: string,
        args: string[]
    ): Promise<any> {
        try {
            await this.gatewayService.connect(userId, connectionProfile);
            
            const contract = await this.gatewayService.getContract(channelName, contractName);
            
            console.log(`📋 Evaluating query: ${functionName}(${args.join(', ')})`);
            const result = await contract.evaluateTransaction(functionName, ...args);
            
            return JSON.parse(result.toString());
            
        } catch (error) {
            console.error('❌ Query evaluation failed:', error);
            throw error;
        } finally {
            await this.gatewayService.disconnect();
        }
    }
}
```

### Phase 4: Testing & Scripts

#### 4.1 Admin Setup Script
```typescript
// setupMasterAdmin.ts
import { IdentityService } from './identityService';
import { CAClient } from './caClient';

async function setupMasterAdmin(): Promise<void> {
    try {
        const caClient = new CAClient(
            process.env.CA_URL!,
            process.env.CA_NAME!
        );
        
        // Enroll admin with CA  
        console.log('🔑 Enrolling master admin...');
        const enrollment = await caClient.enroll('admin', 'adminpw');
        
        // Create admin identity
        const adminIdentity = {
            mspId: 'Org1MSP',
            type: 'X.509',
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes()
            }
        };
        
        // Save admin identity  
        await WalletBlockchainRepository.saveIdentityToFirebase('master-admin', adminIdentity);
        
        console.log('✅ Master admin setup completed');
        
    } catch (error) {
        console.error('❌ Master admin setup failed:', error);
        process.exit(1);
    }
}

// Run script
setupMasterAdmin();
```

#### 4.2 User Creation Script
```typescript
// createUserCertificates.ts
async function createUserCertificates(): Promise<void> {
    try {
        // Load admin identity
        const adminIdentity = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin');
        if (!adminIdentity) {
            throw new Error('Master admin not found. Run setupMasterAdmin first.');
        }
        
        // Initialize services
        const caClient = new CAClient(process.env.CA_URL!, process.env.CA_NAME!);
        const identityService = new IdentityService(caClient);
        
        // Get users from Firebase
        const users = await UserRepository.getAll();
        console.log(`📋 Found ${users.length} users to process`);
        
        // Process each user
        for (const user of users) {
            try {
                await identityService.createUserIdentity(user.uid, adminIdentity);
            } catch (error) {
                console.error(`❌ Failed to create identity for ${user.uid}:`, error.message);
            }
        }
        
        console.log('✅ User certificate creation completed');
        
    } catch (error) {
        console.error('❌ User certificate creation failed:', error);
        process.exit(1);
    }
}

createUserCertificates();
```

## 🔒 Security và Best Practices

### 1. **Private Key Management**
```typescript
// ❌ BAD: Storing private key in plain text
const identity = {
    privateKey: "-----BEGIN PRIVATE KEY-----\n..."
};

// ✅ GOOD: Encrypt private keys before storage
import crypto from 'crypto';

class SecureWallet {
    private encryptPrivateKey(privateKey: string, password: string): string {
        const cipher = crypto.createCipher('aes-256-cbc', password);
        let encrypted = cipher.update(privateKey, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        return encrypted;
    }
    
    private decryptPrivateKey(encryptedKey: string, password: string): string {
        const decipher = crypto.createDecipher('aes-256-cbc', password);
        let decrypted = decipher.update(encryptedKey, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    }
}
```

### 2. **Environment Configuration**
```bash
# .env
FABRIC_CA_URL=https://localhost:7054
FABRIC_CA_NAME=ca-org1
FABRIC_NETWORK_PROFILE=./connection-org1.yaml
MSP_ID=Org1MSP
CHANNEL_NAME=rentingchannel
CHAINCODE_NAME=renting

# Firebase
FIREBASE_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json

# Security
WALLET_ENCRYPTION_KEY=your-very-strong-encryption-key
JWT_SECRET=your-jwt-secret
```

### 3. **Error Handling Best Practices**
```typescript
// Structured error handling
class FabricErrorHandler {
    static handle(error: any): WalletException {
        // CA connection errors
        if (error.message?.includes('ECONNREFUSED')) {
            return new WalletException(
                WalletError.CA_CONNECTION_FAILED,
                'Cannot connect to Certificate Authority'
            );
        }
        
        // Enrollment errors
        if (error.message?.includes('already enrolled')) {
            return new WalletException(
                WalletError.ALREADY_ENROLLED,
                'User is already enrolled'
            );
        }
        
        // Network errors
        if (error.message?.includes('failed to connect')) {
            return new WalletException(
                WalletError.NETWORK_CONNECTION_FAILED,
                'Failed to connect to Fabric network'
            );
        }
        
        // Generic error
        return new WalletException(
            WalletError.GENERIC_ERROR,
            error.message || 'Unknown error occurred'
        );
    }
}
```

### 4. **Logging và Monitoring**
```typescript
import winston from 'winston';

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
    ),
    transports: [
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' }),
        new winston.transports.Console({
            format: winston.format.simple()
        })
    ]
});

class WalletLogger {
    static logIdentityCreation(userId: string, success: boolean, error?: Error) {
        const logData = {
            action: 'identity_creation',
            userId,
            success,
            timestamp: new Date().toISOString(),
            error: error?.message
        };
        
        if (success) {
            logger.info('Identity created successfully', logData);
        } else {
            logger.error('Identity creation failed', logData);
        }
    }
    
    static logTransaction(userId: string, functionName: string, args: string[], success: boolean) {
        logger.info('Transaction attempted', {
            action: 'transaction',
            userId,
            functionName,
            args,
            success,
            timestamp: new Date().toISOString()
        });
    }
}
```

## 🐛 Troubleshooting

### Common Issues & Solutions

#### 1. **CA Connection Failed**
```bash
❌ Error: connect ECONNREFUSED 127.0.0.1:7054
```
**Solution**:
```bash
# Check CA is running
docker ps | grep ca

# Check CA logs
docker logs ca_org1

# Verify CA URL in config
echo $FABRIC_CA_URL
```

#### 2. **Identity Already Enrolled**
```bash
❌ Error: identity 'admin' is already enrolled
```
**Solution**:
```typescript
// Check before enrolling
try {
    await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
    console.log('Admin already enrolled');
} catch (error) {
    if (error.message.includes('already enrolled')) {
        console.log('Admin is already enrolled, continuing...');
        return; // Skip enrollment
    }
    throw error; // Re-throw other errors
}
```

#### 3. **Certificate Validation Failed** 
```bash
❌ Error: certificate verify failed: self signed certificate
```
**Solution**:
```typescript
// For development - disable TLS verification
const tlsOptions = {
    trustedRoots: [],
    verify: false
};

// For production - provide proper CA certificates
const tlsOptions = {
    trustedRoots: readFileSync('./tls-ca-cert.pem', 'utf8'),
    verify: true
};
```

#### 4. **Wallet Identity Not Found**
```bash
❌ Error: identity for user 'user123' not found in wallet
```
**Solution**:
```typescript
// Debug wallet contents
async function debugWallet(userId: string) {
    const wallet = await Wallets.newFileSystemWallet('./wallet');
    
    // List all identities
    const identities = await wallet.list();
    console.log('Wallet contents:', identities);
    
    // Check specific identity
    const identity = await wallet.get(userId);
    console.log(`Identity for ${userId}:`, identity ? 'EXISTS' : 'NOT FOUND');
}
```

### Debug Commands

#### System Health Check
```typescript
// healthCheck.ts
async function systemHealthCheck(): Promise<void> {
    console.log('🔍 Running system health check...\n');
    
    // 1. Environment variables
    console.log('📊 Environment Check:');
    const requiredEnvs = ['FABRIC_CA_URL', 'FABRIC_CA_NAME', 'MSP_ID'];
    requiredEnvs.forEach(env => {
        console.log(`  ${env}: ${process.env[env] ? '✅' : '❌'}`);
    });
    
    // 2. CA connectivity
    console.log('\n🔗 CA Connectivity:');
    try {
        const ca = new CAClient(process.env.FABRIC_CA_URL!, process.env.FABRIC_CA_NAME!);
        await ca.enroll('admin', 'adminpw');
        console.log('  CA Connection: ✅');
    } catch (error) {
        console.log(`  CA Connection: ❌ (${error.message})`);
    }
    
    // 3. Firebase connectivity  
    console.log('\n🔥 Firebase Connectivity:');
    try {
        const db = getFirestore();
        await db.collection('test').limit(1).get();
        console.log('  Firebase Connection: ✅');
    } catch (error) {
        console.log(`  Firebase Connection: ❌ (${error.message})`);
    }
    
    // 4. Identity check
    console.log('\n👤 Identity Check:');
    try {
        const adminIdentity = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin');
        console.log(`  Master Admin: ${adminIdentity ? '✅' : '❌'}`);
    } catch (error) {
        console.log(`  Master Admin: ❌ (${error.message})`);
    }
}
```

## 📈 Kiến thức mở rộng

### 1. **Advanced Wallet Types**

#### Hardware Security Module (HSM) Wallet
```typescript
class HSMWallet implements Wallet {
    constructor(private hsmConfig: HSMConfig) {}
    
    async put(label: string, identity: Identity): Promise<void> {
        // Store identity in HSM
        await this.hsm.storeKey(label, identity.credentials.privateKey);
    }
    
    async get(label: string): Promise<Identity> {
        // Retrieve from HSM
        const privateKey = await this.hsm.getKey(label);
        // Certificate from separate storage
        return identity;
    }
}
```

#### Cloud KMS Wallet
```typescript
class CloudKMSWallet implements Wallet {
    constructor(private kmsClient: any) {}
    
    async put(label: string, identity: Identity): Promise<void> {
        // Encrypt private key using Cloud KMS
        const encryptedKey = await this.kmsClient.encrypt({
            name: this.keyName,
            plaintext: Buffer.from(identity.credentials.privateKey)
        });
        
        // Store encrypted key
        await this.storage.save(label, encryptedKey);
    }
}
```

### 2. **Performance Optimization**

#### Connection Pooling
```typescript
class ConnectionPool {
    private connections: Map<string, Gateway> = new Map();
    
    async getConnection(userId: string): Promise<Gateway> {
        if (this.connections.has(userId)) {
            return this.connections.get(userId)!;
        }
        
        const gateway = new Gateway();
        const wallet = await WalletBlockchainRepository.createInMemoryWalletWithUser(userId);
        
        await gateway.connect(connectionProfile, {
            wallet,
            identity: userId,
            discovery: { enabled: true }
        });
        
        this.connections.set(userId, gateway);
        return gateway;
    }
}
```

#### Caching Strategy
```typescript
class IdentityCache {
    private cache: Map<string, { identity: Identity, expires: number }> = new Map();
    private TTL = 30 * 60 * 1000; // 30 minutes
    
    async get(userId: string): Promise<Identity | null> {
        const cached = this.cache.get(userId);
        
        if (cached && cached.expires > Date.now()) {
            return cached.identity;
        }
        
        // Load from Firebase
        const identity = await WalletBlockchainRepository.getIdentityFromFirebase(userId);
        
        if (identity) {
            this.cache.set(userId, {
                identity,
                expires: Date.now() + this.TTL
            });
        }
        
        return identity;
    }
}
```

### 3. **Multi-Org Support**
```typescript
interface MultiOrgConfig {
    orgs: {
        [orgName: string]: {
            mspId: string;
            ca: {
                url: string;
                name: string;
            };
        };
    };
}

class MultiOrgWalletService {
    async createCrossOrgIdentity(userId: string, targetOrg: string): Promise<void> {
        // Get source org admin
        const sourceAdmin = await this.getOrgAdmin('org1');
        
        // Create identity for target org
        const targetCA = this.getCAClient(targetOrg);
        const secret = await targetCA.register(userId, 'client', sourceAdmin);
        const enrollment = await targetCA.enroll(userId, secret);
        
        // Create cross-org identity
        const identity = this.createIdentity(enrollment, this.config.orgs[targetOrg].mspId);
        
        // Store with org prefix
        await WalletBlockchainRepository.saveIdentityToFirebase(`${targetOrg}_${userId}`, identity);
    }
}
```

### 4. **Advanced Security Patterns**

#### Identity Rotation
```typescript
class IdentityRotationService {
    async rotateUserCertificate(userId: string): Promise<void> {
        // 1. Create new certificate
        const newIdentity = await this.identityService.createUserIdentity(userId + '_new');
        
        // 2. Test new certificate
        await this.validateIdentity(newIdentity);
        
        // 3. Backup old certificate  
        const oldIdentity = await WalletBlockchainRepository.getIdentityFromFirebase(userId);
        await this.backupIdentity(userId, oldIdentity);
        
        // 4. Replace with new certificate
        await WalletBlockchainRepository.saveIdentityToFirebase(userId, newIdentity);
        
        // 5. Clean up temporary certificate
        await WalletBlockchainRepository.removeIdentity(userId + '_new');
    }
    
    async scheduleRotation(userId: string, intervalDays: number): Promise<void> {
        const nextRotation = new Date();
        nextRotation.setDate(nextRotation.getDate() + intervalDays);
        
        // Schedule using your preferred job scheduler
        await this.scheduler.schedule('identity_rotation', {
            userId,
            executeAt: nextRotation
        });
    }
}
```

## 🎯 Kết luận

### Key Takeaways

1. **Fabric Wallets are critical** cho security và identity management dalam Hyperledger Fabric
2. **Proper certificate management** là foundation của secure blockchain applications
3. **Layered architecture** giúp maintainability và scalability
4. **Error handling và logging** essential cho production deployment
5. **Security best practices** phải implement từ đầu, không thể bổ sung sau

### Next Steps for Learning

1. **Practice với test networks** - Setup local Fabric network và experiment
2. **Implement advanced features** - HSM integration, identity rotation
3. **Study production patterns** - Multi-org setups, enterprise integrations  
4. **Security hardening** - TLS mutual authentication, secure key storage
5. **Performance optimization** - Connection pooling, caching strategies

### Recommended Resources

- [Hyperledger Fabric SDK for Node.js](https://hyperledger.github.io/fabric-sdk-node/)
- [Fabric Network Model](https://hyperledger-fabric.readthedocs.io/network/network.html)
- [X.509 Certificate Management](https://hyperledger-fabric.readthedocs.io/msp.html)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin)

---
*Document này cung cấp kiến thức comprehensive về Fabric Wallet management, từ basic concepts đến advanced implementation patterns. Sử dụng làm reference cho development và learning journey của bạn.*