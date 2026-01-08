import { db } from "@/lib/firebase/admin";
import admin from "firebase-admin";

export interface IoTDeviceInDepartment {
	Id: string;
	IoTDeviceID: string;
	ApartmentID: string;
	DeviceID: string;
	Otp?: string;
	Status?: string;
	CreationDate?: FirebaseFirestore.Timestamp | Date;

	//phục vụ chức năng kiểm tra iot còn online hay không
	PingCode?: string;     // App ghi mã ngẫu nhiên vào đây
    PingReply?: string;    // IoT copy mã đó ghi lại vào đây
}

export type CreateIoTDeviceInDepartmentData = Omit<IoTDeviceInDepartment, "Id" | "CreationDate">;
export type UpdateIoTDeviceInDepartmentData = Partial<Omit<IoTDeviceInDepartment, "Id" | "CreationDate">>;

const COLLECTION_NAME = "iot_device_in_apartment";

export class IoTDeviceInDepartmentRepository {
	/**
	 * Get all IoT devices in apartments
	 */
	static async getAll(): Promise<IoTDeviceInDepartment[]> {
		try {
			const snapshot = await db.collection(COLLECTION_NAME).get();
			const items: IoTDeviceInDepartment[] = [];

			snapshot.forEach((doc) => {
				items.push({
					Id: doc.id,
					...doc.data(),
				} as IoTDeviceInDepartment);
			});

			return items;
		} catch (error) {
			console.error("Error getting all IoT devices in apartments:", error);
			throw error;
		}
	}

	/**
	 * Get by ID
	 */
	static async getById(id: string): Promise<IoTDeviceInDepartment | null> {
		try {
			const doc = await db.collection(COLLECTION_NAME).doc(id).get();
			if (!doc.exists) return null;

			return {
				Id: doc.id,
				...doc.data(),
			} as IoTDeviceInDepartment;
		} catch (error) {
			console.error("Error getting IoT device in apartment by ID:", error);
			throw error;
		}
	}

	/**
	 * Create new mapping/device
	 */
	static async create(data: CreateIoTDeviceInDepartmentData): Promise<IoTDeviceInDepartment> {
		try {
			const payload = {
				...data,
				CreationDate: admin.firestore.Timestamp.now(),
			};
			const docRef = await db.collection(COLLECTION_NAME).add(payload);
			const doc = await docRef.get();

			return {
				Id: doc.id,
				...doc.data(),
			} as IoTDeviceInDepartment;
		} catch (error) {
			console.error("Error creating IoT device in apartment:", error);
			throw error;
		}
	}

	/**
	 * Update by ID
	 */
	static async update(id: string, updateData: UpdateIoTDeviceInDepartmentData): Promise<IoTDeviceInDepartment> {
		try {
			const docRef = db.collection(COLLECTION_NAME).doc(id);
			await docRef.update(updateData);
			const doc = await docRef.get();

			return {
				Id: doc.id,
				...doc.data(),
			} as IoTDeviceInDepartment;
		} catch (error) {
			console.error("Error updating IoT device in apartment:", error);
			throw error;
		}
	}

	/**
	 * Delete by ID
	 */
	static async delete(id: string): Promise<boolean> {
		try {
			await db.collection(COLLECTION_NAME).doc(id).delete();
			return true;
		} catch (error) {
			console.error("Error deleting IoT device in apartment:", error);
			throw error;
		}
	}
}
