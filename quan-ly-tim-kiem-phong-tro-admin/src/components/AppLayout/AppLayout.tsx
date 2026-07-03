"use client";

import { auth } from "@/lib/firebase/config";
import {
  AppstoreOutlined,
  DashboardOutlined,
  LogoutOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  UserOutlined
} from "@ant-design/icons";
import type { GetProps, MenuProps } from "antd";
import { Avatar, Button, Dropdown, Input, Layout, Menu, message, Modal, theme } from "antd";
import { useRouter } from "next/navigation";
import React, { ReactNode, useEffect, useState } from "react";

type MenuItem = Required<MenuProps>["items"][number];
type SearchProps = GetProps<typeof Input.Search>;
const { Header, Sider, Content } = Layout;
const { Search } = Input;

// Avatar
const UserList = ["U", "Lucy", "Tom", "Edward"];
const ColorList = ["#f56a00", "#7265e6", "#ffbf00", "#00a2ae"];
const GapList = [4, 3, 2, 1];

interface UserAvatarProps {
  userName?: string;
  onProfileClick: () => void;
  onLogoutClick: () => void;
}

const UserAvatar: React.FC<UserAvatarProps> = ({ userName, onProfileClick, onLogoutClick }) => {
  const displayName = userName || "A";
  const color = ColorList[0];

  const dropdownItems: MenuProps['items'] = [
    {
      key: 'profile',
      icon: <UserOutlined />,
      label: 'Thông tin cá nhân',
      onClick: onProfileClick,
    },
    {
      type: 'divider',
    },
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: 'Đăng xuất',
      danger: true,
      onClick: onLogoutClick,
    },
  ];

  return (
    <Dropdown menu={{ items: dropdownItems }} placement="bottomRight" trigger={['click']}>
      <Avatar
        style={{ backgroundColor: color, verticalAlign: "middle", cursor: "pointer" }}
        size="large"
      >
        {displayName.charAt(0).toUpperCase()}
      </Avatar>
    </Dropdown>
  );
};

const onSearch: SearchProps["onSearch"] = (value) =>
  console.log("Searching for:", value);

interface AppLayoutProps {
  children: ReactNode;
}

export const AppLayout: React.FC<AppLayoutProps> = ({ children }) => {
  const [collapsed, setCollapsed] = useState(false);
  const [logoutModalVisible, setLogoutModalVisible] = useState(false);
  const [userName, setUserName] = useState<string>("");
  const router = useRouter();
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();

  useEffect(() => {
    // Get user info from localStorage
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      const user = JSON.parse(storedUser);
      setUserName(user.fullName || "Admin");
    }
  }, []);

  const handleProfileClick = () => {
    router.push("/admin/profile");
  };

  const handleLogoutClick = () => {
    setLogoutModalVisible(true);
  };

  const handleLogout = async () => {
    try {
      await auth.signOut();
      localStorage.removeItem("user");
      localStorage.removeItem("idToken");
      message.success("Đăng xuất thành công!");
      router.push("/auth/login");
    } catch (error) {
      console.error("Error logging out:", error);
      message.error("Có lỗi xảy ra khi đăng xuất");
    }
    setLogoutModalVisible(false);
  };

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
          label: "Chủ Căn Hộ",
          onClick: () => router.push("/admin/quan-ly-tai-khoan/owner"),
        },
        {
          key: "guest",
          label: "Khách Thuê",
          onClick: () => router.push("/admin/quan-ly-tai-khoan/guest"),
        },
      ],
    },
    {
      key: "quan-ly-bai-dang",
      label: "Quản Lý Bài Đăng",
      icon: <AppstoreOutlined />,
      onClick: () => router.push("/admin/quan-ly-bai-dang"),
    },
    {
      key: "quan-ly-iot",
      label: "Quản Lý Thiết Bị IoT",
      icon: <AppstoreOutlined />,
      children: [
        {
          key: "loai-thiet-bi",
          label: "Loại thiết bị hỗ trợ",
          onClick: () => router.push("/admin/quan-ly-thiet-bi-iot/loai-thiet-bi"),
        },
        {
          key: "thiet-bi-da-ket-noi",
          label: "Thiết bị đã kết nối",
          onClick: () => router.push("/admin/quan-ly-thiet-bi-iot/thiet-bi-da-ket-noi"),
        },
      ],
    },
    {
      key: "quan-ly-lich-dat-phong",
      label: "Quản Lý Đặt Phòng",
      icon: <AppstoreOutlined />,
      onClick: () => router.push("/admin/quan-ly-lich-dat-phong"),
    },
    {
      key: "quan-ly-giao-dich",
      label: "Quản Lý Giao Dịch",
      icon: <AppstoreOutlined />,
      children: [
        {
          key: "lich-su-giao-dich",
          label: "Lịch Sử Giao Dịch",
          onClick: () => router.push("/admin/quan-ly-giao-dich/lich-su-giao-dich"),
        },
        {
          key: "yeu-cau-rut-tien",
          label: "Yêu Cầu Rút Tiền",
          onClick: () => router.push("/admin/quan-ly-giao-dich/yeu-cau-rut-tien"),
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
            <h3 style={{ margin: 0, fontWeight: 600 }}>Trang quản trị</h3>
          </div>

          {/* Thanh tìm kiếm */}
          <div
            style={{
              position: "absolute",
              left: "50%",
              transform: "translateX(-50%)",
              width: "400px",
              display: "flex",
              justifyContent: "center"
            }}
          >
            <Search
              placeholder="Tìm kiếm người dùng, bài đăng..."
              allowClear
              enterButton="Tìm kiếm"
              size="large"
              onSearch={onSearch}
            />
          </div>

          {/* Avatar */}
          <UserAvatar
            userName={userName}
            onProfileClick={handleProfileClick}
            onLogoutClick={handleLogoutClick}
          />
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

      <Modal
        title="Xác nhận đăng xuất"
        open={logoutModalVisible}
        onOk={handleLogout}
        onCancel={() => setLogoutModalVisible(false)}
        okText="Đăng xuất"
        cancelText="Hủy"
        okButtonProps={{ danger: true }}
      >
        <p>Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?</p>
      </Modal>
    </Layout>
  );
};

export default AppLayout;
