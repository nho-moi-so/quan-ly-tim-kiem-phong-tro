// ID, Balance, CCCD, Email, Fullname, Password, Phone, Role, Status

import { NextResponse } from "next/server";
import z from "zod";

const CreateUserSchema = z.object({
    balance: z.number().min(0).default(0),
    cccd: z.string().min(9).max(12).optional(),
    email: z.string().email(),
    fullName: z.string().min(1),
    password: z.string().min(6),
    phone: z.string().min(10).max(15),
    role: z.enum(['GUEST', 'OWNER', 'ADMIN']),
    status: z.string().default("ACTIVE")
});

export const POST = async (request: Request) => {
    try{
        const body = await request.json();
        const parsedData = CreateUserSchema.parse(body);

        console.log('🔄 Dynamic importing UserService...');
        
        // Dynamic import để tránh webpack bundling issues
        const { UserService } = await import("@/services/userService");
        
        console.log('✅ UserService imported, creating user...');
        const result = await UserService.createUser(parsedData);

        return NextResponse.json({
            status: "success",
            message: "User created successfully",
            data: {
                userId: result.Id,
                email: result.Email,
                fullName: result.Fullname,
                phone: result.Phone,
                role: result.Role,
                status: result.Status,
                balance: result.Balance
            }
        }, { status: 201 });
    }

    catch(err : unknown){
        console.error('❌ API Route Error:', err);
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}