# Admin Server Production Changes Checklist

## 🎯 Critical Changes Required for Production

### **1. Environment Configuration** 

#### **Current (.env for development)**
```bash
FABRIC_PEER_ENDPOINT=localhost:7051
FABRIC_PEER_HOST_ALIAS=peer0.org1.example.com
FABRIC_CRYPTO_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com
```

#### **Required (.env.production)**
```bash
# Production Network Endpoints
FABRIC_PEER_ENDPOINT=10.0.1.11:7051          # ❌ Was: localhost:7051
FABRIC_ORDERER_ENDPOINT=10.0.1.10:7050       # ❌ Was: localhost:7050  
FABRIC_CA_ENDPOINT=10.0.1.11:7054            # ❌ Was: localhost:7054

# Production Certificate Paths
FABRIC_CRYPTO_PATH=/opt/fabric/crypto/peerOrganizations/org1.example.com  # ❌ Was: test-network path
FABRIC_CONNECTION_PROFILE=/opt/fabric/connection-profiles/connection-org1-production.json

# Production Discovery Settings
FABRIC_DISCOVERY_AS_LOCALHOST=false          # ❌ Was: true (or undefined)
FABRIC_DISCOVERY_ENABLED=true

# Production TLS Settings
FABRIC_TLS_ENABLED=true
FABRIC_TLS_VERIFY=true                        # ❌ Was: false for development
```

---

### **2. Code Files Requiring Updates**

#### **File: `/src/lib/fabric/fabricClient.ts`**

**Current (Development):**
```typescript
peerEndpoint: process.env.FABRIC_PEER_ENDPOINT || 'localhost:7051',
```

**Required (Production):**
```typescript
peerEndpoint: process.env.FABRIC_PEER_ENDPOINT || '10.0.1.11:7051',
ordererEndpoint: process.env.FABRIC_ORDERER_ENDPOINT || '10.0.1.10:7050',
```

**Add new configuration options:**
```typescript
export type FabricConfig = {
    // ... existing fields
    ordererEndpoint: string;          // ✅ ADD
    caEndpoint: string;               // ✅ ADD
    tlsEnabled: boolean;              // ✅ ADD
    discoveryAsLocalhost: boolean;    // ✅ ADD
};
```

---

#### **File: `/src/lib/fabric/caClient.ts`**

**Current (Development):**
```typescript
const ccpPath = path.resolve(
    process.env.FABRIC_CRYPTO_PATH || '/root/.../test-network/organizations/...',
    'connection-org1.json'
);
```

**Required (Production):**
```typescript
const ccpPath = process.env.FABRIC_CONNECTION_PROFILE || path.resolve(
    process.env.FABRIC_CRYPTO_PATH || '/opt/fabric/crypto/peerOrganizations/org1.example.com',
    'connection-org1-production.json'    // ❌ Filename change
);

// Add production TLS configuration
const tlsOptions = process.env.NODE_ENV === 'production' ? {
    trustedRoots: readFileSync(process.env.FABRIC_TLS_CERT_PATH!, 'utf8'),
    verify: process.env.FABRIC_TLS_VERIFY === 'true'
} : { verify: false };
```

---

#### **File: `/src/repositories/blockchainFabricRepository.ts`**

**Current (Development):**  
```typescript
discovery: { enabled: true, asLocalhost: true }
```

**Required (Production):**
```typescript
discovery: { 
    enabled: process.env.FABRIC_DISCOVERY_ENABLED !== 'false',
    asLocalhost: process.env.FABRIC_DISCOVERY_AS_LOCALHOST === 'true'  // ❌ Will be false
}
```

---

#### **File: `/src/script-fabric-blockchain/healthCheck.ts`**

**Current (Development):**
```typescript
const ca = new FabricCAServices(caUrl, { verify: false }, caName);
```

**Required (Production):**
```typescript
const tlsOptions = process.env.NODE_ENV === 'production' ? {
    trustedRoots: readFileSync(process.env.FABRIC_TLS_CERT_PATH!, 'utf8'),
    verify: true  // ❌ Enable verification in production
} : { verify: false };

const ca = new FabricCAServices(caUrl, tlsOptions, caName);
```

---

### **3. New Files Required**

#### **Create: `/config/connection-org1-production.json`**
```json
{
    "name": "production-network-org1",
    "version": "1.0.0",
    "client": {"organization": "Org1"},
    "orderers": {
        "orderer.example.com": {
            "url": "grpcs://10.0.1.10:7050",                    // ❌ Was: localhost:7050
            "tlsCACerts": {"pem": "[PRODUCTION_ORDERER_CERT]"},
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com"
            }
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpcs://10.0.1.11:7051",                   // ❌ Was: localhost:7051  
            "tlsCACerts": {"pem": "[PRODUCTION_PEER_CERT]"},
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "https://10.0.1.11:7054",                   // ❌ Was: localhost:7054
            "caName": "ca-org1",
            "tlsCACerts": {"pem": ["[PRODUCTION_CA_CERT]"]}
        }
    }
}
```

#### **Create: `/scripts/deploy-production.sh`**
```bash
#!/bin/bash

# Copy production certificates
sudo mkdir -p /opt/fabric/crypto
sudo rsync -avz /tmp/production-crypto/ /opt/fabric/crypto/

# Copy production connection profiles
sudo mkdir -p /opt/fabric/connection-profiles  
sudo cp config/connection-org1-production.json /opt/fabric/connection-profiles/

# Set production environment
cp .env.production .env

# Install production dependencies
npm ci --only=production

# Start with production configuration
NODE_ENV=production npm start
```

---

### **4. Docker & Infrastructure Changes**

#### **Current docker-compose.yml (if using)**
```yaml
# Development - all services on localhost
services:
  admin-server:
    environment:
      - FABRIC_PEER_ENDPOINT=localhost:7051
```

#### **Required docker-compose.production.yml**
```yaml
# Production - services on different VPS
services:
  admin-server:
    environment:
      - FABRIC_PEER_ENDPOINT=10.0.1.11:7051        # ❌ External VPS IP
      - FABRIC_ORDERER_ENDPOINT=10.0.1.10:7050     # ❌ External VPS IP
      - FABRIC_DISCOVERY_AS_LOCALHOST=false        # ❌ Critical change
    volumes:
      - /opt/fabric/crypto:/opt/fabric/crypto:ro   # ❌ Production cert path
      - /opt/fabric/connection-profiles:/opt/fabric/connection-profiles:ro
```

---

### **5. Security & TLS Configuration**

#### **Current (Development - Relaxed Security)**
```typescript
tlsOptions: { verify: false }
```

#### **Required (Production - Strict Security)**
```typescript
// Proper TLS validation
if (process.env.NODE_ENV === 'production') {
    tlsOptions = {
        trustedRoots: readFileSync(process.env.FABRIC_TLS_CERT_PATH!, 'utf8'),
        verify: true,
        checkServerIdentity: (hostname, cert) => {
            // Custom hostname verification if needed
            return undefined; // undefined = default verification
        }
    };
} else {
    tlsOptions = { verify: false };
}
```

---

### **6. Deployment Sequence**

#### **Phase 1: Infrastructure Preparation**
```bash
# On VPS-ADMIN (10.0.1.20)

# 1. Create production directories
sudo mkdir -p /opt/fabric/{crypto,connection-profiles,logs}

# 2. Copy production certificates from build machine
scp -r production-crypto/* root@10.0.1.20:/opt/fabric/crypto/

# 3. Copy production connection profiles
scp config/connection-*-production.json root@10.0.1.20:/opt/fabric/connection-profiles/

# 4. Set proper permissions
sudo chown -R nodeuser:nodeuser /opt/fabric/
sudo chmod -R 600 /opt/fabric/crypto/*/private_keys/*
```

#### **Phase 2: Application Deployment**
```bash
# 5. Deploy admin application
git clone <admin-repo> /opt/fabric-admin
cd /opt/fabric-admin

# 6. Install dependencies
npm ci --only=production

# 7. Copy production configuration
cp .env.production .env

# 8. Build application (if needed)
npm run build

# 9. Start production services
NODE_ENV=production pm2 start ecosystem.config.js
```

#### **Phase 3: Verification**
```bash
# 10. Test network connectivity
npm run fabric:health

# 11. Test transaction functionality  
npm run test:production

# 12. Verify blockchain explorer
curl http://10.0.1.20:8080
```

---

### **7. Critical Configuration Summary**

| Component | Development | Production | Action Required |
|-----------|-------------|------------|-----------------|
| **Peer Endpoint** | `localhost:7051` | `10.0.1.11:7051` | ❌ Update .env |
| **Orderer Endpoint** | `localhost:7050` | `10.0.1.10:7050` | ❌ Update .env |
| **CA Endpoint** | `localhost:7054` | `10.0.1.11:7054` | ❌ Update .env |
| **Discovery asLocalhost** | `true` | `false` | ❌ Update code |
| **TLS Verify** | `false` | `true` | ❌ Update code |
| **Crypto Path** | `/test-network/...` | `/opt/fabric/crypto/...` | ❌ Update .env |
| **Connection Profile** | `connection-org1.json` | `connection-org1-production.json` | ❌ Create new file |
| **Certificate Validation** | Disabled | Enabled | ❌ Update code |

---

### **8. Testing Checklist** 

After deployment, verify these functions work:

- [ ] **Health Check**: `npm run fabric:health` passes
- [ ] **User Creation**: Can create user certificate và store identity  
- [ ] **Transaction Submit**: Can create apartment/user on blockchain
- [ ] **Query Function**: Can retrieve data from blockchain
- [ ] **Explorer Access**: Blockchain explorer shows network activity
- [ ] **Certificate Rotation**: Identity management functions work
- [ ] **Error Handling**: Proper error messages for network issues

---

### **9. Rollback Plan**

Nếu production deployment fails:

```bash
# Quick rollback to development
cp .env.development .env
docker-compose down
docker-compose up -d

# Or rollback to previous production version
pm2 reload ecosystem.config.js --update-env
```

---

## 🚨 Most Critical Changes

**Top 3 cần phải thay đổi:**

1. **Discovery Setting**: `asLocalhost: false` - Without này Admin server không thể discover production peers
2. **Connection Profile**: Create production profile với real IP addresses thay vì localhost  
3. **Environment Endpoints**: Update tất cả localhost references thành production VPS IPs

**These changes are MANDATORY** - Admin server will not work với production network without them.