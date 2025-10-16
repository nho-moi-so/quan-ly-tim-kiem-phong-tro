"use client";
import React from "react";
import { Table, Button, Space, Input } from "antd";
import type { TableColumnsType } from "antd";

const { Search } = Input;

const onSearch = (value: string) => {
  console.log("Tìm kiếm:", value);
};

const columns: TableColumnsType<any> = [
  {
    title: "Mã bài đăng",
    dataIndex: "maBaiDang",
    key: "maBaiDang",
    align: "center",
  },
  { title: "Tiêu đề", dataIndex: "tieuDe", key: "tieuDe" },
  {
    title: "Người đăng",
    dataIndex: "nguoiDang",
    key: "nguoiDang",
    align: "center",
  },
  {
    title: "Ngày đăng",
    dataIndex: "ngayDang",
    key: "ngayDang",
    align: "center",
  },
  {
    title: "Trạng thái",
    dataIndex: "trangThai",
    key: "trangThai",
    align: "center",
  },
  {
    title: "Hành động",
    key: "action",
    align: "center",
    render: (_, record) => (
      <Space>
        <Button
          type="link"
          onClick={() => console.log("Xem", record.maBaiDang)}
        >
          Xem
        </Button>
        <Button
          type="primary"
          onClick={() => console.log("Duyệt", record.maBaiDang)}
        >
          Duyệt
        </Button>
        <Button danger onClick={() => console.log("Từ chối", record.maBaiDang)}>
          Từ chối
        </Button>
      </Space>
    ),
  },
];

const data = [
  {
    maBaiDang: "BD01",
    tieuDe: "Phòng cho thuê Q1",
    nguoiDang: "Ngọc",
    ngayDang: "2025-10-14",
    trangThai: "Chờ duyệt",
  },
  {
    maBaiDang: "BD02",
    tieuDe: "Căn hộ mini Bình Thạnh",
    nguoiDang: "Hải",
    ngayDang: "2025-10-12",
    trangThai: "Chờ duyệt",
  },
  {
    maBaiDang: "BD03",
    tieuDe: "Phòng giá rẻ Q7",
    nguoiDang: "Lan",
    ngayDang: "2025-10-10",
    trangThai: "Đang duyệt",
  },
  {
    maBaiDang: "BD04",
    tieuDe: "Chung cư Quận 2",
    nguoiDang: "Minh",
    ngayDang: "2025-10-08",
    trangThai: "Đã duyệt",
  },
  {
    maBaiDang: "BD05",
    tieuDe: "Phòng cao cấp Q3",
    nguoiDang: "Trâm",
    ngayDang: "2025-10-05",
    trangThai: "Bị từ chối",
  },
];

export default function DanhSachBaiDang() {
  return (
    <div style={{ padding: 24 }}>
      <h2>Danh sách bài đăng</h2>
      <div
        style={{
          maxWidth: "100%",
          marginBottom: 16,
          display: "flex", 
          justifyContent: "flex-end", 
        }}
      >
        <Search
          placeholder="input search text"
          allowClear
          onSearch={onSearch}
          style={{ width: 200 }}
        />
      </div>

      <Table
        columns={columns}
        dataSource={data}
        rowKey="maBaiDang"
        pagination={{ pageSize: 5 }}
      />
    </div>
  );
}
