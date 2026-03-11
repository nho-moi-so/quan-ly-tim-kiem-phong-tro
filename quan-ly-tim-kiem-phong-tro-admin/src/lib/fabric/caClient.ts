import FabricCAServices from 'fabric-ca-client';
import fs from 'fs';
import path from 'path';

export interface ConnectionProfile {
    certificateAuthorities: {
        [key: string]: {
            url: string;
            caName: string;
            tlsCACerts: {
                pem: string | string[];
            };
        };
    };
    organizations?: any;
    peers?: any;
    orderers?: any;
    channels?: any;
}

export interface CAInfo {
    url: string;
    caName: string;
    tlsCACerts: {
        pem: string | string[];
    };
}

// Đọc file connection profile (json) từ thư mục test-network
const ccpPath = path.resolve(
    process.env.FABRIC_CRYPTO_PATH || '/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com',
    'connection-org1.json'
);

const ccp: ConnectionProfile = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

// Lấy thông tin CA từ profile
const caInfo: CAInfo = ccp.certificateAuthorities['ca.org1.example.com'];
const caTLSCACerts = Array.isArray(caInfo.tlsCACerts.pem) 
    ? caInfo.tlsCACerts.pem 
    : [caInfo.tlsCACerts.pem];
const ca = new FabricCAServices(
    caInfo.url, 
    { trustedRoots: caTLSCACerts, verify: false }, 
    caInfo.caName
);

export { ca, ccp };
