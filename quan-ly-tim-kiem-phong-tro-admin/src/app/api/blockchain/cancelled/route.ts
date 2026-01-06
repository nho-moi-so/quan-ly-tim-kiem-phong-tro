import { bookingChainService } from "@/services/bookingChainService";
import { NextResponse } from "next/server";
import { z } from "zod";

const CancelInputSchema = z.object({
	contract_hash: z.string()
});

export async function POST(request: Request) {
	try {
		const json = await request.json();
		const { contract_hash } = CancelInputSchema.parse(json);

		const result = await bookingChainService.cancelBookingOnChain(contract_hash);
		const normalizedResult = JSON.parse(JSON.stringify(result, (_, value) =>
			typeof value === "bigint" ? value.toString() : value
		));

		return NextResponse.json({
			status: "success",
			message: "Booking contract cancelled successfully",
			data: {
				contract_hash,
				transaction_hash: normalizedResult.hash,
				block_number: normalizedResult.receipt.blockNumber,
				contract_info: normalizedResult.contractInfo
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

		const errorMessage = err instanceof Error ? err.message : "Unknown error";
		
		// Trả về status code khác nhau dựa trên loại lỗi
		const statusCode = errorMessage.includes("does not exist") || 
		                   errorMessage.includes("invalid") 
		                   ? 404 
		                   : errorMessage.includes("already in")
		                   ? 409 // Conflict - already cancelled
		                   : 400;

		return NextResponse.json({
			status: "fail",
			message: errorMessage
		}, { status: statusCode });
	}
}
