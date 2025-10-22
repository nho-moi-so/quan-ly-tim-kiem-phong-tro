import { UserService } from "@/services/userService";
import { NextResponse } from "next/server";

export const GET = async (request: Request) => {
    
    try{
        const guests = await UserService.getAllGests();
        return NextResponse.json({
            status: "success",
            data: guests
        });
    }

    catch(err : unknown){
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
};