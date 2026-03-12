# Production Deployment Guide

## 🎯 Mục tiêu
Chuyển từ **test-network development setup** sang **multi-VPS production deployment** với các node Fabric chạy trên các máy chủ khác nhau.

## 📋 Mục lục
1. [Architecture Thay đổi](#architecture-thay-đổi)
2. [VPS Infrastructure Planning](#vps-infrastructure-planning)
3. [Network Configuration](#network-configuration)
4. [Certificate Management](#certificate-management)
5. [Admin Server Modifications](#admin-server-modifications)
6. [Deployment Checklist](#deployment-checklist)
7. [Security Considerations](#security-considerations)
8. [Monitoring & Maintenance](#monitoring--maintenance)
9. [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Thay đổi

### **From Development (Single Machine)**
```
┌─────────────────────────────────────────────────────┐
│              Single Development Server               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐│
│  │ Orderer  │ │  Org1    │ │  Org2    │ │   CA    ││
│  │:7050     │ │  Peer    │ │  Peer    │ │  :7054  ││
│  │          │ │ :7051    │ │ :9051    │ │         ││
│  └──────────┘ └──────────┘ └──────────┘ └─────────┘│
│                        localhost                    │
└─────────────────────────────────────────────────────┘
```

### **To Production (Multi-VPS)**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VPS-ORDERER   │    │    VPS-ORG1     │    │    VPS-ORG2     │
│                 │    │                 │    │                 │
│  ┌──────────┐   │    │  ┌──────────┐   │    │  ┌──────────┐   │
│  │ Orderer  │   │◄──►│  │  Peer0   │   │◄──►│  │  Peer0   │   │
│  │:7050     │   │    │  │ :7051    │   │    │  │ :7051    │   │
│  └──────────┘   │    │  │          │   │    │  │          │   │
│                 │    │  │ ┌─────┐  │   │    │  │ ┌─────┐  │   │
│  IP: 10.0.1.10  │    │  │ │ CA  │  │   │    │  │ │ CA  │  │   │
│                 │    │  │ │:7054│  │   │    │  │ │:7054│  │   │
│                 │    │  │ └─────┘  │   │    │  │ └─────┘  │   │
│                 │    │  └──────────┘   │    │  └──────────┘   │
│                 │    │                 │    │                 │
│                 │    │  IP: 10.0.1.11  │    │  IP: 10.0.1.12  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Administrative VPS**
```
┌─────────────────┐
│  VPS-ADMIN      │
│                 │
│  ┌──────────┐   │
│  │ Admin    │   │◄─── Connects to all Fabric nodes
│  │ Server   │   │
│  │ :3000    │   │
│  └──────────┘   │
│                 │
│  ┌──────────┐   │
│  │ Explorer │   │◄─── Blockchain visualization
│  │ :8080    │   │
│  └──────────┘   │
│                 │
│  IP: 10.0.1.20  │
└─────────────────┘
```

## 🌐 VPS Infrastructure Planning

### **Option 1: Minimum 4-VPS Setup**
| VPS | Role | Components | Resources | Public IP |
|-----|------|------------|-----------|-----------|
| **VPS-ORDERER** | Ordering Service | Orderer + Admin Tools | 2 CPU, 4GB RAM, 50GB SSD | 202.x.x.10 |
| **VPS-ORG1** | Organization 1 | Peer + CA + CouchDB | 2 CPU, 4GB RAM, 100GB SSD | 202.x.x.11 |
| **VPS-ORG2** | Organization 2 | Peer + CA + CouchDB | 2 CPU, 4GB RAM, 100GB SSD | 202.x.x.12 |
| **VPS-ADMIN** | Application Layer | Admin Server + Explorer + Database | 2 CPU, 4GB RAM, 50GB SSD | 202.x.x.20 |

### **Option 2: Expanded Setup (High Availability)**
| VPS | Role | Components | Resources |
|-----|------|------------|-----------|
| **VPS-ORDERER-1** | Primary Orderer | Orderer Node 1 | 2 CPU, 4GB RAM |
| **VPS-ORDERER-2** | Secondary Orderer | Orderer Node 2 | 2 CPU, 4GB RAM |
| **VPS-ORDERER-3** | Tertiary Orderer | Orderer Node 3 | 2 CPU, 4GB RAM |
| **VPS-ORG1-PEER1** | Org1 Primary Peer | Peer0 + CA | 2 CPU, 4GB RAM |
| **VPS-ORG1-PEER2** | Org1 Secondary Peer | Peer1 (optional) | 2 CPU, 4GB RAM |
| **VPS-ORG2-PEER1** | Org2 Primary Peer | Peer0 + CA | 2 CPU, 4GB RAM |
| **VPS-ORG2-PEER2** | Org2 Secondary Peer | Peer1 (optional) | 2 CPU, 4GB RAM |
| **VPS-ADMIN** | Application | Admin + Explorer | 2 CPU, 4GB RAM |

### **Network Requirements**
- **Bandwidth**: 100 Mbps+ cho mỗi VPS
- **Latency**: <50ms giữa các Fabric nodes
- **Firewall**: Specific port openings (chi tiết bên dưới)
- **Load Balancer**: Optional cho high availability

## ⚙️ Network Configuration

### **Required Port Openings**

#### **VPS-ORDERER** (10.0.1.10)
```bash
# External access
sudo ufw allow 7050/tcp    # Orderer service
sudo ufw allow 7053/tcp    # Orderer admin
sudo ufw allow 9443/tcp    # Prometheus metrics (optional)

# Internal communication (only from Fabric network)
sudo ufw allow from 10.0.1.11 to any port 7050
sudo ufw allow from 10.0.1.12 to any port 7050
sudo ufw allow from 10.0.1.20 to any port 7050
```

#### **VPS-ORG1** (10.0.1.11)
```bash
# Peer service
sudo ufw allow 7051/tcp    # Peer service
sudo ufw allow 7052/tcp    # Chaincode service
sudo ufw allow 9444/tcp    # Prometheus metrics

# Certificate Authority
sudo ufw allow 7054/tcp    # CA service

# CouchDB (if using)
sudo ufw allow 5984/tcp    # CouchDB

# Internal gossip communication
sudo ufw allow from 10.0.1.12 to any port 7051
sudo ufw allow from 10.0.1.10 to any port 7051
sudo ufw allow from 10.0.1.20 to any port 7051
```

#### **VPS-ORG2** (10.0.1.12)
```bash
# Peer service  
sudo ufw allow 7051/tcp    # Peer service
sudo ufw allow 7052/tcp    # Chaincode service
sudo ufw allow 9445/tcp    # Prometheus metrics

# Certificate Authority
sudo ufw allow 8054/tcp    # CA service (different port)

# CouchDB
sudo ufw allow 6984/tcp    # CouchDB (different port)

# Internal gossip communication  
sudo ufw allow from 10.0.1.11 to any port 7051
sudo ufw allow from 10.0.1.10 to any port 7051
sudo ufw allow from 10.0.1.20 to any port 7051
```

#### **VPS-ADMIN** (10.0.1.20)
```bash
# Application services
sudo ufw allow 3000/tcp    # Admin API
sudo ufw allow 8080/tcp    # Hyperledger Explorer

# Database
sudo ufw allow 5432/tcp    # PostgreSQL (for Explorer)
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 80/tcp      # HTTP redirect

# Outbound connections to Fabric network
# (outbound rules - usually allowed by default)
```

### **Docker Compose Modifications**

#### **VPS-ORDERER Production Compose**
```yaml
# docker-compose-orderer.yaml
version: '3.7'

volumes:
  orderer.example.com:

networks:
  production:
    name: fabric_production

services:
  orderer.example.com:
    container_name: orderer.example.com
    image: hyperledger/fabric-orderer:latest
    environment:
      - FABRIC_LOGGING_SPEC=INFO
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_LISTENPORT=7050
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
      - ORDERER_GENERAL_TLS_ENABLED=true
      - ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_GENERAL_BOOTSTRAPMETHOD=none
      - ORDERER_CHANNELPARTICIPATION_ENABLED=true
      - ORDERER_ADMIN_TLS_ENABLED=true
      - ORDERER_ADMIN_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_ADMIN_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_ADMIN_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_ADMIN_TLS_CLIENTROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_ADMIN_LISTENADDRESS=0.0.0.0:7053
      - ORDERER_OPERATIONS_LISTENADDRESS=0.0.0.0:9443
      - ORDERER_METRICS_PROVIDER=prometheus
    working_dir: /root
    command: orderer
    volumes:
      - ./crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp
      - ./crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/:/var/hyperledger/orderer/tls
      - orderer.example.com:/var/hyperledger/production/orderer
    ports:
      - "7050:7050"
      - "7053:7053"
      - "9443:9443"
    networks:
      - production
    restart: unless-stopped
```

#### **VPS-ORG1 Production Compose**  
```yaml
# docker-compose-org1.yaml
version: '3.7'

volumes:
  peer0.org1.example.com:
  couchdb_org1:

networks:
  production:
    name: fabric_production  

services:
  ca_org1:
    image: hyperledger/fabric-ca:latest
    container_name: ca_org1
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-org1
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT=7054
    ports:
      - "7054:7054"
    volumes:
      - ./crypto/peerOrganizations/org1.example.com/ca/:/etc/hyperledger/fabric-ca-server
    networks:
      - production
    restart: unless-stopped

  couchdb_org1:
    container_name: couchdb_org1
    image: couchdb:3.1.1
    environment:
      - COUCHDB_USER=admin
      - COUCHDB_PASSWORD=adminpw
    ports:
      - "5984:5984"
    volumes:
      - couchdb_org1:/opt/couchdb/data
    networks:
      - production
    restart: unless-stopped

  peer0.org1.example.com:
    container_name: peer0.org1.example.com
    image: hyperledger/fabric-peer:latest
    environment:
      - FABRIC_CFG_PATH=/etc/hyperledger/peercfg
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=false
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      - CORE_PEER_ID=peer0.org1.example.com
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
      - CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
      - CORE_OPERATIONS_LISTENADDRESS=0.0.0.0:9444
      - CORE_METRICS_PROVIDER=prometheus
      # State database
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb_org1:5984
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=admin
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=adminpw
    volumes:
      - ./crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com:/etc/hyperledger/fabric
      - peer0.org1.example.com:/var/hyperledger/production
    working_dir: /root
    command: peer node start
    ports:
      - "7051:7051"
      - "9444:9444"
    depends_on:
      - couchdb_org1
    networks:
      - production  
    restart: unless-stopped
```

## 🔐 Certificate Management

### **Production Certificate Generation**

#### **1. Generate Crypto Materials with Real Hostnames**
```bash
# Modify cryptogen config for production hostnames
# crypto-config.yaml

OrdererOrgs:
  - Name: Orderer
    Domain: example.com
    Specs:
      - Hostname: orderer    # Will create orderer.example.com
        SANS:
          - localhost
          - orderer.example.com
          - 10.0.1.10        # VPS-ORDERER IP
          - 202.x.x.10       # Public IP

PeerOrgs:
  - Name: Org1
    Domain: org1.example.com
    Template:
      Count: 1
      SANS:
        - localhost
        - peer0.org1.example.com
        - 10.0.1.11         # VPS-ORG1 IP  
        - 202.x.x.11        # Public IP
        
  - Name: Org2  
    Domain: org2.example.com
    Template:
      Count: 1
      SANS:
        - localhost
        - peer0.org2.example.com
        - 10.0.1.12         # VPS-ORG2 IP
        - 202.x.x.12        # Public IP
```

#### **2. Generate Production Certificates**
```bash
# Generate crypto materials
../bin/cryptogen generate --config=./crypto-config.yaml --output="crypto"

# Or use Fabric CA for production
./fabric-ca-generate-production.sh
```

#### **3. Certificate Distribution**
```bash
# Copy certificates to respective VPS machines

# To VPS-ORDERER  
rsync -avz crypto/ordererOrganizations/ root@10.0.1.10:/opt/fabric/crypto/ordererOrganizations/

# To VPS-ORG1
rsync -avz crypto/peerOrganizations/org1.example.com/ root@10.0.1.11:/opt/fabric/crypto/peerOrganizations/org1.example.com/

# To VPS-ORG2  
rsync -avz crypto/peerOrganizations/org2.example.com/ root@10.0.1.12:/opt/fabric/crypto/peerOrganizations/org2.example.com/

# To VPS-ADMIN (for client access)
rsync -avz crypto/ root@10.0.1.20:/opt/fabric/crypto/
```

### **Production Connection Profiles**

#### **connection-org1-production.json**
```json
{
    "name": "production-network-org1",
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {"endorser": "300"},
                "orderer": "300"
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": ["peer0.org1.example.com"],
            "certificateAuthorities": ["ca.org1.example.com"]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpcs://10.0.1.10:7050",
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\n[PRODUCTION_ORDERER_TLS_CERT]\n-----END CERTIFICATE-----\n"
            },
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com",
                "hostnameOverride": "orderer.example.com"
            }
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpcs://10.0.1.11:7051",
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\n[PRODUCTION_ORG1_PEER_TLS_CERT]\n-----END CERTIFICATE-----\n"
            },
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com",
                "hostnameOverride": "peer0.org1.example.com"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "https://10.0.1.11:7054",
            "caName": "ca-org1",
            "tlsCACerts": {
                "pem": ["-----BEGIN CERTIFICATE-----\n[PRODUCTION_ORG1_CA_TLS_CERT]\n-----END CERTIFICATE-----\n"]
            },
            "httpOptions": {"verify": false}
        }
    }
}
```

## 🔧 Admin Server Modifications

### **Environment Variables** (Production `.env`)
```bash
# Production Network Configuration
FABRIC_CHANNEL_NAME=rentingchannel
FABRIC_CHAINCODE_NAME=renting
FABRIC_MSP_ID=Org1MSP

# Production Paths
FABRIC_CRYPTO_PATH=/opt/fabric/crypto/peerOrganizations/org1.example.com
FABRIC_USER_NAME=User1@org1.example.com
FABRIC_PEER_NAME=peer0.org1.example.com

# Production Endpoints (không còn localhost)
FABRIC_PEER_ENDPOINT=10.0.1.11:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com
FABRIC_ORDERER_ENDPOINT=10.0.1.10:7050
FABRIC_CA_ENDPOINT=10.0.1.11:7054

# Production Certificate Paths
FABRIC_KEY_DIR=/opt/fabric/crypto/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore
FABRIC_CERT_PATH=/opt/fabric/crypto/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem
FABRIC_TLS_CERT_PATH=/opt/fabric/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

# Production Connection Profile
FABRIC_CONNECTION_PROFILE=/opt/fabric/connection-profiles/connection-org1-production.json

# Network Discovery (production setting)
FABRIC_DISCOVERY_AS_LOCALHOST=false
FABRIC_DISCOVERY_ENABLED=true
```

### **Code Modifications Required**

#### **1. Update fabricClient.ts**
```typescript
// src/lib/fabric/fabricClient.ts

const loadConfigFromEnv = (): FabricConfig => {
    const cryptoPath = process.env.FABRIC_CRYPTO_PATH || '/opt/fabric/crypto/peerOrganizations/org1.example.com';
    const userName = process.env.FABRIC_USER_NAME || 'User1@org1.example.com';
    const peerName = process.env.FABRIC_PEER_NAME || 'peer0.org1.example.com';

    return {
        channelName: process.env.FABRIC_CHANNEL_NAME || 'rentingchannel',
        chaincodeName: process.env.FABRIC_CHAINCODE_NAME || 'renting',
        mspId: process.env.FABRIC_MSP_ID || 'Org1MSP',
        cryptoPath,
        keyDirectoryPath: process.env.FABRIC_KEY_DIR || 
            path.resolve(cryptoPath, 'users', userName, 'msp', 'keystore'),
        certPath: process.env.FABRIC_CERT_PATH ||
            path.resolve(cryptoPath, 'users', userName, 'msp', 'signcerts', `${userName}-cert.pem`),
        tlsCertPath: process.env.FABRIC_TLS_CERT_PATH ||
            path.resolve(cryptoPath, 'peers', peerName, 'tls', 'ca.crt'),
        // PRODUCTION: Use actual IP addresses instead of localhost
        peerEndpoint: process.env.FABRIC_PEER_ENDPOINT || '10.0.1.11:7051',
        peerHostAlias: process.env.FABRIC_PEER_HOST_ALIAS || peerName,
        ordererEndpoint: process.env.FABRIC_ORDERER_ENDPOINT || '10.0.1.10:7050',
    };
};
```

#### **2. Update Connection Profile Loading**
```typescript
// src/lib/fabric/caClient.ts

const ccpPath = process.env.FABRIC_CONNECTION_PROFILE || 
    path.resolve(
        process.env.FABRIC_CRYPTO_PATH || '/opt/fabric/crypto/peerOrganizations/org1.example.com',
        'connection-org1-production.json'  // Use production profile
    );
```

#### **3. Update Discovery Settings**
```typescript
// src/repositories/blockchainFabricRepository.ts

await this.gateway.connect(ccp, {
    wallet,
    identity: userId,
    discovery: { 
        enabled: process.env.FABRIC_DISCOVERY_ENABLED === 'true' || true,
        asLocalhost: process.env.FABRIC_DISCOVERY_AS_LOCALHOST === 'true' || false  // FALSE for production
    }
});
```

#### **4. Update Health Check Script**
```typescript
// src/script-fabric-blockchain/healthCheck.ts

async checkCAConnectivity(): Promise<void> {
    try {
        const caUrl = process.env.FABRIC_CA_ENDPOINT || 'https://10.0.1.11:7054';  // Production endpoint
        const caName = process.env.FABRIC_CA_NAME || 'ca-org1';
        
        // For production, may need to verify certificates
        const tlsOptions = process.env.NODE_ENV === 'production' ? {
            trustedRoots: readFileSync(process.env.FABRIC_TLS_CERT_PATH!, 'utf8'),
            verify: true  // Enable certificate verification in production
        } : { verify: false };
        
        const ca = new FabricCAServices(caUrl, tlsOptions, caName);
        const caInfo = await ca.getCaInfo();
        
        // ... rest of the function
    } catch (error: any) {
        // Enhanced error handling for production network issues
    }
}
```

### **Production Deployment Script**
```bash
#!/bin/bash
# deploy-admin-production.sh

# Stop development services
docker-compose down

# Update environment
cp .env.production .env

# Copy production certificates
sudo rsync -avz /tmp/production-crypto/ /opt/fabric/crypto/

# Copy production connection profiles  
sudo cp connection-profiles/production/* /opt/fabric/connection-profiles/

# Install dependencies
npm install --production

# Build for production
npm run build

# Start production services
NODE_ENV=production npm start
```

## ✅ Deployment Checklist

### **Pre-Deployment**
- [ ] **VPS Preparation**
  - [ ] All VPS instances provisioned với adequate resources
  - [ ] Docker và Docker Compose installed trên all VPS
  - [ ] Network connectivity between VPS tested
  - [ ] Domain names configured (nếu sử dụng)

- [ ] **Security Setup**  
  - [ ] Firewall rules configured correctly
  - [ ] SSH key authentication setup
  - [ ] Certificate và private key files có proper permissions (600)
  - [ ] Production passwords generated và stored securely

- [ ] **Certificate Generation**
  - [ ] Production crypto materials generated với real hostnames/IPs
  - [ ] TLS certificates include proper SAN entries
  - [ ] Certificates distributed to respective VPS machines
  - [ ] Certificate expiration dates noted for renewal planning

### **Deployment Execution**
- [ ] **Network Bootstrap**
  - [ ] Start Orderer service trên VPS-ORDERER
  - [ ] Start CA services trên organization VPS
  - [ ] Start Peer services trên organization VPS
  - [ ] Verify all services are healthy và reachable

- [ ] **Channel & Chaincode**
  - [ ] Create channel với production orderer
  - [ ] Join peers to channel
  - [ ] Package và install chaincode on all peers
  - [ ] Approve chaincode for all organizations
  - [ ] Commit chaincode definition to channel

- [ ] **Application Configuration**
  - [ ] Deploy Admin server với production configuration
  - [ ] Deploy Hyperledger Explorer với production settings
  - [ ] Test connection from Admin server to blockchain network
  - [ ] Verify transaction submission/query functionality

### **Post-Deployment Verification**
- [ ] **Functional Testing**
  - [ ] Submit test transactions to verify end-to-end functionality
  - [ ] Verify user registration/certificate enrollment
  - [ ] Test apartment creation và rental contract workflow
  - [ ] Confirm blockchain data persistence

- [ ] **Performance Testing**  
  - [ ] Load test transaction throughput
  - [ ] Monitor resource utilization on all VPS
  - [ ] Verify network latency between nodes
  - [ ] Test failover scenarios (if HA setup)

- [ ] **Security Validation**
  - [ ] Verify TLS encryption is working
  - [ ] Confirm access controls với proper authentication
  - [ ] Test certificate validation
  - [ ] Audit logs for unauthorized access attempts

## 🔒 Security Considerations

### **Network Security**
```bash
# Additional firewall hardening
# Block all non-essential ports
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow specific Fabric ports only from known IPs
sudo ufw allow from 10.0.1.0/24 to any port 7050
sudo ufw allow from 10.0.1.0/24 to any port 7051
sudo ufw allow from 10.0.1.0/24 to any port 7054

# Block direct access to CouchDB from external
sudo ufw deny 5984

# Enable logging  
sudo ufw logging on
```

### **Certificate Security**
```bash
# Set proper permissions on certificate files
sudo chown -R fabric:fabric /opt/fabric/crypto
sudo chmod -R 600 /opt/fabric/crypto/*/private_keys/*
sudo chmod -R 644 /opt/fabric/crypto/*/ca/*
sudo chmod -R 644 /opt/fabric/crypto/*/tlsca/*

# Regular certificate backup
#!/bin/bash
# backup-crypto.sh
tar -czf "crypto-backup-$(date +%Y%m%d).tar.gz" /opt/fabric/crypto
scp crypto-backup-*.tar.gz secure-backup-location:/backups/
```

### **Application Security**
```typescript
// Production security headers
app.use(helmet({
    contentSecurityPolicy: true,
    crossOriginEmbedderPolicy: true
}));

// Rate limiting
app.use(rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
}));

// Production error handling (no stack traces)
if (process.env.NODE_ENV === 'production') {
    app.use((err, req, res, next) => {
        res.status(500).json({ error: 'Internal server error' });
    });
}
```

## 📊 Monitoring & Maintenance

### **System Monitoring**
```yaml
# docker-compose-monitoring.yaml
version: '3.7'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      
  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=secure_password
    volumes:
      - grafana-data:/var/lib/grafana
```

### **Health Check Scripts**
```bash
#!/bin/bash
# health-check-production.sh

echo "Checking Fabric Network Health..."

# Check Orderer
if curl -s --max-time 5 https://10.0.1.10:7050 >/dev/null; then
    echo "✅ Orderer is responsive"
else
    echo "❌ Orderer is not responsive" 
fi

# Check Org1 Peer
if ./peer-health-check.sh 10.0.1.11 7051; then
    echo "✅ Org1 Peer is healthy"
else
    echo "❌ Org1 Peer has issues"
fi

# Check Org2 Peer  
if ./peer-health-check.sh 10.0.1.12 7051; then
    echo "✅ Org2 Peer is healthy"
else
    echo "❌ Org2 Peer has issues"
fi

# Check Admin Server
if curl -s --max-time 5 http://10.0.1.20:3000/health >/dev/null; then
    echo "✅ Admin Server is responsive"
else
    echo "❌ Admin Server is not responsive"
fi
```

### **Backup Strategy**
```bash
#!/bin/bash
# backup-production.sh

DATE=$(date +%Y%m%d_%H%M%S)

# Backup blockchain ledger data
docker exec peer0.org1.example.com tar czf - /var/hyperledger/production > "backup_org1_${DATE}.tar.gz"
docker exec peer0.org2.example.com tar czf - /var/hyperledger/production > "backup_org2_${DATE}.tar.gz"

# Backup application data
pg_dump fabricexplorer > "backup_explorer_${DATE}.sql"

# Backup certificates
tar czf "backup_crypto_${DATE}.tar.gz" /opt/fabric/crypto

# Upload to secure backup location
aws s3 cp backup_*_${DATE}.* s3://fabric-backup-bucket/
```

## 🚨 Troubleshooting

### **Common Production Issues**

#### **1. Peer Connection Issues**  
```bash
# Symptoms: Peers cannot connect to orderer
# Check:
docker logs peer0.org1.example.com | grep -i error
netstat -tlnp | grep 7050

# Solution:
# - Verify firewall rules
# - Check certificate SAN entries
# - Confirm orderer is listening on correct interface
```

#### **2. Certificate Validation Failures**
```bash
# Symptoms: TLS handshake failures
# Check:
openssl s_client -connect 10.0.1.10:7050 -servername orderer.example.com

# Solution:  
# - Regenerate certificates với production hostnames
# - Verify SAN entries include production IPs
# - Check certificate expiration dates
```

#### **3. Discovery Service Issues**
```bash
# Symptoms: Admin server cannot discover peers
# Check discovery settings:
export CORE_PEER_ADDRESS=10.0.1.11:7051
peer channel fetch config

# Solution:
# - Set discovery.asLocalhost=false
# - Verify peer external endpoints
# - Check gossip configuration
```

#### **4. Transaction Endorsement Failures**
```bash
# Symptoms: Insufficient endorsements
# Check peer availability:
peer chaincode query -C rentingchannel -n renting -c '{"function":"GetUserById","Args":["test"]}'

# Solution:
# - Verify all required peers are online
# - Check endorsement policy compliance  
# - Review chaincode installation status
```

---

### **🎯 Summary**

Production deployment requires:
1. **Infrastructure**: Separate VPS cho orderer, peers, và admin services
2. **Networking**: Proper firewall rules và port access
3. **Certificates**: Production certs với real hostnames/IPs
4. **Configuration**: Update all localhost references to production IPs  
5. **Security**: TLS validation, proper permissions, monitoring
6. **Monitoring**: Health checks, metrics collection, automated backups

**Critical changes in Admin server:**
- Update `.env` với production endpoints
- Change `discovery.asLocalhost` to `false`
- Update connection profiles với production IPs
- Verify certificate paths point to production crypto materials