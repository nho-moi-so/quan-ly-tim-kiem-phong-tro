/**
 * POST /api/fabric/endorse-tx
 *
 * BƯỚC 2 của luồng ký số phân tán:
 *   - Nhận proposalBytes (base64), derSignatureHex (chữ ký của Proposal), certificate (PEM), mspId
 *   - Ghép chữ ký vào proposal
 *   - Gửi Endorsing Peers để endorse
 *   - Trả về transactionBytes (base64) + digestHex (của Transaction) cho mobile ký lần 2
 */

import { NextResponse } from 'next/server';
import { endorseTx } from '@/services/fabricService';

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { proposalBytes, derSignatureHex, certificate, mspId } = body;

    if (!proposalBytes || !derSignatureHex || !certificate) {
      return NextResponse.json(
        {
          status: 'error',
          message:
            'Thiếu tham số: proposalBytes, derSignatureHex và certificate là bắt buộc.',
        },
        { status: 400 }
      );
    }

    const result = await endorseTx({
      proposalBytes,
      derSignatureHex,
      certificate,
      mspId,
    });

    return NextResponse.json({
      status: 'success',
      data: {
        transactionBytes: result.transactionBytes, // base64 — gửi lại ở submit-tx
        digestHex: result.digestHex,               // hex    — mobile ký bằng private key lần 2
      },
    });
  } catch (error: any) {
    console.error('[endorse-tx] Error:', error);
    return NextResponse.json(
      { status: 'error', message: error.message },
      { status: 500 }
    );
  }
}
