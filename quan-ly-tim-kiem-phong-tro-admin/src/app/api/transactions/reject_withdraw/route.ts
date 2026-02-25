import { TransactionService } from "@/services/transactionService";
import z from "zod";

const RejectWithdrawSchema = z.object({
    transactionId: z.string(),
});

export const POST = async (request: Request) => {
    try {
        const body = await request.json();
        const parsedData = RejectWithdrawSchema.parse(body);

        const result = await TransactionService.rejectWithdraw(parsedData);

        return new Response(JSON.stringify({
            status: "success",
            message: "Withdraw transaction rejected successfully",
            data: result
        }), { status: 200 });
    } catch (err: unknown) {
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }), { status: 400 });
    }
};