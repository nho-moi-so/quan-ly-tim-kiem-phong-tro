"use client";
import React from "react";
import {
  Form,
  Input,
  Button,
  Checkbox,
  Row,
  Col,
  Typography,
  Card,
} from "antd";
import type { FormProps } from "antd";
const { Title, Text } = Typography;

type FieldType = {
  username?: string;
  password?: string;
  remember?: boolean;
};

const onFinish: FormProps<FieldType>["onFinish"] = (values) => {
  console.log("Đăng nhập thành công:", values);
};

const onFinishFailed: FormProps<FieldType>["onFinishFailed"] = (errorInfo) => {
  console.log("Lỗi đăng nhập:", errorInfo);
};

const LoginForm: React.FC = () => (
  <Row
    justify="center"
    align="middle"
    style={{ minHeight: "100vh", width: "100%", backgroundColor: "#f0f2f5" }}
  >
    <Col xs={24} sm={20} md={18} lg={16}>
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
            label="Tài khoản"
            name="username"
            rules={[{ required: true, message: "Vui lòng nhập tài khoản!" }]}
          >
            <Input placeholder="Nhập tên đăng nhập" />
          </Form.Item>

          <Form.Item<FieldType>
            label="Mật khẩu"
            name="password"
            rules={[{ required: true, message: "Vui lòng nhập mật khẩu!" }]}
          >
            <Input.Password placeholder="Nhập mật khẩu" />
          </Form.Item>

          <Form.Item<FieldType>
            name="remember"
            valuePropName="checked"
          >
            <Checkbox>Ghi nhớ đăng nhập</Checkbox>
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" block>
              Đăng nhập
            </Button>
          </Form.Item>

          <div style={{ textAlign: "center" }}>
            <a href="#">Quên mật khẩu?</a> |{" "}
            <a href="#">Đăng ký tài khoản mới</a>
          </div>
        </Form>
      </Card>
    </Col>
  </Row>
);

export default function LoginPage() {
  return <LoginForm />;
}
