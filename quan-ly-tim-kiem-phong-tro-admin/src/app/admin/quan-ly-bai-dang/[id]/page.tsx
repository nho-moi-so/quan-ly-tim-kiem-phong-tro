"use client";
import { formatId } from "@/lib/formatId";
import type { DescriptionsProps } from "antd";
import { Badge, Card, Descriptions, Image, message, Spin } from "antd";
import { useParams } from "next/navigation";
import { useEffect, useState } from "react";

interface PostDetail {
  codePost: string;
  roomNumber: string;
  location: string;
  area: string;
  dailyRate: number;
  address: string;
  publishDate: string;
  status: string;
  description: string;
  imgPath: string[];
}

export default function Page() {
  const { id } = useParams<{ id: string }>();
  const [data, setData] = useState<PostDetail | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const response = await fetch(`/api/posts/${id}`);
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        
        if (result.status === "success" && result.data) {
          setData(result.data);
        } else {
          message.error("Không thể tải chi tiết bài đăng");
        }
      } catch (error) {
        console.error("Error fetching post detail:", error);
        message.error("Lỗi khi tải dữ liệu");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchData();
    }
  }, [id]);

  // Format currency
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(amount);
  };

  // Get badge status
  const getStatusBadge = (status: string) => {
    const lowerStatus = (status || '').toLowerCase();
    const statusMap: { [key: string]: { status: any; text: string } } = {
      approved: { status: "success", text: "Đã duyệt" },
      pending: { status: "processing", text: "Chờ duyệt" },
      rejected: { status: "error", text: "Bị từ chối" },
      hidden: { status: "default", text: "Đã ẩn" },
    };
    
    const statusInfo = statusMap[lowerStatus] || { status: "default", text: status };
    return <Badge status={statusInfo.status} text={statusInfo.text} />;
  };

  if (loading) {
    return (
      <div style={{ padding: 24, textAlign: "center" }}>
        <Spin size="large" />
      </div>
    );
  }

  if (!data) {
    return (
      <div style={{ padding: 24, textAlign: "center" }}>
        <p>Không tìm thấy bài đăng</p>
      </div>
    );
  }

  const items: DescriptionsProps["items"] = [
    {
      key: "1",
      label: "Mã bài đăng",
      children: data.codePost,
    },
    {
      key: "2",
      label: "Phòng",
      children: data.roomNumber,
    },
    {
      key: "3",
      label: "Giá thuê",
      children: formatCurrency(data.dailyRate),
    },
    {
      key: "4",
      label: "Địa chỉ",
      span: 2,
      children: data.address,
    },
    {
      key: "5",
      label: "Ngày đăng",
      children: data.publishDate,
    },
    {
      key: "6",
      label: "Trạng thái",
      children: getStatusBadge(data.status),
    },
    {
      key: "7",
      label: "Mô tả chi tiết",
      span: 3,
      children: data.description,
    },
  ];

  return (
    <div style={{ padding: 24 }}>
      <h2 style={{ textAlign: "center", marginBottom: 24 }}>
        Chi Tiết Bài Đăng #{formatId.formatPostId(data.codePost)}
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
        {data.imgPath && data.imgPath.length > 0 ? (
          <Image.PreviewGroup>
            {data.imgPath.map((img, index) => (
              <Image
                key={index}
                width={200}
                src={img}
                alt={`Hình ${index + 1}`}
                style={{ marginRight: 8, marginBottom: 8 }}
              />
            ))}
          </Image.PreviewGroup>
        ) : (
          <p>Không có hình ảnh</p>
        )}
      </Card>
    </div>
  );
}
