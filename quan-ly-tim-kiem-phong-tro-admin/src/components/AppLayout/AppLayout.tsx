"use client";

import React, { ReactNode, useState } from "react";
import {
  AudioOutlined,
  AppstoreOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  UserOutlined,
  DashboardOutlined,
} from "@ant-design/icons";
import type { GetProps, MenuProps } from "antd";
import { Avatar, Input, Button, Layout, Menu, theme } from "antd";
import { useRouter } from "next/navigation";

type MenuItem = Required<MenuProps>["items"][number];
type SearchProps = GetProps<typeof Input.Search>;
const { Header, Sider, Content } = Layout;
const { Search } = Input;

// Avatar
const UserList = ["U", "Lucy", "Tom", "Edward"];
const ColorList = ["#f56a00", "#7265e6", "#ffbf00", "#00a2ae"];
const GapList = [4, 3, 2, 1];

const UserAvatar: React.FC = () => {
  const [user] = useState(UserList[0]);
  const [color] = useState(ColorList[0]);
  const [gap] = useState(GapList[0]);

  return (
    <Avatar
      style={{ backgroundColor: color, verticalAlign: "middle" }}
      size="large"
      gap={gap}
    >
      {user}
    </Avatar>
  );
};

const onSearch: SearchProps["onSearch"] = (value) =>
  console.log("Searching for:", value);

interface AppLayoutProps {
  children: ReactNode;
}

export const AppLayout: React.FC<AppLayoutProps> = ({ children }) => {
  const [collapsed, setCollapsed] = useState(false);
  const router = useRouter();
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();

  const items: MenuItem[] = [
    {
      key: "thong-ke",
      label: "Thống Kê",
      icon: <DashboardOutlined />,
      onClick: () => router.push("/admin"),
    },
    {
      key: "quan-ly-tai-khoan",
      label: "Quản Lý Tài Khoản",
      icon: <UserOutlined />,
      children: [
        {
          key: "owner",
          label: "Owner",
          onClick: () => router.push("/admin/quan-ly-tai-khoan/owner"),
        },
        {
          key: "guest",
          label: "Guest",
          onClick: () => router.push("/admin/quan-ly-tai-khoan/guest"),
        },
      ],
    },
    {
      key: "quan-ly-bai-dang",
      label: "Quản Lý Bài Đăng",
      icon: <AppstoreOutlined />,
      children: [
        {
          key: "ds-baidang",
          label: "Danh Sách Bài Đăng",
          onClick: () => router.push("/admin/quan-ly-bai-dang"),
        },
        {
          key: "bcvp",
          label: "Báo cáo vi phạm",
          onClick: () =>
            router.push("/admin/quan-ly-bai-dang/bao-cao"),
        },
      ],
    },
  ];

  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Sider
        trigger={null}
        width={240}
        collapsible
        collapsed={collapsed}
        style={{
          overflow: "auto",
          height: "100vh",
          position: "sticky",
          top: 0,
          left: 0,
        }}
      >
        <div
          className="demo-logo-vertical"
          style={{
            height: 32,
            margin: 16,
            background: "rgba(255, 255, 255, 0.2)",
            borderRadius: 6,
          }}
        />
        <Menu
          theme="dark"
          mode="inline"
          items={items}
          onClick={(e) => console.log("clicked", e)}
        />
      </Sider>

      <Layout>
        <Header
          style={{
            height: 64,
            padding: "0 24px",
            background: colorBgContainer,
            position: "sticky",
            top: 0,
            zIndex: 1,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            boxShadow: "0 2px 8px rgba(0,0,0,0.1)",
          }}
        >
          {/* Nút thu gọn + tiêu đề */}
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <Button
              type="text"
              icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
              onClick={() => setCollapsed(!collapsed)}
              style={{
                fontSize: "16px",
                width: 48,
                height: 48,
              }}
            />
            <h3 style={{ margin: 0, fontWeight: 600 }}>Admin Dashboard</h3>
          </div>

          {/* Thanh tìm kiếm */}
          <div
            style={{
              position: "absolute",
              left: "50%",
              transform: "translateX(-50%)",
              width: "400px",
              display:"flex",
              justifyContent:"center"
            }}
          >
            <Search
              placeholder="Tìm kiếm người dùng, bài đăng..."
              allowClear
              enterButton="Search"
              size="large"
              onSearch={onSearch}
            />
          </div>

          {/* Avatar */}
          <UserAvatar />
        </Header>

        <Content
          style={{
            margin: "24px 16px",
            padding: 24,
            minHeight: 280,
            background: colorBgContainer,
            borderRadius: borderRadiusLG,
          }}
        >
          {children}
        </Content>
      </Layout>
    </Layout>
  );
};

export default AppLayout;
