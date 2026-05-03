const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const path = require('path');

// Đọc file connection profile (json) từ thư mục test-network của ông
const ccpPath = path.resolve(__dirname, '..', '..', '..', 'blockchain-fabric-v2', 'test-network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

// Lấy thông tin CA từ profile
const caInfo = ccp.certificateAuthorities['ca.org1.example.com'];
const caTLSCACerts = caInfo.tlsCACerts.pem;
const ca = new FabricCAServices(caInfo.url, { trustedRoots: caTLSCACerts, verify: false }, caInfo.caName);

module.exports = { ca, ccp };