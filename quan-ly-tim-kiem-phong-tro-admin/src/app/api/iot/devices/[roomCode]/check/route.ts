import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";

export async function POST(_: Request, { params }: { params: { roomCode: string } }) {
  try {
    const roomCode = params.roomCode;
    const result = await IOTService.checkDevice(roomCode);
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
