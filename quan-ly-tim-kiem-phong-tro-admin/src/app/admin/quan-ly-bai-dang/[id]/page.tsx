"use client";
import React, { useEffect, useState } from "react";
import { Descriptions, Badge, Card, Image } from "antd";
import type { DescriptionsProps } from "antd";
import { useParams } from "next/navigation";

export default function Page() {
  const { id } = useParams<{ id: string }>();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  console.log("Mã bài đăng: ", id);

  const items: DescriptionsProps["items"] = [
    {
      key: "1",
      label: "Mã bài đăng",
      children: "BD01",
    },
    {
      key: "2",
      label: "Phòng",
      children: "403",
    },
    {
      key: "3",
      label: "Khu",
      children: "Tầng 4",
    },
    {
      key: "4",
      label: "Diện tích",
      children: "30m²",
    },
    {
      key: "5",
      label: "Giá thuê",
      children: "1.500.000 VND / tháng",
    },
    {
      key: "6",
      label: "Địa chỉ",
      span: 2,
      children: "Chung cư Nam Long, Hưng Thạnh, Cái Răng",
    },
    {
      key: "7",
      label: "Ngày đăng",
      children: "2025-10-16",
    },
    {
      key: "8",
      label: "Trạng thái",
      children: <Badge status="processing" text="Đang duyệt" />,
    },
    {
      key: "9",
      label: "Mô tả chi tiết",
      span: 3,
      children: (
        <>
          Phòng mới xây, nội thất đầy đủ, gần trung tâm, thuận tiện đi lại.
          <br />
          Bao nước, có chỗ để xe miễn phí.
          <br />
          Phù hợp cho sinh viên hoặc nhân viên văn phòng.
        </>
      ),
    },
  ];

  useEffect(() => {
    const fetchData = async () => {
      try {
        // TODO: update api
        const response = await fetch("/api/chi-tiet-bai-dang");
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
        Chi Tiết Bài Đăng #{id}
      </h2>

      {/* Thông tin bài đăng */}
      <Card bordered style={{ marginBottom: 24 }}>
        <Descriptions
          title="Thông tin bài đăng"
          bordered
          column={3}
          layout="vertical"
          items={items}
        />
      </Card>

      {/* Hình ảnh bài đăng */}
      <Card title="Hình ảnh bài đăng" bordered>
        <Image.PreviewGroup>
          <Image
            width={200}
            src="https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800"
          />
          <Image
            width={200}
            src="https://images.unsplash.com/photo-1560448075-bb485b067938?w=800"
          />
          <Image
            width={200}
            src="https://images.unsplash.com/photo-1616486701727-9bdb6b96e1b1?w=800"
          />
        </Image.PreviewGroup>
      </Card>
    </div>
  );
}
