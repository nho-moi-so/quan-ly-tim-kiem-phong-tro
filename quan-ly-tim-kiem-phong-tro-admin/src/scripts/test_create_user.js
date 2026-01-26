/*
 * node test_create_user.js
 * Script tạo User mẫu cho hệ thống blockchain
 * Kết nối trực tiếp tới test-network
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
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
 * Tạo User trong Smart Contract
 */
async function createUser(contract, id, name, balance) {
    console.log(`\n--> Submit Transaction: CreateUser`);
    console.log(`Tạo user: ${name} (${id})`);
    console.log(`Số dư ban đầu: ${balance.toLocaleString()} VNĐ`);

    try {
        await contract.submitTransaction('CreateUser', id, name, balance.toString());
        console.log(`*** User ${name} (${id}) đã được tạo thành công!`);
        return true;
    } catch (error) {
        if (error.message.includes('đã tồn tại')) {
            console.log(`*** User ${id} đã tồn tại, bỏ qua tạo mới`);
            return true;
        }
        console.error(`*** Lỗi tạo user ${name}: ${error.message}`);
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
            
            // ===== TẠO 2 USERS MẪU =====
            console.log('\n========== TẠO USERS MẪU ==========');
            
            // 1. Chủ căn hộ
            const landlordId = 'user001';
            const landlordName = 'Nguyễn Văn A - Chủ căn hộ';
            const landlordBalance = 0; // Chủ nhà bắt đầu với số dư 0
            
            console.log('\n--- TẠO CHỦ CĂN HỘ ---');
            await createUser(contract, landlordId, landlordName, landlordBalance);
            
            // 2. Người thuê
            const tenantId = 'user002';
            const tenantName = 'Trần Thị B - Khách thuê';
            const tenantBalance = 5000000; // 5 triệu VNĐ
            
            console.log('\n--- TẠO NGƯỜI THUÊ ---');
            await createUser(contract, tenantId, tenantName, tenantBalance);
            
            // ===== KIỂM TRA KẾT QUẢ =====
            console.log('\n========== KIỂM TRA KẾT QUẢ ==========');
            
            const landlord = await getUser(contract, landlordId);
            if (landlord) {
                console.log(`✅ Chủ căn hộ: ${landlord.name}`);
                console.log(`   - ID: ${landlord.id}`);
                console.log(`   - Số dư: ${landlord.balance.toLocaleString()} VNĐ`);
                console.log(`   - DocType: ${landlord.docType}`);
            }
            
            const tenant = await getUser(contract, tenantId);
            if (tenant) {
                console.log(`✅ Khách thuê: ${tenant.name}`);
                console.log(`   - ID: ${tenant.id}`);
                console.log(`   - Số dư: ${tenant.balance.toLocaleString()} VNĐ`);
                console.log(`   - DocType: ${tenant.docType}`);
            }
            
            console.log('\n🎉 Tạo users thành công!');
            console.log('\n📋 BƯỚC TIẾP THEO:');
            console.log('- Chạy create_apartment.js để tạo căn hộ');
            console.log('- Sử dụng user001 làm chủ nhà, user002 làm khách thuê');
            
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
    createUser,
    getUser,
    main
};