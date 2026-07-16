#!/bin/bash

# Hyperledger Fabric Explorer - Management Script
# Usage: ./explorer.sh [command]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FABRIC_NET_DIR="../blockchain-fabric-v2/test-network"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    echo -e "${2}${1}${NC}"
}

print_header() {
    print_color "=== $1 ===" "$BLUE"
}

# Check if Fabric network is running
check_fabric_network() {
    print_header "Kiểm tra Fabric Network"
    
    if ! docker ps | grep -q "peer0.org1.example.com"; then
        print_color "❌ Fabric network chưa chạy!" "$RED"
        print_color "Khởi động Fabric network trước:" "$YELLOW"
        echo "cd $FABRIC_NET_DIR"
        echo "./network.sh up createChannel -c rentingchannel"
        exit 1
    else
        print_color "✅ Fabric network đang chạy" "$GREEN"
    fi
}

# Check certificates
# Check certificates
check_certificates() {
    print_header "Kiểm tra Certificates"
    
    # --- 1. KIỂM TRA VÀ CẬP NHẬT PRIVATE KEY ---
    KEYSTORE_DIR="$FABRIC_NET_DIR/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore"
    
    if [ ! -d "$KEYSTORE_DIR" ]; then
        print_color "❌ Keystore directory không tồn tại: $KEYSTORE_DIR" "$RED"
        exit 1
    fi
    
    PRIVATE_KEY=$(ls $KEYSTORE_DIR/*_sk $KEYSTORE_DIR/*.sk 2>/dev/null | head -1)
    if [ -z "$PRIVATE_KEY" ]; then
        print_color "❌ Không tìm thấy private key" "$RED"
        exit 1
    fi
    
    PRIVATE_KEY_NAME=$(basename "$PRIVATE_KEY")
    print_color "✅ Private key: $PRIVATE_KEY_NAME" "$GREEN"
    
    if ! grep -q "$PRIVATE_KEY_NAME" connection-profile/network-config.json; then
        print_color "🔄 Cập nhật private key path..." "$YELLOW"
        sed -i "s|/tmp/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/[^\"]*|/tmp/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/$PRIVATE_KEY_NAME|g" connection-profile/network-config.json
        print_color "✅ Đã cập nhật private key path" "$GREEN"
    fi

    # --- 2. KIỂM TRA VÀ CẬP NHẬT SIGNED CERTIFICATE ---
    SIGNCERTS_DIR="$FABRIC_NET_DIR/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts"
    
    CERT_FILE=$(ls $SIGNCERTS_DIR/*.pem 2>/dev/null | head -1)
    if [ -z "$CERT_FILE" ]; then
        print_color "❌ Không tìm thấy certificate file trong $SIGNCERTS_DIR" "$RED"
        exit 1
    fi
    
    CERT_FILE_NAME=$(basename "$CERT_FILE")
    print_color "✅ Certificate: $CERT_FILE_NAME" "$GREEN"
    
    if ! grep -q "$CERT_FILE_NAME" connection-profile/network-config.json; then
        print_color "🔄 Cập nhật signedCert path..." "$YELLOW"
        sed -i "s|/tmp/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/[^\"]*|/tmp/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/$CERT_FILE_NAME|g" connection-profile/network-config.json
        print_color "✅ Đã cập nhật signedCert path" "$GREEN"
    fi
}

# Start Explorer
start_explorer() {
    print_header "Khởi động Explorer"
    
    check_fabric_network
    check_certificates
    
    print_color "🚀 Khởi động Explorer containers..." "$BLUE"
    docker-compose up -d
    
    print_color "⏳ Đợi Explorer khởi tạo..." "$YELLOW"
    sleep 10
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        print_color "✅ Explorer đang chạy!" "$GREEN"
        print_color "🌐 Truy cập: http://localhost:8080" "$BLUE"
        
        # Test web interface
        if curl -f -s -I http://localhost:8080 > /dev/null; then
            print_color "✅ Web interface accessible" "$GREEN"
        else
            print_color "⚠️  Web interface chưa sẵn sàng, vui lòng đợi thêm..." "$YELLOW"
        fi
    else
        print_color "❌ Có lỗi khi khởi động Explorer" "$RED"
        echo "Kiểm tra logs:"
        docker-compose logs --tail 10
    fi
}

# Stop Explorer
stop_explorer() {
    print_header "Dừng Explorer"
    
    print_color "🛑 Dừng Explorer containers..." "$YELLOW"
    docker-compose down
    
    print_color "✅ Explorer đã dừng" "$GREEN"
}

# Restart Explorer
restart_explorer() {
    print_header "Khởi động lại Explorer"
    
    print_color "🔄 Dừng Explorer..." "$YELLOW"
    docker-compose down
    
    print_color "🚀 Khởi động lại..." "$BLUE"
    start_explorer
}

# View logs
logs_explorer() {
    print_header "Explorer Logs"
    
    echo "Theo dõi logs realtime (Ctrl+C để thoát):"
    docker-compose logs -f explorer.example.com
}

# Status check
status_explorer() {
    print_header "Trạng thái Explorer"
    
    echo "Docker Containers:"
    docker-compose ps
    
    echo ""
    echo "Docker Network:"
    docker network ls | grep fabric_test || echo "Network chưa tồn tại"
    
    echo ""
    echo "Web Interface Test:"
    if curl -f -s -I http://localhost:8080 > /dev/null; then
        print_color "✅ http://localhost:8080 - Accessible" "$GREEN"
    else
        print_color "❌ http://localhost:8080 - Not accessible" "$RED"
    fi
    
    echo ""
    echo "Recent Logs:"
    docker-compose logs --tail 5 explorer.example.com
}

# Clean data
clean_explorer() {
    print_header "Dọn dẹp dữ liệu"
    
    print_color "🗑️  Dừng và xóa containers..." "$YELLOW"
    docker-compose down
    
    print_color "🗑️  Xóa database data..." "$YELLOW"
    rm -rf pgdata
    
    print_color "✅ Đã dọn дẹp dữ liệu" "$GREEN"
    print_color "💡 Chạy 'start' để khởi tạo lại từ đầu" "$BLUE"
}

# Help
show_help() {
    print_header "Hyperledger Fabric Explorer - Management Script"
    
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start     - Khởi động Explorer"
    echo "  stop      - Dừng Explorer" 
    echo "  restart   - Khởi động lại Explorer"
    echo "  status    - Kiểm tra trạng thái"
    echo "  logs      - Xem logs realtime"
    echo "  clean     - Dọn dẹp dữ liệu và khởi tạo lại"
    echo "  check     - Kiểm tra prerequisites"
    echo "  help      - Hiển thị help này"
    echo ""
    echo "Examples:"
    echo "  $0 start    # Khởi động Explorer"
    echo "  $0 status   # Kiểm tra trạng thái" 
    echo "  $0 logs     # Xem logs"
}

# Check prerequisites
check_prerequisites() {
    print_header "Kiểm tra Prerequisites"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_color "✅ Docker: $(docker --version)" "$GREEN"
    else
        print_color "❌ Docker chưa được cài đặt" "$RED"
        exit 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_color "✅ Docker Compose: $(docker-compose --version)" "$GREEN"
    else
        print_color "❌ Docker Compose chưa được cài đặt" "$RED"
        exit 1
    fi
    
    # Check if in correct directory
    if [ ! -f "docker-compose.yaml" ]; then
        print_color "❌ Chạy script từ thư mục blockchain-fabric-explorer" "$RED"
        exit 1
    fi
    
    print_color "✅ Tất cả prerequisites đều OK" "$GREEN"
}

# Main script logic
case ${1:-help} in
    start)
        start_explorer
        ;;
    stop)
        stop_explorer
        ;;
    restart)
        restart_explorer
        ;;
    status)
        status_explorer
        ;;
    logs)
        logs_explorer
        ;;
    clean)
        clean_explorer
        ;;
    check)
        check_prerequisites
        check_fabric_network
        check_certificates
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_color "❌ Command không hợp lệ: $1" "$RED"
        echo ""
        show_help
        exit 1
        ;;
esac