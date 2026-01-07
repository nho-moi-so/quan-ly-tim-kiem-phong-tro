import { UserService } from "@/services/userService";
import { NextResponse } from "next/server";

export const POST = async (
  request: Request,
  { params }: { params: { id: string } }
) => {
  try {
    const result = await UserService.lockGuest(params.id);
    return NextResponse.json({ status: "success", data: result });
  } catch (err: unknown) {
    return NextResponse.json(
      {
        status: "fail",
        message: err instanceof Error ? err.message : "Unknown error",
      },
      { status: 400 }
    );
  }
};
