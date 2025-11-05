import { db } from "@/lib/firebase/admin";
import { getIO } from "@/lib/socket";
import admin from "firebase-admin";
import { NextResponse } from "next/server";
import { z } from "zod";

const ConnectRoomInputSchema = z.object({
    roomCode: z.string()
});

export async function POST(request: Request) {
    try{
        const json = await request.json();
        const { roomCode } = ConnectRoomInputSchema.parse(json);
        if (!roomCode) return NextResponse.json({ status: "error", message: "Missing roomCode" }, { status: 400 });

            // 1) tạo OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
            // 2) lưu OTP vào Firestore (collection iot_otps, document ID = roomCode)
        await db.collection("iot_otps").doc(roomCode).set({
            otp,
            status:"pending",
            createdAt: admin.firestore.Timestamp.now(), // nếu dùng admin
        });
            // 3) emit OTP qua socket theo roomCode (nếu socket đã init)
        try {
            const io = getIO();
            io.to(roomCode).emit("otp_received", { otp, roomCode });
        } catch (e) {
            // socket có thể chưa init, log nhưng vẫn trả success
            console.warn("Socket not initialized or emit failed", e);
        }

        return NextResponse.json({
            status: "success",
            message: `OTP was sent to mobile app with code: ${roomCode}`
        });
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}