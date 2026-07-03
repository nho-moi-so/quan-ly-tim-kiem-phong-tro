import { BookingService } from "@/services/bookingService";
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  try {
    const bookings = await BookingService.getBookingsLimit();
    return NextResponse.json(
      {
        success: true,
        data: bookings,
        total: bookings.length,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error fetching bookings:", error);
    return NextResponse.json(
      {
        success: false,
        message: "Failed to fetch bookings",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const result = await BookingService.verifyBookingWithBlockchain(body);
    return NextResponse.json(
      result,
      { status: 200 }
    );
  } catch (error) {
    console.error("Error verifying booking:", error);
    return NextResponse.json(
      {
        success: false,
        message: `${error instanceof Error ? error.message : ""}`,
        error: error instanceof Error ? error.message : "Unknown error",
      },
      { status: 500 }
    );
  }
}
