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
        const user = await UserRepository.getById(ownerId);
        if (!user || user.Role !== 'owner') {
            throw new Error('Owner not found');
        }
        const updated = await UserRepository.update(ownerId, { Status: 'APPROVED' });
        return { userCode: updated.Id, status: updated.Status.toUpperCase() ?? 'APPROVED' };
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