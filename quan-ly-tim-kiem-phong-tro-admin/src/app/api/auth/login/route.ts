import { UserService } from "@/services/userService";
import admin from "firebase-admin";
import { NextResponse } from "next/server";

export const POST = async (request: Request) => {
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
        const uid = decodedToken.uid;
        const email = decodedToken.email;

        if (!email) {
            return NextResponse.json({
                status: "fail",
                message: "Email không tồn tại"
            }, { status: 400 });
        }

        // Get user info from Firestore to check role
        const user = await UserService.getUserByEmail(email);

        if (!user) {
            return NextResponse.json({
                status: "fail",
                message: "Tài khoản không tồn tại trong hệ thống"
            }, { status: 404 });
        }

        // Check if user is admin
        if (user.role !== 'admin') {
            return NextResponse.json({
                status: "fail",
                message: "Tài khoản không có quyền truy cập"
            }, { status: 403 });
        }

        return NextResponse.json({
            status: "success",
            data: {
                userId: user.userId,
                email: user.email,
                fullName: user.fullName,
                role: user.role
            }
        });
    } catch (err: any) {
        console.error("Login error:", err);
        
        if (err.code === "auth/id-token-expired") {
            return NextResponse.json({
                status: "fail",
                message: "Phiên đăng nhập đã hết hạn"
            }, { status: 401 });
        }
        
        return NextResponse.json({
            status: "fail",
            message: err.message || "Đăng nhập thất bại"
        }, { status: 401 });
    }
};
