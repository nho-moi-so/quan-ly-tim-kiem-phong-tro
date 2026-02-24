import { TransactionService } from "@/services/transactionService";
import z from "zod";

const ApproveWithdrawSchema = z.object({
    transactionId: z.string(),
});
export const POST = async (request: Request) => {
    try {
        const body = await request.json();
        const parsedData = ApproveWithdrawSchema.parse(body);

        // Call service to approve withdraw transaction
        const result = await TransactionService.approveWithdraw(parsedData);

        return new Response(JSON.stringify({
            status: "success",
            message: "Withdraw transaction approved successfully",
            data: result
        }), { status: 200 });
    } catch (err: unknown) {
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }), { status: 400 });
    }
}