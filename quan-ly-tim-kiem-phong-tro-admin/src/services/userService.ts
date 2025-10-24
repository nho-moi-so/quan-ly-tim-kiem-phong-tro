import { UserRepository } from "@/repositories/userRepository";

export const UserService = {
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
                status: "Hoạt động", //== Hardcoded for now
                registeredAt: "2023-01-01" //== Hardcoded for now
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
            status: "Hoạt động", //== Hardcoded for now
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
                status: "Hoạt động", //== Hardcoded for now
                registeredAt: "2023-01-01" //== Hardcoded for now
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
            status: "Hoạt động", //== Hardcoded for now
            registeredAt: "2023-01-01" //== Hardcoded for now
        };
    }
};