import { createFabricClient } from "@/lib/fabric/fabricClient";
import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { ContractRepository } from "@/repositories/contractRepository";
import { UserRepository } from "@/repositories/userRepository";
import { WalletBlockchainRepository } from "@/repositories/walletBlockchainRepository";
import { X509Identity } from "fabric-network";
import admin from "firebase-admin";

const {contract, close} = await createFabricClient();
const repoBlockchainFabric = new BlockchainFabricRepository(contract);

export const ContractService = {
    bookApartment: async (data: {
        apartmentId: string;
        endDate: number;
        startDate: number;
        status?: string;
        total?: number;
        userId: string;
    }) => {
        const startDateMs = data.startDate.toString().length === 10
            ? data.startDate * 1000
            : data.startDate;
        const endDateMs = data.endDate.toString().length === 10
            ? data.endDate * 1000
            : data.endDate;
        const startDateSec = Math.floor(startDateMs / 1000);
        const endDateSec = Math.floor(endDateMs / 1000);

        //tao du lieu tren firebase
        const apartment = await ApartmentRepository.getById(data.apartmentId);
        if(!apartment){
            throw new Error("Apartment not found");
        }
        const apartmentStatus = (apartment.Status || "").toLowerCase();
        if(apartmentStatus !== "available"){
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
        if(!user){
            throw new Error("User not found");
        }
        if(user.Balance < escrowAmount){
            throw new Error("Insufficient balance");
        }
        await UserRepository.update(data.userId, { Balance: user.Balance - escrowAmount });

        const contractData = await ContractRepository.create({
            ApartmentId: data.apartmentId,
            UserID: data.userId,
            StartDate: admin.firestore.Timestamp.fromMillis(startDateMs),
            EndDate: admin.firestore.Timestamp.fromMillis(endDateMs),
            EscrowAmount: escrowAmount,
            Status: "CREATED",
        });
        
        
        //tao du lieu tren blockchain
        try{
            //lay identity tu firebase de tao tren blockchain
            const walletUser = await WalletBlockchainRepository.getIdentityFromFirebase(data.userId) as X509Identity;

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
        catch(err){
            //neu tao tren blockchain that bai thi xoa tren firebase
            await ContractRepository.delete(contractData.Id);
            throw err;
        }
        return contractData;
    },
}