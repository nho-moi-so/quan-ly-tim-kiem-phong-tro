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
                status: owner.OwnerStatus ?? "active",
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
            status: user.OwnerStatus ?? "active",
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
        const updated = await UserRepository.update(ownerId, { OwnerStatus: 'locked' });
        return { userCode: updated.Id, status: updated.OwnerStatus ?? 'locked' };
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
        const updated = await UserRepository.update(ownerId, { OwnerStatus: 'active' });
        return { userCode: updated.Id, status: updated.OwnerStatus ?? 'active' };
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
    }
};