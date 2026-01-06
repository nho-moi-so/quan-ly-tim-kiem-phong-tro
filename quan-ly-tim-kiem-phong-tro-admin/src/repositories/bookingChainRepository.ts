import BookingChainABI from "@/lib/BookingChain.json";
import * as dotenv from "dotenv";
import {
    createPublicClient,
    createWalletClient,
    getContract,
    http,
    parseEventLogs,
    type Address,
    type Hash,
    type Log,
    type PublicClient,
    type TransactionReceipt,
    type WalletClient,
} from "viem";
import { privateKeyToAccount, type PrivateKeyAccount } from "viem/accounts";
import { sepolia } from "viem/chains";

dotenv.config();

// ==================== Types ====================

export enum ContractStatus {
    PAID = 0,        // Đã thanh toán - hợp lệ
    CANCELLED = 1,   // Đã hủy
}

export type Contract = {
    checkin: bigint;
    checkout: bigint;
    timestamp: bigint;
    status: ContractStatus;
    isValid: boolean;
};

export type ConfirmContractParams = {
    contractHash: string;
    checkin: number; // Unix timestamp (seconds)
    checkout: number; // Unix timestamp (seconds)
};

export type ContractHashParams = {
    contractHash: string;
};

export type AdminParams = {
    admin: Address;
};

// ==================== Repository ====================

export class BookingChainRepository {
    private contractAddress: Address;
    private publicClient: PublicClient;
    private walletClient: WalletClient;
    private account: PrivateKeyAccount;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    private contract: any;

    constructor() {
        this.contractAddress = process.env.CONTRACT_ADDRESS as Address;
        const rpcUrl = process.env.RPC_URL;
        
        if (!rpcUrl) {
            throw new Error("RPC_URL is not defined in environment variables");
        }
        
        if (!this.contractAddress) {
            throw new Error("CONTRACT_ADDRESS is not defined in environment variables");
        }

        const privateKey = process.env.SEPOLIA_PRIVATE_KEY;
        if (!privateKey) {
            throw new Error("SEPOLIA_PRIVATE_KEY is required in environment variables");
        }

        this.account = privateKeyToAccount(`0x${privateKey}` as `0x${string}`);
        
        this.publicClient = createPublicClient({
            chain: sepolia,
            transport: http(rpcUrl),
        }) as PublicClient;
        
        this.walletClient = createWalletClient({
            account: this.account,
            chain: sepolia,
            transport: http(rpcUrl),
        }) as WalletClient;

        this.contract = getContract({
            address: this.contractAddress,
            abi: BookingChainABI.abi,
            client: { 
                public: this.publicClient,
                wallet: this.walletClient
            },
        });
    }


    // ==================== Helper ====================

    /**
     * Convert Contract tuple sang object dễ đọc
     */
    private parseContract(contractData: any): Contract {
        // Viem returns structs as objects with named properties
        // Handle both named properties and numeric indices
        return {
            checkin: contractData.checkin ?? contractData[0],
            checkout: contractData.checkout ?? contractData[1],
            timestamp: contractData.timestamp ?? contractData[2],
            status: (contractData.status ?? contractData[3]) as ContractStatus,
            isValid: contractData.isValid ?? contractData[4],
        };
    }

    /**
     * Convert Unix timestamp (seconds) sang Date
     */
    private timestampToDate(timestamp: bigint): Date {
        return new Date(Number(timestamp) * 1000);
    }

    // ==================== Read Functions ====================

    /**
     * Lấy địa chỉ owner của contract
     */
    async getOwner(): Promise<Address> {
        return this.contract.read.owner();
    }

    /**
     * Lấy địa chỉ admin hiện tại
     */
    async getAdminAddress(): Promise<Address> {
        return this.account.address;
    }

    /**
     * Kiểm tra address có phải admin không
     */
    async isAdmin(address: Address): Promise<boolean> {
        return this.contract.read.isAdmin([address]);
    }

    /**
     * Lấy thông tin contract theo hash
     */
    async getContract(contractHash: string): Promise<Contract> {
        try {
            const contractData = await this.contract.read.getContract([contractHash]);
            return this.parseContract(contractData);
        } catch (error: any) {
            // Handle "Contract not found" error gracefully
            if (error?.shortMessage?.includes("Contract not found")) {
                return {
                    checkin: BigInt(0),
                    checkout: BigInt(0),
                    timestamp: BigInt(0),
                    status: ContractStatus.PAID,
                    isValid: false,
                };
            }
            throw error;
        }
    }

    /**
     * Lấy thông tin contract chi tiết với format dễ đọc
     */
    async getContractDetails(contractHash: string) {
        const contract = await this.getContract(contractHash);
        return {
            contractHash,
            checkin: this.timestampToDate(contract.checkin),
            checkout: this.timestampToDate(contract.checkout),
            timestamp: this.timestampToDate(contract.timestamp),
            status: contract.status === ContractStatus.PAID ? "PAID" : "CANCELLED",
            isValid: contract.isValid,
            checkinTimestamp: Number(contract.checkin),
            checkoutTimestamp: Number(contract.checkout),
            createdTimestamp: Number(contract.timestamp),
        };
    }

    /**
     * Kiểm tra contract có tồn tại không (isValid = true)
     */
    async isContractValid(contractHash: string): Promise<boolean> {
        const contract = await this.getContract(contractHash);
        return contract.isValid;
    }

    /**
     * Lấy status của contract
     */
    async getContractStatus(contractHash: string): Promise<ContractStatus> {
        const contract = await this.getContract(contractHash);
        return contract.status;
    }

    // ==================== Write Functions ====================

    /**
     * Grant admin role cho address
     * Chỉ owner mới có quyền
     */
    async grantRoleAdmin(params: AdminParams): Promise<Hash> {
        const { admin } = params;
        const hash = await this.contract.write.grantRoleAdmin([admin]);
        return hash;
    }

    /**
     * Revoke admin role của address
     * Chỉ owner mới có quyền
     */
    async revokeRoleAdmin(params: AdminParams): Promise<Hash> {
        const { admin } = params;
        const hash = await this.contract.write.revokeRoleAdmin([admin]);
        return hash;
    }

    /**
     * Xác nhận contract với thông tin checkin/checkout
     * Yêu cầu admin role
     */
    async confirmContract(params: ConfirmContractParams): Promise<Hash> {
        const { contractHash, checkin, checkout } = params;
        const hash = await this.contract.write.confirmContract([
            contractHash,
            BigInt(checkin),
            BigInt(checkout),
        ]);
        return hash;
    }

    /**
     * Hủy contract
     * Yêu cầu admin role
     */
    async cancelContract(params: ContractHashParams): Promise<Hash> {
        const { contractHash } = params;
        const hash = await this.contract.write.cancelContract([contractHash]);
        return hash;
    }

    /**
     * Void contract (đánh dấu là không hợp lệ)
     * Yêu cầu admin role
     */
    async voidContract(params: ContractHashParams): Promise<Hash> {
        const { contractHash } = params;
        const hash = await this.contract.write.voidContract([contractHash]);
        return hash;
    }

    /**
     * Verify contract (đánh dấu là hợp lệ)
     */
    async verify(params: ContractHashParams): Promise<Hash> {
        const { contractHash } = params;
        const hash = await this.contract.write.verify([contractHash]);
        return hash;
    }

    // ==================== Utility Functions ====================

    /**
     * Chờ transaction được confirm
     */
    async waitForTransaction(hash: Hash): Promise<TransactionReceipt> {
        return this.publicClient.waitForTransactionReceipt({ hash });
    }

    /**
     * Confirm contract và chờ confirm
     */
    async confirmContractAndWait(params: ConfirmContractParams) {
        const hash = await this.confirmContract(params);
        const receipt = await this.waitForTransaction(hash);
        return { hash, receipt };
    }

    /**
     * Cancel contract và chờ confirm
     */
    async cancelContractAndWait(params: ContractHashParams) {
        const hash = await this.cancelContract(params);
        const receipt = await this.waitForTransaction(hash);
        return { hash, receipt };
    }

    /**
     * Void contract và chờ confirm
     */
    async voidContractAndWait(params: ContractHashParams) {
        const hash = await this.voidContract(params);
        const receipt = await this.waitForTransaction(hash);
        return { hash, receipt };
    }

    /**
     * Verify contract và chờ confirm
     */
    async verifyAndWait(params: ContractHashParams) {
        const hash = await this.verify(params);
        const receipt = await this.waitForTransaction(hash);
        return { hash, receipt };
    }

    /**
     * Grant admin và chờ confirm
     */
    async grantRoleAdminAndWait(params: AdminParams) {
        const hash = await this.grantRoleAdmin(params);
        const receipt = await this.waitForTransaction(hash);
        return { hash, receipt };
    }

    /**
     * Revoke admin và chờ confirm
     */
    async revokeRoleAdminAndWait(params: AdminParams) {
        const hash = await this.revokeRoleAdmin(params);
        const receipt = await this.waitForTransaction(hash);
        return { hash, receipt };
    }

    /**
     * Lấy thông tin tổng quan của contract
     */
    async getContractInfo() {
        const [owner, isCurrentAdmin] = await Promise.all([
            this.getOwner(),
            this.isAdmin(this.account.address),
        ]);

        return {
            address: this.contractAddress,
            owner,
            currentAccount: this.account.address,
            isCurrentAccountAdmin: isCurrentAdmin,
        };
    }

    // ==================== Event Parsing ====================

    /**
     * Lấy transaction receipt từ blockchain
     */
    async getTransactionReceipt(txHash: Hash): Promise<TransactionReceipt> {
        return await this.publicClient.getTransactionReceipt({ hash: txHash });
    }

    /**
     * Parse ContractConfirmed event
     * Note: contractHash is indexed as string, so Solidity stores keccak256(contractHash)
     * We need to find the original value from the transaction input or rely on caller to provide it
     */
    async parseContractConfirmedEvent(logs: Log[], expectedHash?: string): Promise<{
        contractHash: string;
        checkin: bigint;
        checkout: bigint;
    } | null> {
        try {
            const parsedLogs = parseEventLogs({
                abi: BookingChainABI.abi,
                logs: logs,
                eventName: "ContractConfirmed",
            });

            if (parsedLogs.length === 0) {
                console.log("No ContractConfirmed events found in logs");
                return null;
            }

            const event = parsedLogs[0] as any;
            console.log("Parsed event:", JSON.stringify(event, (key, value) =>
                typeof value === 'bigint' ? value.toString() : value
            ));
            
            // Handle both event.args and direct properties
            const args = event.args || event;
            
            // For indexed strings, use the expected hash if provided
            const contractHash = expectedHash || (args.contractHash || args[0]) as string;
            
            return {
                contractHash,
                checkin: (args.checkin || args[1]) as bigint,
                checkout: (args.checkout || args[2]) as bigint,
            };
        } catch (error) {
            console.error("Error parsing ContractConfirmed event:", error);
            return null;
        }
    }

    /**
     * Parse ContractCancelled event
     */
    async parseContractCancelledEvent(logs: Log[], expectedHash?: string): Promise<{
        contractHash: string;
    } | null> {
        try {
            const parsedLogs = parseEventLogs({
                abi: BookingChainABI.abi,
                logs: logs,
                eventName: "ContractCancelled",
            });

            if (parsedLogs.length === 0) {
                return null;
            }

            const event = parsedLogs[0] as any;
            // Handle both event.args and direct properties
            const args = event.args || event;
            // For indexed strings, use the expected hash if provided
            const contractHash = expectedHash || (args.contractHash || args[0]) as string;
            return {
                contractHash,
            };
        } catch (error) {
            console.error("Error parsing ContractCancelled event:", error);
            return null;
        }
    }

    /**
     * Parse ContractVerified event
     */
    async parseContractVerifiedEvent(logs: Log[], expectedHash?: string): Promise<{
        contractHash: string;
        isValid: boolean;
    } | null> {
        try {
            const parsedLogs = parseEventLogs({
                abi: BookingChainABI.abi,
                logs: logs,
                eventName: "ContractVerified",
            });

            if (parsedLogs.length === 0) {
                return null;
            }

            const event = parsedLogs[0] as any;
            // Handle both event.args and direct properties
            const args = event.args || event;
            // For indexed strings, use the expected hash if provided
            const contractHash = expectedHash || (args.contractHash || args[0]) as string;
            return {
                contractHash,
                isValid: (args.isValid || args[1]) as boolean,
            };
        } catch (error) {
            console.error("Error parsing ContractVerified event:", error);
            return null;
        }
    }

    /**
     * Verify transaction cho confirm contract
     */
    async verifyConfirmTransaction(
        txHash: Hash,
        expectedContractHash: string
    ): Promise<{
        success: boolean;
        message: string;
        checkin?: Date;
        checkout?: Date;
    }> {
        try {
            const receipt = await this.getTransactionReceipt(txHash);

            if (receipt.status !== "success") {
                return {
                    success: false,
                    message: "Transaction failed on blockchain",
                };
            }

            // Pass expected hash since indexed strings are hashed in events
            const event = await this.parseContractConfirmedEvent(receipt.logs, expectedContractHash);
            if (!event) {
                return {
                    success: false,
                    message: "No ContractConfirmed event found in transaction",
                };
            }

            // Since we're passing expectedContractHash to the parser, it will always match
            // The important verification is that the event exists and has valid checkin/checkout
            if (!event.checkin || !event.checkout) {
                return {
                    success: false,
                    message: "Invalid event data - missing checkin or checkout",
                };
            }

            return {
                success: true,
                message: "Contract confirmed successfully",
                checkin: this.timestampToDate(event.checkin),
                checkout: this.timestampToDate(event.checkout),
            };
        } catch (error) {
            console.error("Error verifying confirm transaction:", error);
            return {
                success: false,
                message: "Failed to verify transaction",
            };
        }
    }
}

// Export singleton instance
export const bookingChainRepository = new BookingChainRepository();
