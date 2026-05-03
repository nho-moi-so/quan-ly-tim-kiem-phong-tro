// cd /root/quan-ly-tim-kiem-phong-tro/quan-ly-tim-kiem-phong-tro-admin
// npx tsx src/script-fabric-blockchain/syncFirebaseToFabricApartment.ts
import { ccp } from '@/lib/fabric/caClient';
import { ApartmentRepository } from '@/repositories/apartmentRepository';
import { WalletBlockchainRepository } from '@/repositories/walletBlockchainRepository';
import crypto from 'crypto';
import { Gateway, Wallets } from 'fabric-network';

/**
 * Script đồng bộ dữ liệu Apartment từ Firebase vào Fabric Blockchain
 * Dùng cho việc reset mạng fabric và khôi phục dữ liệu apartment
 */

/**
 * Mapping Firebase Apartment Status sang Fabric ApartmentStatus
 */
function mapFirebaseStatusToFabricStatus(firebaseStatus: string): string {
    switch (firebaseStatus && firebaseStatus.toLowerCase()) {
        case 'available':
            return 'AVAILABLE';
        case 'booked':
            return 'BOOKED';
        case 'occupied':
            return 'OCCUPIED';
        default:
            return 'AVAILABLE'; // Mặc định là AVAILABLE
    }
}

/**
 * Hash password để lưu trên blockchain
 */
function hashPassword(password: string): string {
    if (!password) {
        return ''; // Nếu không có password thì để trống
    }
    return crypto.createHash('sha256').update(password).digest('hex');
}

/**
 * Transform Firebase Apartment thành Fabric IApartment
 */
function transformFirebaseApartmentToFabricApartment(firebaseApartment: any) {
    return {
        docType: 'apartment',
        id: firebaseApartment.Id,
        ownerId: firebaseApartment.UserID,
        dailyRate: firebaseApartment.DailyRate || 0,
        status: mapFirebaseStatusToFabricStatus(firebaseApartment.Status),
        passwordHash: hashPassword(firebaseApartment.Password)
    };
}

/**
 * Sync một apartment từ Firebase vào Fabric
 */
async function syncApartmentToFabric(fabricApartment: any, masterAdminIdentity: any, firebaseApartment: any) {
    const gateway = new Gateway();
    try {
        console.log(`🏠 Syncing apartment: ${firebaseApartment.CodeApartment} (${fabricApartment.id})`);
        console.log(`📍 Address: ${firebaseApartment.Address}`);
        console.log(`👤 Owner: ${fabricApartment.ownerId}`);
        console.log(`💰 Daily Rate: ${fabricApartment.dailyRate}`);
        
        // Tạo in-memory wallet với master admin identity
        const memoryWallet = await Wallets.newInMemoryWallet();
        await memoryWallet.put('admin', masterAdminIdentity);

        // Connect với master admin identity
        await gateway.connect(ccp as any, {
            wallet: memoryWallet,
            identity: 'admin',
            discovery: { enabled: true, asLocalhost: true }
        });

        const network = await gateway.getNetwork('rentingchannel');
        const contract = network.getContract('renting');
        
        // Submit transaction để tạo apartment trên blockchain
        await contract.submitTransaction('CreateApartment', 
            fabricApartment.id, 
            fabricApartment.ownerId, 
            fabricApartment.dailyRate.toString()
        );
        
        // Nếu có password thì cập nhật password hash
        if (fabricApartment.passwordHash) {
            console.log(`🔑 Updating password for apartment: ${fabricApartment.id}`);
            await contract.submitTransaction('UpdatePasswordApartment', 
                fabricApartment.id, 
                fabricApartment.passwordHash
            );
        }
        
        console.log(`✅ Đã sync apartment: ${fabricApartment.id} (${firebaseApartment.CodeApartment})`);
    } catch (error) {
        console.error(`❌ Lỗi sync apartment ${fabricApartment.id}:`, error);
        throw error;
    } finally {
        gateway.disconnect();
    }
}

/**
 * Main function - Đồng bộ tất cả apartments từ Firebase vào Fabric
 */
export async function syncFirebaseApartmentsToFabric() {
    console.log('🏠 Bắt đầu đồng bộ apartments từ Firebase vào Fabric Blockchain...');

    try {
        // 1. Lấy tất cả apartments từ Firebase
        console.log('📊 Đang lấy dữ liệu apartments từ Firebase...');
        const firebaseApartments = await ApartmentRepository.getAll();
        console.log(`📋 Tìm thấy ${firebaseApartments.length} apartments trong Firebase`);

        if (firebaseApartments.length === 0) {
            console.log('⚠️ Không có apartments nào trong Firebase để sync');
            return;
        }

        // 2. Transform Firebase Apartments sang Fabric Apartments
        console.log('🔄 Đang transform dữ liệu apartments...');
        const fabricApartments = firebaseApartments.map(transformFirebaseApartmentToFabricApartment);

        // 3. Lấy Master Admin Identity từ Firebase
        console.log('🔑 Đang lấy Master Admin Identity từ Firebase...');
        const masterAdminIdentity = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin');
        if (!masterAdminIdentity) {
            throw new Error('Master admin identity not found in Firebase. Vui lòng chạy setup master admin trước.');
        }

        // 4. Sync từng apartment vào Fabric
        console.log('🔄 Bắt đầu sync apartments vào Fabric...');
        
        let successCount = 0;
        let errorCount = 0;

        for (let i = 0; i < fabricApartments.length; i++) {
            const fabricApartment = fabricApartments[i];
            const firebaseApartment = firebaseApartments[i];
            
            try {
                await syncApartmentToFabric(fabricApartment, masterAdminIdentity, firebaseApartment);
                successCount++;
                
                // Đợi một chút giữa các apartments để tránh overload
                if (i < fabricApartments.length - 1) {
                    console.log('⏳ Đợi 1 giây trước apartment tiếp theo...');
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }
            } catch (error) {
                console.error(`❌ Lỗi sync apartment ${fabricApartment.id}:`, error);
                errorCount++;
            }
        }

        // 5. Báo cáo kết quả
        console.log('\n📊 KẾT QUẢ ĐỒNG BỘ APARTMENTS:');
        console.log(`✅ Thành công: ${successCount}/${firebaseApartments.length} apartments`);
        console.log(`❌ Lỗi: ${errorCount}/${firebaseApartments.length} apartments`);
        console.log(`📊 Tỷ lệ thành công: ${((successCount/firebaseApartments.length) * 100).toFixed(2)}%`);
        
        if (errorCount === 0) {
            console.log('🎉 Hoàn thành đồng bộ tất cả apartments!');
        } else {
            console.log('⚠️ Đồng bộ hoàn thành với một số lỗi. Vui lòng kiểm tra logs phía trên.');
        }

        // 6. Hiển thị thống kê chi tiết
        console.log('\n📈 THỐNG KÊ CHI TIẾT:');
        const statusCount: {[key: string]: number} = {};
        firebaseApartments.forEach(apt => {
            const status = mapFirebaseStatusToFabricStatus(apt.Status);
            statusCount[status] = (statusCount[status] || 0) + 1;
        });
        
        Object.entries(statusCount).forEach(([status, count]) => {
            console.log(`${status}: ${count} apartments`);
        });

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
        await syncFirebaseApartmentsToFabric();
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

export default syncFirebaseApartmentsToFabric;