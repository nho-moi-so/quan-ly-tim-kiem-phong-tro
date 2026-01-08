import { db } from "@/lib/firebase/admin";

export interface IoTDevice {
	Id: string;
	Name: string;
	Description?: string;
}

export type CreateIoTDeviceData = Omit<IoTDevice, "Id">;
export type UpdateIoTDeviceData = Partial<Omit<IoTDevice, "Id">>;

const COLLECTION_NAME = "iot_devices";

export class IoTDeviceRepository {
	/**
	 * Get all IoT devices
	 */
	static async getAll(): Promise<IoTDevice[]> {
		try {
			const snapshot = await db.collection(COLLECTION_NAME).get();
			const devices: IoTDevice[] = [];

			snapshot.forEach((doc) => {
				devices.push({
					Id: doc.id,
					...doc.data(),
				} as IoTDevice);
			});

			return devices;
		} catch (error) {
			console.error("Error getting all IoT devices:", error);
			throw error;
		}
	}

	/**
	 * Get a device by ID
	 */
	static async getById(deviceId: string): Promise<IoTDevice | null> {
		try {
			const doc = await db.collection(COLLECTION_NAME).doc(deviceId).get();
			if (!doc.exists) return null;

			return {
				Id: doc.id,
				...doc.data(),
			} as IoTDevice;
		} catch (error) {
			console.error("Error getting IoT device by ID:", error);
			throw error;
		}
	}

	/**
	 * Create a new device
	 */
	static async create(deviceData: CreateIoTDeviceData): Promise<IoTDevice> {
		try {
			const docRef = await db.collection(COLLECTION_NAME).add(deviceData);
			const doc = await docRef.get();

			return {
				Id: doc.id,
				...doc.data(),
			} as IoTDevice;
		} catch (error) {
			console.error("Error creating IoT device:", error);
			throw error;
		}
	}

	/**
	 * Create a new device with a specific ID
	 */
	static async createWithId(deviceId: string, deviceData: CreateIoTDeviceData): Promise<IoTDevice> {
		try {
			const docRef = db.collection(COLLECTION_NAME).doc(deviceId);
			const existing = await docRef.get();
			if (existing.exists) {
				throw new Error("Device ID already exists");
			}

			await docRef.set(deviceData);
			const doc = await docRef.get();
			return {
				Id: doc.id,
				...doc.data(),
			} as IoTDevice;
		} catch (error) {
			console.error("Error creating IoT device with specific ID:", error);
			throw error;
		}
	}

	/**
	 * Update a device by ID
	 */
	static async update(deviceId: string, updateData: UpdateIoTDeviceData): Promise<IoTDevice> {
		try {
			const docRef = db.collection(COLLECTION_NAME).doc(deviceId);
			await docRef.update(updateData);

			const doc = await docRef.get();
			return {
				Id: doc.id,
				...doc.data(),
			} as IoTDevice;
		} catch (error) {
			console.error("Error updating IoT device:", error);
			throw error;
		}
	}

	/**
	 * Delete a device by ID
	 */
	static async delete(deviceId: string): Promise<boolean> {
		try {
			await db.collection(COLLECTION_NAME).doc(deviceId).delete();
			return true;
		} catch (error) {
			console.error("Error deleting IoT device:", error);
			throw error;
		}
	}
}
