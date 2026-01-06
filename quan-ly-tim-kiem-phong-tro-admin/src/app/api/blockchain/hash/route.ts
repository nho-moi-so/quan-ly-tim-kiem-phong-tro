import { bookingChainService } from "@/services/bookingChainService";
import { NextResponse } from "next/server";
import { z } from "zod";

const BlockchainHashInputSchema = z.object({
    bookingId: z.string(),
    apartmentId: z.string(),
    price: z.number(),
    ownerId: z.string(),
    guestId: z.string(),
    password: z.string()
});

export async function POST(request: Request) {
    try {
        const json = await request.json();
        const { bookingId, apartmentId, price, ownerId, guestId, password } = 
            BlockchainHashInputSchema.parse(json);
        const hash = await bookingChainService.createBookingHash({
            bookingId,
            apartmentId,
            price,
            ownerId,
            guestId,
            password
        });
        

        return NextResponse.json({
            status: "success",
            message: "Blockchain hash created successfully",
            data: {
                hash
            }
        });
    } catch (err: unknown) {
        if (err instanceof z.ZodError) {
            return NextResponse.json({
                status: "fail",
                message: "Validation error",
                errors: err.issues
            }, { status: 400 });
        }
        
        return NextResponse.json({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }, { status: 400 });
    }
}
