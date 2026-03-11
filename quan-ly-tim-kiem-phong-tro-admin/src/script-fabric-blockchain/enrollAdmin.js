const { ca } = require('./caClient');
const path = require('path');

// Ensure all relative config loads (.env, firebase-service-account.json) are resolved from project root.
const projectRoot = path.resolve(__dirname, '..', '..');
process.chdir(projectRoot);
require('dotenv').config({ path: path.join(projectRoot, '.env') });

// Allow this JS script to import TypeScript repository and path aliases (@/*).
process.env.TS_NODE_PROJECT = path.resolve(__dirname, '..', '..', 'tsconfig.server.json');
process.env.TS_NODE_COMPILER_OPTIONS = JSON.stringify({
    module: 'commonjs',
    moduleResolution: 'node'
});
require('ts-node/register/transpile-only');
require('tsconfig-paths/register');

const { WalletBlockchainRepository } = require('../repositories/walletBlockchainRepository');

async function checkFabricCA() {
    try {
        // Thử enroll admin để kiểm tra admin đã có trên CA chưa
        await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        return true;
    } catch (error) {
        // Nếu lỗi "already enrolled" hoặc tương tự thì có nghĩa là đã có
        if (error.message && error.message.includes('already enrolled')) {
            return true;
        }
        // Các lỗi khác (network, wrong credentials) thì coi như chưa có
        return false;
    }
}

async function main() {
    try {
        const masterAdminId = 'master-admin';

        console.log("Kiem tra master admin tren Firebase va Fabric CA...");
        
        const existingOnFirebase = await WalletBlockchainRepository.getById(masterAdminId);
        const existingOnFabric = await checkFabricCA();

        console.log(`  - Firebase: ${existingOnFirebase ? 'CO' : 'KHONG'}`);
        console.log(`  - Fabric CA: ${existingOnFabric ? 'CO' : 'KHONG'}`);

        // Case 1: Cả 2 bên đều có
        if (existingOnFirebase && existingOnFabric) {
            console.log("Master admin da ton tai ca tren Firebase va Fabric CA. Khong can lam gi.");
            return;
        }

        // Case 2 & 4: Fabric không có → cần enroll
        if (!existingOnFabric) {
            console.log("Dang enroll admin tren Fabric CA...");
            var enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        } else {
            // Case 3: Fabric có, Firebase không → cần enroll lại để lấy cert
            console.log("Admin co tren Fabric CA, nhung Firebase chua co. Dang enroll lai...");
            var enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        }

        // Lưu/cập nhật Firebase
        await WalletBlockchainRepository.upsertById(masterAdminId, {
            UserID: masterAdminId,
            MSPID: 'Org1MSP',
            Type: 'X.509',
            CredentialsCertificate: enrollment.certificate,
            CredentialsPrivateKey: enrollment.key.toBytes(),
        });

        console.log("Da dong bo master admin thanh cong tren Firebase (walletBlockchains/master-admin).");

    } catch (error) {
        console.error(`Loi dong bo master admin: ${error.message || error}`);
        process.exit(1);
    }
}

main();