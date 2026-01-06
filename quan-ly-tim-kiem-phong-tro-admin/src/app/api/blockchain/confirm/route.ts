import { bookingChainService } from "@/services/bookingChainService";
import { NextResponse } from "next/server";
import { z } from "zod";

const ConfirmInputSchema = z.object({
	contract_hash: z.string(),
	// Require full date-time strings (e.g., ISO 8601)
	checkin: z.string().datetime({ offset: true }).or(z.string().datetime()),
	checkout: z.string().datetime({ offset: true }).or(z.string().datetime())
});

export async function POST(request: Request) {
	try {
		const json = await request.json();
		const { contract_hash, checkin, checkout } = ConfirmInputSchema.parse(json);

		const checkinDate = new Date(checkin);
		const checkoutDate = new Date(checkout);
		if (Number.isNaN(checkinDate.getTime()) || Number.isNaN(checkoutDate.getTime())) {
			return NextResponse.json({
				status: "fail",
				message: "Invalid date format for checkin/checkout"
			}, { status: 400 });
		}

		const result = await bookingChainService.confirmBookingOnChain({
			contractHash: contract_hash,
			checkin: checkinDate,
			checkout: checkoutDate
		});

		// Normalize BigInt fields so NextResponse can serialize
		const normalizedResult = JSON.parse(JSON.stringify(result, (_, value) =>
			typeof value === "bigint" ? value.toString() : value
		));

		return NextResponse.json({
			status: "success",
			message: "Booking contract confirmed",
			data: {
				contract_hash,
                checkin,
                checkout,
				result: normalizedResult
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
