"use client";
import { auth } from "@/lib/firebase/config";
import { onAuthStateChanged } from "firebase/auth";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function HomePage() {
  const router = useRouter();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        // Đã đăng nhập -> chuyển đến /admin
        router.push("/admin");
      } else {
        // Chưa đăng nhập -> chuyển đến trang login
        router.push("/auth/login");
      }
    });

    return () => unsubscribe();
  }, [router]);

  return (
    <div style={{ 
      display: "flex", 
      justifyContent: "center", 
      alignItems: "center", 
      minHeight: "100vh" 
    }}>
      <p>Đang kiểm tra trạng thái đăng nhập...</p>
    </div>
  );
}
