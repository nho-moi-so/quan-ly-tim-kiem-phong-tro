# Hyperledger Fabric Network v2 - Complete Guide

## 📋 Mục lục
1. [Tổng quan Architecture](#tổng-quan-architecture)
2. [Current Test Network Setup](#current-test-network-setup)
3. [Smart Contract Business Logic](#smart-contract-business-logic)
4. [Network Components](#network-components)
5. [Development Commands](#development-commands)
6. [Configuration Files](#configuration-files)
7. [Chaincode Deployment](#chaincode-deployment)
8. [Admin Server Integration](#admin-server-integration)

## 🏗️ Tổng quan Architecture

### **System Overview**
Đây là một **Room Rental Blockchain System** sử dụng Hyperledger Fabric với:
- **Escrow-based payments** cho thuê phòng
- **Multi-party trust** giữa Owner, Guest, và System
- **Smart contract automation** cho contract lifecycle
- **Identity management** với role-based access

### **Network Topology**
```
┌─────────────────────┐    ┌─────────────────────┐
│   Orderer Service   │    │   Certificate       │
│   (OrdererMSP)      │    │   Authority         │  
│   Port: 7050        │    │   Port: 7054        │
└─────────────────────┘    └─────────────────────┘
           │                          │
           ▼                          ▼
┌─────────────────────┐    ┌─────────────────────┐
│   Org1 Peer0        │    │   Org2 Peer0        │
│   (Org1MSP)         │    │   (Org2MSP)         │
│   Port: 7051        │    │   Port: 9051        │
└─────────────────────┘    └─────────────────────┘
           │                          │
           └───────┬──────────────────┘
                   ▼
         ┌─────────────────────┐
         │   Channel:          │
         │   rentingchannel    │
         │                     │
         │   Chaincode:        │
         │   renting           │
         └─────────────────────┘
```

## 📂 Current Test Network Setup

### **Directory Structure**
```
blockchain-fabric-v2/
├── bin/                          # Fabric binaries (peer, orderer, etc.)
├── builders/                     # Chaincode builders
├── config/                       # Core configuration files
├── chaincode-go/                 # Smart contract source code
│   ├── assetTransfer.go         # Main chaincode entrypoint
│   ├── chaincode/
│   │   ├── smartcontract.go     # Business logic
│   │   └── SMARTCONTRACT_API.md # API documentation
│   ├── go.mod                   # Go module dependencies
│   └── vendor/                  # Vendored dependencies
├── test-network/                # Development network setup
│   ├── network.sh               # Network management script
│   ├── compose/                 # Docker compose files
│   │   ├── compose-test-net.yaml
│   │   ├── compose-ca.yaml
│   │   └── compose-couch.yaml
│   ├── configtx/                # Channel configuration
│   ├── organizations/           # Certificates & MSP
│   │   ├── peerOrganizations/
│   │   ├── ordererOrganizations/
│   │   └── fabric-ca/
│   └── scripts/                 # Automation scripts
└── command.md                   # Development commands
```

### **Network Components**

#### **1. Orderer Service**
- **Image**: `hyperledger/fabric-orderer:latest`
- **MSP ID**: `OrdererMSP`
- **Port**: `7050` (main), `7053` (admin), `9443` (metrics)
- **TLS**: Enabled với mutual TLS
- **Consensus**: RAFT (single node for test)

#### **2. Organization 1 (Org1MSP)**
- **Peer**: `peer0.org1.example.com`
- **Port**: `7051` (main), `7052` (chaincode), `9444` (metrics)
- **Database**: CouchDB available (optional)
- **CA**: `ca.org1.example.com:7054`

#### **3. Organization 2 (Org2MSP)**  
- **Peer**: `peer0.org2.example.com`
- **Port**: `9051` (main), `9052` (chaincode), `9445` (metrics)
- **Database**: CouchDB available (optional)
- **CA**: `ca.org2.example.com:8054`

#### **4. Channel Configuration**
- **Channel Name**: `rentingchannel`
- **Participating Orgs**: Org1MSP, Org2MSP
- **Anchor Peers**: Configured for both organizations
- **Block Size**: Default
- **Timeout**: Standard Fabric settings

## 💼 Smart Contract Business Logic

### **Data Structures**

#### **User Entity**
```go
type User struct {
    DocType       string `json:"docType"`        // "user"
    ID            string `json:"id"`             // Firebase UID
    FullName      string `json:"FullName"`       // User's full name
    Balance       int    `json:"Balance"`        // Available balance
    LockedBalance int    `json:"LockedBalance"`  // Escrowed amount
    Status        string `json:"Status"`         // ACTIVE/PENDING/LOCKED/APPROVED
    Role          string `json:"Role"`           // ADMIN/OWNER/GUEST
}
```

#### **Apartment Entity**
```go
type Apartment struct {
    DocType      string `json:"docType"`        // "apartment"
    ID           string `json:"id"`             // Unique apartment ID
    OwnerID      string `json:"OwnerID"`        // Reference to User.ID
    DailyRate    int    `json:"DailyRate"`      // Daily rental rate
    Status       string `json:"Status"`         // AVAILABLE/BOOKED/OCCUPIED
    PasswordHash string `json:"PasswordHash"`   // Access password hash
}
```

#### **Contract Entity**
```go
type Contract struct {
    DocType      string `json:"docType"`        // "contract"
    ID           string `json:"id"`             // Unique contract ID
    ApartmentID  string `json:"ApartmentID"`    // Reference to Apartment.ID
    GuestID      string `json:"GuestID"`        // Reference to User.ID  
    StartDate    int64  `json:"StartDate"`      // Unix timestamp
    EndDate      int64  `json:"EndDate"`        // Unix timestamp
    EscrowAmount int    `json:"EscrowAmount"`   // Locked payment amount
    Status       string `json:"Status"`         // CREATED/ACTIVE/COMPLETED/CANCELED
}
```

### **Key Functions**

#### **User Management**
```go
// Create new user on blockchain
func (s *SmartContract) CreateUser(ctx, id, fullName string, balance int, role string) error

// Get user by ID
func (s *SmartContract) GetUserById(ctx, id string) (*User, error)

// Update user balance (for payments)
func (s *SmartContract) UpdateUserBalance(ctx, userID string, amount int) error
```

#### **Apartment Management**
```go
// Create apartment listing
func (s *SmartContract) CreateApartment(ctx, id, ownerID string, dailyRate int) error

// Update apartment password
func (s *SmartContract) UpdatePasswordApartment(ctx, apartmentID, passwordHash string) error

// Change apartment status
func (s *SmartContract) UpdateApartmentStatus(ctx, apartmentID, status string) error
```

#### **Contract & Escrow Management**
```go
// Create rental contract with escrow
func (s *SmartContract) CreateContract(ctx, contractID, apartmentID, guestID string, 
    startDate, endDate int64, escrowAmount int) error

// Release escrow to owner (after successful rental)
func (s *SmartContract) CompleteContract(ctx, contractID string) error

// Refund escrow to guest (cancellation/dispute)
func (s *SmartContract) CancelContract(ctx, contractID string) error
```

### **Business Flow**
1. **User Registration**: `CreateUser` → Firebase + Blockchain
2. **Apartment Listing**: Owner `CreateApartment` 
3. **Booking Request**: Guest creates booking request
4. **Escrow Lock**: `CreateContract` locks guest's balance
5. **Check-in**: Password verification + contract activation
6. **Check-out**: `CompleteContract` releases escrow to owner
7. **Dispute Resolution**: Admin can `CancelContract` if needed

## ⚙️ Network Components

### **Docker Services**

#### **Orderer Configuration**
```yaml
orderer.example.com:
  image: hyperledger/fabric-orderer:latest
  environment:
    - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
    - ORDERER_GENERAL_LISTENPORT=7050
    - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
    - ORDERER_GENERAL_TLS_ENABLED=true
    - ORDERER_CHANNELPARTICIPATION_ENABLED=true
  ports:
    - "7050:7050"    # Main orderer service
    - "7053:7053"    # Admin service  
    - "9443:9443"    # Prometheus metrics
```

#### **Peer Configuration**
```yaml
peer0.org1.example.com:
  image: hyperledger/fabric-peer:latest
  environment:
    - CORE_PEER_ID=peer0.org1.example.com
    - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    - CORE_PEER_LOCALMSPID=Org1MSP
    - CORE_PEER_TLS_ENABLED=true
    - CORE_PEER_GOSSIP_USELEADERELECTION=true
  ports:
    - "7051:7051"    # Peer service
    - "9444:9444"    # Prometheus metrics
```

#### **Certificate Authority**
```yaml
ca_org1:
  image: hyperledger/fabric-ca:latest
  environment:
    - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
    - FABRIC_CA_SERVER_CA_NAME=ca-org1
    - FABRIC_CA_SERVER_TLS_ENABLED=true
  ports:
    - "7054:7054"    # CA service
```

### **Certificate Structure**
```
organizations/
├── ordererOrganizations/
│   └── example.com/
│       ├── msp/                    # OrdererMSP materials
│       └── orderers/
│           └── orderer.example.com/
│               ├── msp/            # Node MSP
│               └── tls/            # TLS certificates
├── peerOrganizations/
│   ├── org1.example.com/
│   │   ├── msp/                    # Org1MSP materials
│   │   ├── peers/
│   │   │   └── peer0.org1.example.com/
│   │   │       ├── msp/            # Peer MSP
│   │   │       └── tls/            # Peer TLS
│   │   ├── users/
│   │   │   ├── Admin@org1.example.com/    # Admin identity
│   │   │   └── User1@org1.example.com/    # User identity
│   │   └── ca/                     # CA certificates
│   └── org2.example.com/           # Similar structure
```

## 🛠️ Development Commands

### **Network Management**
```bash
cd test-network/

# Start network with CA and create channel
./network.sh up createChannel -c rentingchannel -ca

# Deploy chaincode
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go

# Upgrade chaincode  
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go -ccv 2.0 -ccs 2

# Stop network
./network.sh down
```

### **Environment Setup**
```bash
# Add Fabric binaries to PATH
export PATH=${PWD}/../bin:$PATH

# Set configuration path
export FABRIC_CFG_PATH=$PWD/../config/

# Configure peer environment
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

### **Chaincode Interaction**
```bash
# Query user by ID
peer chaincode query -C rentingchannel -n renting -c '{"function":"GetUserById","Args":["user123"]}'

# Create new user
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
    --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
    -C rentingchannel -n renting --peerAddresses localhost:7051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
    --peerAddresses localhost:9051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
    -c '{"function":"CreateUser","Args":["user123","John Doe","1000","GUEST"]}'
```

### **Container Management**
```bash
# Clean up all containers
docker rm -f $(docker ps -aq --filter name=peer) 
docker rm -f $(docker ps -aq --filter name=orderer) 
docker rm -f $(docker ps -aq --filter name=cli) 
docker volume rm $(docker volume ls -q | grep example.com)

# Stop all containers (preserve state)
docker stop $(docker ps -aq)

# Start all containers (restore state)
docker start $(docker ps -aq)
```

## 📄 Configuration Files

### **Connection Profile** (`/test-network/organizations/peerOrganizations/org1.example.com/connection-org1.json`)
```json
{
    "name": "test-network-org1",
    "version": "1.0.0",
    "client": {"organization": "Org1"},
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": ["peer0.org1.example.com"],
            "certificateAuthorities": ["ca.org1.example.com"]
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpcs://localhost:7051",
            "tlsCACerts": {"pem": "-----BEGIN CERTIFICATE-----..."},
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com",
                "hostnameOverride": "peer0.org1.example.com"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "https://localhost:7054",
            "caName": "ca-org1",
            "tlsCACerts": {"pem": ["-----BEGIN CERTIFICATE-----..."]}
        }
    }
}
```

### **Channel Configuration** (`/test-network/configtx/configtx.yaml`)
- **Organizations**: OrdererMSP, Org1MSP, Org2MSP
- **Orderer Type**: etcdraft (RAFT consensus)
- **Channel Policies**: Majority/Any endorsement
- **Application Capabilities**: V2_0

## 🚀 Chaincode Deployment

### **Build Process**
```bash
# Build Go chaincode
cd chaincode-go/
go mod tidy
go mod vendor

# Package chaincode
cd ../test-network/
peer lifecycle chaincode package renting.tar.gz --path ../chaincode-go/ --lang golang --label renting_1.0
```

### **Installation & Approval**
```bash
# Install on Org1 peer
peer lifecycle chaincode install renting.tar.gz

# Install on Org2 peer
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer lifecycle chaincode install renting.tar.gz

# Approve for Org1
peer lifecycle chaincode approveformyorg -o localhost:7050 --channelID rentingchannel --name renting --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

# Approve for Org2 (similar command with Org2 settings)

# Commit chaincode definition
peer lifecycle chaincode commit -o localhost:7050 --channelID rentingchannel --name renting --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
```

## 🔗 Admin Server Integration

### **Current Configuration** (Test Network)
Admin ở `/quan-ly-tim-kiem-phong-tro-admin` connect tới blockchain qua:

#### **Environment Variables** (`.env`)
```bash
FABRIC_CHANNEL_NAME=rentingchannel
FABRIC_CHAINCODE_NAME=renting
FABRIC_MSP_ID=Org1MSP
FABRIC_CRYPTO_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com
FABRIC_USER_NAME=User1@org1.example.com
FABRIC_PEER_NAME=peer0.org1.example.com
FABRIC_PEER_ENDPOINT=localhost:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com
```

#### **Connection Files**
- **Connection Profile**: `/src/scripts/org1.example.com/connection-org1.json`
- **Certificates**: Points to test-network crypto materials
- **Discovery**: Set to `asLocalhost: true`

#### **Integration Points**
1. **Fabric Client** (`/src/lib/fabric/fabricClient.ts`): Gateway connection
2. **CA Client** (`/src/lib/fabric/caClient.ts`): Identity management  
3. **Blockchain Repository** (`/src/repositories/blockchainFabricRepository.ts`): Transaction submission
4. **Server** (`server_blockchain.js`): Express API endpoints

### **Key Integration Functions**
```typescript
// Submit transaction to blockchain
async submitTransaction(functionName: string, args: string[]): Promise<any>

// Query blockchain data  
async evaluateTransaction(functionName: string, args: string[]): Promise<any>

// User identity management
async createBlockchainUser(user: FirebaseUser): Promise<void>

// Contract operations
async createRentalContract(contractData: ContractData): Promise<string>
```

---

**📝 Note**: Đây là setup cho development/testing. Để deploy production, cần những thay đổi chủ yếu về network configuration, certificates, và endpoints như được mô tả trong [PRODUCTION_DEPLOYMENT.md](./PRODUCTION_DEPLOYMENT.md).