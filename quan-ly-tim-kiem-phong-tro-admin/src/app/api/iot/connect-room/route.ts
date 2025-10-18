import { NextResponse } from "next/server";
import { z } from "zod";

const ConnectRoomInputSchema = z.object({
    roomCode: z.string()
});

export async function POST(request: Request) {
    try{
        const json = await request.json();
        const { roomCode } = ConnectRoomInputSchema.parse(json);
        return NextResponse.json({
            status: "success",
            message: `Connected to room with code: ${roomCode}`
        });
    }
    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}