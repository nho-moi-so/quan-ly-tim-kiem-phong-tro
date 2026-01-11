import { IOTService } from "@/services/IOTService";
import { NextResponse } from "next/server";
import z from "zod";

const ReConnectInputSchema = z.object({
    deviceId: z.string()
});

export async function POST(request: Request) {
    try {
        const json = await request.json();
        const { deviceId } = ReConnectInputSchema.parse(json);

        const result = await IOTService.reConnect(deviceId);

        let httpStatus = 200;
        if (result.status === "error") httpStatus = 400;
        else if (result.status === "fail") httpStatus = 404;

        return NextResponse.json(result, { status: httpStatus });
    } catch (err: unknown) {
        return NextResponse.json({
            status: "error",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}
