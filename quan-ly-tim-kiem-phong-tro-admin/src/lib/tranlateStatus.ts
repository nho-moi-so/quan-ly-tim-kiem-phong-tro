export const tranlateStatus = {
        tranlateToVietnameseStatusPost: (status: string): string => {
            switch (status.toLowerCase()) {
                case 'pending':
                    return 'Đang chờ duyệt';
                case 'approved':
                    return 'Đã duyệt';
                case 'rejected':
                    return 'Đã từ chối';
                case 'hidden':
                    return 'Đã ẩn';
                default:
                    return status;
            }
        },
        tranlateToVietnameseStatusIoT: (status: string): string => {
            switch (status.toLowerCase()) {
                case 'verified':
                    return 'Đã kết nối';
                case 'pending':
                    return 'Đang chờ kết nối';
                default:
                    return status;
            }
        },

        tranlateToVietnameseStatusBooking: (status: string): string => {
            switch (status.toLowerCase()) {
                case 'created':
                    return 'Đã đặt & thanh toán';
                case 'active':
                    return 'Đang lưu trú';
                case 'completed':
                    return 'Đã hoàn thành';
                case 'cancelled':
                    return 'Đã hủy';
                default:
                    return status;
            }
        },
}