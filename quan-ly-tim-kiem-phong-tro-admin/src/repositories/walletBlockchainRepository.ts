import { db } from "@/lib/firebase/admin";

export interface WalletBlockchain{
    Id: string;
    UserID: string;
    MSPID: string;
    Type: string;
    CredentialsCertificate: string;
    CredentialsPrivateKey: string;
}
export type CreateWalletBlockchainData = Omit<WalletBlockchain, "Id"> & { Id?: string };
export type UpdateWalletBlockchainData = Partial<Omit<WalletBlockchain, "Id">>;

const COLLECTION_NAME = "walletBlockchains";

const removeUndefined = <T extends Record<string, unknown>>(obj: T): Partial<T> => {
    return Object.fromEntries(
        Object.entries(obj).filter(([, value]) => value !== undefined)
    ) as Partial<T>;
};

export class WalletBlockchainRepository {
    static async getAll(): Promise<WalletBlockchain[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).get();
            const walletBlockchains: WalletBlockchain[] = [];

            snapshot.forEach((doc) => {
                walletBlockchains.push({
                    Id: doc.id,
                    ...doc.data(),
                } as WalletBlockchain);
            });

            return walletBlockchains;
        } catch (error) {
            throw new Error("Failed to fetch wallet blockchains: " + error);
        }
    }

    static async getById(id: string): Promise<WalletBlockchain | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(id).get();

            if (!doc.exists) {
                return null;
            }

            return {
                Id: doc.id,
                ...doc.data(),
            } as WalletBlockchain;
        } catch (error) {
            throw new Error("Failed to fetch wallet blockchain by ID: " + error);
        }
    }

    static async getByUserId(userId: string): Promise<WalletBlockchain[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).where("UserID", "==", userId).get();
            const walletBlockchains: WalletBlockchain[] = [];

            snapshot.forEach((doc) => {
                walletBlockchains.push({
                    Id: doc.id,
                    ...doc.data(),
                } as WalletBlockchain);
            });

            return walletBlockchains;
        } catch (error) {
            throw new Error("Failed to fetch wallet blockchains by user ID: " + error);
        }
    }
    static async getIdentityFromFirebase(userId: string): Promise<{ credentials: { certificate: string; privateKey: string }; mspId: string; type: string } | null> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME).where("UserID", "==", userId).get();

            if (snapshot.empty) {
                return null;
            }

            const doc = snapshot.docs[0];
            const data = doc.data();

            // Trả về đúng định dạng X.509 mà Fabric SDK yêu cầu
            return {
                credentials: {
                    certificate: data.CredentialsCertificate,
                    privateKey: data.CredentialsPrivateKey, // Nếu có mã hóa AES thì giải mã ở đây
                },
                mspId: data.MSPID || 'Org1MSP',
                type: 'X.509',
            };
        } catch (error) {
            throw new Error("Failed to fetch identity from Firebase: " + error);
        }
    }

    static async create(data: CreateWalletBlockchainData): Promise<WalletBlockchain> {
        try {
            const docRef = await db.collection(COLLECTION_NAME).add(data);
            return { Id: docRef.id, ...data } as WalletBlockchain;
        } catch (error) {
            throw new Error("Failed to create wallet blockchain: " + error);
        }
    }

    static async upsertById(id: string, data: UpdateWalletBlockchainData): Promise<WalletBlockchain> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(id);
            await docRef.set(removeUndefined(data), { merge: true });
            const updatedDoc = await docRef.get();

            if (!updatedDoc.exists) {
                throw new Error("Wallet blockchain not found after upsert");
            }

            return {
                Id: updatedDoc.id,
                ...updatedDoc.data(),
            } as WalletBlockchain;
        } catch (error) {
            throw new Error("Failed to upsert wallet blockchain: " + error);
        }
    }

    static async update(id: string, data: UpdateWalletBlockchainData): Promise<WalletBlockchain> {
        try {
            const docRef = db.collection(COLLECTION_NAME).doc(id);
            await docRef.update(removeUndefined(data));
            const updatedDoc = await docRef.get();

            if (!updatedDoc.exists) {
                throw new Error("Wallet blockchain not found after update");
            }

            return {
                Id: updatedDoc.id,
                ...updatedDoc.data(),
            } as WalletBlockchain;
        } catch (error) {
            throw new Error("Failed to update wallet blockchain: " + error);
        }
    }

    static async delete(id: string): Promise<void> {
        try {
            await db.collection(COLLECTION_NAME).doc(id).delete();
        } catch (error) {
            throw new Error("Failed to delete wallet blockchain: " + error);
        }
    }
}