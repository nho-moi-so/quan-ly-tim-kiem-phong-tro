/**
 * POST /api/fabric/prepare-tx
 *
 * BƯỚC 1 của luồng ký số phân tán:
 *   - Nhận functionName, args, certificate (PEM), mspId từ mobile
 *   - Tạo unsigned Fabric Proposal
 *   - Tính SHA-256 digest
 *   - Trả về proposalBytes (base64) + digestHex cho mobile ký
 */

import { NextResponse } from 'next/server';
import { prepareTx } from '@/services/fabricService';

export async function POST(req: Request) {
    try {
        const body = await req.json();
        const { functionName, args, certificate, mspId } = body;

        if (!certificate || !functionName) {
            return NextResponse.json(
                { status: 'error', message: 'Thiếu tham số: functionName và certificate là bắt buộc.' },
                { status: 400 }
            );
        }

        const result = await prepareTx({ functionName, args, certificate, mspId });

        return NextResponse.json({
            status: 'success',
            data: {
                proposalBytes: result.proposalBytes, // base64 — gửi lại ở submit-tx
                digestHex: result.digestHex,         // hex    — mobile ký bằng private key
            },
        });
    } catch (error: any) {
        console.error('[prepare-tx] Error:', error);
        return NextResponse.json(
            { status: 'error', message: error.message },
            { status: 500 }
        );
    }
}