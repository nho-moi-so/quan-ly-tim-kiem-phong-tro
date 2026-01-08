"use client";
import { Card, Space, Typography } from "antd";
import Link from "next/link";

export default function QuanLyThietBiIoTPage() {
  return (
    <div style={{ padding: 16 }}>
      <Typography.Title level={3}>Quản Lý Thiết Bị IoT</Typography.Title>
      <Typography.Paragraph>Chọn một mục để quản lý.</Typography.Paragraph>
      <Space direction="vertical" size="large" style={{ width: "100%", marginTop: 24 }}>
        <Card
          title="Thiết bị đã kết nối"
          extra={<Link href="/admin/quan-ly-thiet-bi-iot/thiet-bi-da-ket-noi">Mở</Link>}
          hoverable
        >
          Xem danh sách thiết bị IoT đã kết nối với các căn hộ, kiểm tra trạng thái và xóa thiết bị.
        </Card>
        <Card
          title="Loại thiết bị được hỗ trợ"
          extra={<Link href="/admin/quan-ly-thiet-bi-iot/loai-thiet-bi">Mở</Link>}
          hoverable
        >
          Quản lý danh sách các loại thiết bị IoT mà hệ thống hỗ trợ, thêm mới loại thiết bị với ID, tên và mô tả.
        </Card>
      </Space>
    </div>
  );
}
