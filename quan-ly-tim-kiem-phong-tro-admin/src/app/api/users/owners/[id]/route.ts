import { UserService } from "@/services/userService";
import { NextResponse } from "next/server";

export const GET = async (req: Request, { params }: { params: { id: string } }) => {
    try {
        const ownerId = params.id;
        const owner = await UserService.getOwnerById(ownerId);

        if (!owner) {
            return NextResponse.json({
                status: "fail",
                message: "Owner not found"
            }, { status: 404 });
        }

        return NextResponse.json({
            status: "success",
            data: owner
        });
    } catch (err: unknown) {
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}