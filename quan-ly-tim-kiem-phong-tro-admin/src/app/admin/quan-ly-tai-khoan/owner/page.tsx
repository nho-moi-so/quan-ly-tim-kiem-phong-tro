"use client";
import React from "react";
import { Table, Button, Space, Input, Tag } from "antd";
import type { TableColumnsType } from "antd";
import { useRouter } from "next/navigation";

const { Search } = Input;

export default function DanhSachTaiKhoanOwner() {
  const router = useRouter();

  const onSearch = (value: string) => {
    console.log("Tìm kiếm:", value);
  };

  const columns: TableColumnsType<any> = [
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
              router.push(`/admin/quan-ly-tai-khoan/${record.maTaiKhoan}`)
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

  const data = [
    {
      maTaiKhoan: "TK001",
      tenNguoiDung: "Nguyễn Văn A",
      email: "owner.a@gmail.com",
      soDienThoai: "0912123456",
      trangThai: "Hoạt động",
      ngayTao: "2025-05-10",
    },
    {
      maTaiKhoan: "TK002",
      tenNguoiDung: "Trần Thị B",
      email: "owner.b@gmail.com",
      soDienThoai: "0933123456",
      trangThai: "Hoạt động",
      ngayTao: "2025-06-18",
    },
    {
      maTaiKhoan: "TK003",
      tenNguoiDung: "Phạm Minh C",
      email: "owner.c@gmail.com",
      soDienThoai: "0987654321",
      trangThai: "Bị khóa",
      ngayTao: "2025-04-03",
    },
    {
      maTaiKhoan: "TK004",
      tenNguoiDung: "Lê Thị D",
      email: "owner.d@gmail.com",
      soDienThoai: "0905456789",
      trangThai: "Hoạt động",
      ngayTao: "2025-03-12",
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
        pagination={{ pageSize: 5 }}
      />
    </div>
  );
}
