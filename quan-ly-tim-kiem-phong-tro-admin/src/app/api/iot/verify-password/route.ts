import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";
import z from "zod";


const VerifyPasswordInputSchema = z.object({
    password: z.string(),
    roomCode: z.string(),
    deviceId: z.string()
});

export async function POST(request: Request) {
    try{
        const json = await request.json();
        const { password, roomCode, deviceId } = VerifyPasswordInputSchema.parse(json);

        const verifyPasswordResult = await IOTService.verifyPassword(password, roomCode, deviceId);

        return NextResponse.json({...verifyPasswordResult});
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}
