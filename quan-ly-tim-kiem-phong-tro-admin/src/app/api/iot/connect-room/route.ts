import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";
import { z } from "zod";

const ConnectRoomInputSchema = z.object({
    roomCode: z.string(),
    type_iot: z.string(), // ex: smart_lock
    deviceId: z.string()
});

export async function POST(request: Request) {
    try{
        const json = await request.json();
        const { roomCode, type_iot, deviceId } = ConnectRoomInputSchema.parse(json);
        if(!type_iot || roomCode.trim() === "" || !deviceId){
            return NextResponse.json({
                status: "fail",
                message: "Missing type_iot, roomCode, or deviceId"
            }, { status: 400 });
        }
        const result = await IOTService.connectRoom(roomCode, type_iot, deviceId);

        const httpStatus = result.status === "success" ? 200 : 400;
        return NextResponse.json(result, { status: httpStatus });
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}