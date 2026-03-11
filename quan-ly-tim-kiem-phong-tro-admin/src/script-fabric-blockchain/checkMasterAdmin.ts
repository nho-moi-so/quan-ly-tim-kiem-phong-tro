// Script kiểm tra master admin trong Firebase
import { WalletBlockchainRepository } from '@/repositories/walletBlockchainRepository';

async function checkMasterAdmin() {
    try {
        console.log('🔍 Kiểm tra master-admin identity trong Firebase...');
        const identity = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin');
        
        if (!identity) {
            console.log('❌ Không tìm thấy master-admin identity trong Firebase');
            console.log('💡 Cần tạo master admin identity trước khi sync users');
        } else {
            console.log('✅ Tìm thấy master-admin identity:');
            console.log('- MSPID:', identity.mspId);
            console.log('- Type:', identity.type);
            console.log('- Certificate length:', identity.credentials.certificate.length);
            console.log('- Private key length:', identity.credentials.privateKey.length);
        }
    } catch (error) {
        console.error('❌ Lỗi kiểm tra master admin:', error);
    }
}

checkMasterAdmin();