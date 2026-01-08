"use client";
import { Button, Form, Input, message, Modal, notification, Popconfirm, Space, Table, Typography } from "antd";
import type { ColumnsType } from "antd/es/table";
import { useEffect, useState } from "react";

type DeviceTypeRow = {
  Id: string;
  Name: string;
  Description?: string;
};

export default function LoaiThietBiPage() {
  const [form] = Form.useForm();
  const [editForm] = Form.useForm();
  const [typeRows, setTypeRows] = useState<DeviceTypeRow[]>([]);
  const [addingType, setAddingType] = useState(false);
  const [checkingId, setCheckingId] = useState(false);
  const [idCheckResult, setIdCheckResult] = useState<"available" | "exists" | null>(null);
  const [viewModalOpen, setViewModalOpen] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [selectedDevice, setSelectedDevice] = useState<DeviceTypeRow | null>(null);
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    fetchDeviceTypes();
  }, []);

  const fetchDeviceTypes = async () => {
    try {
      const res = await fetch("/api/iot/device-types", { cache: "no-store" });
      const json = await res.json();
      if (json.status === "success") {
        setTypeRows(json.data || []);
      }
    } catch (e: any) {
      message.error(e?.message || "Lỗi tải loại thiết bị");
    }
  };

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

  const handleCheckDeviceTypeId = async () => {
    const idValue = form.getFieldValue("id");
    if (!idValue) {
      message.warning("Nhập ID thiết bị trước khi kiểm tra");
      return;
    }

    setCheckingId(true);
    setIdCheckResult(null);
    try {
      const res = await fetch(`/api/iot/device-types/${encodeURIComponent(idValue)}`, { cache: "no-store" });
      const json = await res.json();
      if (json.status === "success") {
        if (json.exists) {
          setIdCheckResult("exists");
          message.warning("ID đã tồn tại, vui lòng chọn ID khác");
        } else {
          setIdCheckResult("available");
          message.success("ID khả dụng");
        }
      } else {
        message.error(json.message || "Kiểm tra ID thất bại");
      }
    } catch (e: any) {
      message.error(e?.message || "Kiểm tra ID thất bại");
    } finally {
      setCheckingId(false);
    }
  };

  const typeColumns: ColumnsType<DeviceTypeRow> = [
    { title: "ID", dataIndex: "Id", key: "Id" },
    { title: "Tên", dataIndex: "Name", key: "Name" },
    {
      title: "Hành động",
      key: "actions",
      render: (_, record) => (
        <Space>
          <Button onClick={() => handleView(record)}>Xem</Button>
          <Button type="primary" onClick={() => handleEdit(record)}>Chỉnh sửa</Button>
          <Popconfirm 
            title="Xác nhận xóa loại thiết bị?" 
            onConfirm={() => handleDelete(record.Id)}
          >
            <Button danger type="primary">Xóa</Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const handleView = (device: DeviceTypeRow) => {
    setSelectedDevice(device);
    setViewModalOpen(true);
  };

  const handleEdit = (device: DeviceTypeRow) => {
    setSelectedDevice(device);
    editForm.setFieldsValue({
      name: device.Name,
      description: device.Description,
    });
    setEditModalOpen(true);
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await fetch(`/api/iot/device-types/${encodeURIComponent(id)}`, {
        method: "DELETE",
      });
      const json = await res.json();
      if (json.status === "success") {
        showNotice("success", "Đã xóa loại thiết bị", "Loại thiết bị đã được xóa thành công.");
        setTypeRows((prev) => prev.filter((r) => r.Id !== id));
      } else {
        showNotice("error", "Xóa thất bại", json.message || "Không thể xóa loại thiết bị.");
      }
    } catch (e: any) {
      message.error(e?.message || "Lỗi xóa loại thiết bị");
    }
  };

  const handleUpdate = async (values: any) => {
    if (!selectedDevice) return;

    setUpdating(true);
    try {
      const res = await fetch(`/api/iot/device-types/${encodeURIComponent(selectedDevice.Id)}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name: values.name, description: values.description }),
      });
      const json = await res.json();
      if (json.status === "success") {
        showNotice("success", "Đã cập nhật loại thiết bị", values.name);
        fetchDeviceTypes();
        setEditModalOpen(false);
        editForm.resetFields();
        setSelectedDevice(null);
      } else {
        showNotice("error", "Cập nhật thất bại", json.message || "Không thể cập nhật thiết bị.");
      }
    } catch (e: any) {
      showNotice("error", "Lỗi", e?.message || "Không thể cập nhật thiết bị.");
    } finally {
      setUpdating(false);
    }
  };

  return (
    <div style={{ padding: 16 }}>
      <Typography.Title level={4}>Các loại thiết bị IoT được hỗ trợ</Typography.Title>

      <Form
        form={form}
        layout="inline"
        onFinish={async (values) => {
          setAddingType(true);
          try {
            const res = await fetch("/api/iot/device-types", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({ id: values.id, name: values.name, description: values.description }),
            });
            const json = await res.json();
            if (json.status === "success") {
              showNotice("success", "Đã thêm loại thiết bị", values.name);
              fetchDeviceTypes();
              form.resetFields();
              setIdCheckResult(null);
            } else {
              showNotice("error", "Thêm thất bại", json.message || "Không thể thêm thiết bị.");
            }
          } catch (e: any) {
            showNotice("error", "Lỗi", e?.message || "Không thể thêm thiết bị.");
          } finally {
            setAddingType(false);
          }
        }}
        style={{ marginBottom: 12 }}
      >
        <Form.Item name="id" rules={[{ required: true, message: "Nhập ID thiết bị" }]}> 
          <Input placeholder="ID thiết bị" allowClear />
        </Form.Item>
        <Form.Item>
          <Button onClick={handleCheckDeviceTypeId} loading={checkingId}>Kiểm tra ID</Button>
        </Form.Item>
        <Form.Item name="name" rules={[{ required: true, message: "Nhập tên thiết bị" }]}> 
          <Input placeholder="Tên thiết bị" allowClear />
        </Form.Item>
        <Form.Item name="description">
          <Input placeholder="Mô tả" allowClear />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit" loading={addingType}>Thêm thiết bị</Button>
        </Form.Item>
      </Form>

      <Table
        rowKey={(r) => r.Id}
        columns={typeColumns}
        dataSource={typeRows}
        pagination={{ pageSize: 10 }}
      />

      {/* View Modal */}
      <Modal
        title="Chi tiết loại thiết bị"
        open={viewModalOpen}
        onCancel={() => {
          setViewModalOpen(false);
          setSelectedDevice(null);
        }}
        footer={[
          <Button key="close" onClick={() => {
            setViewModalOpen(false);
            setSelectedDevice(null);
          }}>
            Đóng
          </Button>,
        ]}
      >
        {selectedDevice && (
          <div>
            <p><strong>ID:</strong> {selectedDevice.Id}</p>
            <p><strong>Tên:</strong> {selectedDevice.Name}</p>
            <p><strong>Mô tả:</strong> {selectedDevice.Description || "Không có"}</p>
          </div>
        )}
      </Modal>

      {/* Edit Modal */}
      <Modal
        title="Chỉnh sửa loại thiết bị"
        open={editModalOpen}
        onCancel={() => {
          setEditModalOpen(false);
          setSelectedDevice(null);
          editForm.resetFields();
        }}
        footer={null}
      >
        <Form
          form={editForm}
          layout="vertical"
          onFinish={handleUpdate}
        >
          <Form.Item label="ID">
            <Input value={selectedDevice?.Id} disabled />
          </Form.Item>
          <Form.Item 
            name="name" 
            label="Tên thiết bị"
            rules={[{ required: true, message: "Nhập tên thiết bị" }]}
          >
            <Input placeholder="Tên thiết bị" />
          </Form.Item>
          <Form.Item name="description" label="Mô tả">
            <Input.TextArea placeholder="Mô tả" rows={3} />
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit" loading={updating}>
                Cập nhật
              </Button>
              <Button onClick={() => {
                setEditModalOpen(false);
                setSelectedDevice(null);
                editForm.resetFields();
              }}>
                Hủy
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
