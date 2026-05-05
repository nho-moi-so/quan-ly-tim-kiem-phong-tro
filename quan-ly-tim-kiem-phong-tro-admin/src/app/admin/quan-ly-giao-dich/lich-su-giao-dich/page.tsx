"use client";

import {
  Button,
  Modal,
  Popconfirm,
  Select,
  Space,
  Table,
  Tabs,
  Tag,
  Tooltip,
  Typography,
  message,
} from "antd";
import type { ColumnsType } from "antd/es/table";
import { useEffect, useMemo, useState } from "react";

const { Title, Text } = Typography;

type TransactionType = "DEPOSIT" | "WITHDRAW" | string;
type TransactionStatus = "PENDING" | "SUCCESS" | "COMPLETED" | "FAILED" | "REJECTED" | string;
type PaymentMethod = "BANK_TRANSFER" | "VNPAY" | string;

interface TransactionHistoryItem {
  id: string;
  trans_code: string;
  type: TransactionType;
  amount: number;
  status: TransactionStatus;
  user: {
    full_name: string;
    phone: string;
  };
  payment_detail: {
    method?: PaymentMethod | null;
    bank_name?: string | null;
    account_number?: string | null;
    account_holder?: string | null;
    gateway_ref?: string | null;
  };
  tx_hash: string | null;
  created_at: string | null;
}

interface HistoryApiResponse {
  status: "success" | "fail";
  message: string;
  data?: TransactionHistoryItem[];
}

type StatusTabKey = "all" | "pending" | "success" | "failed";
type TypeFilter = "ALL" | "DEPOSIT" | "WITHDRAW";

const formatCurrency = (value: number) =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(Math.abs(value));

const formatDateTime = (value: string | null) => {
  if (!value) return "—";
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return "—";

  return parsed.toLocaleString("vi-VN", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const getStatusTag = (status: TransactionStatus) => {
  const upper = status?.toUpperCase?.() ?? "";
  if (upper === "PENDING") return <Tag color="gold">Chờ duyệt</Tag>;
  if (upper === "SUCCESS" || upper === "COMPLETED") return <Tag color="green">Thành công</Tag>;
  if (upper === "FAILED" || upper === "REJECTED") return <Tag color="red">Thất bại</Tag>;
  return <Tag>{upper || "—"}</Tag>;
};

const getTypeTag = (type: TransactionType) => {
  const upper = type?.toUpperCase?.() ?? "";
  if (upper === "DEPOSIT") return <Tag color="blue">Nạp tiền</Tag>;
  if (upper === "WITHDRAW") return <Tag color="orange">Rút tiền</Tag>;
  return <Tag>{upper || "—"}</Tag>;
};
const getTypeText = (type: PaymentMethod) => {
  const upper = type?.toUpperCase?.() ?? "";
  if (upper === "BANK_TRANSFER") return "Chuyển khoản";
  if (upper === "VNPAY") return "VNPAY";
  return upper || "—";
}

const mapStatusToTab = (status: TransactionStatus): StatusTabKey => {
  const upper = status?.toUpperCase?.() ?? "";
  if (upper === "PENDING") return "pending";
  if (upper === "SUCCESS" || upper === "COMPLETED") return "success";
  if (upper === "FAILED" || upper === "REJECTED") return "failed";
  return "all";
};

export default function LichSuGiaoDichPage() {
  const [rawData, setRawData] = useState<TransactionHistoryItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeStatusTab, setActiveStatusTab] = useState<StatusTabKey>("all");
  const [typeFilter, setTypeFilter] = useState<TypeFilter>("ALL");
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);
  const [viewingItem, setViewingItem] = useState<TransactionHistoryItem | null>(null);

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const response = await fetch("/api/transactions/history");
      const result: HistoryApiResponse = await response.json();
      if (!response.ok || result.status !== "success") {
        throw new Error(result.message || "Không thể tải lịch sử giao dịch");
      }
      setRawData(result.data ?? []);
    } catch (error) {
      message.error(error instanceof Error ? error.message : "Lỗi tải dữ liệu");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHistory();
  }, []);

  const data = useMemo(() => {
    return rawData.filter((item) => {
      if (typeFilter !== "ALL" && item.type.toUpperCase() !== typeFilter) {
        return false;
      }

      if (activeStatusTab === "all") {
        return true;
      }

      return mapStatusToTab(item.status) === activeStatusTab;
    });
  }, [activeStatusTab, rawData, typeFilter]);

  const countByTab = useMemo(() => {
    return rawData.reduce(
      (acc, item) => {
        acc.all += 1;
        const tab = mapStatusToTab(item.status);
        if (tab === "pending") acc.pending += 1;
        if (tab === "success") acc.success += 1;
        if (tab === "failed") acc.failed += 1;
        return acc;
      },
      { all: 0, pending: 0, success: 0, failed: 0 },
    );
  }, [rawData]);

  const handleApprove = async (record: TransactionHistoryItem) => {
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

      message.success("Duyệt giao dịch rút tiền thành công");
      fetchHistory();
    } catch (error) {
      message.error(error instanceof Error ? error.message : "Có lỗi khi duyệt giao dịch");
    } finally {
      setActionLoadingId(null);
    }
  };

  const handleReject = async (record: TransactionHistoryItem) => {
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
      fetchHistory();
    } catch (error) {
      message.error(error instanceof Error ? error.message : "Có lỗi khi từ chối giao dịch");
    } finally {
      setActionLoadingId(null);
    }
  };

  const columns: ColumnsType<TransactionHistoryItem> = [
    {
      title: "Mã GD",
      dataIndex: "trans_code",
      key: "trans_code",
      width: 130,
      fixed: "left",
      render: (code: string) => <Text strong>{code}</Text>,
    },
    {
      title: "Người dùng",
      key: "user",
      width: 200,
      render: (_, record) => (
        <div>
          <div style={{ fontWeight: 600 }}>{record.user?.full_name || "—"}</div>
          <div style={{ fontSize: 12, color: "#8c8c8c" }}>{record.user?.phone || "—"}</div>
        </div>
      ),
    },
    {
      title: "Loại GD",
      dataIndex: "type",
      key: "type",
      width: 120,
      render: (type: TransactionType) => getTypeTag(type),
    },
    {
      title: "Số tiền",
      dataIndex: "amount",
      key: "amount",
      width: 170,
      align: "right",
      render: (amount: number, record) => {
        const isDeposit = record.type.toUpperCase() === "DEPOSIT";
        return (
          <Text strong style={{ color: isDeposit ? "#52c41a" : "#ff4d4f" }}>
            {isDeposit ? "+" : "-"} {formatCurrency(amount)}
          </Text>
        );
      },
    },
    {
      title: "Chi tiết thanh toán",
      key: "payment_detail",
      width: 280,
      render: (_, record) => {
        const isDeposit = record.type.toUpperCase() === "DEPOSIT";
        const detail = record.payment_detail || {};

        if (isDeposit) {
          return (
            <div>
              <div>{getTypeText(detail.method)}</div>
              <div style={{ fontSize: 12, color: "#8c8c8c" }}>Ref: {detail.gateway_ref || "—"}</div>
            </div>
          );
        }

        return (
          <Space direction="vertical" size={0}>
            <Text>{getTypeText(detail.method)}</Text>
            <Space size={8}>
              <Text>{detail.account_number || "—"}</Text>
              {detail.account_number && <Text copyable={{ text: detail.account_number }} />}
            </Space>
            <Text type="secondary">{detail.account_holder || "—"}</Text>
          </Space>
        );
      },
    },
    {
      title: "Blockchain",
      dataIndex: "tx_hash",
      key: "tx_hash",
      width: 110,
      render: (hash: string | null) => {
        if (!hash) {
          return "—";
        }

        const explorerBase = process.env.NEXT_PUBLIC_BLOCKCHAIN_EXPLORER_URL || "";
        const href = explorerBase ? `${explorerBase}${hash}` : "#";

        return (
          <Tooltip title={hash}>
            <a href={href} target="_blank" rel="noreferrer">
              🔗 Xem
            </a>
          </Tooltip>
        );
      },
    },
    {
      title: "Thời gian",
      dataIndex: "created_at",
      key: "created_at",
      width: 170,
      render: (value: string | null) => formatDateTime(value),
    },
    {
      title: "Trạng thái",
      dataIndex: "status",
      key: "status",
      width: 140,
      render: (status: TransactionStatus) => getStatusTag(status),
    },
    {
      title: "Hành động",
      key: "actions",
      width: 250,
      fixed: "right",
      render: (_, record) => {
        const type = record.type.toUpperCase();
        const status = record.status.toUpperCase();
        const isPendingWithdraw = type === "WITHDRAW" && status === "PENDING";
        const isDeposit = type === "DEPOSIT";
        const isWithdrawDone = type === "WITHDRAW" && ["COMPLETED", "SUCCESS", "FAILED", "REJECTED"].includes(status);
        const isLoadingAction = actionLoadingId === record.id;

        if (isPendingWithdraw) {
          return (
            <Space>
              <Popconfirm
                title="Duyệt yêu cầu rút tiền"
                description="Bạn chắc chắn muốn duyệt giao dịch này?"
                onConfirm={() => handleApprove(record)}
                okText="Duyệt"
                cancelText="Hủy"
              >
                <Button type="primary" size="small" loading={isLoadingAction}>✅ Duyệt</Button>
              </Popconfirm>
              <Popconfirm
                title="Từ chối yêu cầu"
                description="Giao dịch sẽ bị xóa khỏi Firebase, bạn có muốn tiếp tục?"
                onConfirm={() => handleReject(record)}
                okText="Từ chối"
                cancelText="Hủy"
                okButtonProps={{ danger: true }}
              >
                <Button danger size="small" loading={isLoadingAction}>❌ Từ chối</Button>
              </Popconfirm>
            </Space>
          );
        }

        if (isDeposit) {
          const gatewayRef = record.payment_detail?.gateway_ref;
          return gatewayRef ? (
            <Button size="small" type="link" href={`https://sandbox.vnpayment.vn/merchantv2/`} target="_blank">
              Kiểm tra VNPAY
            </Button>
          ) : (
            <Button size="small" onClick={() => setViewingItem(record)}>
              Xem chi tiết
            </Button>
          );
        }

        if (isWithdrawDone) {
          return (
            <Button size="small" onClick={() => setViewingItem(record)}>
              Xem biên lai
            </Button>
          );
        }

        return (
          <Button size="small" onClick={() => setViewingItem(record)}>
            Xem chi tiết
          </Button>
        );
      },
    },
  ];

  return (
    <Space direction="vertical" size={16} style={{ width: "100%" }}>
      <Space style={{ width: "100%", justifyContent: "space-between" }}>
        <Title level={3} style={{ margin: 0 }}>
          Lịch sử giao dịch
        </Title>
        <Button onClick={fetchHistory} loading={loading}>
          Làm mới
        </Button>
      </Space>

      <Tabs
        activeKey={activeStatusTab}
        onChange={(key) => setActiveStatusTab(key as StatusTabKey)}
        items={[
          { key: "all", label: `Tất cả (${countByTab.all})` },
          { key: "pending", label: `Chờ xử lý (${countByTab.pending})` },
          { key: "success", label: `Thành công (${countByTab.success})` },
          { key: "failed", label: `Thất bại (${countByTab.failed})` },
        ]}
      />

      <Space>
        <Text strong>Lọc loại giao dịch:</Text>
        <Select<TypeFilter>
          value={typeFilter}
          onChange={setTypeFilter}
          style={{ width: 170 }}
          options={[
            { value: "ALL", label: "Tất cả" },
            { value: "DEPOSIT", label: "Chỉ Nạp" },
            { value: "WITHDRAW", label: "Chỉ Rút" },
          ]}
        />
      </Space>

      <Table
        rowKey="id"
        columns={columns}
        dataSource={data}
        loading={loading}
        pagination={{ pageSize: 10, showSizeChanger: true }}
        scroll={{ x: 1800 }}
      />

      <Modal
        title="Chi tiết giao dịch"
        open={Boolean(viewingItem)}
        onCancel={() => setViewingItem(null)}
        footer={null}
      >
        {viewingItem && (
          <Space direction="vertical" size={12} style={{ width: "100%" }}>
            <div style={{ display: "flex", justifyContent: "space-between", paddingBottom: 8, borderBottom: "1px solid #f0f0f0" }}>
              <Text><b>Mã GD:</b></Text>
              <Text>{viewingItem.trans_code}</Text>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", paddingBottom: 8, borderBottom: "1px solid #f0f0f0" }}>
              <Text><b>Người dùng:</b></Text>
              <Text>{viewingItem.user.full_name} - {viewingItem.user.phone}</Text>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", paddingBottom: 8, borderBottom: "1px solid #f0f0f0" }}>
              <Text><b>Loại GD:</b></Text>
              <Text>{getTypeTag(viewingItem.type)}</Text>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", paddingBottom: 8, borderBottom: "1px solid #f0f0f0" }}>
              <Text><b>Số tiền:</b></Text>
              <Text strong style={{ color: viewingItem.type.toUpperCase() === "DEPOSIT" ? "#52c41a" : "#ff4d4f" }}>
                {viewingItem.type === "DEPOSIT" ? "+" : "-"} {formatCurrency(viewingItem.amount)}
              </Text>
            </div>
            <div style={{ paddingBottom: 8, borderBottom: "1px solid #f0f0f0" }}>
              <Text><b>Chi tiết thanh toán:</b></Text>
              <div style={{ marginTop: 6, paddingLeft: 16 }}>
                {viewingItem.type.toUpperCase() === "DEPOSIT" ? (
                  <>
                    <div>{getTypeText(viewingItem.payment_detail?.method || "—")}</div>
                    <div style={{ fontSize: 12, color: "#8c8c8c" }}>Ref: {viewingItem.payment_detail?.gateway_ref || "—"}</div>
                  </>
                ) : (
                  <>
                    <div>{getTypeText(viewingItem.payment_detail?.method || "—")}</div>
                    <div style={{ fontSize: 12, color: "#8c8c8c" }}>{viewingItem.payment_detail?.account_number || "—"}</div>
                    <div style={{ fontSize: 12, color: "#8c8c8c" }}>{viewingItem.payment_detail?.account_holder || "—"}</div>
                  </>
                )}
              </div>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", paddingBottom: 8, borderBottom: "1px solid #f0f0f0" }}>
              <Text><b>Chuỗi khối:</b></Text>
              <Text>{viewingItem.tx_hash ? <Tooltip title={viewingItem.tx_hash}><a href={`${process.env.NEXT_PUBLIC_BLOCKCHAIN_EXPLORER_URL || "#"}${viewingItem.tx_hash}`} target="_blank" rel="noreferrer">🔗 Xem</a></Tooltip> : "—"}</Text>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", paddingBottom: 8, borderBottom: "1px solid #f0f0f0" }}>
              <Text><b>Thời gian:</b></Text>
              <Text>{formatDateTime(viewingItem.created_at)}</Text>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <Text><b>Trạng thái:</b></Text>
              <Text>{getStatusTag(viewingItem.status)}</Text>
            </div>
          </Space>
        )}
      </Modal>

      {/* <Text type="secondary">
        Gợi ý: cấu hình biến môi trường <Text code>NEXT_PUBLIC_BLOCKCHAIN_EXPLORER_URL</Text> để link blockchain mở đúng explorer.
      </Text> */}
    </Space>
  );
}