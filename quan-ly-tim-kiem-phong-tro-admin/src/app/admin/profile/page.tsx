"use client";

import { auth } from "@/lib/firebase/config";
import {
    KeyOutlined,
    LockOutlined,
    LogoutOutlined,
    SaveOutlined,
    UserOutlined,
} from "@ant-design/icons";
import {
    Avatar,
    Button,
    Card,
    Col,
    Divider,
    Form,
    Input,
    message,
    Modal,
    Row,
    Spin,
    Tabs,
    Typography,
} from "antd";
import {
    EmailAuthProvider,
    reauthenticateWithCredential,
    updatePassword,
} from "firebase/auth";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

const { Title, Text } = Typography;
const { TabPane } = Tabs;

interface UserInfo {
  userId: string;
  email: string;
  fullName: string;
  phone?: string;
  role: string;
}

export default function ProfilePage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [changingPassword, setChangingPassword] = useState(false);
  const [userInfo, setUserInfo] = useState<UserInfo | null>(null);
  const [form] = Form.useForm();
  const [passwordForm] = Form.useForm();
  const [logoutModalVisible, setLogoutModalVisible] = useState(false);

  useEffect(() => {
    // Load user info from localStorage
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      const user = JSON.parse(storedUser);
      setUserInfo(user);
      form.setFieldsValue({
        fullName: user.fullName,
        email: user.email,
        phone: user.phone || "",
      });
    }
    
    // Fetch latest user info from server
    fetchUserProfile();
  }, []);

  const fetchUserProfile = async () => {
    try {
      setLoading(true);
      const idToken = localStorage.getItem("idToken");
      
      if (!idToken) {
        message.error("Phiên đăng nhập đã hết hạn");
        router.push("/auth/login");
        return;
      }

      const response = await fetch("/api/auth/profile", {
        method: "GET",
        headers: {
          Authorization: `Bearer ${idToken}`,
        },
      });

      const result = await response.json();

      if (result.status === "success") {
        setUserInfo(result.data);
        form.setFieldsValue({
          fullName: result.data.fullName,
          email: result.data.email,
          phone: result.data.phone || "",
        });
        // Update localStorage
        localStorage.setItem("user", JSON.stringify(result.data));
      } else if (response.status === 401) {
        message.error("Phiên đăng nhập đã hết hạn");
        router.push("/auth/login");
      }
    } catch (error) {
      console.error("Error fetching profile:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateProfile = async (values: any) => {
    try {
      setSaving(true);
      const idToken = localStorage.getItem("idToken");

      if (!idToken) {
        message.error("Phiên đăng nhập đã hết hạn");
        router.push("/auth/login");
        return;
      }

      const response = await fetch("/api/auth/profile", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${idToken}`,
        },
        body: JSON.stringify({
          fullName: values.fullName,
          phone: values.phone,
        }),
      });

      const result = await response.json();

      if (result.status === "success") {
        message.success("Cập nhật thông tin thành công!");
        setUserInfo(result.data);
        localStorage.setItem("user", JSON.stringify(result.data));
      } else {
        message.error(result.message || "Cập nhật thất bại");
      }
    } catch (error) {
      console.error("Error updating profile:", error);
      message.error("Có lỗi xảy ra khi cập nhật thông tin");
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async (values: any) => {
    try {
      setChangingPassword(true);

      const user = auth.currentUser;
      if (!user || !user.email) {
        message.error("Không tìm thấy thông tin người dùng");
        return;
      }

      // Re-authenticate user with current password
      const credential = EmailAuthProvider.credential(
        user.email,
        values.currentPassword
      );

      await reauthenticateWithCredential(user, credential);

      // Update password
      await updatePassword(user, values.newPassword);

      message.success("Đổi mật khẩu thành công!");
      passwordForm.resetFields();
    } catch (error: any) {
      console.error("Error changing password:", error);

      if (error.code === "auth/wrong-password") {
        message.error("Mật khẩu hiện tại không chính xác");
      } else if (error.code === "auth/weak-password") {
        message.error("Mật khẩu mới phải có ít nhất 6 ký tự");
      } else if (error.code === "auth/requires-recent-login") {
        message.error("Vui lòng đăng nhập lại để thực hiện thao tác này");
      } else {
        message.error("Có lỗi xảy ra khi đổi mật khẩu");
      }
    } finally {
      setChangingPassword(false);
    }
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
  };

  const showLogoutConfirm = () => {
    setLogoutModalVisible(true);
  };

  if (loading) {
    return (
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          minHeight: "400px",
        }}
      >
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div style={{ maxWidth: 800, margin: "0 auto" }}>
      <Title level={2}>
        <UserOutlined /> Thông tin cá nhân
      </Title>

      <Card style={{ marginBottom: 24 }}>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            marginBottom: 24,
          }}
        >
          <Avatar
            size={80}
            style={{
              backgroundColor: "#1890ff",
              fontSize: 32,
            }}
          >
            {userInfo?.fullName?.charAt(0)?.toUpperCase() || "A"}
          </Avatar>
          <div style={{ marginLeft: 24 }}>
            <Title level={4} style={{ margin: 0 }}>
              {userInfo?.fullName || "Admin"}
            </Title>
            <Text type="secondary">{userInfo?.email}</Text>
            <br />
            <Text
              style={{
                color: "#52c41a",
                backgroundColor: "#f6ffed",
                padding: "2px 8px",
                borderRadius: 4,
                fontSize: 12,
              }}
            >
              {userInfo?.role === "admin" ? "Quản trị viên" : userInfo?.role}
            </Text>
          </div>
        </div>

        <Tabs defaultActiveKey="info">
          <TabPane
            tab={
              <span>
                <UserOutlined /> Thông tin tài khoản
              </span>
            }
            key="info"
          >
            <Form
              form={form}
              layout="vertical"
              onFinish={handleUpdateProfile}
              style={{ maxWidth: 500 }}
            >
              <Form.Item
                label="Họ và tên"
                name="fullName"
                rules={[
                  { required: true, message: "Vui lòng nhập họ và tên" },
                  { min: 2, message: "Họ tên phải có ít nhất 2 ký tự" },
                ]}
              >
                <Input
                  prefix={<UserOutlined />}
                  placeholder="Nhập họ và tên"
                  size="large"
                />
              </Form.Item>

              <Form.Item label="Email" name="email">
                <Input
                  prefix={<UserOutlined />}
                  disabled
                  size="large"
                  style={{ backgroundColor: "#f5f5f5" }}
                />
              </Form.Item>

              <Form.Item
                label="Số điện thoại"
                name="phone"
                rules={[
                  {
                    pattern: /^[0-9]{10,11}$/,
                    message: "Số điện thoại không hợp lệ",
                  },
                ]}
              >
                <Input
                  prefix={<UserOutlined />}
                  placeholder="Nhập số điện thoại"
                  size="large"
                />
              </Form.Item>

              <Form.Item>
                <Button
                  type="primary"
                  htmlType="submit"
                  icon={<SaveOutlined />}
                  loading={saving}
                  size="large"
                >
                  Lưu thay đổi
                </Button>
              </Form.Item>
            </Form>
          </TabPane>

          <TabPane
            tab={
              <span>
                <KeyOutlined /> Đổi mật khẩu
              </span>
            }
            key="password"
          >
            <Form
              form={passwordForm}
              layout="vertical"
              onFinish={handleChangePassword}
              style={{ maxWidth: 500 }}
            >
              <Form.Item
                label="Mật khẩu hiện tại"
                name="currentPassword"
                rules={[
                  { required: true, message: "Vui lòng nhập mật khẩu hiện tại" },
                ]}
              >
                <Input.Password
                  prefix={<LockOutlined />}
                  placeholder="Nhập mật khẩu hiện tại"
                  size="large"
                />
              </Form.Item>

              <Form.Item
                label="Mật khẩu mới"
                name="newPassword"
                rules={[
                  { required: true, message: "Vui lòng nhập mật khẩu mới" },
                  { min: 6, message: "Mật khẩu phải có ít nhất 6 ký tự" },
                ]}
              >
                <Input.Password
                  prefix={<LockOutlined />}
                  placeholder="Nhập mật khẩu mới"
                  size="large"
                />
              </Form.Item>

              <Form.Item
                label="Xác nhận mật khẩu mới"
                name="confirmPassword"
                dependencies={["newPassword"]}
                rules={[
                  { required: true, message: "Vui lòng xác nhận mật khẩu mới" },
                  ({ getFieldValue }) => ({
                    validator(_, value) {
                      if (!value || getFieldValue("newPassword") === value) {
                        return Promise.resolve();
                      }
                      return Promise.reject(
                        new Error("Mật khẩu xác nhận không khớp")
                      );
                    },
                  }),
                ]}
              >
                <Input.Password
                  prefix={<LockOutlined />}
                  placeholder="Nhập lại mật khẩu mới"
                  size="large"
                />
              </Form.Item>

              <Form.Item>
                <Button
                  type="primary"
                  htmlType="submit"
                  icon={<KeyOutlined />}
                  loading={changingPassword}
                  size="large"
                >
                  Đổi mật khẩu
                </Button>
              </Form.Item>
            </Form>
          </TabPane>
        </Tabs>
      </Card>

      <Card>
        <Row gutter={16}>
          <Col span={24}>
            <Divider orientation="left">Đăng xuất</Divider>
            <Text type="secondary" style={{ display: "block", marginBottom: 16 }}>
              Đăng xuất khỏi tài khoản của bạn. Bạn sẽ cần đăng nhập lại để truy
              cập hệ thống.
            </Text>
            <Button
              danger
              icon={<LogoutOutlined />}
              onClick={showLogoutConfirm}
              size="large"
            >
              Đăng xuất
            </Button>
          </Col>
        </Row>
      </Card>

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
    </div>
  );
}
