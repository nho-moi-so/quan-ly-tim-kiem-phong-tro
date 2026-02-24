import { TransactionService } from "@/services/transactionService";
import z from "zod";

const RequestWithdrawSchema = z.object({
    amount: z.number().min(0.01, "Amount must be greater than 0"),
    userId: z.string()
});
export const GET = async (request: Request) => {
    try{
        const result = await TransactionService.getAllTransactionRequestWithdraws();
        return new Response(JSON.stringify({
            status: "success",
            message: "Transactions retrieved successfully",
            data: result
        }), { status: 200 });
    }
    catch(err){
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }), { status: 400 });
    }
}

export const POST = async (request: Request) => {
    try {
        const body = await request.json();
        const parsedData = RequestWithdrawSchema.parse(body);

        // Call service to create withdraw transaction
        const result = await TransactionService.requestWithdraw(parsedData);

        return new Response(JSON.stringify({
            status: "success",
            message: "Withdraw request created successfully",
            data: result
        }), { status: 201 });
    } catch (err: unknown) {
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }), { status: 400 });
    }
}
