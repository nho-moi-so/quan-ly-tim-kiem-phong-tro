"use client";
import { auth } from "@/lib/firebase/config";
import type { FormProps } from "antd";
import { Button, Card, Checkbox, Form, Input, Typography, message } from "antd";
import { signInWithEmailAndPassword } from "firebase/auth";
import { useRouter } from "next/navigation";
import React, { useState } from "react";

interface LoginFormProps {
  // Add your props here
}

type FieldType = {
  email?: string;
  password?: string;
  remember?: boolean;
};

const { Title, Text } = Typography;

export const LoginForm: React.FC<LoginFormProps> = (props) => {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const onFinish: FormProps<FieldType>["onFinish"] = async (values) => {
    setLoading(true);
    try {
      // Sign in with Firebase Authentication
      const userCredential = await signInWithEmailAndPassword(
        auth,
        values.email!,
        values.password!
      );

      const user = userCredential.user;

      // Get ID token to verify on server
      const idToken = await user.getIdToken();

      // Call API to verify user role and get additional info
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${idToken}`
        },
      });

      const result = await response.json();

      if (result.status === "success") {
        message.success("Đăng nhập thành công!");
        
        // Store user info in localStorage
        if (typeof window !== "undefined") {
          localStorage.setItem("user", JSON.stringify(result.data));
          localStorage.setItem("idToken", idToken);
        }

        // Redirect to admin dashboard
        router.push("/admin");
      } else {
        message.error(result.message || "Đăng nhập thất bại");
        // Sign out if role check fails
        await auth.signOut();
      }
    } catch (error: any) {
      console.error("Lỗi đăng nhập:", error);
      
      // Handle Firebase Auth errors
      if (error.code === "auth/invalid-credential") {
        message.error("Email hoặc mật khẩu không chính xác");
      } else if (error.code === "auth/user-not-found") {
        message.error("Tài khoản không tồn tại");
      } else if (error.code === "auth/wrong-password") {
        message.error("Mật khẩu không chính xác");
      } else if (error.code === "auth/too-many-requests") {
        message.error("Quá nhiều lần đăng nhập thất bại. Vui lòng thử lại sau");
      } else {
        message.error("Có lỗi xảy ra khi đăng nhập");
      }
    } finally {
      setLoading(false);
    }
  };

  const onFinishFailed: FormProps<FieldType>["onFinishFailed"] = (
    errorInfo
  ) => {
    console.log("Lỗi đăng nhập:", errorInfo);
  };

  return (
    <Card
      style={{
        width: "750px",
        maxWidth: "100%",
        margin: "0 auto",
        borderRadius: "16px",
        boxShadow: "0 4px 12px rgba(0,0,0,0.1)",
        padding: "45px 15px",
      }}
    >
      <div style={{ textAlign: "center", marginBottom: 24 }}>
        {/* <img
            src="/login-image.png"
            alt="Login Illustration"
            style={{ width: "120px", marginBottom: "16px" }}
          /> */}
        <Title level={3}>Đăng nhập</Title>
        <Text type="secondary">Chào mừng bạn quay lại!</Text>
      </div>

      <Form
        name="login"
        layout="vertical"
        initialValues={{ remember: true }}
        onFinish={onFinish}
        onFinishFailed={onFinishFailed}
        autoComplete="off"
      >
        <Form.Item<FieldType>
          label="Email"
          name="email"
          rules={[
            { required: true, message: "Vui lòng nhập email!" },
            { type: "email", message: "Email không hợp lệ!" }
          ]}
        >
          <Input placeholder="Nhập email" />
        </Form.Item>

        <Form.Item<FieldType>
          label="Mật khẩu"
          name="password"
          rules={[{ required: true, message: "Vui lòng nhập mật khẩu!" }]}
        >
          <Input.Password placeholder="Nhập mật khẩu" />
        </Form.Item>

        <Form.Item<FieldType> name="remember" valuePropName="checked">
          <Checkbox>Ghi nhớ đăng nhập</Checkbox>
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit" block loading={loading}>
            Đăng nhập
          </Button>
        </Form.Item>
      </Form>
    </Card>
  );
};

export default LoginForm;
