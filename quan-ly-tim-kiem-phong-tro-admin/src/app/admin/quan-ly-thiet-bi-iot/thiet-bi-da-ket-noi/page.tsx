"use client";
import { tranlateStatus } from "@/lib/tranlateStatus";
import { CheckCircleOutlined, CloseCircleOutlined } from "@ant-design/icons";
import { Button, message, Modal, Popconfirm, Progress, Space, Spin, Table, Tag, Typography } from "antd";
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
  ReadyStatus?: string; // 'Đã sẵn sàng' or 'Chưa sẵn sàng'
};

export default function ThietBiDaKetNoiPage() {
  const [loading, setLoading] = useState(false);
  const [rows, setRows] = useState<DeviceRow[]>([]);
  const [checkingDeviceId, setCheckingDeviceId] = useState<string | null>(null);
  const [isCheckingDevice, setIsCheckingDevice] = useState(false);
  const [checkResultVisible, setCheckResultVisible] = useState(false);
  const [checkResult, setCheckResult] = useState<{ device: DeviceRow; isOnline: boolean } | null>(null);
  const [countdown, setCountdown] = useState(5);

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
          ReadyStatus: d.PingReply ? 'Đã sẵn sàng' : 'Chưa sẵn sàng',
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
    message[type]({
      content: desc,
    });
  };
  const handleCheck = async (roomCode: string, deviceId: string, rowId?: string) => {
    // Use rowId (document id) to track which row is being checked for button/loading state
    setCheckingDeviceId(rowId || deviceId);
    setIsCheckingDevice(true);
    setCountdown(5);

    const interval = setInterval(() => {
      setCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);

    const device = rows.find(
      (r) => (rowId && r.Id === rowId) || r.DeviceID === deviceId || r.ApartmentCode === roomCode
    );
    try {
      const res = await fetch(`/api/iot/devices/${roomCode}/check`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ deviceId }),
      });
      const json = await res.json();
      const isOnline = json.status === "success";
      setCheckResult({ device: device!, isOnline });
      setCheckResultVisible(true);
    } catch (e: any) {
      message.error(e?.message || "Không thể kiểm tra trạng thái thiết bị.");
    } finally {
      clearInterval(interval);
      setCheckingDeviceId(null);
      setIsCheckingDevice(false);
    }
  };

  const handleDelete = async (roomCode: string, deviceId: string) => {
    try {
      const res = await fetch(`/api/iot/devices/${roomCode}/delete?deviceId=${deviceId}`, { method: "DELETE" });
      const json = await res.json();
      if (json.status === "success") {
        showNotice("success", "Đã xóa thiết bị", "Bản ghi thiết bị đã bị loại bỏ.");
        fetchDevices();
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
      key: "CombinedStatus",
      render: (_, record) => (
        <>
          <Tag color={record.Status === 'Đã kết nối' ? 'blue' : 'orange'}>
            {record.Status}
          </Tag>
          <Tag color={record.ReadyStatus === 'Đã sẵn sàng' ? 'green' : 'orange'}>
            {record.ReadyStatus}
          </Tag>
        </>
      ),
    },
    {
      title: "Hành động",
      key: "actions",
      render: (_, record) => (
        <Space>
          {record.StatusRaw !== "pending" && (
            <Button
              onClick={() => handleCheck(record.ApartmentCode!, record.DeviceID, record.Id)}
              loading={checkingDeviceId === record.Id}
              disabled={checkingDeviceId === record.Id}
            >
              Kiểm tra
            </Button>
          )}
          <Popconfirm title="Xác nhận xóa thiết bị?" onConfirm={() => handleDelete(record.ApartmentCode!, record.DeviceID)}>
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
      <Spin
        spinning={isCheckingDevice}
        indicator={<span />}
        tip={
          <div style={{
            padding: '16px 32px',
            background: 'rgba(255, 255, 255, 0.98)',
            borderRadius: '16px',
            boxShadow: '0 12px 48px rgba(0,0,0,0.15)',
            display: 'inline-block',
            border: '1px solid #f0f0f0',
            width: 'max-content',
            maxWidth: '90vw'
          }}>
            <Typography.Text style={{ fontSize: '16px', whiteSpace: 'nowrap' }}>
              Đang kiểm tra thiết bị <Typography.Text strong type="warning" style={{ fontSize: '16px' }}>{rows.find(r => r.Id === checkingDeviceId)?.DeviceType || ''}</Typography.Text>
              {' '}của căn hộ <Typography.Text strong style={{ color: '#1890ff', fontSize: '16px' }}>{rows.find(r => r.Id === checkingDeviceId)?.ApartmentCode || ''}</Typography.Text>
            </Typography.Text>
            <br />
            <Typography.Text style={{ fontSize: '15px', color: '#595959', marginTop: '12px', display: 'inline-block', whiteSpace: 'nowrap' }}>
              Vui lòng đợi.
            </Typography.Text>
          </div>
        }
      >
        <Table
          rowKey={(r) => r.Id}
          columns={columns}
          dataSource={rows}
          loading={loading}
          pagination={{ pageSize: 10 }}
        />
      </Spin>

      <Modal
        title={checkResult?.isOnline ? "Thiết bị đang trực tuyến" : "Cảnh báo: Thiết bị không phản hồi"}
        open={checkResultVisible}
        onCancel={() => setCheckResultVisible(false)}
        footer={[
          <Button key="close" onClick={() => setCheckResultVisible(false)}>
            Đóng
          </Button>,
        ]}
      >
        {checkResult && (
          <div>
            <p><strong>Mã thiết bị:</strong> {checkResult.device.DeviceID}</p>
            <p><strong>Loại thiết bị:</strong> {checkResult.device.DeviceType}</p>
            <p><strong>Căn hộ:</strong> {checkResult.device.ApartmentCode}</p>
            <p><strong>Chủ sở hữu:</strong> {checkResult.device.OwnerName}</p>
            {checkResult.isOnline ? (
              <p style={{ color: "#52c41a", marginTop: "12px" }}>
                <CheckCircleOutlined /> Thiết bị đã phản hồi thành công trong vòng 5 giây
              </p>
            ) : (
              <p style={{ color: "#ff4d4f", marginTop: "12px" }}>
                <CloseCircleOutlined /> Thiết bị không phản hồi.
              </p>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
