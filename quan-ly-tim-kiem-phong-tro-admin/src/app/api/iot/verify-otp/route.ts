import { IOTService } from "@/services/IOTService";
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
        const result = await IOTService.verifyOtp(otpCode, roomCode);

        let httpStatus = 200;
        if (result.status === "error") httpStatus = 400;
        else if (result.status === "fail") httpStatus = 401;

        return NextResponse.json(result, { status: httpStatus });
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}