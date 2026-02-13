/** @type {import('next').NextConfig} */
const nextConfig = {
	experimental: {
		serverComponentsExternalPackages: ['pkcs11js', '@hyperledger/fabric-gateway'],
	},
};

export default nextConfig;
