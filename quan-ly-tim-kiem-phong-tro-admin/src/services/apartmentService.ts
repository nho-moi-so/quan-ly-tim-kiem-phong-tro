import { createFabricClient } from "@/lib/fabric/fabricClient";
import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";

const {contract, close} = await createFabricClient();
const repoBlockchainFabric = new BlockchainFabricRepository(contract);

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
            const blockchainApartment = await repoBlockchainFabric.createApartment(newApartment.Id, data.userId, data.dailyRate);
        }
        catch(err){
            //neu tao tren blockchain that bai thi xoa tren firebase
            await ApartmentRepository.delete(newApartment.Id);
            throw err;
        }
        return newApartment;
    },
}