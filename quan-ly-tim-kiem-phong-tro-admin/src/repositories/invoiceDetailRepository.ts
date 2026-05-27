import { db } from "@/lib/firebase/admin";
import admin from 'firebase-admin';

export interface InvoiceDetail {
    Id: string;
    Description: string; // phí thuê phòng, phí dọn dẹp, chăm sóc thú cưng, phí dịch vụ khác
    Quantity: number;
    UnitPrice: number; // giá mỗi đơn vị
    SubTotal: number; // quantity * unitPrice
    InvoiceId: string;
    CreatedDate?: admin.firestore.Timestamp;
    UpdatedDate?: admin.firestore.Timestamp;
}

export type CreateInvoiceDetailData = Omit<InvoiceDetail, "Id" | "CreatedDate" | "UpdatedDate">;
export type UpdateInvoiceDetailData = Partial<Omit<InvoiceDetail, "Id">>;

const COLLECTION_NAME = "invoiceDetail";

export class InvoiceDetailRepository {
    static async getAll(): Promise<InvoiceDetail[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const items: InvoiceDetail[] = [];
            snapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as InvoiceDetail);
            });
            return items;
        } catch (error) {
            console.error("Error getting all invoice details:", error);
            throw error;
        }
    }

    static async getById(id: string): Promise<InvoiceDetail | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(id).get();
            if (!doc.exists) return null;
            return { Id: doc.id, ...doc.data() } as InvoiceDetail;
        } catch (error) {
            console.error("Error getting invoice detail by ID:", error);
            throw error;
        }
    }

    static async create(data: CreateInvoiceDetailData): Promise<InvoiceDetail> {
        try {
            const docRef = await db.collection(COLLECTION_NAME).add({
                ...data,
                CreatedDate: admin.firestore.FieldValue.serverTimestamp(),
                UpdatedDate: admin.firestore.FieldValue.serverTimestamp(),
            } as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as InvoiceDetail;
        } catch (error) {
            console.error("Error creating invoice detail:", error);
            throw error;
        }
    }

    static async update(id: string, updateData: UpdateInvoiceDetailData): Promise<InvoiceDetail> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(id);
            await docRef.update({
                ...updateData,
                UpdatedDate: admin.firestore.FieldValue.serverTimestamp(),
            } as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as InvoiceDetail;
        } catch (error) {
            console.error("Error updating invoice detail:", error);
            throw error;
        }
    }

    static async delete(id: string): Promise<boolean> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).delete();
            return true;
        } catch (error) {
            console.error("Error deleting invoice detail:", error);
            throw error;
        }
    }

    static async getByInvoiceId(invoiceId: string): Promise<InvoiceDetail[]> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("InvoiceId", "==", invoiceId)
                .get();
            const items: InvoiceDetail[] = [];
            querySnapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as InvoiceDetail);
            });
            return items;
        } catch (error) {
            console.error("Error getting invoice details by invoice ID:", error);
            throw error;
        }
    }

    static async deleteByInvoiceId(invoiceId: string): Promise<boolean> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("InvoiceId", "==", invoiceId)
                .get();
            
            const batch = db.batch();
            querySnapshot.forEach((doc) => {
                batch.delete(doc.ref);
            });
            
            await batch.commit();
            return true;
        } catch (error) {
            console.error("Error deleting invoice details by invoice ID:", error);
            throw error;
        }
    }
}
