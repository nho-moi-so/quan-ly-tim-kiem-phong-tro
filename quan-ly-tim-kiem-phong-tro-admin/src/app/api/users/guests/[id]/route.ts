import { UserService } from "@/services/userService";
import { NextResponse } from "next/server";

export const GET = async (req: Request, { params }: { params: { id: string } }) => {
    try {
        const guestId = params.id;
        const guest = await UserService.getGuestById(guestId);

        if (!guest) {
            return NextResponse.json({
                status: "fail",
                message: "Guest not found"
            }, { status: 404 });
        }

        return NextResponse.json({
            status: "success",
            data: guest
        });
    } catch (err: unknown) {
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}