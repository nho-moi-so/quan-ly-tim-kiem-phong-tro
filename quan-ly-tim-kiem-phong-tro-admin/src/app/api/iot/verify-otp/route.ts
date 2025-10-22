import { db } from "@/lib/firebase/admin";
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

        if (!otpCode || !roomCode)
        return NextResponse.json({ status: "error", message: "Missing otpCode or roomCode" }, { status: 400 });

        const docRef = db.collection("iot_otps").doc(roomCode);
        const doc = await docRef.get();
        if (!doc.exists) return NextResponse.json({ status: "error", message: "OTP not found for this room" }, { status: 404 });

        const data = doc.data();
        const savedOtp = data?.otp;

        if (savedOtp !== otpCode) {
        return NextResponse.json({ status: "error", message: "Invalid OTP" }, { status: 401 });
        }

        // // (optional) mark verified, delete OTP doc or add audit log
        // await docRef.delete();

        return NextResponse.json({ status: "success", message: `verified success to roomCode is ${roomCode}` });
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}