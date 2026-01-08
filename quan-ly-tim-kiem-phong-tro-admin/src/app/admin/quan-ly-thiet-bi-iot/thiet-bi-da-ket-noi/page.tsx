"use client";
import { tranlateStatus } from "@/lib/tranlateStatus";
import { Button, message, notification, Popconfirm, Space, Table, Typography } from "antd";
import type { ColumnsType } from "antd/es/table";
import { useEffect, useState } from "react";

type DeviceRow = {
  Id: string; // roomCode (document id)
  DeviceID: string;
  DeviceType?: string;
  ApartmentCode?: string;
  OwnerName?: string;
  Status?: string; // hiển thị tiếng Việt
  StatusRaw?: string; // giá trị gốc từ server
  CreationDate?: string;
};

export default function ThietBiDaKetNoiPage() {
  const [loading, setLoading] = useState(false);
  const [rows, setRows] = useState<DeviceRow[]>([]);

  const fetchDevices = async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/iot/devices", { cache: "no-store" });
      const json = await res.json();
      if (json.status === "success") {
        const data = (json.data || []).map((d: any) => ({
          Id: d.Id,
          DeviceID: d.DeviceID,
          DeviceType: d.DeviceType,
          ApartmentCode: d.ApartmentCode,
          OwnerName: d.OwnerName,
          Status: tranlateStatus.tranlateToVietnameseStatusIoT(d.Status),
          StatusRaw: d.Status,
          CreationDate: d.CreationDate,
        }));
        setRows(data);
      } else {
        message.error(json.message || "Tải danh sách thất bại");
      }
    } catch (e: any) {
      message.error(e?.message || "Lỗi tải dữ liệu");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDevices();
  }, []);

  const showNotice = (
    type: "success" | "warning" | "error",
    title: string,
    desc: string
  ) => {
    notification[type]({
      message: title,
      description: desc,
      placement: "topRight",
      style: {
        borderRadius: 12,
        boxShadow: "0 12px 40px rgba(0,0,0,0.18)",
      },
    });
  };

  const handleCheck = async (roomCode: string) => {
    try {
      const res = await fetch(`/api/iot/devices/${roomCode}/check`, { method: "POST" });
      const json = await res.json();
      if (json.status === "success") {
        showNotice("success", "Thiết bị đang trực tuyến", "Đã phản hồi trong 5 giây kiểm tra.");
      } else {
        showNotice(
          "warning",
          "Không nhận được phản hồi",
          json.message || "Thiết bị chưa trả lời yêu cầu kiểm tra trong 5 giây."
        );
      }
    } catch (e: any) {
      showNotice("error", "Lỗi kiểm tra thiết bị", e?.message || "Không thể kiểm tra trạng thái thiết bị.");
    }
  };

  const handleDelete = async (roomCode: string) => {
    try {
      const res = await fetch(`/api/iot/devices/${roomCode}/delete`, { method: "DELETE" });
      const json = await res.json();
      if (json.status === "success") {
        showNotice("success", "Đã xóa thiết bị", "Bản ghi thiết bị đã bị loại bỏ.");
        setRows((prev) => prev.filter((r) => r.Id !== roomCode));
      } else {
        showNotice("error", "Xóa thất bại", json.message || "Không thể xóa thiết bị.");
      }
    } catch (e: any) {
      message.error(e?.message || "Lỗi xóa thiết bị");
    }
  };

  const columns: ColumnsType<DeviceRow> = [
    {
      title: "Mã thiết bị",
      dataIndex: "DeviceID",
      key: "DeviceID",
    },
    {
      title: "Loại thiết bị",
      dataIndex: "DeviceType",
      key: "DeviceType",
    },
    {
      title: "Thuộc Căn hộ",
      dataIndex: "ApartmentCode",
      key: "ApartmentCode",
    },
    {
      title: "Chủ sở hữu",
      dataIndex: "OwnerName",
      key: "OwnerName",
    },
    {
      title: "Trạng thái",
      dataIndex: "Status",
      key: "Status",
    },
    {
      title: "Hành động",
      key: "actions",
      render: (_, record) => (
        <Space>
          {record.StatusRaw !== "pending" && (
            <Button onClick={() => handleCheck(record.Id)}>Kiểm tra</Button>
          )}
          <Popconfirm title="Xác nhận xóa thiết bị?" onConfirm={() => handleDelete(record.Id)}>
            <Button danger type="primary">Xóa</Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      <Typography.Title level={4}>Thiết bị IoT đang kết nối</Typography.Title>
      <Space style={{ marginBottom: 12 }}>
        <Button onClick={fetchDevices} loading={loading}>Làm mới</Button>
      </Space>
      <Table
        rowKey={(r) => r.Id}
        columns={columns}
        dataSource={rows}
        loading={loading}
        pagination={{ pageSize: 10 }}
      />
    </div>
  );
}
