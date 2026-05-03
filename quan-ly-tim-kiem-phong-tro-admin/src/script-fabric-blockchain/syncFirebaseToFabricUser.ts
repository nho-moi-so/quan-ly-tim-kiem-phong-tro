// cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
// npm run ts-node src/script-fabric-blockchain/syncFirebaseToFabricUser.ts
import { ca, ccp } from '@/lib/fabric/caClient';
import { UserRepository } from '@/repositories/userRepository';
import { WalletBlockchainRepository } from '@/repositories/walletBlockchainRepository';
import { Gateway, Wallets } from 'fabric-network';
import fs from 'fs';
import path from 'path';

/**
 * Script đồng bộ dữ liệu User từ Firebase vào Fabric Blockchain
 * Dùng cho việc reset mạng fabric và khôi phục dữ liệu  
 * Note: Script này tạo HOÀN TOÀN user (bao gồm cả wallet certificates từ CA)
 */

/**
 * Mapping Firebase User Role sang Fabric UserRole
 */
function mapFirebaseRoleToFabricRole(firebaseRole) {
    switch (firebaseRole && firebaseRole.toLowerCase()) {
        case 'admin':
            return 'ADMIN';
        case 'owner':
            return 'OWNER';
        case 'guest':
        default:
            return 'GUEST';
    }
}

/**
 * Mapping Firebase User Status sang Fabric UserStatus
 */
function mapFirebaseStatusToFabricStatus(firebaseStatus, approvalStatus) {
    // Ưu tiên ApprovalStatus nếu có
    if (approvalStatus && approvalStatus.toLowerCase() === 'approved') {
        return 'APPROVED';
    }
    
    switch (firebaseStatus && firebaseStatus.toLowerCase()) {
        case 'active':
            return 'ACTIVE';
        case 'locked':
            return 'LOCKED';
        case 'pending':
        default:
            return 'PENDING';
    }
}

/**
 * Transform Firebase User thành Fabric IUser
 */
function transformFirebaseUserToFabricUser(firebaseUser) {
    return {
        docType: 'user',
        id: firebaseUser.Id,
        fullName: firebaseUser.Fullname || 'Unknown User',
        balance: firebaseUser.Balance || 0,
        lockedBalace: 0, // Mặc định 0 khi sync
        status: mapFirebaseStatusToFabricStatus(firebaseUser.Status, firebaseUser.ApprovalStatus),
        role: mapFirebaseRoleToFabricRole(firebaseUser.Role)
    };
}

/**
 * Tạo Master Admin Identity từ certificates
 */
async function createMasterAdminIdentity() {
    try {
        // Đường dẫn tới certificates của admin - path tuyệt đối
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

        return {
            credentials: {
                certificate,
                privateKey,
            },
            mspId: 'Org1MSP',
            type: 'X.509',
        };
    } catch (error) {
        console.error('Lỗi tạo Master Admin Identity:', error);
        throw error;
    }
}

/**
 * Tạo CA Admin Identity bằng cách enroll trực tiếp với CA
 * Identity này có quyền register/enroll users với CA
 */
async function createCAAdminIdentity() {
    try {
        const enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        return {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'Org1MSP',
            type: 'X.509',
        };
    } catch (error) {
        console.error('Lỗi tạo CA Admin Identity:', error);
        throw error;
    }
}

/**
 * Sync một user từ Firebase vào Fabric (bao gồm cả wallet certificates từ CA)
 * Sử dụng 2 identity riêng biệt:
 * - caAdminIdentity: để register/enroll user với CA
 * - mspAdminIdentity: để submit transaction lên blockchain
 */
async function syncUserToFabric(fabricUser, caAdminIdentity, mspAdminIdentity, firebaseUser) {
    const gateway = new Gateway();
    try {
        console.log(`🔄 Syncing user: ${firebaseUser.Email} (${fabricUser.id})`);
        
        // 1. Kiểm tra xem user đã có wallet certificates chưa
        const existingWallet = await WalletBlockchainRepository.getByUserId(fabricUser.id);
        if (existingWallet.length === 0) {
            console.log(`🔑 Tạo wallet certificates cho user: ${fabricUser.id}`);
            
            // Tạo in-memory wallet với CA admin để register user với CA
            const caWallet = await Wallets.newInMemoryWallet();
            await caWallet.put('admin', caAdminIdentity);
            
            const provider = caWallet.getProviderRegistry().getProvider(caAdminIdentity.type);
            const adminUser = await provider.getUserContext(caAdminIdentity, 'admin');
            
            try {
                // Register user với CA (dùng CA Admin)
                const secret = await ca.register({
                    affiliation: 'org1.department1',
                    enrollmentID: fabricUser.id,
                    role: 'client'
                }, adminUser);
                
                // Enroll để lấy certificates
                const enrollment = await ca.enroll({
                    enrollmentID: fabricUser.id,
                    enrollmentSecret: secret
                });
                
                // Lưu certificates vào Firebase
                await WalletBlockchainRepository.create({
                    UserID: fabricUser.id,
                    CredentialsCertificate: enrollment.certificate,
                    CredentialsPrivateKey: enrollment.key.toBytes(),
                    MSPID: 'Org1MSP',
                    Type: 'X.509'
                });
                
                console.log(`✅ Đã tạo wallet certificates cho user: ${fabricUser.id}`);
            } catch (walletError) {
                console.error(`❌ Lỗi tạo wallet cho user ${fabricUser.id}:`, walletError);
                throw walletError;
            }
        } else {
            console.log(`⏭️ User ${fabricUser.id} đã có wallet certificates, bỏ qua`);
        }
        
        // 2. Tạo user record trên blockchain (dùng MSP Admin)
        console.log(`⛓️ Tạo user ${fabricUser.id} trên blockchain...`);
        
        // Tạo in-memory wallet với MSP admin cho việc submit transaction
        const mspWallet = await Wallets.newInMemoryWallet();
        await mspWallet.put('admin', mspAdminIdentity);

        // Connect với MSP admin identity (có quyền trên channel)
        await gateway.connect(ccp as any, {
            wallet: mspWallet,
            identity: 'admin',
            discovery: { enabled: true, asLocalhost: true }
        });

        const network = await gateway.getNetwork('rentingchannel');
        const contract = network.getContract('renting');
        
        // Submit transaction để tạo user trên blockchain
        await contract.submitTransaction('CreateUser', 
            fabricUser.id, 
            fabricUser.fullName, 
            fabricUser.balance.toString(), 
            fabricUser.role
        );
        
        console.log(`✅ Đã sync HOÀN TOÀN user: ${fabricUser.id} (${fabricUser.fullName})`);
    } catch (error) {
        console.error(`❌ Lỗi sync user ${fabricUser.id}:`, error);
        throw error;
    } finally {
        gateway.disconnect();
    }
}

/**
 * Main function - Đồng bộ tất cả users từ Firebase vào Fabric
 */
export async function syncFirebaseUsersToFabric() {
    console.log('🚀 Bắt đầu đồng bộ users từ Firebase vào Fabric Blockchain...');

    try {
        // 1. Lấy tất cả users từ Firebase
        console.log('📊 Đang lấy dữ liệu users từ Firebase...');
        const firebaseUsers = await UserRepository.getAll();
        console.log(`📋 Tìm thấy ${firebaseUsers.length} users trong Firebase`);

        if (firebaseUsers.length === 0) {
            console.log('⚠️ Không có users nào trong Firebase để sync');
            return;
        }

        // 2. Transform Firebase Users sang Fabric Users
        console.log('🔄 Đang transform dữ liệu users...');
        const fabricUsers = firebaseUsers.map(transformFirebaseUserToFabricUser);

        // 3. Tạo CA Admin Identity (để register users với CA)
        console.log('🔑 Đang tạo CA Admin Identity...');
        const caAdminIdentity = await createCAAdminIdentity();
        console.log('✅ CA Admin Identity sẵn sàng');

        // 4. Tạo MSP Admin Identity (để submit transaction lên blockchain)
        console.log('🔑 Đang tạo MSP Admin Identity từ filesystem...');
        const mspAdminIdentity = await createMasterAdminIdentity();
        console.log('✅ MSP Admin Identity sẵn sàng');

        // 5. Sync từng user vào Fabric (bao gồm cả wallet certificates)
        console.log('🔄 Bắt đầu sync users vào Fabric với wallet certificates...');
        
        let successCount = 0;
        let errorCount = 0;

        for (let i = 0; i < fabricUsers.length; i++) {
            const fabricUser = fabricUsers[i];
            const firebaseUser = firebaseUsers[i];
            
            try {
                await syncUserToFabric(fabricUser, caAdminIdentity, mspAdminIdentity, firebaseUser);
                successCount++;
                
                // Đợi một chút giữa các users để tránh overload CA
                if (i < fabricUsers.length - 1) {
                    console.log('⏳ Đợi 2 giây trước user tiếp theo...');
                    await new Promise(resolve => setTimeout(resolve, 2000));
                }
            } catch (error) {
                console.error(`❌ Lỗi sync user ${fabricUser.id}:`, error);
                errorCount++;
            }
        }

        // 5. Báo cáo kết quả
        console.log('\n📊 KẾT QUẢ ĐỒNG BỘ HOÀN TOÀN:');
        console.log(`✅ Thành công: ${successCount}/${firebaseUsers.length} users`);
        console.log(`❌ Lỗi: ${errorCount}/${firebaseUsers.length} users`);
        console.log(`📊 Tỷ lệ thành công: ${((successCount/firebaseUsers.length) * 100).toFixed(2)}%`);
        
        if (errorCount === 0) {
            console.log('🎉 Hoàn thành đồng bộ HOÀN TOÀN tất cả users (bao gồm wallet certificates)!');
        } else {
            console.log('⚠️ Đồng bộ hoàn thành với một số lỗi. Vui lòng kiểm tra logs phía trên.');
        }

    } catch (error) {
        console.error('💥 Lỗi trong quá trình đồng bộ:', error);
        throw error;
    }
}

/**
 * Function để chạy script từ command line
 */
async function runSyncScript() {
    try {
        await syncFirebaseUsersToFabric();
        process.exit(0);
    } catch (error) {
        console.error('💥 Script thất bại:', error);
        process.exit(1);
    }
}

// Chạy script nếu file này được execute trực tiếp

if (import.meta.url === `file://${process.argv[1]}`) {
    runSyncScript();
}

export default syncFirebaseUsersToFabric;
