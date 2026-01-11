import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";

/**
 * GET: Lấy PingCode hiện tại
 */
export async function GET(req: Request, { params }: { params: { roomCode: string } }) {
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
    
    const result = await IOTService.getPingCode(roomCode, deviceId);
    const httpStatus = result.status === "success" ? 200 : result.status === "fail" ? 404 : 400;
    return NextResponse.json(result, { status: httpStatus });
  } catch (err: unknown) {
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}

/**
 * POST: Cập nhật PingReply (thiết bị gửi lại mã)
 */
export async function POST(req: Request, { params }: { params: { roomCode: string } }) {
  try {
    const roomCode = params.roomCode;
    const json = await req.json();
    const { pingReply, deviceId } = json;
    
    if (!deviceId) {
      return NextResponse.json(
        { status: "error", message: "Missing deviceId" },
        { status: 400 }
      );
    }
    
    const result = await IOTService.updatePingReply(roomCode, deviceId, pingReply);
    const httpStatus = result.status === "success" ? 200 : result.status === "fail" ? 400 : 400;
    return NextResponse.json(result, { status: httpStatus });
  } catch (err: unknown) {
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}
