/*
 * FILE: server_blockchain.js
 * Chức năng: Gộp cả API Gateway và Clocker System
 * 1. REST API cho IoT gọi vào kiểm tra mật khẩu
 * 2. Hệ thống tự động quét và xử lý check-in/check-out
 * Cách chạy: node server_blockchain.js
 */
import { ApartmentRepository } from '@/repositories/apartmentRepository';

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const grpc = require('@grpc/grpc-js');
const { connect, signers } = require('@hyperledger/fabric-gateway');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

// --- CẤU HÌNH EXPRESS ---
const app = express();
const PORT = 4000;
app.use(cors());
app.use(bodyParser.json());

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

// --- HÀM TIỆN ÍCH CHUNG ---
async function newGrpcConnection() {
    const tlsRootCert = fs.readFileSync(tlsCertPath);
    const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
    return new grpc.Client(peerEndpoint, tlsCredentials, {
        'grpc.ssl_target_name_override': peerHostAlias,
    });
}

async function newIdentity() {
    const credentials = fs.readFileSync(certPath);
    return { mspId, credentials };
}

async function newSigner() {
    const files = fs.readdirSync(keyDirectoryPath);
    const keyPath = path.resolve(keyDirectoryPath, files[0]);
    const privateKeyPem = fs.readFileSync(keyPath);
    const privateKey = crypto.createPrivateKey(privateKeyPem);
    return signers.newPrivateKeySigner(privateKey);
}

function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

function getCurrentTimestamp() {
    return Math.floor(Date.now() / 1000);
}

function generateRandomPin() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// ========================================
// PHẦN 1: REST API CHO IOT
// ========================================

app.post('/api/verify', async (req, res) => {
    const { roomCode, password } = req.body;
    
    console.log(`\n📩 [API] Nhận yêu cầu từ IoT: RoomCode=${roomCode}, Pass=${password}`);

    //từ roomCode lấy apartmentId
    const apartmentId = await ApartmentRepository.getApartmentIdByRoomCode(roomCode); 

    if (!apartmentId || !password) {
        return res.status(400).json({ error: 'Thiếu apartmentId hoặc password' });
    }

    const passwordHashToSend = hashPassword(password);
    console.log(`   🔒 [API] Đã băm mật khẩu thành: ${passwordHashToSend}`);

    let client = null;
    let gateway = null;

    try {
        client = await newGrpcConnection();
        gateway = connect({
            client,
            identity: await newIdentity(),
            signer: await newSigner(),
        });

        const network = gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);

        console.log("   -> [API] Đang hỏi Blockchain...");
        const resultBytes = await contract.evaluateTransaction('VerifyAccess', apartmentId, passwordHashToSend);
        const resultString = new TextDecoder().decode(resultBytes);

        if (resultString === 'true') {
            console.log("   ✅ [API] MẬT KHẨU ĐÚNG -> ACCESS GRANTED");
            return res.json({ 
                status: 'success', 
                access: true, 
                message: 'Mở cửa thành công' 
            });
        } else {
            console.log("   ⛔ [API] MẬT KHẨU SAI -> ACCESS DENIED");
            return res.json({ 
                status: 'success', 
                access: false, 
                message: 'Sai mật khẩu' 
            });
        }

    } catch (error) {
        console.error(`   ❌ [API] Lỗi kết nối Blockchain: ${error.message}`);
        return res.status(500).json({ error: error.message });
    } finally {
        if (gateway) gateway.close();
        if (client) client.close();
    }
});

// ========================================
// PHẦN 2: HỆ THỐNG TỰ ĐỘNG (CLOCKER)
// ========================================

async function scanAndProcess() {
    console.log(`\n⏰ [CLOCKER] [${new Date().toLocaleTimeString()}] Bắt đầu quét hệ thống...`);
    
    const client = await newGrpcConnection();
    const gateway = connect({
        client,
        identity: await newIdentity(),
        signer: await newSigner(),
    });

    try {
        const network = gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);

        const resultBytes = await contract.evaluateTransaction('GetAllBookings');
        const resultString = new TextDecoder().decode(resultBytes);
        
        if (!resultString || resultString.length === 0) {
            console.log("   -> [CLOCKER] Không tìm thấy booking nào.");
            return;
        }

        const bookings = JSON.parse(resultString);
        const now = getCurrentTimestamp();

        console.log(`   -> [CLOCKER] Tìm thấy ${bookings.length} đơn hàng trên Blockchain.`);

        for (const booking of bookings) {
            
            // AUTO CHECK-IN
            if (booking.status === 'CREATED' && now >= booking.checkInTime) {
                console.log(`   >>> [CLOCKER] Phát hiện đơn ${booking.id} đến giờ Check-in!`);
                
                const newPass = '123456'; // Sử dụng mật khẩu cố định theo quy trình
                const newPassHash = hashPassword(newPass);

                try {
                    await contract.submitTransaction('CheckIn', booking.id, newPassHash);
                    console.log(`       ✅ [CLOCKER] AUTO CHECK-IN THÀNH CÔNG: ${booking.id}`);
                    console.log(`       🔑 [CLOCKER] Mật khẩu cho khách: ${newPass}`);
                } catch (err) {
                    console.error(`       ❌ [CLOCKER] Lỗi khi Check-in ${booking.id}: ${err.message}`);
                }
            }

            // AUTO CHECK-OUT
            if (booking.status === 'ACTIVE' && now >= booking.checkOutTime) {
                console.log(`   >>> [CLOCKER] Phát hiện đơn ${booking.id} đến giờ Check-out!`);

                const resetPass = '1234567'; // Sử dụng mật khẩu reset cố định
                const resetPassHash = hashPassword(resetPass);

                try {
                    await contract.submitTransaction('CheckOut', booking.id, resetPassHash);
                    console.log(`       ✅ [CLOCKER] AUTO CHECK-OUT THÀNH CÔNG: ${booking.id}`);
                    console.log(`       💰 [CLOCKER] Tiền đã được giải ngân cho chủ nhà.`);
                    console.log(`       🔑 [CLOCKER] Mật khẩu reset thành: ${resetPass}`);
                } catch (err) {
                    console.error(`       ❌ [CLOCKER] Lỗi khi Check-out ${booking.id}: ${err.message}`);
                }
            }
        }

    } catch (error) {
        console.error(`❌ [CLOCKER] Lỗi hệ thống: ${error.message}`);
    } finally {
        gateway.close();
        client.close();
    }
}

// ========================================
// KHỞI ĐỘNG HỆ THỐNG
// ========================================

async function main() {
    console.log("=== KHỞI ĐỘNG HỆ THỐNG TÍCH HỢP ===");
    console.log("🚀 API Gateway đang chạy tại cổng", PORT);
    console.log("📡 URL cho IoT: POST http://<IP_MAY_TINH>:" + PORT + "/api/verify");
    console.log("⏰ Clocker: Chu kỳ quét 60 giây/lần");
    
    // Khởi động API Server
    app.listen(PORT, () => {
        console.log(`\n✅ Server đã sẵn sàng!`);
    });

    // Quét ngay lần đầu
    await scanAndProcess();

    // Cài đặt lặp lại mỗi 60 giây
    setInterval(async () => {
        await scanAndProcess();
    }, 60000);
}

main().catch(console.error);