# Hyperledger Fabric Explorer - Hướng dẫn Setup và Sử dụng

## 📋 Mục lục
1. [Tổng quan](#tổng-quan)
2. [Cấu trúc thư mục](#cấu-trúc-thư-mục)
3. [Kiến thức cần biết](#kiến-thức-cần-biết)
4. [Quy trình Setup](#quy-trình-setup)
5. [Cấu hình chi tiết](#cấu-hình-chi-tiết)
6. [Vận hành và Monitoring](#vận-hành-và-monitoring)
7. [Troubleshooting](#troubleshooting)
8. [Kiến thức mở rộng](#kiến-thức-mở-rộng)

## 🎯 Tổng quan

Hyperledger Fabric Explorer là một công cụ web-based dashboard để khám phá và giám sát mạng Hyperledger Fabric. Nó cho phép bạn:

- **Xem thông tin blocks và transactions** trong blockchain
- **Giám sát network topology** và trạng thái các nodes
- **Khám phá channel data** và chaincode information
- **Query blockchain data** thông qua giao diện web thân thiện

### 🏗️ Kiến trúc hệ thống

```
Frontend (React) → Backend (Node.js) → PostgreSQL Database
                                    ↘
                                      Fabric Network (gRPC/TLS)
```

## 📁 Cấu trúc thư mục

```
blockchain-fabric-explorer/
├── config/
│   └── config.json              # Cấu hình chính của Explorer
├── connection-profile/
│   └── network-config.json      # Cấu hình kết nối Fabric network
├── docker-compose.yaml          # Docker compose configuration
└── README.md                    # Documentation này
```

### Chi tiết từng file:

#### 1. `config/config.json`
```json
{
  "network-configs": {
    "fabric-network": {
      "name": "fabric-network",
      "profile": "./connection-profile/network-config.json"
    }
  },
  "license": "Apache-2.0"
}
```
**Mục đích**: Định nghĩa các network mà Explorer sẽ kết nối

#### 2. `connection-profile/network-config.json`
**Mục đích**: Chứa thông tin chi tiết về Fabric network:
- Thông tin peers và orderers
- TLS certificates
- Admin credentials
- Channel configurations

#### 3. `docker-compose.yaml`
**Mục đích**: Orchestration file để chạy Explorer và PostgreSQL database

## 🧠 Kiến thức cần biết

### 1. **Docker & Docker Compose**
- **Containers**: Đóng gói ứng dụng với dependencies
- **Images**: Template để tạo containers
- **Networks**: Kết nối giữa containers
- **Volumes**: Lưu trữ persistent data

### 2. **Hyperledger Fabric Fundamentals**
- **Peers**: Nodes lưu trữ ledger và thực thi chaincode
- **Orderers**: Nodes sắp xếp transactions thành blocks
- **Channels**: Subnet riêng tư trong network
- **MSP (Membership Service Provider)**: Quản lý identity
- **TLS**: Transport Layer Security cho bảo mật gRPC

### 3. **gRPC Communication**
- **grpc:// vs grpcs://**: HTTP/2 without/with TLS
- **TLS Certificates**: Xác thực và mã hóa connection
- **SSL Target Name Override**: Mapping hostname trong TLS

### 4. **PostgreSQL Database**
- Explorer sử dụng PostgreSQL để cache blockchain data
- Tăng performance khi query large datasets
- Sync data từ Fabric network periodically

## 🚀 Quy trình Setup

### Bước 1: Chuẩn bị môi trường
```bash
# Kiểm tra prerequisites
docker --version
docker-compose --version

# Đảm bảo Fabric network đang chạy
cd ../blockchain-fabric-v2/test-network
./network.sh up createChannel -c rentingchannel
```

### Bước 2: Cấu hình Explorer
```bash
cd blockchain-fabric-explorer

# Xem cấu hình hiện tại
cat config/config.json
cat connection-profile/network-config.json
```

### Bước 3: Cấu hình Network Connection
**Quan trọng**: Cập nhật đường dẫn certificates trong `network-config.json`:
```bash
# Kiểm tra private key filename
ls ../blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/

# Cập nhật đường dẫn nếu cần
```

### Bước 4: Khởi động Explorer
```bash
# Khởi động services
docker-compose up -d

# Kiểm tra trạng thái
docker-compose ps

# Xem logs
docker-compose logs -f explorer.example.com
```

### Bước 5: Verifikasi
```bash
# Test web interface
curl -I http://localhost:8080

# Mở trình duyệt
# http://localhost:8080
```

## ⚙️ Cấu hình chi tiết

### TLS Configuration
```json
{
  "client": {
    "tlsEnable": true,  // Bật TLS cho security
    "organization": "Org1",
    "adminCredential": {
      "id": "exploreradmin",      // Admin user cho Explorer
      "password": "exploreradminpw"
    }
  }
}
```

### Peer Configuration
```json
{
  "peers": {
    "peer0.org1.example.com": {
      "url": "grpcs://peer0.org1.example.com:7051",  // gRPC với TLS
      "tlsCACerts": {
        "path": "/tmp/crypto/peerOrganizations/.../tls/ca.crt"
      },
      "grpcOptions": {
        "ssl-target-name-override": "peer0.org1.example.com"
      }
    }
  }
}
```

### Volume Mappings
- **config**: `/opt/explorer/app/platform/fabric/config.json`
- **connection-profile**: `/opt/explorer/app/platform/fabric/connection-profile`
- **crypto**: `/tmp/crypto` (Fabric certificates)

## 🔧 Vận hành và Monitoring

### Startup Process
1. **Database Connection**: Explorer kết nối PostgreSQL
2. **Network Discovery**: Đọc connection profile
3. **TLS Setup**: Setup secure connection với peers
4. **Admin Enrollment**: Enroll admin user vào network
5. **Channel Sync**: Sync blockchain data từ channels
6. **Web Server Start**: Khởi động HTTP server port 8080

### Monitoring Commands
```bash
# Xem trạng thái containers
docker-compose ps

# Xem resource usage
docker stats

# Theo dõi logs realtime
docker-compose logs -f

# Kiểm tra kết nối database
docker exec -it explorerdb.example.com psql -U hppoc -d fabricexplorer -c "\dt"
```

### Performance Monitoring
```bash
# Kiểm tra sync progress
docker-compose logs explorer.example.com | grep "syncBlocks"

# Xem block processing
docker-compose logs explorer.example.com | grep "block_row.blocknum"
```

## 🐛 Troubleshooting

### Lỗi thường gặp:

#### 1. Container exit với code 1
**Nguyên nhân**: Lỗi configuration
```bash
# Debug
docker-compose logs explorer.example.com

# Kiểm tra
- Private key path đúng
- TLS certificates tồn tại
- Network connectivity
```

#### 2. `ECONNRESET` hoặc `UNAVAILABLE`
**Nguyên nhân**: Peer connection issues
```bash
# Kiểm tra peer status
docker ps | grep peer0.org1.example.com

# Test connection
docker exec -it explorer.example.com telnet peer0.org1.example.com 7051
```

#### 3. `Failed to create wallet`
**Nguyên nhân**: Certificate path hoặc format sai
```bash
# Verify certificates
ls -la ../blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/

# Check permissions
docker exec -it explorer.example.com ls -la /tmp/crypto/
```

### Debug Commands
```bash
# Xem detailed logs
docker run -it --rm ... -e LOG_LEVEL_APP=debug ... hyperledger/explorer:latest

# Interactive shell
docker run -it --rm ... --entrypoint /bin/sh hyperledger/explorer:latest

# Network debugging
docker run -it --rm --network fabric_test alpine ping peer0.org1.example.com
```

## 📚 Kiến thức mở rộng

### 1. **Fabric Network Architecture**
- **Multi-org setup**: Mở rộng cho nhiều organizations
- **Channel management**: Tạo và quản lý multiple channels
- **Chaincode lifecycle**: Deploy và upgrade chaincodes

### 2. **Explorer Advanced Features**
- **Multi-network support**: Kết nối multiple Fabric networks
- **User authentication**: Setup login/logout functionality
- **Custom APIs**: Extend Explorer với custom endpoints

### 3. **Production Considerations**
- **Security hardening**: TLS mutual authentication
- **Performance tuning**: Database indexing, connection pooling
- **High availability**: Load balancing, redundancy
- **Backup strategies**: Database và configuration backup

### 4. **Integration Patterns**
- **CI/CD integration**: Automated deployment
- **Monitoring stack**: Prometheus, Grafana integration
- **Log aggregation**: ELK stack integration

## 🎯 Kết luận

Hyperledger Fabric Explorer là một công cụ mạnh mẽ để khám phá và giám sát blockchain network. Key takeaways:

1. **Configuration is critical**: TLS và certificate paths phải chính xác
2. **Network connectivity**: Docker networks và gRPC endpoints
3. **Monitoring approach**: Logs và metrics để troubleshoot
4. **Security considerations**: TLS, authentication, và access control

### Tài liệu tham khảo:
- [Hyperledger Explorer GitHub](https://github.com/hyperledger/blockchain-explorer)
- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

---
*Document này được tạo để hỗ trợ học tập và triển khai Hyperledger Fabric Explorer*