import { db } from "@/lib/firebase/admin";
import { getIO } from "@/lib/socket";
import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { IoTDeviceInDepartmentRepository } from "@/repositories/iotDeviceInDepartmentRepository";
import { IoTDeviceRepository } from "@/repositories/iotDeviceRepository";
import { UserRepository } from "@/repositories/userRepository";
import admin from "firebase-admin";

type ServiceResult = {
    status: "success" | "fail" | "error";
    message: string;
    otp?: string;
    roomCode?: string;
    online?: boolean;
};

export const IOTService = {
    /**
     * List IoT devices connected to apartments with enriched info
     */
    listDevices: async () => {
        const devices = await IoTDeviceInDepartmentRepository.getAll();

        // Enrich with apartment and owner info
        const enriched = await Promise.all(
            devices.map(async (d) => {
                const apartment = await ApartmentRepository.getById(d.ApartmentID);
                const deviceType = await IoTDeviceRepository.getById(d.IoTDeviceID);
                let ownerName: string | undefined = undefined;
                if (apartment?.UserID) {
                    const owner = await UserRepository.getById(apartment.UserID);
                    ownerName = owner?.Fullname || owner?.Email || owner?.Phone;
                }
                return {
                    Id: d.Id,
                    DeviceID: d.DeviceID,
                    IoTDeviceID: d.IoTDeviceID,
                    DeviceType: deviceType?.Name,
                    ApartmentID: d.ApartmentID,
                    ApartmentCode: apartment?.CodeApartment,
                    OwnerName: ownerName,
                    Status: d.Status,
                    CreationDate: d.CreationDate,
                };
            })
        );

        return enriched;
    },
    /**
     * Generate OTP for a room, persist to Firestore, and emit to socket room
     */
    connectRoom: async (roomCode: string, type_iot: string, deviceId: string): Promise<ServiceResult> => {
        if (!roomCode) {
            return { status: "error", message: "Missing roomCode" };
        }
        // //kiểm tra coi device có kết nối với apartment khác hay không
        // const existingDevice = await db.collection("iot_device_in_apartment")
        //     .where("DeviceID", "==", deviceId)
        //     .get();

        // if (!existingDevice.empty) {
        //     return { status: "fail", message: "Device is already connected to another apartment" };
        // }

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        //tim apartment theo roomCode
        const apartment = await ApartmentRepository.getByRoomCode(roomCode);
        if (!apartment) {
            return {    status: "fail", message: "Invalid room code" };
        }
        
        await db.collection("iot_device_in_apartment").doc(roomCode).set({
            IoTDeviceID: type_iot,
            ApartmentID: apartment.Id,
            Otp: otp,
            Status: "pending",
            DeviceID: deviceId,
            CreationDate: admin.firestore.Timestamp.now(),
        });

        try {
            const io = getIO();
            io.to(roomCode).emit("otp_received", { otp, roomCode });
        } catch (e) {
            // Socket might not be initialized; log but keep flow
            console.warn("Socket not initialized or emit failed", e);
        }

        return {
            status: "success",
            message: `OTP was sent to mobile app with code: ${roomCode}`,
            otp,
            roomCode,
        };
    },

    /**
     * Verify OTP for a room, update status, and emit success event
     */
    verifyOtp: async (otpCode: string, roomCode: string): Promise<ServiceResult> => {
        if (!otpCode || !roomCode) {
            return { status: "error", message: "Missing otpCode or roomCode" };
        }

        const docRef = db.collection("iot_device_in_apartment").doc(roomCode);
        const doc = await docRef.get();
        if (!doc.exists) {
            return { status: "error", message: "OTP not found for this room" };
        }

        const data = doc.data();
        const savedOtp = data?.Otp;

        if (savedOtp !== otpCode) {
            return { status: "error", message: "Invalid OTP" };
        }

        await docRef.update({ Status: "verified" });

        try {
            const io = getIO();
            io.to(roomCode).emit("iot-verified", {
                roomCode,
                status: "success",
                message: "OTP verified successfully",
            });
            console.log(`Emitted iot-verified to room: ${roomCode}`);
        } catch (e) {
            console.warn("Socket emit failed", e);
        }

        return { status: "success", message: `verified success to roomCode is ${roomCode}` };
    },

    /**
     * Verify password of an apartment by room code
     */
    verifyPassword: async (password: string, roomCode: string): Promise<ServiceResult> => {
        if (!password || !roomCode) {
            return { status: "error", message: "Missing password or roomCode" };
        }

        const apartment = await ApartmentRepository.getByRoomCode(roomCode);
        if (!apartment) {
            return {
                status: "fail",
                message: "Invalid room code",
            };
        }
        if (apartment.Password !== password) {
            return {
                status: "fail",
                message: "Incorrect password",
            };
        }
        return {
            status: "success",
            message: "Password verified successfully",
        };
    },

    /**
     * Trigger an online check (ping) for a device by room code.
     * It writes a random PingCode and waits briefly for PingReply.
     */
    checkDevice: async (roomCode: string): Promise<ServiceResult> => {
        if (!roomCode) {
            return { status: "error", message: "Thiếu mã phòng" };
        }
        const docRef = db.collection("iot_device_in_apartment").doc(roomCode);
        const doc = await docRef.get();
        if (!doc.exists) {
            return { status: "fail", message: "Không tìm thấy thiết bị" };
        }

        const pingCode = Math.random().toString(36).substring(2, 10);
        await docRef.update({ PingCode: pingCode, PingReply: admin.firestore.FieldValue.delete() });

        // Poll for up to ~5 seconds to see if device replies
        const start = Date.now();
        const timeoutMs = 5000;
        let online = false;
        while (Date.now() - start < timeoutMs) {
            const latest = await docRef.get();
            const data = latest.data();
            if (data?.PingReply && data.PingReply === pingCode) {
                online = true;
                break;
            }
            // small delay
            await new Promise((res) => setTimeout(res, 400));
        }

        return {
            status: online ? "success" : "fail",
            message: online ? "Thiết bị đang trực tuyến" : "Thiết bị không phản hồi sau 5 giây",
            roomCode,
            online,
        };
    },

    /**
     * Delete device mapping document
     */
    deleteDevice: async (roomCode: string): Promise<ServiceResult> => {
        if (!roomCode) {
            return { status: "error", message: "Missing roomCode" };
        }
        const docRef = db.collection("iot_device_in_apartment").doc(roomCode);
        const doc = await docRef.get();
        if (!doc.exists) {
            return { status: "fail", message: "Device not found" };
        }
        await docRef.delete();
        return { status: "success", message: "Device deleted", roomCode };
    },
};