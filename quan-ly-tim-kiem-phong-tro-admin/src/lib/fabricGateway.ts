/**
 * fabricGateway.ts
 *
 * Singleton gRPC client dùng chung cho tất cả các API route.
 * Tránh mở kết nối mới mỗi request.
 */

import fs from 'fs';
import path from 'path';
import * as grpc from '@grpc/grpc-js';

const tlsCertPath =
  process.env.FABRIC_TLS_CERT_PATH ||
  path.resolve(
    process.env.FABRIC_CRYPTO_PATH ||
      '/root/quan-ly-tim-kiem-phong-tro/blockchain-fabric-v2/test-network/organizations/peerOrganizations/org1.example.com',
    'peers',
    process.env.FABRIC_PEER_NAME || 'peer0.org1.example.com',
    'tls',
    'ca.crt'
  );

const peerEndpoint = process.env.FABRIC_PEER_ENDPOINT || 'localhost:7051';
const peerHostAlias =
  process.env.FABRIC_PEER_HOST_ALIAS ||
  process.env.FABRIC_PEER_NAME ||
  'peer0.org1.example.com';

let _grpcClient: grpc.Client | null = null;

/**
 * Trả về singleton gRPC client.
 * Lazy-init: tạo mới nếu chưa có hoặc đã bị đóng.
 */
export function getGrpcClient(): grpc.Client {
  if (_grpcClient) return _grpcClient;

  const tlsRootCert = fs.readFileSync(tlsCertPath);
  const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);

  _grpcClient = new grpc.Client(peerEndpoint, tlsCredentials, {
    'grpc.ssl_target_name_override': peerHostAlias,
  });

  return _grpcClient;
}
