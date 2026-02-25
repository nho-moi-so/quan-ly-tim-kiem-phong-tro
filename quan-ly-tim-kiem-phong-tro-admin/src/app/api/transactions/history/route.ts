import { TransactionService } from "@/services/transactionService";

export const GET = async () => {
    try {
        const result = await TransactionService.getTransactionHistory();

        return new Response(JSON.stringify({
            status: "success",
            message: "Transaction history retrieved successfully",
            data: result,
        }), { status: 200 });
    } catch (err: unknown) {
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error",
        }), { status: 400 });
    }
};