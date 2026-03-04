const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const { registerUserToFabric } = require('../test-wallet-blockchain/walletManager');

// Load cấu hình mạng (ccp)
const ccpPath = path.resolve(__dirname, '..', '..', '..', 'blockchain-fabric', 'test-network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

exports.register = async (req, res) => {
    const { email, password, fullName, balance } = req.body;

    try {
        // --- BƯỚC 1: TẠO USER TRÊN FIREBASE (Giả sử ông đã làm xong) ---
        // const fbUser = await admin.auth().createUser({ email, password });
        // const uid = fbUser.uid;
        const uid = "USER_TEMP_" + Date.now(); // Mock UID để test

        // --- BƯỚC 2: TẠO IDENTITY TRONG WALLET CHO USER ---
        // Hàm này ta đã viết ở câu trước, nó sẽ tạo file uid.id trong identities/
        const fabricWalletResult = await registerUserToFabric(uid);
        if (!fabricWalletResult.success) {
            return res.status(500).json({ message: "Lỗi tạo Wallet", error: fabricWalletResult.error });
        }

        // --- BƯỚC 3: DÙNG IDENTITY ADMIN ĐỂ KHỞI TẠO USER TRÊN LEDGER ---
        const walletPath = path.join(__dirname, 'identities');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        const gateway = new Gateway();
        // QUAN TRỌNG: identity ở đây phải là 'admin' vì Smart Contract chỉ cho phép admin tạo User
        await gateway.connect(ccp, {
            wallet,
            identity: 'admin', 
            discovery: { enabled: true, asLocalhost: true }
        });

        const network = await gateway.getNetwork('rentingchannel');
        const contract = network.getContract('renting');

        // Gọi hàm CreateUser trên Blockchain
        await contract.submitTransaction('CreateUser', uid, fullName, balance.toString());

        await gateway.disconnect();

        res.status(200).json({
            message: "Đăng ký thành công!",
            uid: uid,
            blockchainStatus: "User Created on Ledger by Admin"
        });

    } catch (error) {
        console.error(`Lỗi đăng ký: ${error}`);
        res.status(500).json({ error: error.message });
    }
};