"use client";

import {
  CheckCircleOutlined,
  CloseCircleOutlined,
  EyeOutlined,
  FileTextOutlined,
  HomeOutlined,
  UserOutlined
} from "@ant-design/icons";
import { Card, Col, Row, Skeleton, Statistic } from "antd";
import { useEffect, useState } from "react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

const COLORS_POSTS = ["#faad14", "#52c41a", "#ff4d4f", "#8c8c8c"];
const COLORS_USERS = ["#52c41a", "#ff4d4f"];

export default function Page() {
  const [stats, setStats] = useState({
    totalPosts: 0,
    pendingPosts: 0,
    approvedPosts: 0,
    rejectedPosts: 0,
    hiddenPosts: 0,
    totalGuests: 0,
    activeGuests: 0,
    lockedGuests: 0,
    totalOwners: 0,
    activeOwners: 0,
    lockedOwners: 0,
  });
  const [chartData, setChartData] = useState({
    postStatusData: [],
    guestStatusData: [],
    ownerStatusData: [],
    userComparisonData: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setLoading(true);

        // Fetch posts statistics
        const postsRes = await fetch("/api/posts");
        const posts = await postsRes.json();

        // Fetch guests statistics
        const guestsRes = await fetch("/api/users/guests");
        const guests = await guestsRes.json();

        // Fetch owners statistics
        const ownersRes = await fetch("/api/users/owners");
        const owners = await ownersRes.json();

        // Calculate statistics
        const postStats = posts.reduce(
          (acc: any, post: any) => {
            acc.total++;
            if (post.trangThai === "pending") acc.pending++;
            else if (post.trangThai === "approved") acc.approved++;
            else if (post.trangThai === "rejected") acc.rejected++;
            else if (post.trangThai === "hidden") acc.hidden++;
            return acc;
          },
          { total: 0, pending: 0, approved: 0, rejected: 0, hidden: 0 }
        );

        const guestStats = guests.reduce(
          (acc: any, guest: any) => {
            acc.total++;
            if (guest.GuestStatus === "active") acc.active++;
            else if (guest.GuestStatus === "locked") acc.locked++;
            return acc;
          },
          { total: 0, active: 0, locked: 0 }
        );

        const ownerStats = owners.reduce(
          (acc: any, owner: any) => {
            acc.total++;
            if (owner.OwnerStatus === "active") acc.active++;
            else if (owner.OwnerStatus === "locked") acc.locked++;
            return acc;
          },
          { total: 0, active: 0, locked: 0 }
        );

        // Prepare chart data
        const postStatusData = [
          { name: "Chờ Duyệt", value: postStats.pending },
          { name: "Đã Duyệt", value: postStats.approved },
          { name: "Từ Chối", value: postStats.rejected },
          { name: "Đã Ẩn", value: postStats.hidden },
        ];

        const guestStatusData = [
          { name: "Hoạt Động", value: guestStats.active },
          { name: "Bị Khóa", value: guestStats.locked },
        ];

        const ownerStatusData = [
          { name: "Hoạt Động", value: ownerStats.active },
          { name: "Bị Khóa", value: ownerStats.locked },
        ];

        const userComparisonData = [
          {
            name: "Khách Thuê",
            "Hoạt Động": guestStats.active,
            "Bị Khóa": guestStats.locked,
          },
          {
            name: "Chủ Căn Hộ",
            "Hoạt Động": ownerStats.active,
            "Bị Khóa": ownerStats.locked,
          },
        ];

        setStats({
          totalPosts: postStats.total,
          pendingPosts: postStats.pending,
          approvedPosts: postStats.approved,
          rejectedPosts: postStats.rejected,
          hiddenPosts: postStats.hidden,
          totalGuests: guestStats.total,
          activeGuests: guestStats.active,
          lockedGuests: guestStats.locked,
          totalOwners: ownerStats.total,
          activeOwners: ownerStats.active,
          lockedOwners: ownerStats.locked,
        });

        setChartData({
          postStatusData,
          guestStatusData,
          ownerStatusData,
          userComparisonData,
        });
      } catch (error) {
        console.error("Error fetching statistics:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return (
      <div style={{ padding: "24px" }}>
        <Skeleton active paragraph={{ rows: 8 }} />
      </div>
    );
  }

  return (
    <div style={{ padding: "24px", backgroundColor: "#f5f7fa", minHeight: "100vh" }}>
      <h1 style={{ marginBottom: "32px", fontSize: "32px", fontWeight: "bold", color: "#1f2937" }}>
        📊 Thống Kê Hệ Thống Quản Lý Căn Hộ
      </h1>

      {/* Bài Đăng Section */}
      <div style={{ marginBottom: "32px" }}>
        <h2 style={{ fontSize: "20px", fontWeight: "600", marginBottom: "16px", color: "#374151" }}>
          <FileTextOutlined /> Thống Kê Bài Đăng
        </h2>
        <Row gutter={[16, 16]} style={{ marginBottom: "24px" }}>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Tổng Bài Đăng"
                value={stats.totalPosts}
                prefix={<HomeOutlined />}
                valueStyle={{ color: "#1890ff", fontSize: "24px" }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Đang Chờ Duyệt"
                value={stats.pendingPosts}
                prefix={<EyeOutlined />}
                valueStyle={{ color: "#faad14", fontSize: "24px" }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Đã Duyệt"
                value={stats.approvedPosts}
                prefix={<CheckCircleOutlined />}
                valueStyle={{ color: "#52c41a", fontSize: "24px" }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Đã Từ Chối"
                value={stats.rejectedPosts}
                prefix={<CloseCircleOutlined />}
                valueStyle={{ color: "#ff4d4f", fontSize: "24px" }}
              />
            </Card>
          </Col>
        </Row>

        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}>
            <Card style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <h3 style={{ textAlign: "center", marginBottom: "16px", fontWeight: "600" }}>
                Phân Bố Trạng Thái Bài Đăng
              </h3>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={chartData.postStatusData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, value }) => `${name}: ${value}`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {chartData.postStatusData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS_POSTS[index % COLORS_POSTS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </Card>
          </Col>
          <Col xs={24} md={12}>
            <Card style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <h3 style={{ textAlign: "center", marginBottom: "16px", fontWeight: "600" }}>
                Chi Tiết Bài Đăng
              </h3>
              <div style={{ padding: "20px" }}>
                <div style={{ marginBottom: "12px", display: "flex", justifyContent: "space-between" }}>
                  <span>🟡 Chờ Duyệt:</span>
                  <strong>{stats.pendingPosts}</strong>
                </div>
                <div style={{ marginBottom: "12px", display: "flex", justifyContent: "space-between" }}>
                  <span>✅ Đã Duyệt:</span>
                  <strong>{stats.approvedPosts}</strong>
                </div>
                <div style={{ marginBottom: "12px", display: "flex", justifyContent: "space-between" }}>
                  <span>❌ Đã Từ Chối:</span>
                  <strong>{stats.rejectedPosts}</strong>
                </div>
                <div style={{ marginBottom: "12px", display: "flex", justifyContent: "space-between" }}>
                  <span>👁️ Đã Ẩn:</span>
                  <strong>{stats.hiddenPosts}</strong>
                </div>
                <hr style={{ margin: "16px 0" }} />
                <div style={{ display: "flex", justifyContent: "space-between", fontSize: "16px", fontWeight: "bold" }}>
                  <span>Tổng:</span>
                  <strong>{stats.totalPosts}</strong>
                </div>
              </div>
            </Card>
          </Col>
        </Row>
      </div>

      {/* Khách Thuê & Chủ Căn Hộ Section */}
      <div style={{ marginBottom: "32px" }}>
        <h2 style={{ fontSize: "20px", fontWeight: "600", marginBottom: "16px", color: "#374151" }}>
          <UserOutlined /> Thống Kê Người Dùng
        </h2>
        <Row gutter={[16, 16]} style={{ marginBottom: "24px" }}>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Tổng Khách Thuê"
                value={stats.totalGuests}
                prefix={<UserOutlined />}
                valueStyle={{ color: "#1890ff", fontSize: "24px" }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Khách Hoạt Động"
                value={stats.activeGuests}
                prefix={<CheckCircleOutlined />}
                valueStyle={{ color: "#52c41a", fontSize: "24px" }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Tổng Chủ Căn Hộ"
                value={stats.totalOwners}
                prefix={<HomeOutlined />}
                valueStyle={{ color: "#1890ff", fontSize: "24px" }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} md={6}>
            <Card hoverable style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <Statistic
                title="Chủ Hoạt Động"
                value={stats.activeOwners}
                prefix={<CheckCircleOutlined />}
                valueStyle={{ color: "#52c41a", fontSize: "24px" }}
              />
            </Card>
          </Col>
        </Row>

        <Row gutter={[16, 16]}>
          <Col xs={24} md={8}>
            <Card style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <h3 style={{ textAlign: "center", marginBottom: "16px", fontWeight: "600" }}>
                Trạng Thái Khách Thuê
              </h3>
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={chartData.guestStatusData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, value }) => `${name}: ${value}`}
                    outerRadius={70}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {chartData.guestStatusData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS_USERS[index % COLORS_USERS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </Card>
          </Col>
          <Col xs={24} md={8}>
            <Card style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <h3 style={{ textAlign: "center", marginBottom: "16px", fontWeight: "600" }}>
                Trạng Thái Chủ Căn Hộ
              </h3>
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={chartData.ownerStatusData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, value }) => `${name}: ${value}`}
                    outerRadius={70}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {chartData.ownerStatusData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS_USERS[index % COLORS_USERS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </Card>
          </Col>
          <Col xs={24} md={8}>
            <Card style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
              <h3 style={{ textAlign: "center", marginBottom: "16px", fontWeight: "600" }}>
                Tình Trạng Người Dùng
              </h3>
              <div style={{ padding: "20px" }}>
                <div style={{ marginBottom: "16px" }}>
                  <strong style={{ color: "#1890ff" }}>👥 Khách Thuê</strong>
                  <div style={{ marginTop: "8px", marginLeft: "12px", fontSize: "14px" }}>
                    <div>✅ Hoạt động: {stats.activeGuests}</div>
                    <div>🔒 Bị khóa: {stats.lockedGuests}</div>
                  </div>
                </div>
                <hr />
                <div>
                  <strong style={{ color: "#1890ff" }}>🏠 Chủ Căn Hộ</strong>
                  <div style={{ marginTop: "8px", marginLeft: "12px", fontSize: "14px" }}>
                    <div>✅ Hoạt động: {stats.activeOwners}</div>
                    <div>🔒 Bị khóa: {stats.lockedOwners}</div>
                  </div>
                </div>
              </div>
            </Card>
          </Col>
        </Row>
      </div>

      {/* Biểu Đồ So Sánh */}
      <div>
        <h2 style={{ fontSize: "20px", fontWeight: "600", marginBottom: "16px", color: "#374151" }}>
          📈 So Sánh Trạng Thái Người Dùng
        </h2>
        <Card style={{ backgroundColor: "#fff", borderRadius: "8px" }}>
          <ResponsiveContainer width="100%" height={350}>
            <BarChart data={chartData.userComparisonData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="Hoạt Động" fill="#52c41a" />
              <Bar dataKey="Bị Khóa" fill="#ff4d4f" />
            </BarChart>
          </ResponsiveContainer>
        </Card>
      </div>
    </div>
  );
}
function setChartData(arg0: { postStatusData: { name: string; value: any; }[]; guestStatusData: { name: string; value: any; }[]; ownerStatusData: { name: string; value: any; }[]; userComparisonData: { name: string; "Hoạt Động": any; "Bị Khóa": any; }[]; }) {
  throw new Error("Function not implemented.");
}

