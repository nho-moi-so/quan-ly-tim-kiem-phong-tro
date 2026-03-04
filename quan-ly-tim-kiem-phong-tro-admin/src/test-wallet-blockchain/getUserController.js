const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');

const ccpPath = path.resolve(__dirname, '..', '..', '..', 'blockchain-fabric', 'test-network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

exports.getUserProfile = async (req, res) => {
	const requesterId = req.user?.uid;
	const isAdmin = req.user?.role === 'admin' || req.user?.isAdmin === true || requesterId === 'admin';
	const targetId = isAdmin
		? (req.params?.id || req.query?.id || req.body?.id || requesterId)
		: requesterId;

	if (!requesterId) {
		return res.status(401).json({ error: 'Unauthorized: thiếu req.user.uid từ middleware auth.' });
	}

	if (!targetId) {
		return res.status(400).json({ error: 'Thiếu user id cần truy vấn.' });
	}

	const walletPath = path.join(__dirname, 'identities');
	const wallet = await Wallets.newFileSystemWallet(walletPath);

	const identityName = isAdmin ? 'admin' : requesterId;
	const identity = await wallet.get(identityName);
	if (!identity) {
		return res.status(404).json({ error: `Không tìm thấy identity '${identityName}' trong wallet.` });
	}

	const gateway = new Gateway();

	try {
		await gateway.connect(ccp, {
			wallet,
			identity: identityName,
			discovery: { enabled: true, asLocalhost: true }
		});

		const network = await gateway.getNetwork('rentingchannel');
		const contract = network.getContract('renting');

		const resultBytes = await contract.evaluateTransaction('GetUser', targetId);
		const userProfile = JSON.parse(resultBytes.toString());

		return res.status(200).json(userProfile);
	} catch (error) {
		return res.status(500).json({ error: error.message });
	} finally {
		gateway.disconnect();
	}
};
