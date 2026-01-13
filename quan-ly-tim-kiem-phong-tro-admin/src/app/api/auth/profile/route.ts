import { UserService } from "@/services/userService";
import admin from "firebase-admin";
import { NextResponse } from "next/server";

/**
 * GET /api/auth/profile
 * Get current admin profile
 */
export const GET = async (request: Request) => {
    try {
        // Get ID token from Authorization header
        const authHeader = request.headers.get("Authorization");

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return NextResponse.json({
                status: "fail",
                message: "Token không hợp lệ"
            }, { status: 401 });
        }

        const idToken = authHeader.split("Bearer ")[1];

        // Verify ID token with Firebase Admin
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const email = decodedToken.email;

        if (!email) {
            return NextResponse.json({
                status: "fail",
                message: "Email không tồn tại"
            }, { status: 400 });
        }

        // Get user info from Firestore
        const user = await UserService.getAdminByEmail(email);

        if (!user) {
            return NextResponse.json({
                status: "fail",
                message: "Tài khoản không tồn tại trong hệ thống"
            }, { status: 404 });
        }

        return NextResponse.json({
            status: "success",
            data: user
        });
    } catch (err: any) {
        console.error("Get profile error:", err);

        if (err.code === "auth/id-token-expired") {
            return NextResponse.json({
                status: "fail",
                message: "Phiên đăng nhập đã hết hạn"
            }, { status: 401 });
        }

        return NextResponse.json({
            status: "fail",
            message: err.message || "Lấy thông tin thất bại"
        }, { status: 500 });
    }
};

/**
 * PUT /api/auth/profile
 * Update admin profile
 */
export const PUT = async (request: Request) => {
    try {
        // Get ID token from Authorization header
        const authHeader = request.headers.get("Authorization");

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return NextResponse.json({
                status: "fail",
                message: "Token không hợp lệ"
            }, { status: 401 });
        }

        const idToken = authHeader.split("Bearer ")[1];

        // Verify ID token with Firebase Admin
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const email = decodedToken.email;

        if (!email) {
            return NextResponse.json({
                status: "fail",
                message: "Email không tồn tại"
            }, { status: 400 });
        }

        // Get user info from Firestore
        const user = await UserService.getAdminByEmail(email);

        if (!user) {
            return NextResponse.json({
                status: "fail",
                message: "Tài khoản không tồn tại trong hệ thống"
            }, { status: 404 });
        }

        // Get update data from request body
        const body = await request.json();
        const { fullName, phone } = body;

        // Update user profile
        const updatedUser = await UserService.updateAdminProfile(user.userId, {
            fullName,
            phone
        });

        return NextResponse.json({
            status: "success",
            data: updatedUser,
            message: "Cập nhật thông tin thành công"
        });
    } catch (err: any) {
        console.error("Update profile error:", err);

        if (err.code === "auth/id-token-expired") {
            return NextResponse.json({
                status: "fail",
                message: "Phiên đăng nhập đã hết hạn"
            }, { status: 401 });
        }

        return NextResponse.json({
            status: "fail",
            message: err.message || "Cập nhật thất bại"
        }, { status: 500 });
    }
};
