const { Wallets } = require('fabric-network');
const { ca } = require('./caClient');
const path = require('path');

async function main() {
    try {
        const walletPath = path.join(__dirname, 'identities');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Kiểm tra xem admin đã có trong ví chưa
        if (await wallet.get('admin')) {
            console.log('Admin đã tồn tại trong ví rồi.');
            return;
        }

        // Enroll admin (id/pass mặc định của test-network là admin/adminpw)
        const enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'Org1MSP',
            type: 'X.509',
        };
        await wallet.put('admin', x509Identity);
        console.log('✅ Đã khởi tạo Admin thành công vào thư mục identities/');

    } catch (error) {
        console.error(`Lỗi enroll admin: ${error}`);
    }
}

main();