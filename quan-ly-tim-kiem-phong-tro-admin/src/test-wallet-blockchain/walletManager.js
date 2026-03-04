const { Wallets } = require('fabric-network');
const path = require('path');
const { ca } = require('./caClient');

const walletPath = path.join(__dirname, 'identities');

async function registerUserToFabric(userId) {
    try {
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        if (await wallet.get(userId)) {
            return { success: true, message: 'User đã có identity.' };
        }

        const adminIdentity = await wallet.get('admin');
        if (!adminIdentity) {
            throw new Error('Chưa có Admin trong ví. Hãy chạy enrollAdmin.js trước.');
        }

        // Lấy context của admin để thực hiện việc đăng ký cho user mới
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, 'admin');

        // 1. Register: Đăng ký tên trên Fabric CA
        const secret = await ca.register({
            affiliation: 'org1.department1',
            enrollmentID: userId,
            role: 'client'
        }, adminUser);

        // 2. Enroll: Lấy bộ chứng chỉ thực sự về
        const enrollment = await ca.enroll({
            enrollmentID: userId,
            enrollmentSecret: secret
        });

        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'Org1MSP',
            type: 'X.509',
        };

        // 3. Lưu vào ví với tên là Firebase UID
        await wallet.put(userId, x509Identity);
        return { success: true, message: `Đã tạo Identity Blockchain cho ${userId}` };

    } catch (error) {
        return { success: false, error: error.message };
    }
}

module.exports = { registerUserToFabric };