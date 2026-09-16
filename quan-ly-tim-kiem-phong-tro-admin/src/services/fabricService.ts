/**
 * fabricService.ts
 *
 * Tách biệt business logic Fabric Gateway khỏi các API route.
 *
 * Luồng ký số phân tán (offline signing):
 *   1. prepareTx  → tạo unsigned proposal, trả về proposalBytes (base64) + digestHex
 *   2. submitSignedTx → nhận DER signature từ mobile, ghép vào proposal rồi endorse + submit
 */

import crypto from 'crypto';
import { connect, Identity } from '@hyperledger/fabric-gateway';
import { getGrpcClient } from '@/lib/fabricGateway';

// --------------------------------------------------------------------------
// Hằng số cấu hình (có thể override bằng env)
// --------------------------------------------------------------------------
const CHANNEL_NAME = process.env.FABRIC_CHANNEL_NAME || 'rentingchannel';
const CHAINCODE_NAME = process.env.FABRIC_CHAINCODE_NAME || 'renting';
const DEFAULT_MSP_ID = process.env.FABRIC_MSP_ID || 'Org1MSP';

// --------------------------------------------------------------------------
// Kiểu dữ liệu
// --------------------------------------------------------------------------

export interface PrepareTxInput {
  functionName: string;
  args?: string[];
  /** PEM certificate của user (từ keystore.json trên mobile) */
  certificate: string;
  mspId?: string;
}

export interface PrepareTxOutput {
  /** Toàn bộ proposal bytes, encode base64 — gửi lại ở submit-tx */
  proposalBytes: string;
  /** SHA-256 digest (hex) của proposal — mobile ký bằng private key */
  digestHex: string;
}

export interface SubmitSignedTxInput {
  /** proposalBytes nhận được từ prepare-tx (base64) */
  proposalBytes: string;
  /**
   * Chữ ký ECDSA dạng DER ASN.1, encode hex.
   * Flutter tạo: sau khi ký (r,s) → đóng gói DER → hex.
   */
  derSignatureHex: string;
  /** PEM certificate của user */
  certificate: string;
  mspId?: string;
}

export interface SubmitSignedTxOutput {
  transactionId: string;
  blockStatus: string | number;
}

// --------------------------------------------------------------------------
// Helpers
// --------------------------------------------------------------------------

function buildIdentity(certificate: string, mspId: string): Identity {
  return {
    mspId,
    credentials: Buffer.from(certificate, 'utf8'),
  };
}



// --------------------------------------------------------------------------
// Service Functions
// --------------------------------------------------------------------------

/**
 * BƯỚC 1: Tạo unsigned proposal và trả về bytes + digest để mobile ký.
 */
export async function prepareTx(input: PrepareTxInput): Promise<PrepareTxOutput> {
  const { functionName, args, certificate, mspId = DEFAULT_MSP_ID } = input;

  const identity = buildIdentity(certificate, mspId);

  // Dùng dummy signer — bước này chỉ tạo khung Proposal, chưa cần ký thật
  const gateway = connect({
    client: getGrpcClient(),
    identity,
    signer: async () => new Uint8Array(),
  });

  try {
    const network = gateway.getNetwork(CHANNEL_NAME);
    const contract = network.getContract(CHAINCODE_NAME);

    const proposal = contract.newProposal(functionName, {
      arguments: args ?? [],
    });

    const proposalBytes = Buffer.from(proposal.getBytes()).toString('base64');
    const digestHex = Buffer.from(proposal.getDigest()).toString('hex');

    return { proposalBytes, digestHex };
  } finally {
    gateway.close();
  }
}

/**
 * BƯỚC 2: Nhận DER signature của Proposal từ mobile, ghép vào proposal rồi endorse.
 * Trả về transactionBytes và digestHex của Transaction để mobile ký lần 2.
 */
export async function endorseTx(
  input: SubmitSignedTxInput // Tái sử dụng interface, rename logic sau
): Promise<{ transactionBytes: string; digestHex: string }> {
  const { proposalBytes, derSignatureHex, certificate, mspId = DEFAULT_MSP_ID } = input;

  const identity = buildIdentity(certificate, mspId);

  const gateway = connect({
    client: getGrpcClient(),
    identity,
    signer: async () => new Uint8Array(),
  });

  try {
    const signatureBytes = Buffer.from(derSignatureHex, 'hex');

    const signedProposal = gateway.newSignedProposal(
      Buffer.from(proposalBytes, 'base64'),
      signatureBytes
    );

    // Gửi lên Endorsing Peers
    const transaction = await signedProposal.endorse();

    const transactionBytes = Buffer.from(transaction.getBytes()).toString('base64');
    const digestHex = Buffer.from(transaction.getDigest()).toString('hex');

    return { transactionBytes, digestHex };
  } finally {
    gateway.close();
  }
}

export interface SubmitTransactionInput {
  transactionBytes: string;
  derSignatureHex: string;
  certificate: string;
  mspId?: string;
}

/**
 * BƯỚC 3: Nhận DER signature của Transaction từ mobile, ghép vào transaction rồi submit.
 */
export async function submitTx(
  input: SubmitTransactionInput
): Promise<SubmitSignedTxOutput> {
  const { transactionBytes, derSignatureHex, certificate, mspId = DEFAULT_MSP_ID } = input;

  const identity = buildIdentity(certificate, mspId);

  const gateway = connect({
    client: getGrpcClient(),
    identity,
    signer: async () => new Uint8Array(),
  });

  try {
    const signatureBytes = Buffer.from(derSignatureHex, 'hex');

    const signedTransaction = gateway.newSignedTransaction(
      Buffer.from(transactionBytes, 'base64'),
      signatureBytes
    );

    // Submit lên Orderer
    const commit = await signedTransaction.submit();

    return {
      transactionId: signedTransaction.getTransactionId(),
      blockStatus: String(commit.getStatus()),
    };
  } finally {
    gateway.close();
  }
}
