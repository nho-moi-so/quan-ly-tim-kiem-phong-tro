import { ccp } from '@/lib/fabric/caClient';
import { Contract } from '@hyperledger/fabric-gateway';
import { Gateway, Wallets, X509Identity } from 'fabric-network';

//===================dinh nghia lai cac struct tu go trong typescript===========
////user
export type UserStatus = 'ACTIVE' | 'PENDING' | 'LOCKED' | 'APPROVED';
export type UserRole = "ADMIN" | "OWNER" | "GUEST";
export interface IUser{
    docType?: string;
    id: string;
    fullName: string;
    balance: number;
    lockedBalace: number;
    status: UserStatus;
    role: UserRole;
}
////apartment
export type ApartmentStatus = "AVAILABLE" | "BOOKED" | "OCCUPIED";
export interface IApartment{
    docType?: string;
    id: string
    ownerId: string;
    dailyRate: number;
    status: string;
    passwordHash: string;
}
////contract
export type ContractStatus = "CREATED" | "ACTIVE" | "COMPLETED" | "CANCELED";
export interface IContract{
    docType?: string
    id: string
    apartmentId: string;
    guestId: string;
    startDate: number; //checkin
    endDate: number; //checkout
    escrowAmount: number; //tien giu
    status: string; 
}

//=========================Repository class===================
export class BlockchainFabricRepository{
    private contract: Contract
    
    constructor(contract: Contract){
        this.contract = contract
    }

    //helper parse buffer tu blockchain ve json object
    private parseResult<T>(result: Uint8Array): T{
        if(!result || result.length === 0){
            return null as any;
        }
        const text = new TextDecoder().decode(result);
        return JSON.parse(text) as T;
    }



    //=====user function=====
    async createUser(
        id: string,
        fullName: string,
        balance: number,
        role: UserRole,
    ): Promise<void>{
        await this.contract.submitTransaction("CreateUser", id, fullName, balance.toString(), role)
        
    }
    async getUserById(
        id: string
    ): Promise<IUser>{
        const result = await this.contract.evaluateTransaction("GetUserById", id);
        return this.parseResult<IUser>(result);
    }
    async updateUserById(
        id: string,
        fullName: string,
        status: UserStatus,
        role: UserRole
    ): Promise<IUser>{
        const result = await this.contract.submitTransaction('UpdateUserById', id, fullName, status, role);
        return this.parseResult<IUser>(result);
    }
    //===financial functions====
    async deposit(
        userId: string,
        amount: number
    ): Promise<void>{
        await this.contract.submitTransaction('Deposit', userId, amount.toString());
    }
    async requestWithdraw(
        userId: string,
        amount: number
    ): Promise<void>{
        await this.contract.submitTransaction('RequestWithDraw', userId, amount.toString());
    }
    async finishWithdraw(
        userId: string,
        amount: number
    ): Promise<void>{
        await this.contract.submitTransaction('FinishWithDraw', userId, amount.toString())
    }

    //===apartment function===
    async createApartment(
        id: string,
        ownerId: string,
        dailyRate: number
    ): Promise<void>{
        await this.contract.submitTransaction('CreateApartment', id, ownerId, dailyRate.toString())
    }
    async getApartmentById(id: string): Promise<IApartment>{
        const result = await this.contract.evaluateTransaction('GetApartmentById', id);
        return this.parseResult<IApartment>(result);
    }
    async updatePasswordApartment(
        id: string,
        passwordHash: string
    ): Promise<void>{
        await this.contract.submitTransaction('UpdatePasswordApartment', id, passwordHash);
    }
    async verifyAccess(
        apartmentId: string,
        passwordHash: string
    ): Promise<boolean>{
        //ham chi doc -> evaluateTransaction
        const result = await this.contract.evaluateTransaction('VerifyAccess', apartmentId, passwordHash);
        // Go trả về "true" hoặc "false" (string)
        return new TextDecoder().decode(result) === 'true';
    
    }

    //===booking/contract function===
    async bookApartment(
        contractId: string, 
        apartmentId: string,
        guestId: string,
        startDate: number,
        endDate: number,
    ): Promise<void>{
        await this.contract.submitTransaction(
            'BookApartment',
            contractId,
            apartmentId,
            guestId,
            startDate.toString(),
            endDate.toString()
        );
    }
    async checkIn(
        contractId: string,
        newPasswordHash: string
    ): Promise<void>{
        await this.contract.submitTransaction('CheckIn', contractId, newPasswordHash)
    }
    async checkOut(
        contractId: string,
        resetPasswordHash: string
    ): Promise<void>{
        await this.contract.submitTransaction('CheckOut', contractId, resetPasswordHash)
    }
    async cancelBooking(
        contractId: string
    ): Promise<void>{
        await this.contract.submitTransaction('CancelBooking', contractId);
    }
    async getAllContracts(): Promise<IContract[]>{
        const result = await this.contract.evaluateTransaction('GetAllContracts');
        return this.parseResult<IContract[]>(result);
    }

    //===admin identity functions===
    async createUserWithMasterAdmin(
        masterAdminIdentity: X509Identity,
        userId: string,
        fullName: string,
        balance: number,
        role: UserRole
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('admin', masterAdminIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'admin',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('CreateUser', userId, fullName, balance.toString(), role);
        } finally {
            gateway.disconnect();
        }
    }

    async updateUserWithMasterAdmin(
        masterAdminIdentity: X509Identity,
        id: string,
        fullName: string,
        status: UserStatus,
        role: UserRole
    ): Promise<IUser> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('admin', masterAdminIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'admin',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            const result = await contract.submitTransaction('UpdateUserById', id, fullName, status, role);
            const text = new TextDecoder().decode(result);
            return JSON.parse(text) as IUser;
        } finally {
            gateway.disconnect();
        }
    }

    async depositWithMasterAdmin(
        masterAdminIdentity: X509Identity,
        userId: string,
        amount: number
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('admin', masterAdminIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'admin',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('Deposit', userId, amount.toString());
        } finally {
            gateway.disconnect();
        }
    }

    async finishWithdrawWithMasterAdmin(
        masterAdminIdentity: X509Identity,
        userId: string,
        amount: number
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('admin', masterAdminIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'admin',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('FinishWithDraw', userId, amount.toString());
        } finally {
            gateway.disconnect();
        }
    }

    // User wallet functions
    async createApartmentWithUser(
        userIdentity: X509Identity,
        id: string,
        ownerId: string,
        dailyRate: number
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('user', userIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'user',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('CreateApartment', id, ownerId, dailyRate.toString());
        } finally {
            gateway.disconnect();
        }
    }

    async updatePasswordApartmentWithUser(
        userIdentity: X509Identity,
        id: string,
        passwordHash: string
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('user', userIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'user',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('UpdatePasswordApartment', id, passwordHash);
        } finally {
            gateway.disconnect();
        }
    }

    async bookApartmentWithUser(
        userIdentity: X509Identity,
        contractId: string,
        apartmentId: string,
        guestId: string,
        startDate: number,
        endDate: number
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('user', userIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'user',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction(
                'BookApartment',
                contractId,
                apartmentId,
                guestId,
                startDate.toString(),
                endDate.toString()
            );
        } finally {
            gateway.disconnect();
        }
    }

    async cancelBookingWithUser(
        userIdentity: X509Identity,
        contractId: string
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('user', userIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'user',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('CancelBooking', contractId);
        } finally {
            gateway.disconnect();
        }
    }

    async checkInWithUser(
        userIdentity: X509Identity,
        contractId: string,
        newPasswordHash: string
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('user', userIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'user',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('CheckIn', contractId, newPasswordHash);
        } finally {
            gateway.disconnect();
        }
    }

    async checkOutWithUser(
        userIdentity: X509Identity,
        contractId: string,
        resetPasswordHash: string
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('user', userIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'user',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('CheckOut', contractId, resetPasswordHash);
        } finally {
            gateway.disconnect();
        }
    }

    async requestWithdrawWithUser(
        userIdentity: X509Identity,
        userId: string,
        amount: number
    ): Promise<void> {
        const gateway = new Gateway();
        try {
            const memoryWallet = await Wallets.newInMemoryWallet();
            await memoryWallet.put('user', userIdentity);
            
            await gateway.connect(ccp as any, {
                wallet: memoryWallet,
                identity: 'user',
                discovery: { enabled: true, asLocalhost: true }
            });
            
            const network = await gateway.getNetwork('rentingchannel');
            const contract = network.getContract('renting');
            
            await contract.submitTransaction('RequestWithDraw', userId, amount.toString());
        } finally {
            gateway.disconnect();
        }
    }

}


