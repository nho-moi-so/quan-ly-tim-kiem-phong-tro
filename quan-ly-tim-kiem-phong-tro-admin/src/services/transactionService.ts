import { createFabricClient } from "@/lib/fabric/fabricClient";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { TransactionRepository } from "@/repositories/transactionRepository";
import { UserRepository } from "@/repositories/userRepository";
import { WalletBlockchainRepository } from "@/repositories/walletBlockchainRepository";
import { Wallets, X509Identity } from "fabric-network";

const {contract, close} = await createFabricClient();
const repoBlockchainFabric = new BlockchainFabricRepository(contract);

export const TransactionService = {
    createDeposit: async (data: {
        amount: number;
        paymentMethod?: string; // Ví dụ: "MOMO", "ZALO_PAY", "BANK_TRANSFER"
        gatewayTransactionId?: string;
        userId: string;
    }) => {
        try {
            const masterAdmin = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin') as X509Identity;
             if (!masterAdmin) {
                throw new Error("Master admin identity not found in Firebase");
            }
            //TẠO VÍ TRONG BỘ NHỚ (In-Memory Wallet) để lấy context
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('admin', masterAdmin);

            //Lấy provider và adminUser context
            const provider = memoryWallet.getProviderRegistry().getProvider(masterAdmin.type);
            const adminUser = await provider.getUserContext(masterAdmin, 'admin');

            // Tạo giao dịch nạp tiền trên blockchain
            await repoBlockchainFabric.depositWithMasterAdmin(
                masterAdmin,
                data.userId, 
                data.amount
            );
        } catch (err) {
            console.error("Error during blockchain deposit transaction:", err);
            console.error("Error details:", {
                userId: data.userId,
                amount: data.amount,
                paymentMethod: data.paymentMethod,
                gatewayTransactionId: data.gatewayTransactionId,
            });
            throw new Error("Failed to create deposit transaction on blockchain");
        } finally {
            await close();
        }

        // luu giao dich vao firebase sau khi giao dich tren blockchain thanh cong
        const transactionData = {
            Amount: data.amount,
            PaymentMethod: data.paymentMethod ?? "BANK_TRANSFER",
            PaymentDate: new Date(),
            Type: "DEPOSIT",
            Status: "COMPLETED",
            UserID: data.userId,
            ...(data.gatewayTransactionId ? { GatewayTransactionId: data.gatewayTransactionId } : {}),
        };

        const result = await TransactionRepository.create(transactionData);
        //cong balance cho user
        try {
            await UserRepository.updateBalance(data.userId, data.amount);
        } catch (err) {
            console.error("Error updating user balance after deposit:", err);
            // Optionally, you could implement a compensation mechanism here to revert the blockchain transaction if the database update fails
            throw new Error("Failed to update user balance in database after deposit");
        }
        if (!result) {
            console.error("Failed to create deposit transaction in database");
            throw new Error("Failed to create deposit transaction in database");
        }

        return {
            status: "success",
            message: "Deposit transaction created successfully",
            transactionId: result
        };
    },
    requestWithdraw: async (data: {
        amount: number;
        userId: string;
     }) => {
        const { contract: withdrawContract, close: closeWithdraw } = await createFabricClient();
        const withdrawRepo = new BlockchainFabricRepository(withdrawContract);

        // Tạo giao dịch rút tiền trên blockchain
        try{
            //lay identity tu firebase de tao tren blockchain
            const walletUser = await WalletBlockchainRepository.getIdentityFromFirebase(data.userId) as X509Identity;
            await withdrawRepo.requestWithdrawWithUser(
                walletUser,
                data.userId, 
                data.amount);
        }
        catch(err){
            console.error("Error during blockchain withdraw transaction:", err);
            throw new Error("Failed to create withdraw transaction on blockchain"); 
        }
        finally{
            await closeWithdraw();
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
            const masterAdmin = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin') as X509Identity;
            if (!masterAdmin) {
                throw new Error("Master admin identity not found in Firebase");
            }
             //TẠO VÍ TRONG BỘ NHỚ (In-Memory Wallet) để lấy context
             const memoryWallet = await Wallets.newInMemoryWallet();
             await memoryWallet.put('admin', masterAdmin);
 
             //Lấy provider và adminUser context
             const provider = memoryWallet.getProviderRegistry().getProvider(masterAdmin.type);
             const adminUser = await provider.getUserContext(masterAdmin, 'admin');
            await repoBlockchainFabric.finishWithdrawWithMasterAdmin(
                masterAdmin,
                transaction.UserID, 
                transaction.Amount);
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
        // tru balance cho user
        try {
            await UserRepository.updateBalance(transaction.UserID, -transaction.Amount);
        } catch (err) {
            console.error("Error updating user balance after approving withdraw:", err);
            // Optionally, you could implement a compensation mechanism here to revert the blockchain transaction if the database update fails
            throw new Error("Failed to update user balance in database after approving withdraw");
        }
        return {
            status: "success",
            message: "Withdraw transaction approved successfully"
        };
    },
    rejectWithdraw: async (data: {
        transactionId: string;
    }) => {
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

        await TransactionRepository.delete(data.transactionId);

        return {
            status: "success",
            message: "Withdraw transaction rejected and deleted successfully"
        };
    },
    getAllTransactionRequestWithdraws: async () => {
        try {
            const [transactions, users] = await Promise.all([
                TransactionRepository.getByType("WITHDRAW"),
                UserRepository.getAll(),
            ]);

            const userNameById = new Map(users.map((user) => [user.Id, user.Fullname ?? "N/A"]));

            const normalized = transactions
                .map((transaction) => {
                    const rawBankSummary = (transaction as any).bank_summary ?? transaction.BankSummary;
                    const rawCompletedAt = (transaction as any).completed_at ?? transaction.CompletedAt;
                    const rawTxHash = (transaction as any).tx_hash ?? transaction.TxHash;

                    return {
                        id: transaction.Id,
                        user_name: userNameById.get(transaction.UserID) ?? transaction.UserID,
                        amount: transaction.Amount,
                        bank_summary: rawBankSummary ?? `${transaction.PaymentMethod ?? "BANK_TRANSFER"} - --`,
                        completed_at: rawCompletedAt ?? null,
                        status: transaction.Status,
                        tx_hash: rawTxHash ?? null,
                    };
                })
                .sort((a, b) => {
                    const aTime = a.completed_at ? new Date(a.completed_at).getTime() : 0;
                    const bTime = b.completed_at ? new Date(b.completed_at).getTime() : 0;
                    return bTime - aTime;
                });

            return normalized;
        }
        catch(err){
            throw new Error("Failed to retrieve withdraw transactions from database");
        }
    },
    getTransactionHistory: async () => {
        try {
            const [transactions, users] = await Promise.all([
                TransactionRepository.getAll(),
                UserRepository.getAll(),
            ]);

            const userInfoById = new Map(users.map((user) => [
                user.Id,
                {
                    full_name: user.Fullname ?? "N/A",
                    phone: user.Phone ?? "—",
                },
            ]));

            const normalized = transactions
                .filter((transaction) => ["DEPOSIT", "WITHDRAW"].includes((transaction.Type ?? "").toUpperCase()))
                .map((transaction) => {
                    const type = (transaction.Type ?? "").toUpperCase();
                    const status = (transaction.Status ?? "").toUpperCase();
                    const rawTxHash = (transaction as any).tx_hash ?? transaction.TxHash ?? null;
                    const rawMethod = (transaction as any).payment_method ?? transaction.PaymentMethod ?? "BANK_TRANSFER";
                    const rawGatewayRef = (transaction as any).gateway_ref ?? transaction.GatewayTransactionId ?? null;
                    const rawBankName = (transaction as any).bank_name ?? null;
                    const rawAccountNumber = (transaction as any).account_number ?? null;
                    const rawAccountHolder = (transaction as any).account_holder ?? null;
                    const paymentDate = transaction.PaymentDate ? new Date(transaction.PaymentDate) : null;

                    return {
                        id: transaction.Id,
                        trans_code: `TX_${transaction.Id.slice(0, 6).toUpperCase()}`,
                        type,
                        amount: Number(transaction.Amount) || 0,
                        status,
                        user: userInfoById.get(transaction.UserID) ?? {
                            full_name: transaction.UserID,
                            phone: "—",
                        },
                        payment_detail: {
                            method: rawMethod,
                            bank_name: rawBankName,
                            account_number: rawAccountNumber,
                            account_holder: rawAccountHolder,
                            gateway_ref: rawGatewayRef,
                        },
                        tx_hash: rawTxHash,
                        created_at: paymentDate ? paymentDate.toISOString() : null,
                    };
                })
                .sort((a, b) => {
                    const aTime = a.created_at ? new Date(a.created_at).getTime() : 0;
                    const bTime = b.created_at ? new Date(b.created_at).getTime() : 0;
                    return bTime - aTime;
                });

            return normalized;
        } catch (err) {
            throw new Error("Failed to retrieve transaction history");
        }
    }
}