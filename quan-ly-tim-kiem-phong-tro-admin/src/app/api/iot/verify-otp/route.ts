import { db } from "@/lib/firebase/admin";
import { getIO } from "@/lib/socket";
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

        // Cập nhật trạng thái OTP thành 'verified'
        await docRef.update({ status: "verified" });

        // Emit event về Flutter để đóng màn hình OTP
        try {
            const io = getIO();
            io.to(roomCode).emit("iot-verified", { 
                roomCode, 
                status: "success",
                message: "OTP verified successfully" 
            });
            console.log(`✅ Emitted iot-verified to room: ${roomCode}`);
        } catch (e) {
            console.warn("Socket emit failed", e);
        }

        return NextResponse.json({ status: "success", message: `verified success to roomCode is ${roomCode}` });
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}