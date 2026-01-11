import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";

export async function DELETE(req: Request, { params }: { params: { roomCode: string } }) {
  try {
    const roomCode = params.roomCode;
    const { searchParams } = new URL(req.url);
    const deviceId = searchParams.get("deviceId");
    
    if (!deviceId) {
      return NextResponse.json(
        { status: "error", message: "Missing deviceId" },
        { status: 400 }
      );
    }
    
    const result = await IOTService.deleteDevice(roomCode, deviceId);
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
