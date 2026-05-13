import { db } from "@/lib/firebase/admin";
import admin from 'firebase-admin';

export interface Invoice {
    Id: string;
    CreatedDate?: admin.firestore.Timestamp;
    IssueDate?: admin.firestore.Timestamp;
    CancellationDate?: admin.firestore.Timestamp;
    Code?: string;
    Note?: string;
    Status?: string;
    TotalAmount?: number;
    VAT?: number;
    ContractId?: string;
    ApartmentId?: string;
    UserID?: string;
}

export type CreateInvoiceData = Omit<Invoice, "Id">;
export type UpdateInvoiceData = Partial<Omit<Invoice, "Id">>;

const COLLECTION_NAME = "invoice";

export class InvoiceRepository {
    static async getAll(): Promise<Invoice[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const items: Invoice[] = [];
            snapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Invoice);
            });
            return items;
        } catch (error) {
            console.error("Error getting all invoices:", error);
            throw error;
        }
    }

    static async getById(id: string): Promise<Invoice | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(id).get();
            if (!doc.exists) return null;
            return { Id: doc.id, ...doc.data() } as Invoice;
        } catch (error) {
            console.error("Error getting invoice by ID:", error);
            throw error;
        }
    }

    static async create(data: CreateInvoiceData): Promise<Invoice> {
        try {
            const docRef = await db.collection(COLLECTION_NAME).add(data as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as Invoice;
        } catch (error) {
            console.error("Error creating invoice:", error);
            throw error;
        }
    }

    static async update(id: string, updateData: UpdateInvoiceData): Promise<Invoice> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(id);
            await docRef.update(updateData as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as Invoice;
        } catch (error) {
            console.error("Error updating invoice:", error);
            throw error;
        }
    }

    static async delete(id: string): Promise<boolean> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).delete();
            return true;
        } catch (error) {
            console.error("Error deleting invoice:", error);
            throw error;
        }
    }

    static async getByContractId(contractId: string): Promise<Invoice[]> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("ContractId", "==", contractId)
                .get();
            const items: Invoice[] = [];
            querySnapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Invoice);
            });
            return items;
        } catch (error) {
            console.error("Error getting invoices by contract ID:", error);
            throw error;
        }
    }

    static async getByApartmentId(apartmentId: string): Promise<Invoice[]> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("ApartmentId", "==", apartmentId)
                .get();
            const items: Invoice[] = [];
            querySnapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Invoice);
            });
            return items;
        } catch (error) {
            console.error("Error getting invoices by apartment ID:", error);
            throw error;
        }
    }

    static async getByUserId(userId: string): Promise<Invoice[]> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("UserID", "==", userId)
                .get();
            const items: Invoice[] = [];
            querySnapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Invoice);
            });
            return items;
        } catch (error) {
            console.error("Error getting invoices by user ID:", error);
            throw error;
        }
    }

    static async getByStatus(status: string): Promise<Invoice[]> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("Status", "==", status)
                .get();
            const items: Invoice[] = [];
            querySnapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Invoice);
            });
            return items;
        } catch (error) {
            console.error("Error getting invoices by status:", error);
            throw error;
        }
    }
}
