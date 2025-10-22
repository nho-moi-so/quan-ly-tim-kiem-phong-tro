import { PostService } from "@/services/postService";
import { NextResponse } from "next/server";

export const GET = async (request: Request) => {
    try{
        const posts = await PostService.getAllPosts();
        return NextResponse.json({status: "success", data: posts});
    }
    catch(err : unknown){
        return NextResponse.json({
                status: "fail",
                message: err instanceof Error ? err.message : "Unknown error"
            }, { status: 400 });
        }
};