"use client";

import { Card, Space, Typography } from "antd";
import Link from "next/link";

const { Title, Paragraph } = Typography;

export default function QuanLyGiaoDichPage() {
  return (
    <Space direction="vertical" size={20} style={{ width: "100%" }}>
      <div>
        <Title level={3} style={{ marginBottom: 8 }}>
          Quản lý giao dịch
        </Title>
        <Paragraph type="secondary" style={{ marginBottom: 0 }}>
          Chọn trang con để theo dõi và quản trị giao dịch trong hệ thống.
        </Paragraph>
      </div>

      <Card title="Danh sách trang con" bordered>
        <Space direction="vertical" size={8}>
          <Link href="/admin/quan-ly-giao-dich/lich-su-giao-dich">Lịch sử giao dịch</Link>
          <Link href="/admin/quan-ly-giao-dich/yeu-cau-rut-tien">Yêu cầu rút tiền</Link>
        </Space>
      </Card>
    </Space>
  );
}