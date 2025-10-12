"use client";

import { Button, Space, Card } from "antd";

export default function Home() {
  return (
    <main style={{ padding: "50px" }}>
      <Card title="Next.js 15 + Ant Design">
        <Space direction="vertical" size="large">
          <h1>Chào mừng đến với Next.js 15</h1>
          <Button type="primary">Primary Button</Button>
          <Button>Default Button</Button>
          <Button danger>Danger Button</Button>
        </Space>
      </Card>
    </main>
  );
}
