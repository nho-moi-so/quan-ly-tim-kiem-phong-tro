import { ContractService } from "@/services/contractService";
import z from "zod";

const BookApartmentTestSchema = z.object({
    apartmentId: z.string(),
    endDateSec: z.number(),
    startDateSec: z.number(),
    userId: z.string()
});

export const POST = async (request: Request) => {
    try {
        const body = await request.json();
        const parsedData = BookApartmentTestSchema.parse(body);
        
        //call service to book apartment for testing
        const result = await ContractService.bookApartmentTest(parsedData);

        return new Response(JSON.stringify({
            status: "success",
            message: "Apartment booked successfully (test)",
            data: result
        }), { status: 201 });
    } catch(err : unknown) {
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }), { status: 400 });
    }
}
