import { PostService } from "@/services/postService";
import { NextResponse } from "next/server";

export const GET = async (req: Request, { params }: { params: { id: string } }) => {
    try {
        const postId = params.id;
        const post = await PostService.getDetailPost(postId);
        return NextResponse.json({
            status: "success",
            data: post
        });
    }
    catch (err: unknown) {
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}