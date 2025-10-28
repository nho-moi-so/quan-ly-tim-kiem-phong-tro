import { db } from "@/lib/firebase/admin";
import admin from 'firebase-admin';

export interface Apartment{
    Id: string;
    Address: string;
    CodeApartment: string;
    DailyRate: number;
    Decription: string;
    Deposit: number;
    MaxOccupancy: number;
    Password: string;
    PathImage: string;
    Requirements: string;
    Status: string;
    Type: string;
    UserID: string;
}

export type CreateApartmentData = Omit<Apartment, "Id">;
export type UpdateApartmentData = Partial<Omit<Apartment, "Id">>;

const COLLECTION_NAME = "apartment";

export class ApartmentRepository {
    static async getAll(): Promise<Apartment[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const items: Apartment[] = [];
            snapshot.forEach((doc) => {
                items.push({ Id: doc.id, ...doc.data() } as Apartment);
            });
            return items;
        } catch (error) {
            console.error("Error getting all apartments:", error);
            throw error;
        }
    }

    static async getById(id: string): Promise<Apartment | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(id).get();
            if (!doc.exists) return null;
            return { Id: doc.id, ...doc.data() } as Apartment;
        } catch (error) {
            console.error("Error getting apartment by ID:", error);
            throw error;
        }
    }

    static async create(data: CreateApartmentData): Promise<Apartment> {
        try {
            const payload = { ...data, createdAt: admin.firestore.Timestamp.now() };
            const docRef = await db.collection(COLLECTION_NAME).add(payload as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as Apartment;
        } catch (error) {
            console.error("Error creating apartment:", error);
            throw error;
        }
    }

    static async update(id: string, updateData: UpdateApartmentData): Promise<Apartment> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(id);
            await docRef.update(updateData as any);
            const doc = await docRef.get();
            return { Id: doc.id, ...doc.data() } as Apartment;
        } catch (error) {
            console.error("Error updating apartment:", error);
            throw error;
        }
    }

    static async delete(id: string): Promise<boolean> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).delete();
            return true;
        } catch (error) {
            console.error("Error deleting apartment:", error);
            throw error;
        }
    }
    // tim apartment theo roomCode
    static async getByRoomCode(roomCode: string): Promise<Apartment | null> {
        try {
            const querySnapshot = await db.collection(COLLECTION_NAME)
                .where("CodeApartment", "==", roomCode)
                .limit(1)
                .get();
            if (querySnapshot.empty) {
                return null;
            }
            const doc = querySnapshot.docs[0];
            return { Id: doc.id, ...doc.data() } as Apartment;
        } catch (error) {
            console.error("Error getting apartment by room code:", error);
            throw error;
        }
    }
}