import { bookingChainRepository } from '@/repositories/bookingChainRepository';
import crypto from 'crypto';

const bookingChainRepo = bookingChainRepository;

export const bookingChainService = {
    async createBookingHash(bookingData: {
        bookingId: string;
        apartmentId: string;
        price: number;
        ownerId: string;
        guestId: string;
        password: string;
    }) {
    
        const dataParts = [
            bookingData.bookingId,
            bookingData.apartmentId,
            bookingData.price.toString(), // Chuyển số về chuỗi
            bookingData.ownerId,
            bookingData.guestId,
            bookingData.password, // Mã mở cửa (OTP/PIN)
        ];

        // Nối lại bằng ký tự đặc biệt (ví dụ dấu gạch đứng |) để tránh dính chữ
        const dataString = dataParts.join('|');

        //TẠO HASH SHA-256
        const hash = crypto
            .createHash('sha256')      // Chọn thuật toán
            .update(dataString)        // Đưa dữ liệu vào
            .digest('hex');            // Lấy kết quả dạng chuỗi Hexa (0-9, a-f)

        return hash;

    },

    async confirmBookingOnChain(params: {
        contractHash: string;
        checkin: Date | string | number;
        checkout: Date | string | number;
    }) {
        // Validate hash không được rỗng
        if (!params.contractHash || params.contractHash.trim() === '') {
            throw new Error('Contract hash cannot be empty');
        }

        // Kiểm tra contract đã tồn tại chưa (tránh duplicate)
        try {
            const existingContract = await bookingChainRepo.getContract(params.contractHash);
            // Nếu getContract không throw error nghĩa là contract đã tồn tại
            if (existingContract.isValid) {
                throw new Error(`Contract with hash ${params.contractHash} already exists on blockchain`);
            }
        } catch (error: any) {
            // Nếu getContract throw error "Contract not found" thì OK, tiếp tục
            if (!error?.message?.includes('Contract not found') && 
                !error?.message?.includes('already exists')) {
                throw error;
            }
        }

        // Convert và validate dates
        const toUnixSeconds = (value: Date | string | number) => {
            const dt = value instanceof Date ? value : new Date(value);
            if (Number.isNaN(dt.getTime())) {
                throw new Error("Invalid date provided for checkin/checkout");
            }
            return Math.floor(dt.getTime() / 1000);
        };

        const checkinSec = toUnixSeconds(params.checkin);
        const checkoutSec = toUnixSeconds(params.checkout);
        const nowSec = Math.floor(Date.now() / 1000);

        // Validate date logic
        if (checkinSec >= checkoutSec) {
            throw new Error('Check-in date must be before check-out date');
        }

        if (checkinSec < nowSec - 86400) { // Allow backdating by 1 day for testing
            throw new Error('Check-in date cannot be in the past (more than 1 day ago)');
        }

        // Confirm contract trên blockchain
        const result = await bookingChainRepo.confirmContractAndWait({
            contractHash: params.contractHash,
            checkin: checkinSec,
            checkout: checkoutSec,
        });

        // Lấy thông tin contract sau khi confirm để verify
        const confirmedContract = await bookingChainRepo.getContract(params.contractHash);
        
        const checkinTimestamp = Number(confirmedContract.checkin);
        const checkoutTimestamp = Number(confirmedContract.checkout);
        const createdTimestamp = Number(confirmedContract.timestamp);
        
        return {
            ...result,
            contractInfo: {
                checkin: confirmedContract.checkin.toString(),
                checkinDate: new Date(checkinTimestamp * 1000).toISOString(),
                checkout: confirmedContract.checkout.toString(),
                checkoutDate: new Date(checkoutTimestamp * 1000).toISOString(),
                timestamp: confirmedContract.timestamp.toString(),
                createdAt: new Date(createdTimestamp * 1000).toISOString(),
                status: confirmedContract.status,
                statusText: confirmedContract.status === 0 ? 'PAID' : 'CANCELLED',
                isValid: confirmedContract.isValid
            }
        };
    },

    async verifyBookingOnChain(contractHash: string) {
        // Đọc contract từ blockchain (view function - không tốn gas)
        const contract = await bookingChainRepo.getContract(contractHash);
        
        // Kiểm tra contract có tồn tại không (chỉ cần isValid = true)
        if (!contract.isValid) {
            throw new Error(`Contract with hash ${contractHash} does not exist or has been voided`);
        }

        // Trả về thông tin contract (không quan tâm status PAID hay CANCELLED)
        const checkinTimestamp = Number(contract.checkin);
        const checkoutTimestamp = Number(contract.checkout);
        const createdTimestamp = Number(contract.timestamp);
        
        return {
            verified: true,
            contractInfo: {
                checkinDate: new Date(checkinTimestamp * 1000).toISOString(),
                checkoutDate: new Date(checkoutTimestamp * 1000).toISOString(),
                createdAt: new Date(createdTimestamp * 1000).toISOString(),
                statusText: contract.status === 0 ? 'PAID' : 'CANCELLED',
                isValid: contract.isValid
            }
        };
    },

    async cancelBookingOnChain(contractHash: string) {
        // Kiểm tra hash không được rỗng
        if (!contractHash || contractHash.trim() === '') {
            throw new Error('Contract hash cannot be empty');
        }

        // Kiểm tra contract có tồn tại không
        const contract = await bookingChainRepo.getContract(contractHash);
        
        if (!contract.isValid) {
            throw new Error(`Contract with hash ${contractHash} does not exist or is invalid on blockchain`);
        }

        // Kiểm tra contract đang ở trạng thái PAID (chỉ cancel được contract PAID)
        if (contract.status !== 0) { // 0 = PAID
            throw new Error(`Contract is already in ${contract.status === 1 ? 'CANCELLED' : 'Unknown'} status`);
        }

        // Thực hiện cancel trên blockchain
        const result = await bookingChainRepo.cancelContractAndWait({ contractHash });

        // Lấy thông tin contract sau khi cancel
        const cancelledContract = await bookingChainRepo.getContract(contractHash);
        
        const checkinTimestamp = Number(cancelledContract.checkin);
        const checkoutTimestamp = Number(cancelledContract.checkout);
        const createdTimestamp = Number(cancelledContract.timestamp);
        
        return {
            ...result,
            contractInfo: {
                checkinDate: new Date(checkinTimestamp * 1000).toISOString(),
                checkoutDate: new Date(checkoutTimestamp * 1000).toISOString(),
                createdAt: new Date(createdTimestamp * 1000).toISOString(),
                statusText: cancelledContract.status === 0 ? 'PAID' : 'CANCELLED',
                isValid: cancelledContract.isValid
            }
        };
    }
};