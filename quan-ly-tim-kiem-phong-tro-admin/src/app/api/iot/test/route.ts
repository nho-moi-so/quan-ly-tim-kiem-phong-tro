import { NextResponse } from "next/server";

export async function GET () {
    try{
        return NextResponse.json({ status: "success", message: "IoT test endpoint is working!" });
    } catch (error) {
        return NextResponse.json({ status: "error", message: "Failed to reach IoT test endpoint." });
    }
}