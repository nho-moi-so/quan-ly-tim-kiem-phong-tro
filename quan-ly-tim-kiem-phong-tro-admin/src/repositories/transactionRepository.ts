import { db } from "@/lib/firebase/admin";


export interface Transaction {
    Id: string;
    Amount: number;
    PaymentMethod?: string; // Ví dụ: "MOMO", "ZALO_PAY", "BANK_TRANSFER"
    GatewayTransactionId?: string;
    PaymentDate: Date;
    Type: string; //DEPOSIT (Nạp), WITHDRAW (Rút), PAYMENT (Trả Invoice)
    Status: string; //PENDING, COMPLETED, FAILED
    UserID: string;
    InvoiceID?: string; // Chỉ có khi Type là PAYMENT
}
export type CreateTransactionData = Omit<Transaction, "Id">;
export type UpdateTransactionData = Partial<Omit<Transaction, "Id">>;

const COLLECTION_NAME = "transaction";

export class TransactionRepository {
    static async getAll(): Promise<Transaction[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const items: Transaction[] = [];
            snapshot.forEach((doc) => {
                const data = doc.data();
                items.push({
                    Id: doc.id,
                    ...data,
                    PaymentDate: data.PaymentDate.toDate(),
                } as Transaction);
            });
            return items;
        } catch (error) {
            console.error("Error fetching transactions:", error);
            throw error;
        }
    }
    
    static async getById(id: string): Promise<Transaction | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(id).get();
            if (!doc.exists) {
                return null;
            }
            const data = doc.data()!;
            return {
                Id: doc.id,
                ...data,
                PaymentDate: data.PaymentDate.toDate(),
            } as Transaction;
        } catch (error) {
            console.error("Error fetching transaction by ID:", error);
            throw error;
        }
    }

    static async getByStatusAndType(status: string, type: string): Promise<Transaction[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME)
                .where("Status", "==", status)
                .where("Type", "==", type)
                .get();
            const items: Transaction[] = [];
            snapshot.forEach((doc) => {
                const data = doc.data();
                items.push({
                    Id: doc.id,
                    ...data,
                    PaymentDate: data.PaymentDate.toDate(),
                } as Transaction);
            });
            return items;
        } catch (error) {
            console.error("Error fetching transactions by status and type:", error);
            throw error;
        }
    }

    static async create(data: CreateTransactionData): Promise<string> {
        try {
            const docRef = await db.collection(COLLECTION_NAME).add(data);
            return docRef.id;
        } catch (error) {
            console.error("Error creating transaction:", error);
            throw error;
        }
    }

    static async update(id: string, data: UpdateTransactionData): Promise<void> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).update(data);
        } catch (error) {
            console.error("Error updating transaction:", error);
            throw error;
        }
    }

    static async delete(id: string): Promise<void> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).delete();
        } catch (error) {
            console.error("Error deleting transaction:", error);
            throw error;
        }
    }
    static async getByUserId(userId: string): Promise<Transaction[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).where("UserID", "==", userId).get();
            const items: Transaction[] = [];
            snapshot.forEach((doc) => {
                const data = doc.data();
                items.push({
                    Id: doc.id,
                    ...data,
                    PaymentDate: data.PaymentDate.toDate(),
                } as Transaction);
            });
            return items;
        } catch (error) {
            console.error("Error fetching transactions by user ID:", error);
            throw error;
        }
    }
    static async updateWithdrawTransactionStatus(id: string, status: string): Promise<void> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).update({ Status: status });
        } catch (error) {
            console.error("Error updating withdraw transaction status:", error);
            throw error;
        }
    }
}
