import { NextResponse } from "next/server";
import z from "zod";

const VerifyOtpInputSchema = z.object({
    otpCode: z.string(),
    roomCode: z.string()
});

export async function POST(request: Request) {
    try{
        const json = await request.json();
        const { otpCode, roomCode } = VerifyOtpInputSchema.parse(json);
        return NextResponse.json({
            status: "success",
            message: `OTP ${otpCode} verified for room ${roomCode}`
        });
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}