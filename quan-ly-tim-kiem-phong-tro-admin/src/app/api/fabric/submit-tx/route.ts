/**
 * POST /api/fabric/submit-tx
 *
 * BƯỚC 3 của luồng ký số phân tán:
 *   - Nhận transactionBytes (base64), derSignatureHex (của Transaction), certificate (PEM), mspId
 *   - Ghép chữ ký vào transaction
 *   - Submit lên Orderer để ghi vào sổ cái
 *   - Trả về transactionId + blockStatus
 */

import { NextResponse } from 'next/server';
import { submitTx } from '@/services/fabricService';

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { transactionBytes, derSignatureHex, certificate, mspId } = body;

    if (!transactionBytes || !derSignatureHex || !certificate) {
      return NextResponse.json(
        {
          status: 'error',
          message:
            'Thiếu tham số: transactionBytes, derSignatureHex và certificate là bắt buộc.',
        },
        { status: 400 }
      );
    }

    const result = await submitTx({
      transactionBytes,
      derSignatureHex,
      certificate,
      mspId,
    });

    return NextResponse.json({
      status: 'success',
      data: {
        transactionId: result.transactionId,
        blockStatus: result.blockStatus,
      },
    });
  } catch (error: any) {
    console.error('[submit-tx] Error:', error);
    return NextResponse.json(
      { status: 'error', message: error.message },
      { status: 500 }
    );
  }
}