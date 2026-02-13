// check apartment available
// contract := Contract{
// 		DocType:      "contract",
// 		ID:           contractId,
// 		ApartmentID:  apartmentId,
// 		GuestID:      guestId,
// 		StartDate:    startDate,
// 		EndDate:      endDate,
// 		EscrowAmount: totalPrice, //tien bi khoa o day
// 		Status:       "CREATED",
// 	}
// apartment -> booked


import { ContractService } from "@/services/contractService";
import z from "zod";
const BookApartmentSchema = z.object({
    apartmentId: z.string(),
    endDate: z.number(),
    startDate: z.number(),
    status: z.string().optional(),
    total: z.number().optional(),
    userId: z.string()
});
export const POST = async (request: Request) => {
    try{
        const body = await request.json();
        const parsedData = BookApartmentSchema.parse(body);

        //call service to book apartment
        const result = await ContractService.bookApartment(parsedData);

        return new Response(JSON.stringify({
            status: "success",
            message: "Apartment booked successfully",
            data: result
        }), { status: 201});
    }

    catch(err : unknown){
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }), { status: 400});
    }
}
