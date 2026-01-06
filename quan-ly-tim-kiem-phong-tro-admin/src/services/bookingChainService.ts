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
        const toUnixSeconds = (value: Date | string | number) => {
            const dt = value instanceof Date ? value : new Date(value);
            if (Number.isNaN(dt.getTime())) {
                throw new Error("Invalid date provided for checkin/checkout");
            }
            return Math.floor(dt.getTime() / 1000);
        };

        const checkinSec = toUnixSeconds(params.checkin);
        const checkoutSec = toUnixSeconds(params.checkout);

        return bookingChainRepo.confirmContractAndWait({
            contractHash: params.contractHash,
            checkin: checkinSec,
            checkout: checkoutSec,
        });
        
    }
};