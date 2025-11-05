import { db } from "@/lib/firebase/admin";
import admin from 'firebase-admin';

export interface Post{
    Id: string;
    ApartmentID?: string;
    CreationDate?: FirebaseFirestore.Timestamp | Date;
    Description?: string;
    Header?: string;
    Status?: string;
}

export type CreatePostData = Omit<Post, "Id" | "CreationDate">;
export type UpdatePostData = Partial<Omit<Post, "Id" | "CreationDate">>;

const COLLECTION_NAME = "posts";

export class PostRepository {
    /**
     * Get all posts
     */
    static async getAll(): Promise<Post[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const posts: Post[] = [];

            snapshot.forEach((doc) => {
                posts.push({
                    Id: doc.id,
                    ...doc.data(),
                } as Post);
            });

            return posts;
        } catch (error) {
            console.error("Error getting all posts:", error);
            throw error;
        }
    }

    /**
     * Get post by ID
     */
    static async getById(postId: string): Promise<Post | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(postId).get();
            if (!doc.exists) return null;
            return {
                Id: doc.id,
                ...doc.data(),
            } as Post;
        } catch (error) {
            console.error("Error getting post by ID:", error);
            throw error;
        }
    }

    /**
     * Create a new post
     */
    static async create(postData: CreatePostData): Promise<Post> {
        try {
            const payload = {
                ...postData,
                CreationDate: admin.firestore.Timestamp.now(),
            };
            const docRef = await db.collection(COLLECTION_NAME).add(payload);
            const doc = await docRef.get();
            return {
                Id: doc.id,
                ...doc.data(),
            } as Post;
        } catch (error) {
            console.error("Error creating post:", error);
            throw error;
        }
    }

    /**
     * Update post by ID
     */
    static async update(postId: string, updateData: UpdatePostData): Promise<Post> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(postId);
            await docRef.update(updateData);
            const doc = await docRef.get();
            return {
                Id: doc.id,
                ...doc.data(),
            } as Post;
        } catch (error) {
            console.error("Error updating post:", error);
            throw error;
        }
    }

    /**
     * Delete post by ID
     */
    static async delete(postId: string): Promise<boolean> {
        try {
            await db.collection(COLLECTION_NAME).doc(postId).delete();
            return true;
        } catch (error) {
            console.error("Error deleting post:", error);
            throw error;
        }
    }
}


