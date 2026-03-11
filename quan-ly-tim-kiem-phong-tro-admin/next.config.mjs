/** @type {import('next').NextConfig} */
const nextConfig = {
	experimental: {
		serverComponentsExternalPackages: [
			'pkcs11js', 
			'@hyperledger/fabric-gateway',
			'fabric-network',
			'fabric-ca-client', 
			'fabric-common',
			'fabric-protos',
			'@grpc/proto-loader',
			'grpc'
		],
	},
	webpack: (config, { isServer, dev }) => {
		if (isServer) {
			// Exclude fabric libraries from webpack bundling on server side
			config.externals = config.externals || [];
			config.externals.push({
				'fabric-network': 'commonjs fabric-network',
				'fabric-ca-client': 'commonjs fabric-ca-client',
				'fabric-common': 'commonjs fabric-common',
				'fabric-protos': 'commonjs fabric-protos',
				'@grpc/proto-loader': 'commonjs @grpc/proto-loader',
				'@hyperledger/fabric-gateway': 'commonjs @hyperledger/fabric-gateway'
			});
		}
		return config;
	},
};

export default nextConfig;
