import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { ContractRepository } from "@/repositories/contractRepository";
import { UserRepository } from "@/repositories/userRepository";
import { bookingChainService } from "./bookingChainService";
import { UserService } from "./userService";

export interface BookingData {
  booking_id: string;
  owner_name: string;
  owner_phone: string;
  owner_email: string;
  guest_name: string;
  guest_phone: string;
  guest_email: string;
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
            owner_email: owner.Email || "",
            guest_name: guest.Fullname || "",
            guest_phone: guest.Phone || "",
            guest_email: guest.Email || "",
            checkin: startDate,
            checkout: endDate,
            price: contract.Total || "0",
            status: contract.Status ? contract.Status.toLowerCase() : "pending",
            room_name: apartment.CodeApartment || "",
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
            owner_email: owner.Email || "",
            guest_name: guest.Fullname || "",
            guest_phone: guest.Phone || "",
            guest_email: guest.Email || "",
            checkin: startDate,
            checkout: endDate,
            price: contract.Total || "0",
            status: contract.Status ? contract.Status.toLowerCase() : "pending",
            room_name: apartment.CodeApartment || "",
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

  /**
   * Verify booking blockchain integrity with provided data
   */
  static async verifyBookingWithBlockchain(payload: {
    booking_id: string;
    owner_email?: string;
    guest_email?: string;
    checkin?: string; // ISO string
    checkout?: string; // ISO string
    price?: number; // VND amount
    room_name?: string;
    transaction_hash?: string;
  }): Promise<{ success: boolean; result?: { isValid: boolean } }>{
    try {
      const { booking_id, owner_email, guest_email, checkin, checkout, price, room_name, transaction_hash } = payload;
      // console.log('dau vao:', {
      //   booking_id,
      //   owner_email,
      //   guest_email,
      //   checkin,
      //   checkout,
      //   price,
      //   room_name,
      //   transaction_hash,
      // });
      if(!owner_email){
        throw new Error('Email của chủ nhà là bắt buộc');
      }
      const owner = await UserService.getUserByEmail(owner_email);
      if(owner === null){
        throw new Error('Email cung cấp chủ nhà không được tìm thấy');
      }
      // console.log('owner tim thay:', await owner);
      if(!guest_email){
        throw new Error('Email của khách là bắt buộc');
      }
      const guest = await UserService.getUserByEmail(guest_email);
      if(guest === null){
        throw new Error('Email cung cấp khách không được tìm thấy');
      }
      if(!room_name){
        throw new Error('Tên phòng là bắt buộc');
      }
      const apartment = await ApartmentRepository.getByRoomCode(room_name);
      if(apartment === null){
        throw new Error('Không tìm thấy căn hộ với tên phòng đã cho');
      }
      const password = apartment.Password;
      if(password === null || password === undefined){
        throw new Error('Mật khẩu căn hộ không được tìm thấy');
      }
      //chuan bi du lieu
      const preparedBookingId = booking_id.trim();
      const preparedApartmentId = apartment.Id;
      const preparedPrice = price;
      const preparedOwnerId = owner.userId;
      const preparedGuestId = guest.userId;
      const preparedCheckin = checkin;
      const preparedCheckout = checkout;
      const preparedPassword = password;

        // console.log('chuan bi data cho hash', {
        //   preparedBookingId,
        //   preparedApartmentId,
        //   preparedPrice,
        //   preparedOwnerId,
        //   preparedGuestId,
        //   preparedCheckin,
        //   preparedCheckout,
        //   preparedPassword,
        // });
      
      //call api hash
      const result = await bookingChainService.createBookingHash({
        bookingId: preparedBookingId,
        apartmentId: preparedApartmentId,
        price: preparedPrice!,
        ownerId: preparedOwnerId,
        guestId: preparedGuestId,
        password: preparedPassword,
      })
      // console.log(result);
      //call api verify
      try {
        const verifyResult = await bookingChainService.verifyBookingOnChain(
          result
        );
        if(!verifyResult["verified"]){
          return { success: true, result: { isValid: false } };
        }
        // console.log(verifyResult["contractInfo"]["checkinDate"] == preparedCheckin);
        // console.log(verifyResult["contractInfo"]["checkoutDate"] == preparedCheckout);
        if(verifyResult["verified"] && verifyResult["contractInfo"]["checkinDate"] == preparedCheckin && verifyResult["contractInfo"]["checkoutDate"] == preparedCheckout){
          return { success: true, result: { isValid: true } };
        }else{
          return { success: true, result: { isValid: false } };
        }
    } catch (error) {
      console.error('Error during booking verification on chain:', error);
      throw error;
    }
    } catch (error) {
      console.error('Error verifying booking:', error);
      throw error;
    }
  }
}
