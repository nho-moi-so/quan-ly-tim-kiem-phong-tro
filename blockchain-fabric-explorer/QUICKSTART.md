# Quick Start Guide - Hyperledger Fabric Explorer

## 🚀 Khởi động nhanh

```bash
# 1. Đảm bảo Fabric network đang chạy
cd ../blockchain-fabric-v2/test-network
./network.sh up createChannel -c rentingchannel

# 2. Khởi động Explorer  
cd ../blockchain-fabric-explorer
./explorer.sh start

# 3. Truy cập web interface
# http://localhost:8080
```

## 📁 Cấu trúc thư mục (đã dọn dẹp)

```
blockchain-fabric-explorer/
├── README.md                     # Documentation chi tiết  
├── explorer.sh                   # Management script
├── docker-compose.yaml           # Docker orchestration
├── config/
│   └── config.json              # Cấu hình Explorer
└── connection-profile/
    └── network-config.json      # Cấu hình Fabric network
```

## 🛠️ Commands thường dùng

```bash
./explorer.sh start       # Khởi động Explorer
./explorer.sh stop        # Dừng Explorer  
./explorer.sh status      # Kiểm tra trạng thái
./explorer.sh logs        # Xem logs realtime
./explorer.sh restart     # Khởi động lại
./explorer.sh clean       # Dọn dẹp data, reset
```

## 🔧 Troubleshooting cơ bản

### Explorer không khởi động được:
```bash
./explorer.sh check       # Kiểm tra prerequisites
./explorer.sh logs        # Xem error logs
```

### Web không truy cập được:
```bash
curl -I http://localhost:8080    # Test connection
docker-compose ps              # Kiểm tra containers
```

### Reset hoàn toàn:
```bash
./explorer.sh clean       # Xóa data
./explorer.sh start       # Khởi tạo lại
```

## 📚 Chi tiết đầy đủ

Xem file `README.md` để hiểu sâu hơn về:
- Kiến thức cần biết
- Quy trình setup chi tiết  
- Cấu hình advanced
- Troubleshooting đầy đủ
- Kiến thức mở rộng

## 🎯 Kết quả

Sau khi setup thành công:
- ✅ Explorer web UI: http://localhost:8080
- ✅ Xem blockchain data: blocks, transactions, chaincode
- ✅ Monitor network realtime
- ✅ Query channel information