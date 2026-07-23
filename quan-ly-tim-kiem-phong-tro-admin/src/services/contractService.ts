import { createFabricClient } from "@/lib/fabric/fabricClient";
import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { ContractRepository } from "@/repositories/contractRepository";
import { InvoiceRepository } from "@/repositories/invoiceRepository";
import { UserRepository } from "@/repositories/userRepository";
import { WalletBlockchainRepository } from "@/repositories/walletBlockchainRepository";
import { X509Identity } from "fabric-network";
import admin from "firebase-admin";

export const ContractService = {
    bookApartment: async (data: {
        apartmentId: string;
        endDate: Date;
        startDate: Date;
        status?: string;
        total?: number;
        userId: string;
    }) => {


        const { contract, gateway, client, close } = await createFabricClient();
        const repoBlockchainFabric = new BlockchainFabricRepository(contract);

        const apartment = await ApartmentRepository.getById(data.apartmentId);
        if (!apartment) {
            throw new Error("Apartment not found");
        }
        // console.log("Apartment data:", apartment);
        const apartment_check_in_time = apartment.CheckInTime
        const apartment_check_out_time = apartment.CheckOutTime
        const booking_start_time = data.startDate;
        const booking_end_time = data.endDate;

        // BƯỚC 1: Chặt đuôi T...Z, chỉ lấy phần ngày "YYYY-MM-DD"
        const startDateOnly = booking_start_time.toISOString().split('T')[0]; // "2026-06-10"
        const endDateOnly = booking_end_time.toISOString().split('T')[0];     // "2026-06-11"

        // BƯỚC 2: Ghép chuỗi Ngày và Giờ lại (định dạng chuẩn ISO ghép)
        // Thêm :00 ở cuối để tạo thành HH:mm:ss
        const exactCheckInDate = new Date(`${startDateOnly}T${apartment_check_in_time}:00`);
        const exactCheckOutDate = new Date(`${endDateOnly}T${apartment_check_out_time}:00`);

        // BƯỚC 3: Quy đổi ra Unix Timestamp (chia 1000 để chuyển từ mili-giây sang giây)
        const checkInUnix = Math.floor(exactCheckInDate.getTime() / 1000);
        const checkOutUnix = Math.floor(exactCheckOutDate.getTime() / 1000);

        // console.log("Check-in Unix:", checkInUnix); 
        // console.log("Check-out Unix:", checkOutUnix);

        const startDateMs = checkInUnix.toString().length === 10
            ? checkInUnix * 1000
            : checkInUnix;
        const endDateMs = checkOutUnix.toString().length === 10
            ? checkOutUnix * 1000
            : checkOutUnix;
        const startDateSec = Math.floor(startDateMs / 1000);
        // throw new Error("Booking failed due to some reason");
        const endDateSec = Math.floor(endDateMs / 1000);

        //tao du lieu tren firebase
        const apartmentStatus = (apartment.Status || "").toLowerCase();
        if (apartmentStatus !== "available") {
            throw new Error("Apartment is not available for booking");
        }
        const diffMs = endDateMs - startDateMs;
        if (diffMs <= 0) {
            throw new Error("Invalid booking duration");
        }
        const days = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
        const escrowAmount = apartment.DailyRate * Math.max(1, days);
        //trừ tiền của khách
        const user = await UserRepository.getById(data.userId);
        if (!user) {
            throw new Error("User not found");
        }
        if (user.Balance < escrowAmount) {
            throw new Error("Insufficient balance");
        }
        await UserRepository.update(data.userId, { Balance: user.Balance - escrowAmount });

        const contractData = await ContractRepository.create({
            ApartmentId: data.apartmentId,
            UserID: data.userId,
            CreatedDate: admin.firestore.Timestamp.now(),
            UpdateDate: admin.firestore.Timestamp.now(),
            StartDate: admin.firestore.Timestamp.fromMillis(startDateMs),
            EndDate: admin.firestore.Timestamp.fromMillis(endDateMs),
            EscrowAmount: escrowAmount,
            Status: "CREATED",
        });

        const invoiceData = await InvoiceRepository.create({
            ContractId: contractData.Id,
            IssueDate: admin.firestore.Timestamp.now(),
            TotalAmount: escrowAmount,
            Status: "PAID",
            ApartmentId: data.apartmentId,
        });
        await ContractRepository.update(contractData.Id, { InvoiceId: invoiceData.Id });

        //tao du lieu tren blockchain
        try {
            //lay identity tu firebase de tao tren blockchain
            const walletUser = await WalletBlockchainRepository.getIdentityFromFirebase(data.userId) as X509Identity;

            if (!walletUser) {
                throw new Error("User wallet not found on blockchain. Please enroll user first via setupMasterAdmin.ts → syncFirebaseToFabricUser.ts");
            }


            await repoBlockchainFabric.bookApartmentWithUser(
                walletUser,
                contractData.Id,
                data.apartmentId,
                data.userId,
                startDateSec,
                endDateSec
            );

            await ApartmentRepository.update(data.apartmentId, { Status: "booked" });
        }
        catch (err) {
            //neu tao tren blockchain that bai thi xoa tren firebase
            await ContractRepository.delete(contractData.Id);
            await InvoiceRepository.delete(invoiceData.Id);
            throw err;
        }
        finally {
            // ✅ FIX: Luôn close connection khi xong
            close();
        }
        return contractData;
    },
}