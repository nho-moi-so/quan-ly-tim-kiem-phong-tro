import { createFabricClient } from "@/lib/fabric/fabricClient";
import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { ContractRepository } from "@/repositories/contractRepository";
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
        const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
        if (days <= 0) {
            throw new Error("Invalid booking duration");
        }
        const escrowAmount = apartment.DailyRate * days;

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
            const blockchainContract = await repoBlockchainFabric.bookApartment(
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