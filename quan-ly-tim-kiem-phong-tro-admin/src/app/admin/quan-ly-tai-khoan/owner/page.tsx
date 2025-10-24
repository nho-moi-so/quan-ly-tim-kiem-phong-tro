"use client";
import type { TableColumnsType } from "antd";
import { Button, Input, Space, Table, Tag, message } from "antd";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

const { Search } = Input;

interface OwnerData {
  userCode: string;
  fullName: string;
  email: string;
  phone: string;
  status: string;
  registeredAt: string;
}

interface TableData {
  maTaiKhoan: string;
  tenNguoiDung: string;
  email: string;
  soDienThoai: string;
  trangThai: string;
  ngayTao: string;
}

export default function DanhSachTaiKhoanOwner() {
  const router = useRouter();
  const [data, setData] = useState<TableData[]>([]);
  const [loading, setLoading] = useState(false);
  const [originalData, setOriginalData] = useState<TableData[]>([]);

  // Fetch owners from API
  const fetchOwners = async () => {
    setLoading(true);
    try {
      const response = await fetch("/api/users/owners");
      const result = await response.json();

      if (result.status === "success" && result.data) {
        const transformedData: TableData[] = result.data.map((owner: OwnerData) => ({
          maTaiKhoan: owner.userCode,
          tenNguoiDung: owner.fullName,
          email: owner.email,
          soDienThoai: owner.phone,
          trangThai: owner.status,
          ngayTao: owner.registeredAt,
        }));

        setData(transformedData);
        setOriginalData(transformedData);
      } else {
        message.error("Không thể tải danh sách owner");
      }
    } catch (error) {
      console.error("Error fetching owners:", error);
      message.error("Lỗi khi tải dữ liệu");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOwners();
  }, []);

  const onSearch = (value: string) => {
    if (!value.trim()) {
      setData(originalData);
      return;
    }

    const filtered = originalData.filter((item) =>
      item.tenNguoiDung.toLowerCase().includes(value.toLowerCase()) ||
      item.email.toLowerCase().includes(value.toLowerCase()) ||
      item.maTaiKhoan.toLowerCase().includes(value.toLowerCase())
    );
    
    setData(filtered);
  };

  const columns: TableColumnsType<TableData> = [
    {
      title: "Mã tài khoản",
      dataIndex: "maTaiKhoan",
      key: "maTaiKhoan",
      align: "center",
    },
    {
      title: "Tên chủ sở hữu",
      dataIndex: "tenNguoiDung",
      key: "tenNguoiDung",
      align: "center",
    },
    {
      title: "Email",
      dataIndex: "email",
      key: "email",
      align: "center",
    },
    {
      title: "Số điện thoại",
      dataIndex: "soDienThoai",
      key: "soDienThoai",
      align: "center",
    },
    {
      title: "Trạng thái / Ngày tạo",
      key: "trangThaiNgayTao",
      align: "center",
      render: (_, record) => {
        const color =
          record.trangThai === "Hoạt động"
            ? "green"
            : record.trangThai === "Bị khóa"
            ? "red"
            : "orange";
        return (
          <Space>
            <Tag color={color}>{record.trangThai}</Tag>
            <span style={{ color: "#555" }}>{record.ngayTao}</span>
          </Space>
        );
      },
    },
    {
      title: "Hành động",
      key: "action",
      align: "center",
      render: (_, record) => (
        <Space>
          <Button
            type="link"
            onClick={() =>
              router.push(`/admin/quan-ly-tai-khoan/${record.maTaiKhoan}?type=owner`)
            }
          >
            Xem
          </Button>
          <Button
            type="primary"
            onClick={() => console.log("Khóa tài khoản", record.maTaiKhoan)}
          >
            Khóa
          </Button>
          <Button
            danger
            onClick={() => console.log("Xóa tài khoản", record.maTaiKhoan)}
          >
            Xóa
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 24 }}>
      <h2>Danh sách quản lý tài khoản Owner</h2>
      <div
        style={{
          maxWidth: "100%",
          marginBottom: 16,
          display: "flex",
          justifyContent: "flex-end",
        }}
      >
        <Search
          placeholder="Nhập tên hoặc email để tìm kiếm"
          allowClear
          onSearch={onSearch}
          style={{ width: 250 }}
        />
      </div>

      <Table
        columns={columns}
        dataSource={data}
        rowKey="maTaiKhoan"
        loading={loading}
        pagination={{ 
          pageSize: 5,
          showTotal: (total) => `Tổng số ${total} tài khoản`
        }}
      />
    </div>
  );
}
