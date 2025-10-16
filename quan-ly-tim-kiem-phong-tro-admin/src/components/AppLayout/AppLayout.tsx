"use client";

import React, { ReactNode, useState } from "react";
import {
  AudioOutlined,
  AppstoreOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  MailOutlined,
  SettingOutlined,
  UploadOutlined,
  UserOutlined,
  VideoCameraOutlined,
} from "@ant-design/icons";
import type { GetProps, MenuProps } from "antd";
import { Avatar, Input, Space, Button, Layout, Menu, theme } from "antd";
type MenuItem = Required<MenuProps>["items"][number];
type SearchProps = GetProps<typeof Input.Search>;
const { Header, Sider, Content } = Layout;
const { Search } = Input;
const UserList = ["U", "Lucy", "Tom", "Edward"];
const ColorList = ["#f56a00", "#7265e6", "#ffbf00", "#00a2ae"];
const GapList = [4, 3, 2, 1];
const UserAvatar: React.FC = () => {
  const [user, setUser] = useState(UserList[0]);
  const [color, setColor] = useState(ColorList[0]);
  const [gap, setGap] = useState(GapList[0]);

  return (
    <>
      <Avatar
        style={{ backgroundColor: color, verticalAlign: "middle" }}
        size="large"
        gap={gap}
      >
        {user}
      </Avatar>
    </>
  );
};

const suffix = (
  <AudioOutlined
    style={{
      fontSize: 16,
      color: "#1677ff",
    }}
  />
);

const onSearch: SearchProps["onSearch"] = (value, _e, info) =>
  console.log(info?.source, value);

interface AppLayoutProps {
  children: ReactNode;
}

export const AppLayout: React.FC<AppLayoutProps> = ({ children }) => {
  const [collapsed, setCollapsed] = useState(false);
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();
  const items: MenuItem[] = [
    {
      key: "sub1",
      label: "Quản Lý Tài Khoản",
      icon: <MailOutlined />,
      children: [
        {
          key: "g1",
          label: "Danh Sách TK",
          type: "group",
          children: [
            { key: "1", label: "Owner" },
            { key: "2", label: "Guest" },
          ],
        },
      ],
    },
    {
      key: "sub2",
      label: "Quản Lý Bài Đăng",
      icon: <AppstoreOutlined />,
      children: [
        {
          key: "sub3",
          label: "Danh sách Bài Đăng",
          children: [
            { key: "7", label: "DS Chờ Duyệt" },
            { key: "8", label: "Chi Tiết Bài Đăng" },
            { key: "9", label: "Báo cáo vi phạm" },
          ],
        },
      ],
    },
    {
      type: "divider",
    },
    {
      key: "grp",
      label: "Thống Kê",
      icon: <AppstoreOutlined />,
      children: [
            { key: "1", label: "Xem Chi Tiết" },
          ],
    },
  ];
  const App: React.FC = () => (
    <Space direction="vertical">
      <Search
        placeholder="input search text"
        allowClear
        enterButton="Search"
        size="large"
        onSearch={onSearch}
      />
    </Space>
  );
  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Sider
        trigger={null}
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
          defaultSelectedKeys={["1"]}
          defaultOpenKeys={["sub1"]}
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
          {/* Bên trái */}
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <Button
              type="text"
              icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
              onClick={() => setCollapsed(!collapsed)}
              style={{
                fontSize: "16px",
                width: 48,
                height: 48,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            />
            <h3 style={{ margin: 0, fontWeight: 600 }}>Admin Dashboard</h3>
          </div>

          {/* Thanh tìm kiếm ở giữa */}
          <div
            style={{
              position: "absolute",
              left: "50%",
              transform: "translateX(-50%)",
              width: "400px",
              display: "flex",
              alignItems: "center",
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

          {/* Bên phải: Avatar */}
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
