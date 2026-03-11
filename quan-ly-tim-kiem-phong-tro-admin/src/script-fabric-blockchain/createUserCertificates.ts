// Script tạo wallet certificates cho users từ Firebase
// cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
// npm run ts-node src/script-fabric-blockchain/createUserCertificates.ts

import { ca } from '@/lib/fabric/caClient';
import { UserRepository } from '@/repositories/userRepository';
import { WalletBlockchainRepository } from '@/repositories/walletBlockchainRepository';
import { Wallets } from 'fabric-network';

/**
 * Script tạo certificates cho users từ Firebase thông qua CA
 * Sử dụng khi cần tạo certificates cho users đã tồn tại trên blockchain
 */

/**
 * Tạo certificate cho một user
 */
async function createUserCertificate(userId: string, masterAdminIdentity: any) {
    try {
        // Kiểm tra xem user đã có certificate chưa
        const existingWallet = await WalletBlockchainRepository.getIdentityFromFirebase(userId);
        if (existingWallet) {
            console.log(`⚠️ User ${userId} đã có certificate, bỏ qua...`);
            return { success: true, message: 'Already exists' };
        }

        // Tạo in-memory wallet với master admin identity
        const memoryWallet = await Wallets.newInMemoryWallet();
        await memoryWallet.put('admin', masterAdminIdentity);

        // Lấy provider và adminUser context để đăng ký qua CA
        const provider = memoryWallet.getProviderRegistry().getProvider(masterAdminIdentity.type);
        const adminUser = await provider.getUserContext(masterAdminIdentity, 'admin');

        // Đăng ký user qua CA
        console.log(`🔑 Đăng ký user ${userId} qua CA...`);
        const secret = await ca.register({
            affiliation: 'org1.department1',
            enrollmentID: userId,
            role: 'client'
        }, adminUser);

        // Enroll user để lấy chứng chỉ
        console.log(`📜 Enroll user ${userId}...`);
        const enrollment = await ca.enroll({
            enrollmentID: userId,
            enrollmentSecret: secret
        });

        // Lưu chứng chỉ user lên Firebase
        console.log(`💾 Lưu certificate user ${userId} lên Firebase...`);
        await WalletBlockchainRepository.create({
            UserID: userId,
            CredentialsCertificate: enrollment.certificate,
            CredentialsPrivateKey: enrollment.key.toBytes(),
            MSPID: 'Org1MSP',
            Type: 'X.509'
        });

        console.log(`✅ Đã tạo certificate cho user: ${userId}`);
        return { success: true, message: 'Created successfully' };

    } catch (error) {
        console.error(`❌ Lỗi tạo certificate user ${userId}:`, error);
        return { success: false, error: error.message };
    }
}

/**
 * Main function - Tạo certificates cho tất cả users từ Firebase
 */
export async function createUserCertificates(userIds?: string[]) {
    console.log('🚀 Bắt đầu tạo certificates cho users...');

    try {
        // 1. Lấy master admin identity từ Firebase
        console.log('🔑 Đang lấy Master Admin Identity từ Firebase...');
        const masterAdminIdentity = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin');
        if (!masterAdminIdentity) {
            throw new Error('Master admin identity not found in Firebase. Vui lòng chạy setup master admin trước.');
        }

        // 2. Lấy danh sách users cần tạo certificates
        let targetUsers: string[];
        if (userIds && userIds.length > 0) {
            targetUsers = userIds;
            console.log(`📋 Sẽ tạo certificates cho ${targetUsers.length} users được chỉ định`);
        } else {
            console.log('📊 Đang lấy tất cả users từ Firebase...');
            const allUsers = await UserRepository.getAll();
            targetUsers = allUsers.map(user => user.Id);
            console.log(`📋 Tìm thấy ${targetUsers.length} users trong Firebase`);
        }

        if (targetUsers.length === 0) {
            console.log('⚠️ Không có users nào để tạo certificates');
            return;
        }

        // 3. Tạo certificates cho từng user
        console.log('🔄 Bắt đầu tạo certificates...');
        
        let successCount = 0;
        let skipCount = 0;
        let errorCount = 0;

        for (const userId of targetUsers) {
            try {
                const result = await createUserCertificate(userId, masterAdminIdentity);
                if (result.success) {
                    if (result.message === 'Already exists') {
                        skipCount++;
                    } else {
                        successCount++;
                    }
                } else {
                    errorCount++;
                }
            } catch (error) {
                console.error(`❌ Lỗi tạo certificate user ${userId}:`, error);
                errorCount++;
            }
        }

        // 4. Báo cáo kết quả
        console.log('\\n📊 KẾT QUẢ TẠO CERTIFICATES:');
        console.log(`✅ Tạo mới: ${successCount}/${targetUsers.length} users`);
        console.log(`⚠️ Đã tồn tại: ${skipCount}/${targetUsers.length} users`);
        console.log(`❌ Lỗi: ${errorCount}/${targetUsers.length} users`);
        
        if (errorCount === 0) {
            console.log('🎉 Hoàn thành tạo certificates cho tất cả users!');
        } else {
            console.log('⚠️ Hoàn thành với một số lỗi. Vui lòng kiểm tra logs phía trên.');
        }

    } catch (error) {
        console.error('💥 Lỗi trong quá trình tạo certificates:', error);
        throw error;
    }
}

/**
 * Function để chạy script từ command line
 */
async function runCreateCertificatesScript() {
    try {
        // Parse command line arguments
        const args = process.argv.slice(2);
        let userIds: string[] = [];
        
        if (args.length > 0) {
            userIds = args;
            console.log(`🎯 Tạo certificates cho users: ${userIds.join(', ')}`);
        } else {
            console.log('🔄 Tạo certificates cho tất cả users từ Firebase');
        }

        await createUserCertificates(userIds);
        process.exit(0);
    } catch (error) {
        console.error('💥 Script thất bại:', error);
        process.exit(1);
    }
}

// Chạy script nếu file này được execute trực tiếp
if (require.main === module) {
    runCreateCertificatesScript();
}

export default createUserCertificates;