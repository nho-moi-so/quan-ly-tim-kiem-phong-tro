import { createFabricClient } from "@/lib/fabric/fabricClient";
import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { WalletBlockchainRepository } from "@/repositories/walletBlockchainRepository";
import { X509Identity } from "fabric-network";



export const ApartmentService = {
    
    createApartment: async (data: {
        address: string;
        codeApartment: string;
        dailyRate: number;
        decription?: string;
        latitude?: number;
        longitude?: number;
        maxOccupancy: number;
        password?: string;    
        pathImage?: string[];
        requirements?: string[];
        status?: string;
        type?: string;
        userId: string;
    }) => {
        const {contract, close} = await createFabricClient();
        const repoBlockchainFabric = new BlockchainFabricRepository(contract);
        //tao apartment tren firebase
        const newApartment = await ApartmentRepository.create({
            Address: data.address,
            CodeApartment: data.codeApartment,
            DailyRate: data.dailyRate,
            Decription: data.decription,
            Latitude: data.latitude,
            Longitude: data.longitude,
            MaxOccupancy: data.maxOccupancy,
            Password: data.password,
            PathImage: data.pathImage ?? [],
            Requirements: (data.requirements ?? []).join(','),
            Status: data.status,
            Type: data.type,
            UserID: data.userId,    
        });
        //tao apartment tren blockchain
        try{
            //lay id tu firebase de tao tren blockchain
            const walletUser = await WalletBlockchainRepository.getIdentityFromFirebase(data.userId) as X509Identity;

            await repoBlockchainFabric.createApartmentWithUser(
                walletUser,
                newApartment.Id, 
                data.userId, 
                data.dailyRate);
        }
        catch(err){
            //neu tao tren blockchain that bai thi xoa tren firebase
            await ApartmentRepository.delete(newApartment.Id);
            throw err;
        }
        finally{
            await close();
        }
        return newApartment;
    },
}