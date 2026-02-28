import { createFabricClient } from "@/lib/fabric/fabricClient";
import { db } from "@/lib/firebase/admin";
import { getIO } from "@/lib/socket";
import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { IoTDeviceInDepartmentRepository } from "@/repositories/iotDeviceInDepartmentRepository";
import { IoTDeviceRepository } from "@/repositories/iotDeviceRepository";
import { UserRepository } from "@/repositories/userRepository";
import admin from "firebase-admin";
const crypto = require('crypto');
const {contract, close} = await createFabricClient();
const repoBlockchainFabric = new BlockchainFabricRepository(contract);
type ServiceResult = {
    status: "success" | "fail" | "error";
    message: string;
    otp?: string;
    roomCode?: string;
    online?: boolean;
    pingCode?: string | null;
};
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

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
        
        // Sử dụng composite key: roomCode_deviceId
        const docId = `${roomCode}_${deviceId}`;
        await db.collection("iot_device_in_apartment").doc(docId).set({
            IoTDeviceID: type_iot,
            ApartmentID: apartment.Id,
            RoomCode: roomCode,
            Otp: otp,
            Status: "pending",
            DeviceID: deviceId,
            CreationDate: admin.firestore.Timestamp.now(),
        });

        try {
            const io = getIO();
            io.to(roomCode).emit("otp_received", { otp, roomCode, deviceId });
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
    verifyOtp: async (otpCode: string, roomCode: string, deviceId: string): Promise<ServiceResult> => {
        if (!otpCode || !roomCode || !deviceId) {
            return { status: "error", message: "Missing otpCode, roomCode, or deviceId" };
        }

        const docId = `${roomCode}_${deviceId}`;
        const docRef = db.collection("iot_device_in_apartment").doc(docId);
        const doc = await docRef.get();
        if (!doc.exists) {
            return { status: "error", message: "OTP not found for this device" };
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
                deviceId,
                status: "success",
                message: "OTP verified successfully",
            });
            console.log(`Emitted iot-verified to room: ${roomCode} for device: ${deviceId}`);
            const apartmentRef = await ApartmentRepository.getByRoomCode(roomCode);
            //tao mat khau moi cho thiet bi iot
            const newPassword = Array.from(crypto.getRandomValues(new Uint8Array(8)) as Uint8Array)
                    .map((x: number) => x % 10)
                    .join('');
            //hash mật khẩu mới trước khi lưu
            const newPasswordHash = hashPassword(newPassword);
            //cap nhat mau khau hash cho apartment tren blockchain
            await repoBlockchainFabric.updatePasswordApartment(apartmentRef.Id, newPasswordHash);
            //cap nhat mau khau raw cho apartment tren firebase
            await ApartmentRepository.update(apartmentRef.Id, { Password: newPassword });
            console.log(`Updated password for apartment ${apartmentRef.Id} after OTP verification`);
        } catch (e) {
            console.warn("Socket emit failed", e);
        }

        return { status: "success", message: `verified success to roomCode ${roomCode}, device ${deviceId}` };
    },

    /**
     * Verify password of an apartment by room code
     */
    verifyPassword: async (password: string, roomCode: string, deviceId: string): Promise<ServiceResult> => {
        if (!password || !roomCode || !deviceId) {
            return { status: "error", message: "Missing password, roomCode, or deviceId" };
        }


        // Cập nhật trạng thái verified trong Firestore (không cần emit event)
        const docId = `${roomCode}_${deviceId}`;
        const docRef = db.collection("iot_device_in_apartment").doc(docId);
        const doc = await docRef.get();
        

        if (doc.exists) {
            await docRef.update({ Status: "verified" });
            console.log(`✅ Password verified and status updated for room: ${roomCode}, device: ${deviceId}`);
        }

        return {
            status: "success",
            message: "Password verified successfully",
        };
    },

    /**
     * Lấy PingCode hiện tại của thiết bị theo roomCode và deviceId
     */
    getPingCode: async (roomCode: string, deviceId: string): Promise<ServiceResult> => {
        if (!roomCode || !deviceId) {
            return { status: "error", message: "Thiếu mã phòng hoặc mã thiết bị", pingCode: null };
        }

        const docId = `${roomCode}_${deviceId}`;
        const docRef = db.collection("iot_device_in_apartment").doc(docId);
        const doc = await docRef.get();

        if (!doc.exists) {
            return { status: "fail", message: "Device not found", pingCode: null };
        }

        const data = doc.data();
        return {
            status: "success",
            message: "PingCode fetched",
            pingCode: data?.PingCode || null,
            roomCode,
        };
    },

    /**
     * Thiết bị gửi PingReply để xác nhận đang online
     */
    updatePingReply: async (roomCode: string, deviceId: string, pingReply?: string): Promise<ServiceResult> => {
        if (!roomCode || !deviceId) {
            return { status: "error", message: "Thiếu mã phòng hoặc mã thiết bị" };
        }
        if (!pingReply) {
            return { status: "fail", message: "Missing pingReply" };
        }

        const docId = `${roomCode}_${deviceId}`;
        const docRef = db.collection("iot_device_in_apartment").doc(docId);
        const doc = await docRef.get();

        if (!doc.exists) {
            return { status: "fail", message: "Device not found" };
        }

        await docRef.update({ PingReply: pingReply });

        return {
            status: "success",
            message: "PingReply updated",
            roomCode,
        };
    },

    /**
     * Trigger an online check (ping) for a device by room code and device ID.
     * It writes a random PingCode and waits briefly for PingReply.
     */
    checkDevice: async (roomCode: string, deviceId: string): Promise<ServiceResult> => {
        if (!roomCode || !deviceId) {
            return { status: "error", message: "Thiếu mã phòng hoặc mã thiết bị" };
        }
        const docId = `${roomCode}_${deviceId}`;
        console.log(`Checking device with docId: ${docId}`);
        const docRef = db.collection("iot_device_in_apartment").doc(docId);
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
    deleteDevice: async (roomCode: string, deviceId: string): Promise<ServiceResult> => {
        if (!roomCode || !deviceId) {
            return { status: "error", message: "Missing roomCode or deviceId" };
        }
        const docId = `${roomCode}_${deviceId}`;
        const docRef = db.collection("iot_device_in_apartment").doc(docId);
        const doc = await docRef.get();
        if (!doc.exists) {
            return { status: "fail", message: "Device not found" };
        }
        await docRef.delete();
        return { status: "success", message: "Device deleted", roomCode };
    },

    /**
     * Re-connect: Kiểm tra xem device đã được kết nối với phòng nào chưa
     * Dùng khi IoT khởi động lại (mất điện, reset)
     */
    reConnect: async (deviceId: string): Promise<ServiceResult> => {
        if (!deviceId) {
            return { status: "error", message: "Missing deviceId" };
        }

        // Tìm device trong collection iot_device_in_apartment với Status = "verified"
        const querySnapshot = await db.collection("iot_device_in_apartment")
            .where("DeviceID", "==", deviceId)
            .where("Status", "==", "verified")
            .limit(1)
            .get();

        if (querySnapshot.empty) {
            return { 
                status: "fail", 
                message: "No room connected. Please enter room code." 
            };
        }

        const doc = querySnapshot.docs[0];
        const data = doc.data();
        const roomCode = data.RoomCode;

        return {
            status: "success",
            message: "Device reconnected successfully",
            roomCode: roomCode,
        };
    },
};