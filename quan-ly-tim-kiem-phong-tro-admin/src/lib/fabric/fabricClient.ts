import crypto from 'crypto';
import fs from 'fs';
import path from 'path';

import * as grpc from '@grpc/grpc-js';
import { connect, Contract, Gateway, signers } from '@hyperledger/fabric-gateway';

export type FabricConfig = {
	channelName: string;
	chaincodeName: string;
	mspId: string;
	cryptoPath: string;
	keyDirectoryPath: string;
	certPath: string;
	tlsCertPath: string;
	peerEndpoint: string;
	peerHostAlias: string;
};

const defaultCryptoPath = path.resolve(
	process.cwd(),
	'..',
	'blockchain-fabric-v2',
	'test-network',
	'organizations',
	'peerOrganizations',
	'org1.example.com'
);

const loadConfigFromEnv = (): FabricConfig => {
	const cryptoPath = process.env.FABRIC_CRYPTO_PATH || defaultCryptoPath;
	const userName = process.env.FABRIC_USER_NAME || 'User1@org1.example.com';
	const peerName = process.env.FABRIC_PEER_NAME || 'peer0.org1.example.com';

	return {
		channelName: process.env.FABRIC_CHANNEL_NAME || 'mychannel',
		chaincodeName: process.env.FABRIC_CHAINCODE_NAME || 'basic',
		mspId: process.env.FABRIC_MSP_ID || 'Org1MSP',
		cryptoPath,
		keyDirectoryPath:
			process.env.FABRIC_KEY_DIR ||
			path.resolve(cryptoPath, 'users', userName, 'msp', 'keystore'),
		certPath:
			process.env.FABRIC_CERT_PATH ||
		path.resolve(cryptoPath, 'users', userName, 'msp', 'signcerts', 'cert.pem'),
		tlsCertPath:
			process.env.FABRIC_TLS_CERT_PATH ||
			path.resolve(cryptoPath, 'peers', peerName, 'tls', 'ca.crt'),
		peerEndpoint: process.env.FABRIC_PEER_ENDPOINT || 'localhost:7051',
		peerHostAlias: process.env.FABRIC_PEER_HOST_ALIAS || peerName,
	};
};

const newGrpcConnection = async (config: FabricConfig): Promise<grpc.Client> => {
	const tlsRootCert = fs.readFileSync(config.tlsCertPath);
	const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
	return new grpc.Client(config.peerEndpoint, tlsCredentials, {
		'grpc.ssl_target_name_override': config.peerHostAlias,
	});
};

const newIdentity = async (config: FabricConfig) => {
	const credentials = fs.readFileSync(config.certPath);
	return { mspId: config.mspId, credentials };
};

const newSigner = async (config: FabricConfig) => {
	const files = fs.readdirSync(config.keyDirectoryPath);
	if (files.length === 0) {
		throw new Error('No private key files found in keystore directory.');
	}
	const keyPath = path.resolve(config.keyDirectoryPath, files[0]);
	const privateKeyPem = fs.readFileSync(keyPath);
	const privateKey = crypto.createPrivateKey(privateKeyPem);
	return signers.newPrivateKeySigner(privateKey);
};

export type FabricClient = {
	contract: Contract;
	gateway: Gateway;
	client: grpc.Client;
	close: () => void;
};

export const createFabricClient = async (
	overrides: Partial<FabricConfig> = {}
): Promise<FabricClient> => {
	const config = { ...loadConfigFromEnv(), ...overrides };
	const client = await newGrpcConnection(config);
	const gateway = connect({
		client,
		identity: await newIdentity(config),
		signer: await newSigner(config),
	});

	const network = gateway.getNetwork(config.channelName);
	const contract = network.getContract(config.chaincodeName);

	return {
		contract,
		gateway,
		client,
		close: () => {
			gateway.close();
			client.close();
		},
	};
};
