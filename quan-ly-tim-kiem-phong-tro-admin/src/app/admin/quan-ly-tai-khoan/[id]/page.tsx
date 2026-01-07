"use client";
import { UserOutlined } from "@ant-design/icons";
import type { DescriptionsProps } from "antd";
import { Avatar, Card, Descriptions, Spin, message } from "antd";
import { useParams, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";

interface UserDetail {
  userCode: string;
  fullName: string;
  email: string;
  phone: string;
  status: string;
  registeredAt: string;
}

export default function Page() {
  const { id } = useParams<{ id: string }>();
  const searchParams = useSearchParams();
  const type = searchParams.get('type'); // 'owner' or 'guest'
  
  const [data, setData] = useState<UserDetail | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      if (!id || !type) {
        message.error("Thiếu thông tin tài khoản");
        setLoading(false);
        return;
      }

      try {
        const apiUrl = type === 'owner' 
          ? `/api/users/owners/${id}`
          : `/api/users/guests/${id}`;
          
        const response = await fetch(apiUrl);
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        
        if (result.status === "success" && result.data) {
          setData(result.data);
        } else {
          message.error("Không thể tải thông tin tài khoản");
        }
      } catch (error) {
        console.error("Error fetching user detail:", error);
        message.error("Lỗi khi tải dữ liệu");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id, type]);

  if (loading) {
    return (
      <div style={{ padding: 24, textAlign: "center" }}>
        <Spin size="large" tip="Đang tải dữ liệu..." />
      </div>
    );
  }

  if (!data) {
    return (
      <div style={{ padding: 24, textAlign: "center" }}>
        <p>Không tìm thấy thông tin tài khoản</p>
      </div>
    );
  }

  const items: DescriptionsProps["items"] = [
    {
      key: "1",
      label: "Mã tài khoản",
      children: data.userCode,
    },
    {
      key: "2",
      label: "Họ và tên",
      children: data.fullName,
    },
    {
      key: "3",
      label: "Email",
      children: data.email,
    },
    {
      key: "4",
      label: "Số điện thoại",
      children: data.phone,
    },
    {
      key: "5",
      label: "Trạng thái",
      children: data.status,
    },
    {
      key: "6",
      label: "Ngày đăng ký",
      children: data.registeredAt,
    },
  ];

  return (
    <div style={{ padding: 24 }}>
      <h2 style={{ textAlign: "center", marginBottom: 24 }}>
        Thông Tin Tài Khoản {type === 'owner' ? 'Chủ căn hộ' : 'Khách thuê'}
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
            icon={<UserOutlined />}
          />
          <div>
            <h3 style={{ margin: 0 }}>{data.fullName}</h3>
            <p style={{ margin: 0, color: "gray" }}>{data.email}</p>
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
