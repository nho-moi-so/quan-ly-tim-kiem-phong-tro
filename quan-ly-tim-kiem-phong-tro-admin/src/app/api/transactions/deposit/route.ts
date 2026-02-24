import { TransactionService } from "@/services/transactionService";
import z from "zod";

const DepositSchema = z.object({
    amount: z.number().min(0.01, "Amount must be greater than 0"),
    paymentMethod: z.string().optional(), // Ví dụ: "MOMO", "ZALO_PAY", "BANK_TRANSFER"
    gatewayTransactionId: z.string().optional(),
    userId: z.string()
});
export const POST = async (request: Request) => {
    try {
        const body = await request.json();
        const parsedData = DepositSchema.parse(body);

        // Call service to create deposit transaction
        const result = await TransactionService.createDeposit(parsedData);

        return new Response(JSON.stringify({
            status: "success",
            message: "Deposit transaction created successfully",
            data: result
        }), { status: 201 });
    } catch (err: unknown) {
        return new Response(JSON.stringify({
            status: "fail",
            message: err instanceof Error ? err.message : "Unknown error"
        }), { status: 400 });
    }
}