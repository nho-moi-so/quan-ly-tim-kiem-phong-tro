import { PostService } from "@/services/postService";
import { NextResponse } from "next/server";

export const POST = async (
    request: Request,
    { params }: { params: { id: string } }
) => {
    try {
        const postId = params.id;
        const result = await PostService.approvePost(postId);
        return NextResponse.json({
            status: "success",
            data: result
        });
    } catch (err: unknown) {
        return NextResponse.json(
            {
                status: "fail",
                message: err instanceof Error ? err.message : "Unknown error"
            },
            { status: 400 }
        );
    }
};
