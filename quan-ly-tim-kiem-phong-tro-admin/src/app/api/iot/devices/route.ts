import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const devices = await IOTService.listDevices();
    return NextResponse.json({ status: "success", data: devices });
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
