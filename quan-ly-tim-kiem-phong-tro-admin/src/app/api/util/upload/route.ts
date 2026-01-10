import { UtilService } from "@/services/utilService";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
    try {
        const formData = await request.formData();
        const file = formData.get("file") as File;

        if (!file) {
            return NextResponse.json({
                status: "fail",
                message: "No file uploaded"
            }, { status: 400 });
        }

        const result = await UtilService.uploadFile(file);

        return NextResponse.json({
            status: "success",
            message: "File uploaded successfully",
            data: result
        }, { status: 200 });

    } catch (err: unknown) {
        console.error("Upload error:", err);
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error occurred"
        }, { status: 500 });
    }
}