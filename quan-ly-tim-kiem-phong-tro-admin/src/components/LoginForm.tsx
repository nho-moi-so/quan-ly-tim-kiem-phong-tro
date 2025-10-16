"use client";
import React from "react";
import { Form, Input, Button } from "antd";

const LoginForm: React.FC = () => {
  const onFinish = (values: any) => {
    console.log("Đăng nhập thành công:", values);
  };

  return (
    <Form name="login" onFinish={onFinish} layout="vertical">
      <h2 style={{ textAlign: "center", marginBottom: 24 }}>Đăng nhập</h2>

      <Form.Item
        label="Email"
        name="email"
        rules={[{ required: true, message: "Vui lòng nhập email!" }]}
      >
        <Input placeholder="Nhập email" />
      </Form.Item>

      <Form.Item
        label="Mật khẩu"
        name="password"
        rules={[{ required: true, message: "Vui lòng nhập mật khẩu!" }]}
      >
        <Input.Password placeholder="Nhập mật khẩu" />
      </Form.Item>

      <Form.Item>
        <Button
          type="primary"
          htmlType="submit"
          block
          style={{
            background: "linear-gradient(90deg, #007bff, #001f3f)",
            border: "none",
          }}
        >
          Đăng nhập
        </Button>
      </Form.Item>
    </Form>
  );
};

export default LoginForm;
