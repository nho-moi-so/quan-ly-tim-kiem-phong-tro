import { db } from "@/lib/firebase/admin";
import admin from 'firebase-admin';

export interface Contract {
    Id: string;
    CreatedDate?: admin.firestore.Timestamp;
    StartDate?: admin.firestore.Timestamp;
    EndDate?: admin.firestore.Timestamp;
    UpdateDate?: admin.firestore.Timestamp;
    Clause?: string[];
    Status?: string;
    PathFile?: string;
    Total?: string;
    Password?: string;
    ApartmentId?: string;
    InvoiceId?: string;
    UserID?: string;
    EscrowAmount?: number;
}

export type CreateContractData = Omit<Contract, "Id">;
export type UpdateContractData = Partial<Omit<Contract, "Id">>;

const COLLECTION_NAME = "contract";

export class ContractRepository {
    static async getAll(): Promise<Contract[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const items: Contract[] = [];
            snapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Contract);
            });
            return items;
        } catch (error) {
            console.error("Error getting all contracts:", error);
            throw error;
        }
    }

    static async getById(id: string): Promise<Contract | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(id).get();
            if (!doc.exists) return null;
            return { Id: doc.id, ...doc.data() } as Contract;
        } catch (error) {
            console.error("Error getting contract by ID:", error);
            throw error;
        }
    }

    static async create(data: CreateContractData): Promise<Contract> {
        try {
            const docRef = await db.collection(COLLECTION_NAME).add(data as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as Contract;
        } catch (error) {
            console.error("Error creating contract:", error);
            throw error;
        }
    }

    static async update(id: string, updateData: UpdateContractData): Promise<Contract> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(id);
            await docRef.update(updateData as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as Contract;
        } catch (error) {
            console.error("Error updating contract:", error);
            throw error;
        }
    }

    static async delete(id: string): Promise<boolean> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).delete();
            return true;
        } catch (error) {
            console.error("Error deleting contract:", error);
            throw error;
        }
    }

    static async getByGuestId(guestId: string): Promise<Contract[]> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("UserID", "==", guestId)
                .get();
            const items: Contract[] = [];
            querySnapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Contract);
            });
            return items;
        } catch (error) {
            console.error("Error getting contracts by guest ID:", error);
            throw error;
        }
    }

    static async getByApartmentId(apartmentId: string): Promise<Contract[]> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("ApartmentId", "==", apartmentId)
                .get();
            const items: Contract[] = [];
            querySnapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Contract);
            });
            return items;
        } catch (error) {
            console.error("Error getting contracts by apartment ID:", error);
            throw error;
        }
    }

    static async getByInvoiceId(invoiceId: string): Promise<Contract | null> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("InvoiceId", "==", invoiceId)
                .limit(1)
                .get();
            if (querySnapshot.empty) {
                return null;
            }
            const doc = querySnapshot.docs[0];
            return { Id: doc.id, ...doc.data() } as Contract;
        } catch (error) {
            console.error("Error getting contract by invoice ID:", error);
            throw error;
        }
    }
    
    static async getLatestContracts(limitNumber?: number): Promise<Contract[]> {
        try {
            // Lấy tất cả hoặc một lượng lớn để sort ở Javascript
            const query: FirebaseFirestore.Query = db.collection(COLLECTION_NAME);

            const snapshot = await query.get();
            const items: Contract[] = [];

            snapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Contract);
            });

            // Lọc và sắp xếp (Sort) đầu ra bằng Javascript
            items.sort((a, b) => {
                const getTime = (dateVal: any) => {
                    if (!dateVal) return 0;
                    // Nếu là Firebase Timestamp (có hàm toMillis)
                    if (typeof dateVal.toMillis === "function") {
                        return dateVal.toMillis();
                    }
                    // Nếu là dạng chuỗi ISO string hoặc định dạng khác
                    return new Date(dateVal).getTime();
                };

                const timeA = getTime(a.StartDate);
                const timeB = getTime(b.StartDate);
                
                return timeB - timeA; // Sắp xếp giảm dần (Mới nhất lên đầu)
            });

            // Cắt mảng (Limit) sau khi đã sort xong toàn bộ dữ liệu
            if (limitNumber !== undefined) {
                return items.slice(0, limitNumber);
            }

            return items;
        } catch (error) {
            console.error("Error getting latest contracts:", error);
            throw error;
        }
    }
}
