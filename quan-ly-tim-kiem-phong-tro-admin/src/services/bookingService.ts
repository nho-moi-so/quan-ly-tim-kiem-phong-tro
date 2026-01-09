import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { ContractRepository } from "@/repositories/contractRepository";
import { UserRepository } from "@/repositories/userRepository";

export interface BookingData {
  booking_id: string;
  owner_name: string;
  owner_phone: string;
  guest_name: string;
  guest_phone: string;
  checkin: string;
  checkout: string;
  price: string;
  status: string;
  room_name: string;
  transaction_hash?: string;
}

export class BookingService {
  static async getAllBookings(): Promise<BookingData[]> {
    try {
      // Get all contracts
      const contracts = await ContractRepository.getAll();
      const bookings: BookingData[] = [];

      for (const contract of contracts) {
        try {
          // Get apartment info from ApartmentId
          const apartment = contract.ApartmentId
            ? await ApartmentRepository.getById(contract.ApartmentId)
            : null;

          if (!apartment) {
            console.warn(`Apartment not found for contract ${contract.Id}`);
            continue;
          }

          // Get owner info from apartment UserID
          const owner = apartment.UserID
            ? await UserRepository.getById(apartment.UserID)
            : null;

          // Get guest info from contract UserID
          const guest = contract.UserID
            ? await UserRepository.getById(contract.UserID)
            : null;

          if (!owner || !guest) {
            console.warn(
              `Owner or guest not found for contract ${contract.Id}`
            );
            continue;
          }

          // Format StartDate and EndDate
          const startDate = contract.StartDate
            ? typeof contract.StartDate.toDate === 'function'
              ? new Date(contract.StartDate.toDate()).toISOString()
              : new Date(contract.StartDate as any).toISOString()
            : "";
          const endDate = contract.EndDate
            ? typeof contract.EndDate.toDate === 'function'
              ? new Date(contract.EndDate.toDate()).toISOString()
              : new Date(contract.EndDate as any).toISOString()
            : "";

          const booking: BookingData = {
            booking_id: contract.Id,
            owner_name: owner.Fullname || "",
            owner_phone: owner.Phone || "",
            guest_name: guest.Fullname || "",
            guest_phone: guest.Phone || "",
            checkin: startDate,
            checkout: endDate,
            price: contract.Total || "0",
            status: contract.Status ? contract.Status.toLowerCase() : "pending",
            room_name: apartment.Address || "",
            transaction_hash: contract.Id, // Using contract ID as transaction hash
          };

          bookings.push(booking);
        } catch (error) {
          console.error(`Error processing contract ${contract.Id}:`, error);
          continue;
        }
      }

      return bookings;
    } catch (error) {
      console.error("Error getting all bookings:", error);
      throw error;
    }
  }

  static async getBookingsLimit(limit: number): Promise<BookingData[]> {
    try {
      // Get all contracts
      const contracts = await ContractRepository.getAll();
      const bookings: BookingData[] = [];

      for (const contract of contracts) {
        if (bookings.length >= limit) {
          break;
        }

        try {
          // Get apartment info from ApartmentId
          const apartment = contract.ApartmentId
            ? await ApartmentRepository.getById(contract.ApartmentId)
            : null;

          if (!apartment) {
            console.warn(`Apartment not found for contract ${contract.Id}`);
            continue;
          }

          // Get owner info from apartment UserID
          const owner = apartment.UserID
            ? await UserRepository.getById(apartment.UserID)
            : null;

          // Get guest info from contract UserID
          const guest = contract.UserID
            ? await UserRepository.getById(contract.UserID)
            : null;

          if (!owner || !guest) {
            console.warn(
              `Owner or guest not found for contract ${contract.Id}`
            );
            continue;
          }

          // Format StartDate and EndDate
          const startDate = contract.StartDate
            ? typeof contract.StartDate.toDate === 'function'
              ? new Date(contract.StartDate.toDate()).toISOString()
              : new Date(contract.StartDate as any).toISOString()
            : "";
          const endDate = contract.EndDate
            ? typeof contract.EndDate.toDate === 'function'
              ? new Date(contract.EndDate.toDate()).toISOString()
              : new Date(contract.EndDate as any).toISOString()
            : "";

          const booking: BookingData = {
            booking_id: contract.Id,
            owner_name: owner.Fullname || "",
            owner_phone: owner.Phone || "",
            guest_name: guest.Fullname || "",
            guest_phone: guest.Phone || "",
            checkin: startDate,
            checkout: endDate,
            price: contract.Total || "0",
            status: contract.Status ? contract.Status.toLowerCase() : "pending",
            room_name: apartment.Address || "",
            transaction_hash: contract.Id, // Using contract ID as transaction hash
          };

          bookings.push(booking);
        } catch (error) {
          console.error(`Error processing contract ${contract.Id}:`, error);
          continue;
        }
      }

      return bookings;
    } catch (error) {
      console.error("Error getting bookings with limit:", error);
      throw error;
    }
  }
}
