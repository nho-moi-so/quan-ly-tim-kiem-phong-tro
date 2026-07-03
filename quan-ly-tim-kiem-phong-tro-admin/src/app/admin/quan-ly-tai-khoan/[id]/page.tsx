"use client";

import { 
  UserOutlined, 
  MailOutlined, 
  PhoneOutlined, 
  IdcardOutlined, 
  CalendarOutlined,
  CheckCircleOutlined,
  StopOutlined,
  ClockCircleOutlined
} from "@ant-design/icons";
import { Avatar, Card, Descriptions, Spin, message, Tag, Divider, Typography, Space } from "antd";
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

const getStatusTag = (status: string) => {
  const statusLower = status?.toLowerCase();
  switch (statusLower) {
    case 'active':
      return <Tag icon={<CheckCircleOutlined />} color="success" style={{ padding: '4px 10px', fontSize: 14 }}>Hoạt động</Tag>;
    case 'approved':
      return <Tag icon={<CheckCircleOutlined />} color="processing" style={{ padding: '4px 10px', fontSize: 14 }}>Đã duyệt</Tag>;
    case 'pending':
      return <Tag icon={<ClockCircleOutlined />} color="warning" style={{ padding: '4px 10px', fontSize: 14 }}>Chờ duyệt</Tag>;
    case 'locked':
      return <Tag icon={<StopOutlined />} color="error" style={{ padding: '4px 10px', fontSize: 14 }}>Bị khóa</Tag>;
    default:
      return <Tag color="default" style={{ padding: '4px 10px', fontSize: 14 }}>{status}</Tag>;
  }
};

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
      <div style={{ padding: 100, display: "flex", justifyContent: "center", alignItems: "center" }}>
        <Spin size="large" tip="Đang tải dữ liệu..." />
      </div>
    );
  }

  if (!data) {
    return (
      <div style={{ padding: 100, textAlign: "center" }}>
        <Typography.Text type="secondary" style={{ fontSize: 18 }}>Không tìm thấy thông tin tài khoản</Typography.Text>
      </div>
    );
  }

  return (
    <div style={{ padding: "24px", minHeight: "100%" }}>
      <Typography.Title level={2} style={{ textAlign: "center", marginBottom: 32, color: "#1f1f1f" }}>
        Thông Tin Tài Khoản {type === 'owner' ? 'Chủ Căn Hộ' : 'Khách Thuê'}
      </Typography.Title>

      <Card 
        bordered={false}
        style={{ 
          maxWidth: 750, 
          margin: "0 auto", 
          borderRadius: 20, 
          overflow: "hidden", 
          boxShadow: "0 10px 40px rgba(0,0,0,0.08)" 
        }}
        styles={{ body: { padding: 0 } }}
      >
        {/* Banner Gradient */}
        <div style={{ 
          height: 160, 
          background: "linear-gradient(135deg, #0052D4 0%, #4364F7 50%, #6FB1FC 100%)",
        }} />

        {/* Profile Info */}
        <div style={{ padding: "0 40px 40px", position: "relative" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginTop: -60, marginBottom: 24 }}>
            <Avatar
              size={120}
              icon={<UserOutlined />}
              style={{ 
                border: "5px solid white", 
                backgroundColor: "#f0f2f5",
                color: "#1890ff",
                boxShadow: "0 4px 12px rgba(0,0,0,0.15)"
              }}
            />
            <div style={{ marginBottom: 12 }}>
              {getStatusTag(data.status)}
            </div>
          </div>

          <Typography.Title level={3} style={{ margin: 0, fontWeight: 700 }}>
            {data.fullName}
          </Typography.Title>
          <Typography.Text type="secondary" style={{ fontSize: 16 }}>
            {data.email}
          </Typography.Text>

          <Divider style={{ margin: "32px 0" }} />

          <Typography.Title level={4} style={{ marginBottom: 24 }}>
            Thông tin chi tiết
          </Typography.Title>

          <Descriptions
            column={{ xxl: 2, xl: 2, lg: 2, md: 1, sm: 1, xs: 1 }}
            labelStyle={{ fontWeight: 500, color: "#8c8c8c", fontSize: 15 }}
            contentStyle={{ fontWeight: 600, color: "#262626", fontSize: 15 }}
          >
            <Descriptions.Item label={<Space><IdcardOutlined style={{ color: "#1890ff" }} />Mã tài khoản</Space>}>
              {data.userCode}
            </Descriptions.Item>
            <Descriptions.Item label={<Space><MailOutlined style={{ color: "#1890ff" }} />Email</Space>}>
              {data.email}
            </Descriptions.Item>
            <Descriptions.Item label={<Space><PhoneOutlined style={{ color: "#1890ff" }} />Số điện thoại</Space>}>
              {data.phone || "Chưa cập nhật"}
            </Descriptions.Item>
            <Descriptions.Item label={<Space><CalendarOutlined style={{ color: "#1890ff" }} />Ngày đăng ký</Space>}>
              {data.registeredAt}
            </Descriptions.Item>
          </Descriptions>
        </div>
      </Card>
    </div>
  );
}
