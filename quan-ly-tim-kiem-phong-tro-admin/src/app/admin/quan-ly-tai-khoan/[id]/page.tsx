"use client";
import React, { useEffect, useState } from "react";
import { Card, Descriptions, Avatar, Spin, message } from "antd";
import type { DescriptionsProps } from "antd";
import { UserOutlined } from "@ant-design/icons";
import { useParams } from "next/navigation";
export default function Page() {
  const { id } = useParams<{ id: string }>();
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  console.log("Mã tài khoản: ", id);
  const items: DescriptionsProps["items"] = [
    {
      key: "1",
      label: "Mã tài khoản",
      children: "TK001",
    },
    {
      key: "2",
      label: "Họ và tên",
      children: "Ngọc Ngọc",
    },
    {
      key: "3",
      label: "Email",
      children: "ngocngoc310@gmail.com",
    },
    {
      key: "4",
      label: "Số điện thoại",
      children: "0866907310",
    },
    {
      key: "5",
      label: "Ngày đăng ký",
      children: "2025-2-10-16",
    },
  ];
  useEffect(() => {
    const fetchData = async () => {
      try {
        // TODO: update api
        const response = await fetch("/api/chi-tiet-tai-khoan");
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const result = await response.json();
        setData(result);
      } catch (error) {
        setError(error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) return <p>Loading</p>;
  // if (error) return <p>Error</p>;
 return (
    <div style={{ padding: 24 }}>
      <h2 style={{ textAlign: "center", marginBottom: 24 }}>
        Thông Tin Tài Khoản
      </h2>

      <Card bordered style={{ maxWidth: 800, margin: "0 auto" }}>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 20,
            marginBottom: 20,
          }}
        >
          <Avatar
            size={100}
            src={data?.anhDaiDien}
            icon={!data?.anhDaiDien && <UserOutlined />}
          />
          <div>
            <h3 style={{ margin: 0 }}>{data?.hoTen}</h3>
            <p style={{ margin: 0, color: "gray" }}>{data?.email}</p>
          </div>
        </div>
        <Descriptions
          title="Thông tin chi tiết"
          bordered
          column={2}
          layout="vertical"
          items={items}
        />
      </Card>
    </div>
  );
}
