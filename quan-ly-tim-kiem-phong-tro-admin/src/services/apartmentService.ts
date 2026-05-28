import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { BlockchainFabricRepository } from "@/repositories/blockchainFabricRepository";
import { WalletBlockchainRepository } from "@/repositories/walletBlockchainRepository";
import { X509Identity } from "fabric-network";
import { getIO } from "@/lib/socket";


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
        // BỎ createFabricClient() ở đây vì hàm createApartmentWithUser đã tự mở Gateway riêng rồi
        
        // 1. Tạo apartment trên Firebase
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
            Requirements: data.requirements ?? [],
            Status: data.status,
            Type: data.type,
            UserID: data.userId,    
        });

        // 2. Tạo apartment trên Blockchain
        try {
            // Lấy id từ firebase dưới dạng dữ liệu thô (Raw Data)
            const rawWallet: any = await WalletBlockchainRepository.getIdentityFromFirebase(data.userId);
            
            // BẮT BUỘC: Map dữ liệu thô sang đúng chuẩn X509Identity của Fabric SDK
            const walletUser: X509Identity = {
                credentials: {
                    // Ưu tiên đọc cấu trúc lồng nhau (nếu có), không thì đọc cấu trúc phẳng
                    certificate: rawWallet.credentials?.certificate || rawWallet.CredentialsCertificate,
                    privateKey: rawWallet.credentials?.privateKey || rawWallet.CredentialsPrivateKey,
                },
                mspId: rawWallet.mspId || rawWallet.MSPID || 'Org1MSP',
                type: rawWallet.type || rawWallet.Type || 'X.509',
            };

            // Khởi tạo repo (truyền null vào vì ta không dùng chung contract ở tầng này nữa)
            const repoBlockchainFabric = new BlockchainFabricRepository(null as any);

            await repoBlockchainFabric.createApartmentWithUser(
                walletUser,
                newApartment.Id, 
                data.userId, 
                data.dailyRate
            );

        } catch(err) {
            // Nếu tạo trên blockchain thất bại thì xóa trên firebase
            await ApartmentRepository.delete(newApartment.Id);
            throw err;
        }
        // 3. Emit socket event
        try {
            const io = getIO();
            io.emit("apartment_created", {
                apartmentId: newApartment.Id,
                codeApartment: newApartment.CodeApartment,
                userId: data.userId,
            });
            console.log("📡 apartment_created emitted");
        } catch (e) {
            console.warn("⚠️ Socket emit failed", e);
        }
        return newApartment;
    },
}