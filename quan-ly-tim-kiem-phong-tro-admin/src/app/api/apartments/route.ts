

import { ApartmentService } from "@/services/apartmentService";
import z from "zod";

const CreateApartmentSchema = z.object({
    address: z.string(),
    codeApartment: z.string(),
    dailyRate: z.number().min(0),
    decription: z.string().optional(),
    latitude: z.number().min(-90).max(90).optional(),
    longitude: z.number().min(-180).max(180).optional(),
    maxOccupancy: z.number().min(1),
    password: z.string().optional(),    
    pathImage: z.array(z.string()).optional(),
    requirements: z.array(z.string()).optional(),
    status: z.string().optional(),
    type: z.string().optional(),
    userId: z.string(),
});
export const POST = async (request: Request) => {
    try{
        const body = await request.json();
        const parsedData = CreateApartmentSchema.parse(body);

        //call service to create apartment
        const result = await ApartmentService.createApartment(parsedData);

        return new Response(JSON.stringify({
            status: "success",
            message: "Apartment created successfully",
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