import { db } from "@/lib/firebase/admin";
import admin from 'firebase-admin';

export interface Apartment{
    Id: string;
    Address: string;
    CodeApartment: string;
    DailyRate: number;
    Decription: string;
    MaxOccupancy: number;
    Password: string;
    PathImage: string[];
    Requirements: string[];
    Status: string;
    Type: string;
    UserID: string;
    Latitude?: number;
    Longitude?: number;
}

export type CreateApartmentData = Omit<Apartment, "Id">;
export type UpdateApartmentData = Partial<Omit<Apartment, "Id">>;

const COLLECTION_NAME = "apartment";

const normalizePathImage = (value: unknown): string[] => {
    if (!value) {
        return [];
    }
    if (Array.isArray(value)) {
        return value.map((item) => String(item)).filter(Boolean);
    }
    if (typeof value === 'string') {
        try {
            const parsed = JSON.parse(value);
            if (Array.isArray(parsed)) {
                return parsed.map((item) => String(item)).filter(Boolean);
            }
        } catch {
            // Fall through to split below.
        }
        return value
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean);
    }
    return [];
};

export class ApartmentRepository {
    static async getAll(): Promise<Apartment[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const items: Apartment[] = [];
            snapshot.forEach((doc) => {
                const data = doc.data();
                items.push({
                    Id: doc.id,
                    ...data,
                    PathImage: normalizePathImage(data.PathImage),
                } as Apartment);
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
            const data = doc.data();
            return {
                Id: doc.id,
                ...data,
                PathImage: normalizePathImage(data?.PathImage),
            } as Apartment;
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
            const docData = doc.data();
            return {
                Id: doc.id,
                ...docData,
                PathImage: normalizePathImage(docData?.PathImage),
            } as Apartment;
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
            const data = doc.data();
            return {
                Id: doc.id,
                ...data,
                PathImage: normalizePathImage(data?.PathImage),
            } as Apartment;
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
            const data = doc.data();
            return {
                Id: doc.id,
                ...data,
                PathImage: normalizePathImage(data.PathImage),
            } as Apartment;
        } catch (error) {
            console.error("Error getting apartment by room code:", error);
            throw error;
        }
    }
}