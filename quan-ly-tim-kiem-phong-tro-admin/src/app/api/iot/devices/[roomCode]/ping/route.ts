import { db } from "@/lib/firebase/admin";
import { NextResponse } from "next/server";

/**
 * GET: Lấy PingCode hiện tại
 */
export async function GET(_: Request, { params }: { params: { roomCode: string } }) {
  try {
    const roomCode = params.roomCode;
    const docRef = db.collection("iot_device_in_apartment").doc(roomCode);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json({ status: "fail", message: "Device not found" }, { status: 404 });
    }

    const data = doc.data();
    return NextResponse.json({
      status: "success",
      pingCode: data?.PingCode || null,
    });
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
    const { pingReply } = json;

    if (!pingReply) {
      return NextResponse.json({ status: "fail", message: "Missing pingReply" }, { status: 400 });
    }

    const docRef = db.collection("iot_device_in_apartment").doc(roomCode);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json({ status: "fail", message: "Device not found" }, { status: 404 });
    }

    await docRef.update({ PingReply: pingReply });
    return NextResponse.json({ status: "success", message: "PingReply updated" });
  } catch (err: unknown) {
    return NextResponse.json(
      { status: "fail", message: err instanceof Error ? err.message : "Unknown error" },
      { status: 500 }
    );
  }
}
