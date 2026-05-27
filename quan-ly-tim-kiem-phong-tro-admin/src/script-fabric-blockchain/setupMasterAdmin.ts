import { ca } from '@/lib/fabric/caClient';
import { WalletBlockchainRepository } from '@/repositories/walletBlockchainRepository';
import fs from 'fs';
import path from 'path';

/**
 * Tạo và enroll admin identity có quyền register users
 */
async function enrollMasterAdminWithRegistrarRights() {
    try {
        console.log('🔑 1. Enroll CA admin (để cấp quyền Registrar)...');
        let caEnrollment;
        try {
            caEnrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
            await WalletBlockchainRepository.upsertById('ca-admin', {
                UserID: 'ca-admin',
                MSPID: 'Org1MSP',
                Type: 'X.509',
                CredentialsCertificate: caEnrollment.certificate,
                CredentialsPrivateKey: caEnrollment.key.toBytes(),
            });
            console.log('✅ Đã tạo/cập nhật ca-admin identity trên Firebase');
        } catch (error: any) {
             if (error.message && error.message.includes('already enrolled')) {
                  console.log('⚠️ CA admin đã enrolled trước đó. Tiến hành enroll lại...');
                  caEnrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
                  await WalletBlockchainRepository.upsertById('ca-admin', {
                      UserID: 'ca-admin',
                      MSPID: 'Org1MSP',
                      Type: 'X.509',
                      CredentialsCertificate: caEnrollment.certificate,
                      CredentialsPrivateKey: caEnrollment.key.toBytes(),
                  });
                  console.log('✅ Đã tạo/cập nhật ca-admin identity trên Firebase');
             } else {
                  throw error;
             }
        }

        console.log('\n🔑 2. Cài đặt MSP Master admin (để ghi dữ liệu lên Ledger)...');
        
        // Đọc admin certificate và private key từ cryptogen
        const cryptoPath = path.resolve(
            '/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com'
        );

        const certDir = path.resolve(
            cryptoPath,
            'users',
            'Admin@org1.example.com',
            'msp',
            'signcerts'
        );

        const keyPath = path.resolve(
            cryptoPath,
            'users',
            'Admin@org1.example.com',
            'msp',
            'keystore'
        );

        // Tự động tìm file cert trong thư mục signcerts
        const certFiles = fs.readdirSync(certDir);
        const certFile = certFiles.find(file => file.endsWith('.pem'));
        if (!certFile) {
            throw new Error('Không tìm thấy certificate file trong signcerts');
        }
        const certificate = fs.readFileSync(path.resolve(certDir, certFile), 'utf8');

        // Đọc private key từ thư mục keystore
        const keyFiles = fs.readdirSync(keyPath);
        const keyFile = keyFiles.find(file => file.endsWith('_sk'));
        if (!keyFile) {
            throw new Error('Không tìm thấy private key file');
        }

        const privateKey = fs.readFileSync(path.resolve(keyPath, keyFile), 'utf8');

        // Kiểm tra xem master-admin đã tồn tại trong Firebase chưa
        const existingAdmin = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin');
        
        if (existingAdmin) {
            console.log('🔄 Cập nhật master-admin identity...');
            // Cập nhật với certificate từ cryptogen
            const wallets = await WalletBlockchainRepository.getByUserId('master-admin');
            if (wallets.length > 0) {
                await WalletBlockchainRepository.update(wallets[0].Id, {
                    CredentialsCertificate: certificate,
                    CredentialsPrivateKey: privateKey,
                    MSPID: 'Org1MSP',
                    Type: 'X.509'
                });
                console.log('✅ Đã cập nhật master-admin identity');
            }
        } else {
            console.log('🆕 Tạo mới master-admin identity...');
            // Tạo mới master-admin identity với certificate từ cryptogen
            await WalletBlockchainRepository.upsertById('master-admin', {
                UserID: 'master-admin',
                CredentialsCertificate: certificate,
                CredentialsPrivateKey: privateKey,
                MSPID: 'Org1MSP',
                Type: 'X.509'
            });
            console.log('✅ Đã tạo master-admin identity');
        }

        console.log('🎉 Master admin đã sẵn sàng để register users!');
        
    } catch (error) {
        console.error('❌ Lỗi setup master admin:', error);
        throw error;
    }
}


// Chạy script nếu file này được execute trực tiếp

if (import.meta.url === `file://${process.argv[1]}`) {
    enrollMasterAdminWithRegistrarRights()
        .then(() => {
            console.log('✅ Hoàn thành setup master admin');
            process.exit(0);
        })
        .catch((error) => {
            console.error('❌ Setup thất bại:', error);
            process.exit(1);
        });
}

export default enrollMasterAdminWithRegistrarRights;