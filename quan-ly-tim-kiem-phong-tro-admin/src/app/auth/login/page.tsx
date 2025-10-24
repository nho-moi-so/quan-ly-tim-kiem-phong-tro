"use client";
import React from "react";
import { Row, Col } from "antd";
import { LoginForm } from "@/components";

export default function LoginPage() {
  return (
    <Row
      justify="center"
      align="middle"
      style={{ minHeight: "100vh", width: "100%", backgroundColor: "#f0f2f5" }}
    >
      <Col xs={24} sm={20} md={18} lg={16}>
        <LoginForm />
      </Col>
    </Row>
  );
}
