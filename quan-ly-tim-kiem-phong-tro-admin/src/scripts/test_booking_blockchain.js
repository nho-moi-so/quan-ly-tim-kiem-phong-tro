/*
 * FILE: test_booking_blockchain.js
 * Chức năng: Thực hiện Đặt phòng (BookApartment).
 * Logic: UserB đặt Apt1 -> Tiền bị trừ khỏi ví UserB và bị khóa vào Booking (Escrow).
 * Cách chạy: node test_booking_blockchain.js
 */

const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

// --- CẤU HÌNH FABRIC (Cập nhật đường dẫn sử dụng org1.example.com local) ---
const channelName = 'mychannel';
const chaincodeName = 'basic';
const mspId = 'Org1MSP';
const cryptoPath = path.resolve(__dirname, 'org1.example.com');
const keyDirectoryPath = path.resolve(cryptoPath, 'users', 'User1@org1.example.com', 'msp', 'keystore');
const certPath = path.resolve(cryptoPath, 'users', 'User1@org1.example.com', 'msp', 'signcerts', 'User1@org1.example.com-cert.pem');
const tlsCertPath = path.resolve(cryptoPath, 'peers', 'peer0.org1.example.com', 'tls', 'ca.crt');
const peerEndpoint = 'localhost:7051';
const peerHostAlias = 'peer0.org1.example.com';

// --- HÀM TIỆN ÍCH ---
function getCurrentTimestamp() {
    return Math.floor(Date.now() / 1000);
}

// Hàm hỗ trợ tạo hash password (dùng khi tạo căn hộ nếu cần, hoặc để init)
function createPasswordHash(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

/**
 * Đọc private key từ keystore
 */
function getPrivateKey(keyDirectoryPath) {
    const files = fs.readdirSync(keyDirectoryPath);
    const keyFile = files.find(file => file.endsWith('_sk'));
    if (!keyFile) {
        throw new Error('Private key file not found in keystore');
    }
    return fs.readFileSync(path.resolve(keyDirectoryPath, keyFile), 'utf8');
}

/**
 * Tạo connection profile
 */
function buildConnectionProfile() {
    return {
        version: '1.0.0',
        client: {
            organization: 'Org1',
            connection: {
                timeout: {
                    peer: {
                        endorser: '300'
                    }
                }
            }
        },
        organizations: {
            Org1: {
                mspid: mspId,
                peers: ['peer0.org1.example.com']
            }
        },
        peers: {
            'peer0.org1.example.com': {
                url: `grpcs://${peerEndpoint}`,
                tlsCACerts: {
                    pem: fs.readFileSync(tlsCertPath, 'utf8')
                },
                grpcOptions: {
                    'ssl-target-name-override': peerHostAlias,
                    'hostnameOverride': peerHostAlias
                }
            }
        },
        channels: {
            [channelName]: {
                orderers: [],
                peers: {
                    'peer0.org1.example.com': {
                        endorsingPeer: true,
                        chaincodeQuery: true,
                        ledgerQuery: true,
                        eventSource: true
                    }
                }
            }
        }
    };
}



// --- LOGIC CHÍNH: BOOKING ---
async function main() {
    try {
        console.log('🔗 Đang kết nối tới Fabric Test Network...');
        
        // Đọc certificates và keys
        const privateKey = getPrivateKey(keyDirectoryPath);
        const certificate = fs.readFileSync(certPath, 'utf8');
        
        // Tạo wallet in-memory
        const wallet = await Wallets.newInMemoryWallet();
        
        // Tạo identity từ certificates
        const identity = {
            credentials: {
                certificate: certificate,
                privateKey: privateKey,
            },
            mspId: mspId,
            type: 'X.509',
        };
        
        await wallet.put('admin', identity);
        
        // Tạo connection profile
        const connectionProfile = buildConnectionProfile();
        
        // Kết nối tới network
        const gateway = new Gateway();
        
        try {
            await gateway.connect(connectionProfile, {
                wallet,
                identity: 'admin',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            console.log('✅ Kết nối thành công tới Fabric Network');
            
            const network = await gateway.getNetwork(channelName);
            const contract = network.getContract(chaincodeName);

        // --- BƯỚC CHUẨN BỊ (QUAN TRỌNG) ---
        // Đảm bảo đã chạy create_user.js và create_apartment.js trước
        // Nếu chưa chạy, hãy chạy 2 lệnh này trước:
        // node src/scripts/test_create_user.js
        // node src/scripts/test_create_apartment.js


        // 1. Thông số đặt phòng
        const bookingId = 'booking001';
        const apartmentId = 'apt001'; // Căn hộ đã tạo trong create_apartment.js
        const tenantId = 'user002'; // Khách thuê đã tạo trong create_user.js
        
        // Giả lập thời gian: Check-in sau 2 phút nữa, checkout là 2 phút tiếp theo
        const checkInTime = getCurrentTimestamp() + 120; 
        const checkOutTime = checkInTime + 120;

        console.log('\n=== BẮT ĐẦU QUY TRÌNH ĐẶT PHÒNG ===');

        // 2. Kiểm tra số dư TRƯỚC khi đặt (Để so sánh)
        console.log(`\n💰 Kiểm tra ví ${tenantId} trước khi đặt...`);
        let userBytes = await contract.evaluateTransaction('GetUser', tenantId);
        let user = JSON.parse(userBytes.toString());
        console.log(`   Số dư hiện tại: ${user.balance.toLocaleString()} VNĐ`);

        // 3. Gửi lệnh Đặt phòng (BookApartment)
        console.log(`\n📅 Đang gửi lệnh Booking...`);
        console.log(`   - BookingID: ${bookingId}`);
        console.log(`   - Căn hộ: ${apartmentId}`);
        console.log(`   - Thời gian Check-in: ${new Date(checkInTime * 1000).toLocaleString()}`);

        await contract.submitTransaction(
            'BookApartment', 
            bookingId, 
            apartmentId, 
            tenantId, 
            checkInTime.toString(), 
            checkOutTime.toString()
        );

        console.log('✅ Đặt phòng thành công! Tiền đã được chuyển vào Escrow.');
        console.log('📋 QUY TRÌNH MẬT KHẨU:');
        console.log('   - Hiện tại (trước checkin): 123456');
        console.log('   - Sau khi checkin: 123457');
        console.log('   - Sau khi checkout: 123458');

        // 4. Kiểm tra số dư SAU khi đặt (Để chứng minh tiền đã bị trừ)
        console.log(`\n💸 Kiểm tra lại ví ${tenantId} sau khi đặt...`);
        userBytes = await contract.evaluateTransaction('GetUser', tenantId);
        user = JSON.parse(userBytes.toString());
        console.log(`   Số dư còn lại: ${user.balance.toLocaleString()} VNĐ`);
        console.log(`   (Lưu ý: Tiền đã bị trừ đi giá thuê nhưng Chủ nhà chưa nhận được)`);

        } catch (error) {
            console.error(`\n❌ LỖI ĐẶT PHÒNG: ${error.message}`);
            if (error.message.includes("exists")) {
                console.log("💡 Gợi ý: BookingID này đã tồn tại, hãy đổi tên bookingId trong code.");
                console.log(`   Thử đổi thành: booking${Date.now()}`);
            } else if (error.message.includes("Balance")) {
                console.log("💡 Gợi ý: User không đủ tiền.");
            }
        } finally {
            gateway.disconnect();
        }
        
    } catch (error) {
        console.error(`******** LỖI: ${error.message}`);
        console.error('Chi tiết:', error);
        process.exit(1);
    }
}

main();