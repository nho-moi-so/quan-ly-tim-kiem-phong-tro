import { ApartmentRepository } from "@/repositories/apartmentRepository";

export const IOTService = {
    //== nữa sẽ đem password về booking request
    verifyPassword: async (password: string, roomCode: string) => {
        //tiim apartment theo roomCode
        const apartment = await ApartmentRepository.getByRoomCode(roomCode);
        if (!apartment) {
            return {
                status: "fail",
                message: "Invalid room code"
            };
        }
        if (apartment.Password !== password) {
            return {
                status: "fail",
                message: "Incorrect password"
            };
        }
        return {
            status: "success",
            message: "Password verified successfully"
        };

    }
}