import { ca } from "@/lib/fabric/caClient";
import "@/lib/firebase/admin";
import { UserRepository } from "@/repositories/userRepository";
import { WalletBlockchainRepository } from "@/repositories/walletBlockchainRepository";
import 'dotenv/config';
import { Gateway, Wallets, X509Identity } from 'fabric-network';
import admin from "firebase-admin";
import { createFabricClient } from '../lib/fabric/fabricClient';
import { BlockchainFabricRepository } from '../repositories/blockchainFabricRepository';

export const UserService = {
    createUser: async (data: {
        balance: number;
        cccd?: string;
        email: string;
        fullName: string;
        password: string;
        phone: string;
        role: 'GUEST' | 'OWNER' | 'ADMIN';
        status: string;
    }) => {
        let authUid: string | null = null;
        let newUser: Awaited<ReturnType<typeof UserRepository.create>> | null = null;
        console.log("==1==");

        // Khởi tạo fabric client
        const {contract, close} = await createFabricClient();
        const repoBlockchainFabric = new BlockchainFabricRepository(contract);
        console.log("==2==");

        const gateway = new Gateway();
        try {
            const authUser = await admin.auth().createUser({
                email: data.email,
                password: data.password,
                displayName: data.fullName,
            });
            authUid = authUser.uid;
            console.log("==3==");

            //tao user tren firebase/firestore
            newUser = await UserRepository.create({
                Id: authUid,
                Balance: data.balance,
                Cccd: data.cccd,
                Email: data.email,
                Fullname: data.fullName,
                Password: data.password,
                Phone: data.phone,
                Role: data.role.toLocaleLowerCase(),
                Status: data.status.toLocaleLowerCase(),
            });
            //lay idenity cua admin tren firebase de tao user tren blockchain
            const masterAdmin = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin') as X509Identity; //== Hardcoded master admin ID
            if (!masterAdmin) {
                throw new Error("Master admin identity not found in Firebase");
            }
            console.log("==4==");
            try{
                //TẠO VÍ TRONG BỘ NHỚ (In-Memory Wallet) để lấy context
                const memoryWallet = await Wallets.newInMemoryWallet();
                await memoryWallet.put('admin', masterAdmin);

                //Lấy provider và adminUser context
                const provider = memoryWallet.getProviderRegistry().getProvider(masterAdmin.type);
                const adminUser = await provider.getUserContext(masterAdmin, 'admin');

                //Bây giờ mới dùng adminUser này để Register qua CA
                const secret = await ca.register({
                    affiliation: 'org1.department1',
                    enrollmentID: authUid,
                    role: 'client'
                }, adminUser);
                const enrollment = await ca.enroll({
                    enrollmentID: authUid,
                    enrollmentSecret: secret
                });
                await WalletBlockchainRepository.create({
                                UserID: authUid,
                                CredentialsCertificate: enrollment.certificate,
                                CredentialsPrivateKey: enrollment.key.toBytes(),
                                MSPID: 'Org1MSP',
                                Type: 'X.509'
                            });
            }
            catch(err){
                console.error("Failed to register/enroll user with CA, rolling back user creation: ", err);
                throw new Error("Failed to register/enroll user with CA");
            }
                       
            console.log("==5==");
            // 6. BLOCKCHAIN: Tạo bản ghi User trên Ledger bằng Master Admin identity
            try{
                await repoBlockchainFabric.createUserWithMasterAdmin(
                    masterAdmin,
                    newUser.Id, 
                    data.fullName, 
                    data.balance,
                    data.role.toUpperCase() as any
                );
            }catch(err){
                console.error("Failed to create user on blockchain, rolling back user creation: ", err);
                throw new Error("Failed to create user on blockchain");
            }
            
            return newUser;
        } catch (err) {
            if (newUser?.Id) {
                await UserRepository.delete(newUser.Id).catch(() => undefined);
            }

            if (authUid) {
                await admin.auth().deleteUser(authUid).catch(() => undefined);
            }

            throw err;
        } finally {
            // Đóng connection
            await close();
        }
    },

    getAllGests: async () => {
        // get list of guest users
        const users = await UserRepository.getAll();
        const guests = users.filter(user => user.Role === 'guest');

        let guestSummaries = [];
        for (const guest of guests) {
            guestSummaries.push({
                userCode: guest.Id,
                fullName: guest.Fullname,
                email: guest.Email,
                phone: guest.Phone,
                // Return raw status; FE will translate for display
                status: guest.GuestStatus ?? "active",
            });
        }
        return guestSummaries;
    },
    getGuestById: async (guestId: string) => {
        // get guest user by ID
        const user = await UserRepository.getById(guestId);
        if (!user || user.Role !== 'guest') {
            return null;
        }

        return {
            userCode: user.Id,
            fullName: user.Fullname,
            email: user.Email,
            phone: user.Phone,
            status: user.GuestStatus ?? "active",
            registeredAt: "2023-01-01" //== Hardcoded for now
        };
    },
    
    getAllOwners: async () => {
        // get list of owner users
        const users = await UserRepository.getAll();
        const owners = users.filter(user => user.Role === 'owner');

        let ownerSummaries = [];
        for (const owner of owners) {
            ownerSummaries.push({
                userCode: owner.Id,
                fullName: owner.Fullname,
                email: owner.Email,
                phone: owner.Phone,
                status: owner.Status ?? "active",
            });
        }
        return ownerSummaries;
    },
    getOwnerById: async (ownerId: string) => {
        // get owner user by ID
        const user = await UserRepository.getById(ownerId);
        if (!user || user.Role !== 'owner') {
            return null;
        }

        return {
            userCode: user.Id,
            fullName: user.Fullname,
            email: user.Email,
            phone: user.Phone,
            status: user.Status ?? "active",
            registeredAt: "2023-01-01" //== Hardcoded for now
        };
    },

    lockGuest: async (guestId: string) => {
        const user = await UserRepository.getById(guestId);
        if (!user || user.Role !== 'guest') {
            throw new Error('Guest not found');
        }
        const updated = await UserRepository.update(guestId, { GuestStatus: 'locked' });
        return { userCode: updated.Id, status: updated.GuestStatus ?? 'locked' };
    },

    lockOwner: async (ownerId: string) => {
        const user = await UserRepository.getById(ownerId);
        if (!user || user.Role !== 'owner') {
            throw new Error('Owner not found');
        }
        const updated = await UserRepository.update(ownerId, { Status: 'locked' });
        return { userCode: updated.Id, status: updated.Status ?? 'locked' };
    },

    unlockGuest: async (guestId: string) => {
        const user = await UserRepository.getById(guestId);
        if (!user || user.Role !== 'guest') {
            throw new Error('Guest not found');
        }
        const updated = await UserRepository.update(guestId, { GuestStatus: 'active' });
        return { userCode: updated.Id, status: updated.GuestStatus ?? 'active' };
    },

    unlockOwner: async (ownerId: string) => {
        const user = await UserRepository.getById(ownerId);
        if (!user || user.Role !== 'owner') {
            throw new Error('Owner not found');
        }
        const updated = await UserRepository.update(ownerId, { Status: 'active' });
        return { userCode: updated.Id, status: updated.Status ?? 'active' };
    },

    approveOwner: async (ownerId: string) => {
                // Khởi tạo fabric client
        const {contract, close} = await createFabricClient();
        const repoBlockchainFabric = new BlockchainFabricRepository(contract);
        try{
        const user = await UserRepository.getById(ownerId);
        if (!user || user.Role !== 'owner') {
            throw new Error('Owner not found');
        }
        // Cap nhat tren fabric bang master admin
        const masterAdmin = await WalletBlockchainRepository.getIdentityFromFirebase('master-admin') as X509Identity;
        if (!masterAdmin) {
            throw new Error("Master admin identity not found in Firebase");
        }
        await repoBlockchainFabric.updateUserWithMasterAdmin(
            masterAdmin,
            ownerId,
            user.Fullname,
            'APPROVED',
            user.Role.toUpperCase() as any
        );
        //cap nhat tren firebase
        const updated = await UserRepository.update(ownerId, { Status: 'APPROVED' });
        return { userCode: updated.Id, status: updated.Status.toUpperCase() ?? 'APPROVED' };
        }catch(err){
            console.error("Failed to approve owner: ", err);
            throw new Error("Failed to approve owner");
        }finally{
            await close();
        }
    },

    rejectOwner: async (ownerId: string) => {
        const user = await UserRepository.getById(ownerId);
        if (!user || user.Role !== 'owner') {
            throw new Error('Owner not found');
        }
        const updated = await UserRepository.update(ownerId, { Status: 'REJECTED' });
        return { userCode: updated.Id, status: updated.Status.toUpperCase() ?? 'REJECTED' };
    },

    getUserByEmail: async (email: string) => {
        const users = await UserRepository.getAll();
        const user = users.find(u => u.Email === email);
        
        if (!user) {
            return null;
        }

        return {
            userId: user.Id,
            email: user.Email,
            fullName: user.Fullname,
            role: user.Role
        };
    },

    /**
     * Get admin user by email
     */
    getAdminByEmail: async (email: string) => {
        const users = await UserRepository.getAll();
        const user = users.find(u => u.Email === email && u.Role === 'admin');
        
        if (!user) {
            return null;
        }

        return {
            userId: user.Id,
            email: user.Email,
            fullName: user.Fullname,
            phone: user.Phone,
            role: user.Role
        };
    },

    /**
     * Update admin profile
     */
    updateAdminProfile: async (userId: string, data: { fullName?: string; phone?: string }) => {
        const user = await UserRepository.getById(userId);
        
        if (!user || user.Role !== 'admin') {
            throw new Error('Admin not found');
        }

        const updateData: { Fullname?: string; Phone?: string } = {};
        
        if (data.fullName) {
            updateData.Fullname = data.fullName;
        }
        
        if (data.phone !== undefined) {
            updateData.Phone = data.phone;
        }

        const updated = await UserRepository.update(userId, updateData);
        
        return {
            userId: updated.Id,
            email: updated.Email,
            fullName: updated.Fullname,
            phone: updated.Phone,
            role: updated.Role
        };
    }
};