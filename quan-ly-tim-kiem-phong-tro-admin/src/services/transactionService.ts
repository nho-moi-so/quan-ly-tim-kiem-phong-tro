import { createFabricClient } from "@/lib/fabric/fabricClient";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { TransactionRepository } from "@/repositories/transactionRepository";

const {contract, close} = await createFabricClient();
const repoBlockchainFabric = new BlockchainFabricRepository(contract);

export const TransactionService = {
    createDeposit: async (data: {
        amount: number;
        paymentMethod?: string; // Ví dụ: "MOMO", "ZALO_PAY", "BANK_TRANSFER"
        gatewayTransactionId?: string;
        userId: string;
    }) => {
        // Tạo giao dịch nạp tiền trên blockchain
        try{
            await repoBlockchainFabric.deposit(data.userId, data.amount);
        }
        catch(err){
            console.error("Error during blockchain deposit transaction:", err);
            throw new Error("Failed to create deposit transaction on blockchain");
        }
        finally{
            await close();
        }
        // luu giao dich vao firebase sau khi giao dich tren blockchain thanh cong
        const transactionData = {
            Amount: data.amount,
            PaymentMethod: data.paymentMethod,
            GatewayTransactionId: data.gatewayTransactionId,
            PaymentDate: new Date(),
            Type: "DEPOSIT",
            Status: "COMPLETED",
            UserID: data.userId,
        }
        const result = await TransactionRepository.create(transactionData);
        if (!result) {
            console.error("Failed to create deposit transaction in database");
            throw new Error("Failed to create deposit transaction in database");
        }
        return {
            status: "success",
            message: "Deposit transaction created successfully",
            transactionId: result
        }
    },
    requestWithdraw: async (data: {
        amount: number;
        userId: string;
     }) => {
        // Tạo giao dịch rút tiền trên blockchain
        try{
            await repoBlockchainFabric.requestWithdraw(data.userId, data.amount);
        }
        catch(err){
            console.error("Error during blockchain withdraw transaction:", err);
            throw new Error("Failed to create withdraw transaction on blockchain");
            
            
        }
        finally{
            await close();
        }
        // luu giao dich vao firebase sau khi giao dich tren blockchain thanh cong
        const transactionData = {
            Amount: data.amount,
            PaymentDate: new Date(),
            Type: "WITHDRAW",
            Status: "PENDING", // Ban đầu là PENDING, sẽ được cập nhật sau khi hoàn thành
            UserID: data.userId,
        }
        const result = await TransactionRepository.create(transactionData);
        if (!result) {
            console.error("Failed to create withdraw transaction in database");
            throw new Error("Failed to create withdraw transaction in database");
        }
        return {
            status: "success",
            message: "Withdraw transaction created successfully",
            transactionId: result
        };
    },
    approveWithdraw: async (data: {
        transactionId: string;
     }) => {
        // Hoàn thành giao dịch rút tiền trên blockchain
        const transaction = await TransactionRepository.getById(data.transactionId);
        if (!transaction) {
            throw new Error("Withdraw transaction not found");
        }
        if (transaction.Type !== "WITHDRAW") {
            throw new Error("Transaction is not a withdraw type");
        }
        if (transaction.Status !== "PENDING") {
            throw new Error("Withdraw transaction is not in pending status");
        }
        try{
            await repoBlockchainFabric.finishWithdraw(transaction.UserID, transaction.Amount);
        }
        catch(err){
            console.error("Error during blockchain approve withdraw transaction:", err);
            throw new Error("Failed to approve withdraw transaction on blockchain");
        }
        finally{
            await close();
        }
        // Cập nhật trạng thái giao dịch rút tiền trong database thành COMPLETED
        try {
            await TransactionRepository.updateWithdrawTransactionStatus(data.transactionId, "COMPLETED");
        }
        catch(err){
            throw new Error("Failed to update withdraw transaction status in database");
        }
        return {
            status: "success",
            message: "Withdraw transaction approved successfully"
        };
    },
    getAllTransactionRequestWithdraws: async () => {
        try {
            const transactions = await TransactionRepository.getByStatusAndType("PENDING", "WITHDRAW");
            return transactions;
        }
        catch(err){
            throw new Error("Failed to retrieve withdraw transactions from database");
        }
    }
}