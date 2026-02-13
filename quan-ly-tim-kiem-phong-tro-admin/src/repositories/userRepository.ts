import { db } from "@/lib/firebase/admin";

/**
 * User model interface
 */
export interface User {
    Id: string;
    ApprovalStatus?: string;
    Cccd?: string;
    Email?: string;
    Fullname?: string;
    GuestStatus?: string;
    OwnerStatus?: string;
    Phone?: string;
    Role?: string;
    ViewStatistics?: string;
    Status?: string;
    Balance?: number;
    Password?: string;
}

/**
 * User data for creation (without Id)
 */
export type CreateUserData = Omit<User, "Id">;

/**
 * User data for updates (partial)
 */
export type UpdateUserData = Partial<Omit<User, "Id">>;

const COLLECTION_NAME = "users";

/**
 * UserRepository - CRUD operations for User collection
 */
export class UserRepository {
    /**
     * Get all users
     * @returns Promise<User[]> - Array of all users
     */
    static async getAll(): Promise<User[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const users: User[] = [];

            snapshot.forEach((doc) => {
                users.push({
                    Id: doc.id,
                    ...doc.data(),
                } as User);
            });

            return users;
        } catch (error) {
            console.error("Error getting all users:", error);
            throw error;
        }
    }

    /**
     * Get user by ID
     * @param userId - User document ID
     * @returns Promise<User | null> - User data or null if not found
     */
    static async getById(userId: string): Promise<User | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(userId).get();

            if (!doc.exists) {
                return null;
            }

            return {
                Id: doc.id,
                ...doc.data(),
            } as User;
        } catch (error) {
            console.error("Error getting user by ID:", error);
            throw error;
        }
    }

    /**
     * Create a new user
     * @param userData - User data (without Id)
     * @returns Promise<User> - Created user with ID
     */
    static async create(userData: CreateUserData): Promise<User> {
        try {
            const docRef = await db.collection(COLLECTION_NAME).add(userData);
            const doc = await docRef.get();

            return {
                Id: docRef.id,
                ...doc.data(),
            } as User;
        } catch (error) {
            console.error("Error creating user:", error);
            throw error;
        }
    }

    /**
     * Update user by ID
     * @param userId - User document ID
     * @param updateData - Data to update
     * @returns Promise<User> - Updated user data
     */
    static async update(userId: string, updateData: UpdateUserData): Promise<User> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(userId);
            await docRef.update(updateData);

            const doc = await docRef.get();
            return {
                Id: doc.id,
                ...doc.data(),
            } as User;
        } catch (error) {
            console.error("Error updating user:", error);
            throw error;
        }
    }

    /**
     * Delete user by ID
     * @param userId - User document ID
     * @returns Promise<boolean> - True if deleted successfully
     */
    static async delete(userId: string): Promise<boolean> {
        try {
            await db.collection(COLLECTION_NAME).doc(userId).delete();
            return true;
        } catch (error) {
            console.error("Error deleting user:", error);
            throw error;
        }
    }
}