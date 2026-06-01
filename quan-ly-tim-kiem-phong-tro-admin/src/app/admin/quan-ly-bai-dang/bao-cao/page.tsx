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
    title: "Mã vi phạm",
    dataIndex: "maViPham",
    key: "maViPham",
    align: "center",
  },
  {
    title: "Bài đăng vi phạm",
    dataIndex: "tieuDe",
    key: "tieuDe",
  },
  {
    title: "Người đăng",
    dataIndex: "nguoiDang",
    key: "nguoiDang",
    align: "center",
  },
  {
    title: "Người báo cáo",
    dataIndex: "nguoiBaoCao",
    key: "nguoiBaoCao",
    align: "center",
  },
  {
    title: "Loại vi phạm",
    dataIndex: "loaiViPham",
    key: "loaiViPham",
    align: "center",
  },
  {
    title: "Ngày báo cáo",
    dataIndex: "ngayBaoCao",
    key: "ngayBaoCao",
    align: "center",
  },
  {
    title: "Trạng thái xử lý",
    dataIndex: "trangThai",
    key: "trangThai",
    align: "center",
    render: (text) => {
      let color = "";
      switch (text) {
        case "Chưa xử lý":
          color = "volcano";
          break;
        case "Đang xem xét":
          color = "gold";
          break;
        case "Đã xử lý":
          color = "green";
          break;
      }
      return <Tag color={color}>{text}</Tag>;
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
          onClick={() => console.log("Xem chi tiết", record.maViPham)}
        >
          Xem
        </Button>
        <Button
          type="primary"
          onClick={() => console.log("Đánh dấu đã xử lý", record.maViPham)}
        >
          Đã xử lý
        </Button>
        <Button
          danger
          onClick={() => console.log("Xóa bài đăng", record.maViPham)}
        >
          Xóa bài
        </Button>
      </Space>
    ),
  },
];

const data = [
  {
    maViPham: "VP01",
    tieuDe: "Phòng giá rẻ Q7",
    nguoiDang: "Lan",
    nguoiBaoCao: "Ngọc",
    loaiViPham: "Thông tin sai sự thật",
    ngayBaoCao: "2025-10-14",
    trangThai: "Chưa xử lý",
  },
  {
    maViPham: "VP02",
    tieuDe: "Căn hộ mini Bình Thạnh",
    nguoiDang: "Hải",
    nguoiBaoCao: "Minh",
    loaiViPham: "Hình ảnh không phù hợp",
    ngayBaoCao: "2025-10-12",
    trangThai: "Đang xem xét",
  },
  {
    maViPham: "VP03",
    tieuDe: "Phòng cho thuê Q1",
    nguoiDang: "Trâm",
    nguoiBaoCao: "An",
    loaiViPham: "Spam / Nội dung lặp lại",
    ngayBaoCao: "2025-10-08",
    trangThai: "Đã xử lý",
  },
];

// export default function BaoCaoViPham() {
//   return (
//     <div style={{ padding: 24 }}>
//       <h2>Báo cáo vi phạm bài đăng</h2>

//       <div
//         style={{
//           maxWidth: "100%",
//           marginBottom: 16,
//           display: "flex",
//           justifyContent: "flex-end",
//         }}
//       >
//         <Search
//           placeholder="Tìm kiếm bài đăng vi phạm"
//           allowClear
//           onSearch={onSearch}
//           style={{ width: 250 }}
//         />
//       </div>

//       <Table
//         columns={columns}
//         dataSource={data}
//         rowKey="maViPham"
//         pagination={{ pageSize: 5 }}
//       />
//     </div>
//   );
// }
