# Simple Production Deployment Guide - Phase Migration

## 🎯 Deployment Strategy

**Target Architecture:**
- **VPS-1 (202.x.x.10)**: Orderer + CA Services
- **VPS-2 (202.x.x.11)**: Org1 Peer
- **Local Machine**: Org2 Peer + Admin Server

**Migration Approach:**
Từng bước migrate để minimize risk và downtime.

---

## 📋 Giai đoạn Migration

### **Phase 1: Deploy All to Single VPS**
*Mục tiêu: Move từ local development sang VPS đầu tiên*

### **Phase 2: Split Peer1 to Separate VPS**  
*Mục tiêu: Tách Org1 Peer ra VPS riêng*

### **Phase 3: Move Peer2 Back to Local**
*Mục tiêu: Bring Org2 Peer về máy local*

### **Phase 4: Connect Admin to Local Peer2**
*Mục tiêu: Admin server kết nối với local peer*

### **Phase 5: Network Integration**
*Mục tiêu: Full connectivity giữa all nodes*

---

## 🚀 Phase 1: Deploy All to Single VPS

### **VPS-1 Setup** (202.x.x.10)

#### **1.1 VPS Preparation**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create working directory
sudo mkdir -p /opt/fabric
sudo chown $USER:$USER /opt/fabric
cd /opt/fabric
```

#### **1.2 Upload Fabric Network**
```bash
# On local machine - pack everything
cd /root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2
tar -czf fabric-complete.tar.gz .

# Upload to VPS
scp fabric-complete.tar.gz user@202.x.x.10:/opt/fabric/

# On VPS - extract
cd /opt/fabric
tar -xzf fabric-complete.tar.gz
```

#### **1.3 Modify for VPS Deployment**
```bash
cd test-network

# Modify compose file for external access
cp compose/compose-test-net.yaml compose/compose-vps.yaml
```

**Edit compose/compose-vps.yaml:**
```yaml
version: '3.7'

volumes:
  orderer.example.com:
  peer0.org1.example.com:
  peer0.org2.example.com:

networks:
  fabric:
    name: fabric_network

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
    volumes:
      - ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp
      - ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/:/var/hyperledger/orderer/tls
      - orderer.example.com:/var/hyperledger/production/orderer
    ports:
      - "7050:7050"
      - "7053:7053"
    networks:
      - fabric
    restart: unless-stopped

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
      - ./organizations/fabric-ca/org1:/etc/hyperledger/fabric-ca-server
    networks:
      - fabric
    restart: unless-stopped

  ca_org2:
    image: hyperledger/fabric-ca:latest
    container_name: ca_org2
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-org2
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT=8054
    ports:
      - "8054:8054"
    volumes:
      - ./organizations/fabric-ca/org2:/etc/hyperledger/fabric-ca-server
    networks:
      - fabric
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
    volumes:
      - ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com:/etc/hyperledger/fabric
      - peer0.org1.example.com:/var/hyperledger/production
    working_dir: /root
    command: peer node start
    ports:
      - "7051:7051"
    networks:
      - fabric
    restart: unless-stopped

  peer0.org2.example.com:
    container_name: peer0.org2.example.com
    image: hyperledger/fabric-peer:latest
    environment:
      - FABRIC_CFG_PATH=/etc/hyperledger/peercfg
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=false
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      - CORE_PEER_ID=peer0.org2.example.com
      - CORE_PEER_ADDRESS=peer0.org2.example.com:9051
      - CORE_PEER_LISTENADDRESS=0.0.0.0:9051
      - CORE_PEER_CHAINCODEADDRESS=peer0.org2.example.com:9052
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:9052
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org2.example.com:9051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:9051
      - CORE_PEER_LOCALMSPID=Org2MSP
      - CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
    volumes:
      - ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com:/etc/hyperledger/fabric
      - peer0.org2.example.com:/var/hyperledger/production
    working_dir: /root
    command: peer node start
    ports:
      - "9051:9051"
    networks:
      - fabric
    restart: unless-stopped
```

#### **1.4 Configure Firewall**
```bash
# Open required ports
sudo ufw allow 22      # SSH
sudo ufw allow 7050    # Orderer
sudo ufw allow 7051    # Peer Org1
sudo ufw allow 7054    # CA Org1
sudo ufw allow 8054    # CA Org2  
sudo ufw allow 9051    # Peer Org2
sudo ufw enable
```

#### **1.5 Start Network**
```bash
# Start all services
docker-compose -f compose/compose-vps.yaml up -d

# Verify all containers running
docker ps

# Create channel and deploy chaincode
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

./network.sh createChannel -c rentingchannel -ca
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go
```

#### **1.6 Test Network**
```bash
# Set peer environment
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Test transaction
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls \
    --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
    -C rentingchannel -n renting --peerAddresses localhost:7051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
    --peerAddresses localhost:9051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
    -c '{"function":"CreateUser","Args":["testuser","Test User","1000","GUEST"]}'

# Verify
peer chaincode query -C rentingchannel -n renting -c '{"function":"GetUserById","Args":["testuser"]}'
```

**✅ Phase 1 Complete: All services running on VPS-1**

---

## 🔄 Phase 2: Split Peer1 to Separate VPS

### **VPS-2 Setup** (202.x.x.11)

#### **2.1 Prepare VPS-2**
```bash
# Same basic setup as VPS-1
sudo apt update && sudo apt upgrade -y
# Install Docker & Docker Compose (same as Phase 1)
sudo mkdir -p /opt/fabric
cd /opt/fabric
```

#### **2.2 Copy Org1 Materials**
```bash
# From VPS-1, package Org1 materials
cd /opt/fabric/test-network
tar -czf org1-materials.tar.gz \
    organizations/fabric-ca/org1/ \
    organizations/peerOrganizations/org1.example.com/ \
    organizations/ordererOrganizations/ \
    channel-artifacts/ \
    ../bin/ \
    ../config/

# Copy to VPS-2
scp org1-materials.tar.gz user@202.x.x.11:/opt/fabric/

# On VPS-2, extract
cd /opt/fabric
tar -xzf org1-materials.tar.gz
```

#### **2.3 Create Org1 Compose File**
**Create /opt/fabric/docker-compose-org1.yaml:**
```yaml
version: '3.7'

volumes:
  peer0.org1.example.com:

networks:
  fabric:
    name: fabric_network

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
      - ./organizations/fabric-ca/org1:/etc/hyperledger/fabric-ca-server
    networks:
      - fabric
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
    volumes:
      - ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com:/etc/hyperledger/fabric
      - peer0.org1.example.com:/var/hyperledger/production
    working_dir: /root
    command: peer node start
    ports:
      - "7051:7051"
    networks:
      - fabric
    restart: unless-stopped
    extra_hosts:
      - "orderer.example.com:202.x.x.10"        # Point to VPS-1
      - "peer0.org2.example.com:202.x.x.10"     # Point to VPS-1 (for now)
```

#### **2.4 Update VPS-1 Configuration**
```bash
# On VPS-1, stop Org1 services
cd /opt/fabric/test-network
docker-compose -f compose/compose-vps.yaml stop peer0.org1.example.com ca_org1

# Update compose file to remove Org1 and point to VPS-2
```

**Edit VPS-1 compose/compose-vps.yaml - remove Org1 services and add:**
```yaml
services:
  orderer.example.com:
    # ... existing config ...
    extra_hosts:
      - "peer0.org1.example.com:202.x.x.11"     # Point to VPS-2

  peer0.org2.example.com:
    # ... existing config ...
    extra_hosts:
      - "peer0.org1.example.com:202.x.x.11"     # Point to VPS-2
      - "orderer.example.com:202.x.x.10"        # Local
```

#### **2.5 Start VPS-2 Services**
```bash
# On VPS-2
sudo ufw allow 7051
sudo ufw allow 7054
sudo ufw enable

# Start Org1 services
docker-compose -f docker-compose-org1.yaml up -d

# Verify
docker ps
```

#### **2.6 Update VPS-1 and Test**
```bash
# On VPS-1, restart remaining services
docker-compose -f compose/compose-vps.yaml up -d

# Test connectivity
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=202.x.x.11:7051     # Now points to VPS-2

# Test query from Org1 peer on VPS-2
peer chaincode query -C rentingchannel -n renting -c '{"function":"GetUserById","Args":["testuser"]}'
```

**✅ Phase 2 Complete: Org1 Peer running on separate VPS-2**

---

## 🏠 Phase 3: Move Peer2 Back to Local

### **Local Machine Setup**

#### **3.1 Prepare Local Environment**
```bash
# On local machine
cd /root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2

# Backup current setup
cp -r test-network test-network-backup

# Download Org2 materials from VPS-1
scp user@202.x.x.10:/opt/fabric/org2-materials.tar.gz ./
```

#### **3.2 Create VPS-1 Org2 Package**
```bash
# On VPS-1, create Org2 package
cd /opt/fabric/test-network
tar -czf org2-materials.tar.gz \
    organizations/fabric-ca/org2/ \
    organizations/peerOrganizations/org2.example.com/ \
    organizations/ordererOrganizations/ \
    channel-artifacts/

# Make available for download
cp org2-materials.tar.gz /tmp/
```

#### **3.3 Extract and Setup Local Org2**
```bash
# On local machine
cd /root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2
tar -xzf org2-materials.tar.gz

# Create local Org2 compose
```

**Create test-network/compose/compose-local-org2.yaml:**
```yaml
version: '3.7'

volumes:
  peer0.org2.example.com:

networks:
  fabric:
    name: fabric_network

services:
  ca_org2:
    image: hyperledger/fabric-ca:latest
    container_name: ca_org2
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-org2
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT=8054
    ports:
      - "8054:8054"
    volumes:
      - ./organizations/fabric-ca/org2:/etc/hyperledger/fabric-ca-server
    networks:
      - fabric
    restart: unless-stopped

  peer0.org2.example.com:
    container_name: peer0.org2.example.com
    image: hyperledger/fabric-peer:latest
    environment:
      - FABRIC_CFG_PATH=/etc/hyperledger/peercfg
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=false
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      - CORE_PEER_ID=peer0.org2.example.com
      - CORE_PEER_ADDRESS=peer0.org2.example.com:9051
      - CORE_PEER_LISTENADDRESS=0.0.0.0:9051
      - CORE_PEER_CHAINCODEADDRESS=peer0.org2.example.com:9052
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:9052
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org2.example.com:9051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:9051
      - CORE_PEER_LOCALMSPID=Org2MSP
      - CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
    volumes:
      - ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com:/etc/hyperledger/fabric
      - peer0.org2.example.com:/var/hyperledger/production
    working_dir: /root
    command: peer node start
    ports:
      - "9051:9051"
    networks:
      - fabric
    restart: unless-stopped
    extra_hosts:
      - "orderer.example.com:202.x.x.10"        # Point to VPS-1
      - "peer0.org1.example.com:202.x.x.11"     # Point to VPS-2
```

#### **3.4 Start Local Org2**
```bash
# On local machine
cd test-network

# Stop VPS Org2 first (coordinate with VPS-1)
# Then start local
docker-compose -f compose/compose-local-org2.yaml up -d

# Verify
docker ps
```

#### **3.5 Update VPS Configurations**
```bash
# On VPS-1, stop Org2 and update hosts
# Point to your public IP or use VPN

# On VPS-2, update extra_hosts to point Org2 to your IP
```

#### **3.6 Test Local Org2**
```bash
# On local machine
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

# Test query
peer chaincode query -C rentingchannel -n renting -c '{"function":"GetUserById","Args":["testuser"]}'
```

**✅ Phase 3 Complete: Org2 Peer running locally**

---

## 💻 Phase 4: Connect Admin to Local Peer2

### **4.1 Update Admin Server Configuration**

**Update quan-ly-tim-kiem-phong-tro-admin/.env:**
```bash
# Fabric Network Configuration  
FABRIC_CHANNEL_NAME=rentingchannel
FABRIC_CHAINCODE_NAME=renting
FABRIC_MSP_ID=Org2MSP                                    # ❌ Changed to Org2

# Local Peer Configuration
FABRIC_CRYPTO_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org2.example.com
FABRIC_USER_NAME=User1@org2.example.com                  # ❌ Changed to Org2
FABRIC_PEER_NAME=peer0.org2.example.com
FABRIC_PEER_ENDPOINT=localhost:9051                      # ❌ Local Org2 peer
FABRIC_PEER_HOST_ALIAS=peer0.org2.example.com

# Orderer Configuration (still on VPS)
FABRIC_ORDERER_ENDPOINT=202.x.x.10:7050                 # ❌ VPS-1 orderer

# Discovery settings
FABRIC_DISCOVERY_AS_LOCALHOST=false                      # ❌ For mixed environment
FABRIC_DISCOVERY_ENABLED=true

# Certificate paths (Org2)
FABRIC_KEY_DIR=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/keystore
FABRIC_CERT_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/signcerts/User1@org2.example.com-cert.pem
FABRIC_TLS_CERT_PATH=/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

### **4.2 Create Mixed Environment Connection Profile**

**Create quan-ly-tim-kiem-phong-tro-admin/config/connection-mixed.json:**
```json
{
    "name": "mixed-network-org2",
    "version": "1.0.0",
    "client": {
        "organization": "Org2"
    },
    "organizations": {
        "Org2": {
            "mspid": "Org2MSP",
            "peers": ["peer0.org2.example.com"],
            "certificateAuthorities": ["ca.org2.example.com"]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpcs://202.x.x.10:7050",
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\n[ORDERER_TLS_CERT_FROM_VPS]\n-----END CERTIFICATE-----\n"
            },
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com",
                "hostnameOverride": "orderer.example.com"
            }
        }
    },
    "peers": {
        "peer0.org2.example.com": {
            "url": "grpcs://localhost:9051",
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\n[LOCAL_ORG2_PEER_TLS_CERT]\n-----END CERTIFICATE-----\n"
            },
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.example.com",
                "hostnameOverride": "peer0.org2.example.com"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org2.example.com": {
            "url": "https://localhost:8054",
            "caName": "ca-org2",
            "tlsCACerts": {
                "pem": ["-----BEGIN CERTIFICATE-----\n[LOCAL_ORG2_CA_TLS_CERT]\n-----END CERTIFICATE-----\n"]
            },
            "httpOptions": {
                "verify": false
            }
        }
    }
}
```

### **4.3 Update Admin Server Code**

**Update quan-ly-tim-kiem-phong-tro-admin/src/lib/fabric/fabricClient.ts:**
```typescript
const defaultCryptoPath = path.resolve(
    process.cwd(),
    '..',
    'blockchain-fabric-v2',
    'test-network',
    'organizations',
    'peerOrganizations',
    'org2.example.com'        // ❌ Changed to org2
);

const loadConfigFromEnv = (): FabricConfig => {
    const cryptoPath = process.env.FABRIC_CRYPTO_PATH || defaultCryptoPath;
    const userName = process.env.FABRIC_USER_NAME || 'User1@org2.example.com';  // ❌ Changed
    const peerName = process.env.FABRIC_PEER_NAME || 'peer0.org2.example.com';  // ❌ Changed

    return {
        channelName: process.env.FABRIC_CHANNEL_NAME || 'rentingchannel',
        chaincodeName: process.env.FABRIC_CHAINCODE_NAME || 'renting',
        mspId: process.env.FABRIC_MSP_ID || 'Org2MSP',                         // ❌ Changed
        cryptoPath,
        keyDirectoryPath:
            process.env.FABRIC_KEY_DIR ||
            path.resolve(cryptoPath, 'users', userName, 'msp', 'keystore'),
        certPath:
            process.env.FABRIC_CERT_PATH ||
        path.resolve(cryptoPath, 'users', userName, 'msp', 'signcerts', `${userName}-cert.pem`),
        tlsCertPath:
            process.env.FABRIC_TLS_CERT_PATH ||
            path.resolve(cryptoPath, 'peers', peerName, 'tls', 'ca.crt'),
        peerEndpoint: process.env.FABRIC_PEER_ENDPOINT || 'localhost:9051',    // ❌ Changed
        peerHostAlias: process.env.FABRIC_PEER_HOST_ALIAS || peerName,
        ordererEndpoint: process.env.FABRIC_ORDERER_ENDPOINT || '202.x.x.10:7050', // ❌ VPS orderer
    };
};
```

### **4.4 Test Admin Connection**
```bash
# Start admin server
cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
npm run dev

# Test health check
npm run fabric:health

# Test transaction
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"id":"testlocal","fullName":"Local Test","balance":2000,"role":"GUEST"}'
```

**✅ Phase 4 Complete: Admin server connected to local Org2 peer**

---

## 🌐 Phase 5: Network Integration & Optimization

### **5.1 Configure Network Connectivity**

#### **Public IP/VPN Setup**
```bash
# Option 1: Use public IP with port forwarding
# Configure router to forward port 9051 to local machine

# Option 2: Setup VPN between VPS and local machine
# Install WireGuard on all machines
sudo apt install wireguard

# Generate keys and configure VPN
# (detailed VPN setup instructions)
```

#### **Update All Host Mappings**
```bash
# On VPS-1 (202.x.x.10)
# Add to docker compose extra_hosts:
- "peer0.org2.example.com:[YOUR_PUBLIC_IP_OR_VPN_IP]"

# On VPS-2 (202.x.x.11)  
# Add to docker compose extra_hosts:
- "peer0.org2.example.com:[YOUR_PUBLIC_IP_OR_VPN_IP]"

# On local machine
# Add to docker compose extra_hosts:
- "orderer.example.com:202.x.x.10"
- "peer0.org1.example.com:202.x.x.11"
```

### **5.2 Network Testing**

#### **Cross-Node Transaction Test**
```bash
# Test transaction requiring both orgs (endorsement policy)
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

# Submit transaction that requires endorsement from both orgs
peer chaincode invoke -o 202.x.x.10:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
    -C rentingchannel -n renting \
    --peerAddresses 202.x.x.11:7051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
    --peerAddresses localhost:9051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
    -c '{"function":"CreateUser","Args":["distributed-test","Distributed User","5000","OWNER"]}'
```

### **5.3 Performance Optimization**

#### **Connection Monitoring**
**Create network-monitor.sh:**
```bash
#!/bin/bash
echo "=== Network Connectivity Check ==="

# Check VPS-1 (Orderer)
if curl -s --max-time 5 202.x.x.10:7050 >/dev/null 2>&1; then
    echo "✅ Orderer (VPS-1) reachable"
else
    echo "❌ Orderer (VPS-1) unreachable"
fi

# Check VPS-2 (Org1)  
if curl -s --max-time 5 202.x.x.11:7051 >/dev/null 2>&1; then
    echo "✅ Org1 Peer (VPS-2) reachable"
else
    echo "❌ Org1 Peer (VPS-2) unreachable"
fi

# Check Local Org2
if curl -s --max-time 5 localhost:9051 >/dev/null 2>&1; then
    echo "✅ Org2 Peer (Local) running"
else
    echo "❌ Org2 Peer (Local) not running"
fi

# Check Admin Server
if curl -s --max-time 5 localhost:3000/health >/dev/null 2>&1; then
    echo "✅ Admin Server responsive"
else
    echo "❌ Admin Server not responsive"
fi
```

### **5.4 Backup & Recovery**

#### **Create Distributed Backup Strategy**
```bash
#!/bin/bash
# backup-distributed.sh

DATE=$(date +%Y%m%d_%H%M%S)

# Backup local Org2 data
docker exec peer0.org2.example.com tar czf - /var/hyperledger/production > "local_org2_backup_${DATE}.tar.gz"

# Backup certificates
tar czf "local_crypto_backup_${DATE}.tar.gz" organizations/

# Sync with VPS for redundancy
scp *_backup_${DATE}.tar.gz user@202.x.x.10:/opt/fabric/backups/
```

**✅ Phase 5 Complete: Fully distributed network operational**

---

## 🎉 Final Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VPS-1         │    │   VPS-2         │    │  Local Machine  │
│   202.x.x.10    │    │   202.x.x.11    │    │   Your IP       │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │  Orderer    │ │◄──►│ │ Org1 Peer   │ │◄──►│ │ Org2 Peer   │ │
│ │  :7050      │ │    │ │ :7051       │ │    │ │ :9051       │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│                 │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│                 │    │ │ CA Org1     │ │    │ │ CA Org2     │ │
│                 │    │ │ :7054       │ │    │ │ :8054       │ │
│                 │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│                 │    │                 │    │ ┌─────────────┐ │
│                 │    │                 │    │ │ Admin       │ │
│                 │    │                 │    │ │ Server      │ │
│                 │    │                 │    │ │ :3000       │ │
│                 │    │                 │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Management Commands

### **Start/Stop Individual Components**
```bash
# VPS-1 (Orderer only)
docker-compose -f compose/compose-vps.yaml up -d orderer.example.com

# VPS-2 (Org1 only)  
docker-compose -f docker-compose-org1.yaml up -d

# Local (Org2 + Admin)
docker-compose -f compose/compose-local-org2.yaml up -d
cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin && npm run dev
```

### **Health Monitoring**
```bash
# Run network monitor
./network-monitor.sh

# Test end-to-end transaction
./test-distributed-transaction.sh
```

### **Troubleshooting**
```bash
# Check logs on each machine
docker logs peer0.org1.example.com    # On VPS-2
docker logs peer0.org2.example.com    # On Local
docker logs orderer.example.com       # On VPS-1

# Network connectivity test
telnet 202.x.x.10 7050  # Test orderer
telnet 202.x.x.11 7051  # Test Org1 peer
```

---

## 🎯 Summary

**Migration completed successfully:**

1. ✅ **Phase 1**: All services consolidated on VPS-1
2. ✅ **Phase 2**: Org1 Peer isolated to VPS-2  
3. ✅ **Phase 3**: Org2 Peer brought back to local machine
4. ✅ **Phase 4**: Admin server connected to local Org2 peer
5. ✅ **Phase 5**: Full network integration tested and operational

**Benefits achieved:**
- **Cost Efficiency**: Only 2 VPS instead of 4
- **Local Development**: Easy debugging with local peer and admin
- **Network Distribution**: Proper multi-node setup for production-like testing
- **Incremental Migration**: Low-risk phase-by-phase approach
- **Hybrid Architecture**: Mix of cloud and local resources