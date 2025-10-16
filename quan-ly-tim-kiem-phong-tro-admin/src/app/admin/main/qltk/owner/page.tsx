"use client";
import React from "react";
import { Table, Button, Space, Input, Tag } from "antd";
import type { TableColumnsType } from "antd";

const { Search } = Input;

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
    title: "Tên người dùng",
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
          onClick={() => console.log("Xem chi tiết", record.maTaiKhoan)}
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

// Dữ liệu mẫu
const data = [
  {
    maTaiKhoan: "TK001",
    tenNguoiDung: "Ngọc",
    email: "ngoc@gmail.com",
    soDienThoai: "0905123456",
    trangThai: "Hoạt động",
    ngayTao: "2025-09-12",
  },
  {
    maTaiKhoan: "TK002",
    tenNguoiDung: "Minh",
    email: "minh@gmail.com",
    soDienThoai: "0909123456",
    trangThai: "Hoạt động",
    ngayTao: "2025-08-25",
  },
  {
    maTaiKhoan: "TK003",
    tenNguoiDung: "Hải",
    email: "hai@gmail.com",
    soDienThoai: "0912345678",
    trangThai: "Hoạt động",
    ngayTao: "2025-07-01",
  },
  {
    maTaiKhoan: "TK004",
    tenNguoiDung: "Lan",
    email: "lan@gmail.com",
    soDienThoai: "0978123456",
    trangThai: "Bị khóa",
    ngayTao: "2025-09-30",
  },
  {
    maTaiKhoan: "TK005",
    tenNguoiDung: "Trâm",
    email: "tram@gmail.com",
    soDienThoai: "0987654321",
    trangThai: "Bị Khóa",
    ngayTao: "2025-10-01",
  },
];

export default function DanhSachTaiKhoanOwner() {
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
