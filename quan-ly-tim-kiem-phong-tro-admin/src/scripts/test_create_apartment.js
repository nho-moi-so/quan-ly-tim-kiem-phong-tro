/*
 * node test_create_apartment.js
 * Script tạo Apartment mẫu cho hệ thống blockchain
 * Kết nối trực tiếp tới test-network
 */

'use strict';

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

/**
 * Tạo SHA256 hash cho mật khẩu
 */
function hashPassword(password) {
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

/**
 * Tạo Apartment trong Smart Contract
 */
async function createApartment(contract, id, ownerId, price, initialPassword) {
    console.log(`\n--> Submit Transaction: CreateApartment`);
    console.log(`Tạo căn hộ: ${id}`);
    console.log(`Chủ nhà: ${ownerId}`);
    console.log(`Giá thuê: ${price.toLocaleString()} VNĐ/tháng`);
    console.log(`Mật khẩu ban đầu: ${initialPassword}`);
    
    const passwordHash = hashPassword(initialPassword);
    console.log(`Password hash: ${passwordHash.substring(0, 16)}...`);
    
    try {
        await contract.submitTransaction('CreateApartment', id, ownerId, price.toString(), passwordHash);
        console.log(`*** Căn hộ ${id} đã được tạo thành công!`);
        return true;
    } catch (error) {
        console.error(`*** Lỗi tạo căn hộ ${id}: ${error.message}`);
        throw error;
    }
}

/**
 * Lấy thông tin User
 */
async function getUser(contract, userId) {
    try {
        const result = await contract.evaluateTransaction('GetUser', userId);
        return JSON.parse(result.toString());
    } catch (error) {
        return null;
    }
}

/**
 * Lấy thông tin Apartment
 */
async function getApartment(contract, apartmentId) {
    try {
        const result = await contract.evaluateTransaction('ReadAsset', apartmentId);
        return JSON.parse(result.toString());
    } catch (error) {
        return null;
    }
}

/**
 * Main function
 */
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
            
            // ===== KIỂM TRA CHỦ NHÀ TỒN TẠI =====
            console.log('\n========== KIỂM TRA CHỦ NHÀ ==========');
            const ownerId = 'user001';
            const owner = await getUser(contract, ownerId);
            
            if (!owner) {
                console.log(`❌ User ${ownerId} chưa tồn tại!`);
                console.log('Vui lòng chạy create_user.js trước:');
                console.log('   node src/scripts/create_user.js');
                process.exit(1);
            }
            
            console.log(`✅ Tìm thấy chủ nhà: ${owner.name}`);
            console.log(`   - Số dư hiện tại: ${owner.balance.toLocaleString()} VNĐ`);
            
            // ===== TẠO CÁC CĂN HỘ MẪU =====
            const apartments = [
                {
                    id: 'apt001',
                    ownerId: ownerId,
                    price: 3000000, // 3 triệu/tháng
                    password: '12345',
                    description: 'Căn hộ 1 phòng ngủ, view thành phố',
                    address: '123 Nguyễn Huệ, Q.1, TP.HCM',
                    amenities: ['WiFi', 'Điều hòa', 'Tủ lạnh', 'Máy giặt']
                },
                {
                    id: 'apt002',
                    ownerId: ownerId,
                    price: 4500000, // 4.5 triệu/tháng
                    password: '789012',
                    description: 'Căn hộ 2 phòng ngủ, đầy đủ nội thất cao cấp',
                    address: '456 Lê Lợi, Q.1, TP.HCM',
                    amenities: ['WiFi', 'Điều hòa', 'Tủ lạnh', 'Máy giặt', 'Ban công', 'Bếp từ']
                },
                {
                    id: 'apt003',
                    ownerId: ownerId,
                    price: 2500000, // 2.5 triệu/tháng
                    password: '345678',
                    description: 'Studio gần trường đại học, phù hợp sinh viên',
                    address: '789 Điện Biên Phủ, Q.3, TP.HCM',
                    amenities: ['WiFi', 'Điều hòa', 'Tủ lạnh', 'Bàn học']
                }
            ];
            
            console.log('\n========== TẠO CÁC CĂN HỘ MẪU ==========');
            
            for (const apt of apartments) {
                console.log(`\n--- Đang tạo ${apt.id} ---`);
                console.log(`Mô tả: ${apt.description}`);
                console.log(`Địa chỉ: ${apt.address}`);
                console.log(`Tiện ích: ${apt.amenities.join(', ')}`);
                
                // Kiểm tra căn hộ đã tồn tại chưa
                const existingApt = await getApartment(contract, apt.id);
                if (existingApt) {
                    console.log(`Căn hộ ${apt.id} đã tồn tại, bỏ qua...`);
                    continue;
                }
                
                // Tạo căn hộ mới
                await createApartment(contract, apt.id, apt.ownerId, apt.price, apt.password);
                
                // Đợi 1 giây tránh conflict
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
            
            // ===== KIỂM TRA KẾT QUẢ =====
            console.log('\n========== DANH SÁCH CĂN HỘ ĐÃ TẠO ==========');
            
            for (const apt of apartments) {
                const apartment = await getApartment(contract, apt.id);
                if (apartment) {
                    console.log(`\n✅ Căn hộ ${apartment.id}:`);
                    console.log(`   - Chủ nhà: ${apartment.ownerId}`);
                    console.log(`   - Giá thuê: ${apartment.price.toLocaleString()} VNĐ/tháng`);
                    console.log(`   - Trạng thái: ${apartment.status}`);
                    console.log(`   - DocType: ${apartment.docType}`);
                    console.log(`   - Password hash: ${apartment.passwordHash.substring(0, 20)}...`);
                    
                    // Thêm thông tin mô tả từ dữ liệu gốc
                    const originalApt = apartments.find(a => a.id === apartment.id);
                    if (originalApt) {
                        console.log(`   - Mô tả: ${originalApt.description}`);
                        console.log(`   - Địa chỉ: ${originalApt.address}`);
                        console.log(`   - Tiện ích: ${originalApt.amenities.join(', ')}`);
                    }
                }
            }
            
            console.log('\n🎉 Tạo apartments thành công!');
            
            console.log('\n🔐 THÔNG TIN MẬT KHẨU CỬA:');
            for (const apt of apartments) {
                console.log(`- ${apt.id}: ${apt.password} -> hash: ${hashPassword(apt.password).substring(0, 16)}...`);
            }
            
            console.log('\n💰 THỐNG KÊ:');
            const totalPrice = apartments.reduce((sum, apt) => sum + apt.price, 0);
            const avgPrice = totalPrice / apartments.length;
            console.log(`- Số lượng căn hộ: ${apartments.length}`);
            console.log(`- Giá thuê trung bình: ${avgPrice.toLocaleString()} VNĐ/tháng`);
            console.log(`- Tổng doanh thu tiềm năng: ${totalPrice.toLocaleString()} VNĐ/tháng`);
            console.log(`- Giá rẻ nhất: ${Math.min(...apartments.map(a => a.price)).toLocaleString()} VNĐ/tháng`);
            console.log(`- Giá cao nhất: ${Math.max(...apartments.map(a => a.price)).toLocaleString()} VNĐ/tháng`);
            
            console.log('\n📋 BƯỚC TIẾP THEO:');
            console.log('- Tất cả căn hộ đã sẵn sàng cho thuê (status: AVAILABLE)');
            console.log('- Khách thuê user002 có thể đặt phòng bằng BookApartment');
            console.log('- Mật khẩu cửa sẽ thay đổi khi CheckIn và CheckOut');
            console.log('- Tiền sẽ được giữ trong Escrow đến khi hoàn thành CheckOut');
            
        } finally {
            gateway.disconnect();
        }
        
    } catch (error) {
        console.error(`******** LỖI: ${error.message}`);
        console.error('Chi tiết:', error);
        process.exit(1);
    }
}

// Chạy script
if (require.main === module) {
    main();
}

// Export cho việc import từ file khác
module.exports = {
    createApartment,
    getApartment,
    getUser,
    hashPassword,
    main
};