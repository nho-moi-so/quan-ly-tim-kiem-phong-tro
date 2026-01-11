import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";

export async function POST(req: Request, { params }: { params: { roomCode: string } }) {
  try {
    const roomCode = params.roomCode;
    const json = await req.json();
    const { deviceId } = json;
    
    if (!deviceId) {
      return NextResponse.json(
        { status: "error", message: "Missing deviceId" },
        { status: 400 }
      );
    }
    
    const result = await IOTService.checkDevice(roomCode, deviceId);
    const httpStatus = result.status === "success" ? 200 : 400;
    return NextResponse.json(result, { status: httpStatus });
  } catch (err: unknown) {
    return NextResponse.json(
      {
        status: "fail",
        message: err instanceof Error ? err.message : "Unknown error",
      },
      { status: 500 }
    );
  }
}
