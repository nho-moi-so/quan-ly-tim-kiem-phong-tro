"use client";

import { Button, Descriptions, message, Modal, Popconfirm, Space, Table, Tag, Tooltip, Typography } from "antd";
import type { ColumnsType } from "antd/es/table";
import { useEffect, useState } from "react";

const { Title, Text } = Typography;

type WithdrawStatus = "COMPLETED" | "REJECTED" | "PENDING" | string;

interface WithdrawRequestItem {
  id: string;
  user_name: string;
  amount: number;
  bank_summary: string;
  completed_at: string | null;
  status: WithdrawStatus;
  tx_hash: string | null;
}

interface ApiResponse {
  status: "success" | "fail";
  message: string;
  data?: WithdrawRequestItem[];
}

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(Math.abs(amount));
};

const formatDateTime = (value: string | null) => {
  if (!value) {
    return "—";
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return "—";
  }

  return parsed.toLocaleString("vi-VN", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const getStatusTag = (status: WithdrawStatus) => {
  if (status === "COMPLETED") {
    return <Tag color="green">Hoàn thành</Tag>;
  }

  if (status === "REJECTED") {
    return <Tag color="red">Đã hủy/Hoàn tiền ví</Tag>;
  }

  if (status === "PENDING") {
    return <Tag color="orange">Đang chờ duyệt</Tag>;
  }

  return <Tag>{status}</Tag>;
};

export default function YeuCauRutTienPage() {
  const [data, setData] = useState<WithdrawRequestItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);
  const [viewingItem, setViewingItem] = useState<WithdrawRequestItem | null>(null);

  const fetchWithdrawRequests = async () => {
    setLoading(true);
    try {
      const response = await fetch("/api/transactions/request_withdraw");
      const result: ApiResponse = await response.json();

      if (result.status !== "success") {
        throw new Error(result.message || "Không thể tải danh sách yêu cầu rút tiền");
      }

      setData(result.data ?? []);
    } catch (error) {
      message.error(error instanceof Error ? error.message : "Lỗi tải dữ liệu");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchWithdrawRequests();
  }, []);

  const handleApprove = async (record: WithdrawRequestItem) => {
    try {
      setActionLoadingId(record.id);
      const response = await fetch("/api/transactions/approve_withdraw", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ transactionId: record.id }),
      });
      const result = await response.json();

      if (!response.ok || result.status !== "success") {
        throw new Error(result.message || "Duyệt yêu cầu thất bại");
      }

      message.success("Duyệt yêu cầu rút tiền thành công");
      fetchWithdrawRequests();
    } catch (error) {
      message.error(error instanceof Error ? error.message : "Có lỗi khi duyệt yêu cầu");
    } finally {
      setActionLoadingId(null);
    }
  };

  const handleReject = async (record: WithdrawRequestItem) => {
    try {
      setActionLoadingId(record.id);
      const response = await fetch("/api/transactions/reject_withdraw", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ transactionId: record.id }),
      });
      const result = await response.json();

      if (!response.ok || result.status !== "success") {
        throw new Error(result.message || "Từ chối yêu cầu thất bại");
      }

      message.success("Đã từ chối và xóa giao dịch khỏi Firebase");
      fetchWithdrawRequests();
    } catch (error) {
      message.error(error instanceof Error ? error.message : "Có lỗi khi từ chối yêu cầu");
    } finally {
      setActionLoadingId(null);
    }
  };

  const columns: ColumnsType<WithdrawRequestItem> = [
    {
      title: "Mã giao dịch",
      dataIndex: "id",
      key: "id",
      width: 160,
      fixed: "left",
      render: (id: string) => <Text strong>{id.slice(0, 10).toUpperCase()}</Text>,
    },
    {
      title: "Người rút",
      dataIndex: "user_name",
      key: "user_name",
      width: 200,
      render: (name: string) => name || "—",
    },
    {
      title: "Số tiền",
      dataIndex: "amount",
      key: "amount",
      width: 180,
      align: "right",
      render: (amount: number) => (
        <Text strong style={{ color: "#ff4d4f" }}>
          - {formatCurrency(amount)}
        </Text>
      ),
    },


    {
      title: "Trạng thái",
      dataIndex: "status",
      key: "status",
      width: 170,
      render: (status: WithdrawStatus) => getStatusTag(status),
    },

    {
      title: "Hành động",
      key: "actions",
      width: 240,
      fixed: "right",
      render: (_, record) => {
        const canMutate = record.status === "PENDING";
        const isLoadingAction = actionLoadingId === record.id;

        return (
          <Space>
            <Button size="small" onClick={() => setViewingItem(record)}>
              Xem
            </Button>

            <Popconfirm
              title="Duyệt yêu cầu rút tiền"
              description="Bạn chắc chắn muốn duyệt yêu cầu này?"
              onConfirm={() => handleApprove(record)}
              okText="Duyệt"
              cancelText="Hủy"
              disabled={!canMutate}
            >
              <Button size="small" type="primary" loading={isLoadingAction} disabled={!canMutate}>
                Duyệt
              </Button>
            </Popconfirm>

            <Popconfirm
              title="Từ chối yêu cầu"
              description="Giao dịch sẽ bị xóa khỏi Firebase. Bạn có muốn tiếp tục?"
              onConfirm={() => handleReject(record)}
              okText="Từ chối"
              cancelText="Hủy"
              okButtonProps={{ danger: true }}
              disabled={!canMutate}
            >
              <Button size="small" danger loading={isLoadingAction} disabled={!canMutate}>
                Từ chối
              </Button>
            </Popconfirm>
          </Space>
        );
      },
    },
  ];

  return (
    <Space direction="vertical" size={16} style={{ width: "100%" }}>
      <Space style={{ width: "100%", justifyContent: "space-between" }}>
        <Title level={3} style={{ margin: 0 }}>
          Yêu cầu rút tiền
        </Title>
        <Button onClick={fetchWithdrawRequests} loading={loading}>
          Làm mới
        </Button>
      </Space>

      <Table
        rowKey="id"
        columns={columns}
        dataSource={data}
        loading={loading}
        pagination={{ pageSize: 10, showSizeChanger: true }}
        scroll={{ x: "max-content" }}
      />

      <Modal
        title="Chi tiết yêu cầu rút tiền"
        open={Boolean(viewingItem)}
        onCancel={() => setViewingItem(null)}
        footer={null}
      >
        {viewingItem && (
          <Descriptions bordered column={1} size="small">
            <Descriptions.Item label="Mã giao dịch">{viewingItem.id}</Descriptions.Item>
            <Descriptions.Item label="Người rút">{viewingItem.user_name || "—"}</Descriptions.Item>
            <Descriptions.Item label="Số tiền">
              <Text strong style={{ color: "#ff4d4f" }}>
                - {formatCurrency(viewingItem.amount)}
              </Text>
            </Descriptions.Item>

            <Descriptions.Item label="Trạng thái">{getStatusTag(viewingItem.status)}</Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </Space>
  );
}