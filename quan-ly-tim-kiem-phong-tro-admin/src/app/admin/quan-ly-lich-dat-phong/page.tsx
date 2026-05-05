'use client';

import { formatId } from '@/lib/formatId';
import { tranlateStatus } from '@/lib/tranlateStatus';
import { CheckCircleOutlined, CloseCircleOutlined, EyeOutlined } from '@ant-design/icons';
import { Button, Col, DatePicker, Divider, Form, Input, InputNumber, message, Modal, Row, Spin, Table, Tag } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import React, { useEffect, useState } from 'react';

interface BookingData {
  booking_id: string;
  owner_name: string;
  owner_phone: string;
  owner_email?: string;
  guest_name: string;
  guest_phone: string;
  guest_email?: string;
  checkin: string;
  checkout: string;
  price: string;
  status: 'pending' | 'approved'| 'cancelled' | 'completed';
  room_name: string;
  transaction_hash?: string;
}



const QuanLyLichDatPhongPage: React.FC = () => {
  const [bookings, setBookings] = useState<BookingData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedBooking, setSelectedBooking] = useState<BookingData | null>(null);
  const [isDetailModalVisible, setIsDetailModalVisible] = useState(false);
  const [isVerifyingIntegrity, setIsVerifyingIntegrity] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchBookings();
  }, []);

  const fetchBookings = async () => {
    try {
      setIsLoading(true);
      const response = await fetch('/api/bookings');
      
      if (!response.ok) {
        throw new Error('Failed to fetch bookings');
      }
      
      const result = await response.json();
      
      if (result.success && result.data) {
        setBookings(result.data);
      } 
    } catch (error) {
      console.error('Error fetching bookings:', error);
      message.error('Lỗi khi tải dữ liệu booking');
    } finally {
      setIsLoading(false);
    }
  };

  const formatCurrency = (amount: string | number) => {
    const numAmount = typeof amount === 'string' ? parseInt(amount, 10) : amount;
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(numAmount);
  };

  const formatDateTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
    });
  };

  const getStatusTag = (status: string) => {
    const statusConfig: Record<string, { color: string; text: string }> = {
      pending: { color: 'orange', text: tranlateStatus.tranlateToVietnameseStatusBooking('pending') },
      approved: { color: 'blue', text: tranlateStatus.tranlateToVietnameseStatusBooking('approved') },
      cancelled: { color: 'red', text: tranlateStatus.tranlateToVietnameseStatusBooking('cancelled') },
      completed: { color: 'green', text: tranlateStatus.tranlateToVietnameseStatusBooking('completed') },
    };
    const config = statusConfig[status] || { color: 'default', text: status };
    return <Tag color={config.color}>{config.text}</Tag>;
  };

  const handleViewDetail = (record: BookingData) => {
    setSelectedBooking(record);
    setIsDetailModalVisible(true);
    setIsEditing(true);
    form.setFieldsValue({
      booking_id: record.booking_id,
      room_name: record.room_name,
      owner_email: record.owner_email,
      guest_email: record.guest_email,
      checkin: record.checkin ? dayjs(record.checkin) : undefined,
      checkout: record.checkout ? dayjs(record.checkout) : undefined,
      price: parseInt(record.price, 10),
    });
  };

  const handleSave = async () => {
    try {
      setIsVerifyingIntegrity(true);
      const values = await form.validateFields();
      const payload = {
        booking_id: values.booking_id,
        owner_email: values.owner_email,
        guest_email: values.guest_email,
        checkin: values.checkin ? values.checkin.toISOString() : undefined,
        checkout: values.checkout ? values.checkout.toISOString() : undefined,
        price: typeof values.price === 'number' ? values.price : parseInt(values.price, 10),
        room_name: values.room_name,
        transaction_hash: selectedBooking?.transaction_hash,
      };
      
      console.log('[handleSave] Sending payload:', payload);
      
      const res = await fetch('/api/bookings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      
      const json = await res.json();
      console.log('[handleSave] Response:', json);
      
      if (!res.ok) {
        throw new Error(json.message || 'Verify failed');
      }
      
      if (!json.success) {
        throw new Error('Verification failed');
      }
      
      const isValid = json.result?.isValid ?? false;
      console.log('[handleSave] DEBUG - isValid value:', isValid, 'type:', typeof isValid);
      
      if (isValid) {
        Modal.success({
          title: '✅ Kiểm tra tính toàn vẹn thành công',
          content: (
            <div>
              <p><strong>Booking ID:</strong> {formatId.formatBookingId(values.booking_id)}</p>
              <p><strong>Trạng thái:</strong> <span style={{ color: '#52c41a', fontWeight: 'bold' }}>Đã xác minh</span></p>
              <p style={{ color: '#52c41a', marginTop: '12px' }}>
                <CheckCircleOutlined /> Dữ liệu trên blockchain khớp với dữ liệu hệ thống
              </p>
              <p style={{ marginTop: '8px', fontSize: '13px', color: '#666' }}>
                Booking này đã được xác minh thành công trên blockchain.
              </p>
            </div>
          ),
        });
      } else {
        Modal.error({
          title: '⚠️ Cảnh báo: Phát hiện bất thường',
          content: (
            <div>
              <p><strong>Booking ID:</strong> {values.booking_id}</p>
              <p><strong>Trạng thái:</strong> <span style={{ color: '#ff4d4f', fontWeight: 'bold' }}>Không khớp</span></p>
              <p style={{ color: '#ff4d4f', marginTop: '12px' }}>
                <CloseCircleOutlined /> Dữ liệu trên blockchain không khớp với dữ liệu hệ thống
              </p>
              <p style={{ marginTop: '8px', fontSize: '13px' }}>
                Có thể đã xảy ra sự thay đổi trái phép. Vui lòng kiểm tra kỹ các chi tiết sau:
              </p>
              <ul style={{ marginTop: '8px', fontSize: '13px' }}>
                <li>Email chủ căn hộ: {values.owner_email}</li>
                <li>Email người thuê: {values.guest_email}</li>
                <li>Giá: {values.price} VND</li>
                <li>Check-in: {values.checkin?.format('DD/MM/YYYY HH:mm')}</li>
                <li>Check-out: {values.checkout?.format('DD/MM/YYYY HH:mm')}</li>
              </ul>
            </div>
          ),
        });
      }
    } catch (error) {
      console.error('Verify failed:', error);
      message.error(`Lỗi: ${error instanceof Error ? error.message : 'Vui lòng kiểm tra lại các trường!'}`);
    } finally {
      setIsVerifyingIntegrity(false);
    }
  };

  const handleCheckIntegrity = async (record: BookingData) => {
    if (!record.transaction_hash) {
      message.warning('Booking này chưa có transaction hash trên blockchain');
      return;
    }

    setIsVerifyingIntegrity(true);
    
    // Simulate blockchain verification
    setTimeout(() => {
      setIsVerifyingIntegrity(false);
      
      // Mock verification result - random success/fail for demo
      const isValid = Math.random() > 0.2; // 80% success rate
      
      if (isValid) {
        Modal.success({
          title: 'Kiểm tra tính toàn vẹn thành công',
          content: (
            <div>
              <p><strong>ID:</strong> {formatId.formatBookingId(record.booking_id)}</p>
              <p><strong>Transaction Hash:</strong></p>
              <p style={{ wordBreak: 'break-all', fontSize: '12px', color: '#666' }}>
                {record.transaction_hash}
              </p>
              <p style={{ color: '#52c41a', marginTop: '12px' }}>
                <CheckCircleOutlined /> Dữ liệu trên blockchain khớp với dữ liệu hệ thống
              </p>
            </div>
          ),
        });
      } else {
        Modal.error({
          title: 'Cảnh báo: Phát hiện bất thường',
          content: (
            <div>
              <p><strong>Booking ID:</strong> {record.booking_id}</p>
              <p style={{ color: '#ff4d4f', marginTop: '12px' }}>
                <CloseCircleOutlined /> Dữ liệu trên blockchain không khớp với dữ liệu hệ thống
              </p>
              <p style={{ marginTop: '8px', fontSize: '13px' }}>
                Có thể đã xảy ra sự thay đổi trái phép. Vui lòng kiểm tra kỹ.
              </p>
            </div>
          ),
        });
      }
    }, 2000);
  };

  const columns: ColumnsType<BookingData> = [
    {
      title: 'Booking ID',
      dataIndex: 'booking_id',
      key: 'booking_id',
      width: 120,
      fixed: 'left',
      render: (id) => formatId.formatBookingId(id),
    },
    {
      title: 'Chủ căn hộ',
      key: 'owner',
      width: 220,
      render: (_, record) => (
        <div>
          <div style={{ fontWeight: 500 }}>{record.owner_name}</div>
          <div style={{ fontSize: '12px', color: '#666' }}>{record.owner_email || '—'}</div>
        </div>
      ),
    },
    {
      title: 'Người thuê',
      key: 'guest',
      width: 220,
      render: (_, record) => (
        <div>
          <div style={{ fontWeight: 500 }}>{record.guest_name}</div>
          <div style={{ fontSize: '12px', color: '#666' }}>{record.guest_email || '—'}</div>
        </div>
      ),
    },
    {
      title: 'Phòng',
      dataIndex: 'room_name',
      key: 'room_name',
      width: 150,
    },
    {
      title: 'Check-in',
      dataIndex: 'checkin',
      key: 'checkin',
      width: 160,
      render: (date) => formatDateTime(date),
    },
    {
      title: 'Check-out',
      dataIndex: 'checkout',
      key: 'checkout',
      width: 160,
      render: (date) => formatDateTime(date),
    },
    {
      title: 'Giá',
      dataIndex: 'price',
      key: 'price',
      width: 150,
      render: (price) => (
        <span style={{ fontWeight: 500, color: '#1890ff' }}>
          {formatCurrency(price)}
        </span>
      ),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      width: 140,
      render: (status) => getStatusTag(status),
    },
    {
      title: 'Hành động',
      key: 'action',
      fixed: 'right',
      width: 120,
      render: (_, record) => (
        <Button
          type="primary"
          icon={<EyeOutlined />}
          size="small"
          onClick={() => handleViewDetail(record)}
        >
          Xem
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ marginBottom: '20px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 600, margin: 0 }}>
          Quản lý đặt phòng
        </h1>
        {/* <p style={{ color: '#666', marginTop: '8px' }}>
          Quản lý và theo dõi tất cả các đơn đặt phòng trong hệ thống
        </p> */}
      </div>

      <div style={{ marginBottom: 12 }}>
        <Button onClick={fetchBookings} loading={isLoading}>Làm mới</Button>
      </div>
      <Spin spinning={isLoading || isVerifyingIntegrity} tip={isLoading ? "Đang tải dữ liệu..." : "Đang kiểm tra tính toàn vẹn trên blockchain..."}>
        <Table
          columns={columns}
          dataSource={bookings}
          rowKey="booking_id"
          scroll={{ x: 1400 }}
          pagination={{
            pageSize: 10,
            showSizeChanger: true,
            pageSizeOptions: ['5', '10', '20', '50'],
          }}
        />
      </Spin>

      <Modal
        title="Chi tiết đặt phòng"
        open={isDetailModalVisible}
        onCancel={() => {
          setIsDetailModalVisible(false);
          setIsEditing(false);
        }}
        footer={[
          <Button key="close" onClick={() => {
            setIsDetailModalVisible(false);
            setIsEditing(false);
          }}>
            Đóng
          </Button>,
          ...(selectedBooking?.status !== 'pending' ? [
            // <Button 
            //   key="save" 
            //   type="primary" 
            //   icon={<SafetyOutlined spin={isVerifyingIntegrity} />} 
            //   onClick={handleSave}
            //   loading={isVerifyingIntegrity}
            //   title="Kiểm tra tính toàn vẹn của dữ liệu booking trên blockchain. Hệ thống sẽ so sánh dữ liệu trên blockchain với dữ liệu hiện tại để đảm bảo không có sự thay đổi trái phép."
            // >
            //   Kiểm tra Blockchain
            // </Button>
          ] : []),
        ]}
        width={800}
      >
        {selectedBooking && (
          <Form form={form} layout="vertical">
            <Row gutter={16}>
              <Col span={12}>
                <Form.Item label="Booking ID" name="booking_id" rules={[{ required: true, message: 'Vui lòng nhập Booking ID' }]}>
                  <Input />
                </Form.Item>
              </Col>
              <Col span={12}>
                <div style={{ marginBottom: 16 }}>
                  <div style={{ marginBottom: 8, fontSize: 14 }}>Trạng thái</div>
                  {getStatusTag(selectedBooking.status)}
                </div>
              </Col>
            </Row>

            <Form.Item label="Tên phòng" name="room_name" rules={[{ required: true, message: 'Vui lòng nhập tên phòng' }]}>
              <Input placeholder="Nhập tên phòng" />
            </Form.Item>

            <Divider orientation="left">Thông tin chủ căn hộ</Divider>
            <Row gutter={16}>
              <Col span={12}>
                <div style={{ marginBottom: 16 }}>
                  <div style={{ marginBottom: 8, fontSize: 14, color: '#666' }}>Tên chủ căn hộ</div>
                  <div style={{ fontWeight: 500 }}>{selectedBooking.owner_name}</div>
                </div>
              </Col>
              <Col span={12}>
                <Form.Item label="Email chủ căn hộ" name="owner_email" rules={[{ required: true, type: 'email', message: 'Vui lòng nhập email hợp lệ' }]}>
                  <Input placeholder="Nhập email chủ căn hộ" />
                </Form.Item>
              </Col>
            </Row>

            <Divider orientation="left">Thông tin người thuê</Divider>
            <Row gutter={16}>
              <Col span={12}>
                <div style={{ marginBottom: 16 }}>
                  <div style={{ marginBottom: 8, fontSize: 14, color: '#666' }}>Tên người thuê</div>
                  <div style={{ fontWeight: 500 }}>{selectedBooking.guest_name}</div>
                </div>
              </Col>
              <Col span={12}>
                <Form.Item label="Email người thuê" name="guest_email" rules={[{ required: true, type: 'email', message: 'Vui lòng nhập email hợp lệ' }]}>
                  <Input placeholder="Nhập email người thuê" />
                </Form.Item>
              </Col>
            </Row>

            <Divider orientation="left">Thông tin đặt phòng</Divider>
            <Row gutter={16}>
              <Col span={12}>
                <Form.Item label="Checkin" name="checkin" rules={[{ required: true, message: 'Vui lòng chọn Checkin' }]}>
                  <DatePicker showTime format="DD/MM/YYYY HH:mm" style={{ width: '100%' }} />
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item label="Checkout" name="checkout" rules={[{ required: true, message: 'Vui lòng chọn Checkout' }]}>
                  <DatePicker showTime format="DD/MM/YYYY HH:mm" style={{ width: '100%' }} />
                </Form.Item>
              </Col>
            </Row>

            <Form.Item label="Giá thuê" name="price" rules={[{ required: true, message: 'Vui lòng nhập giá thuê' }]}> 
              <InputNumber<number>
                style={{ width: '100%' }}
                formatter={(value) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
                parser={(value) => {
                  const raw = (value ?? '').toString();
                  const digits = raw.replace(/[^0-9]/g, '');
                  return digits ? parseInt(digits, 10) : 0;
                }}
                addonAfter="VND"
                min={0}
              />
            </Form.Item>

            {selectedBooking.transaction_hash && (
              <>
                <Divider orientation="left">Blockchain</Divider>
                <div style={{ marginBottom: 16 }}>
                  <div style={{ marginBottom: 8, fontSize: 14, color: '#666' }}>Transaction Hash</div>
                  <div style={{ 
                    wordBreak: 'break-all', 
                    fontSize: '12px', 
                    fontFamily: 'monospace',
                    backgroundColor: '#f5f5f5',
                    padding: '8px',
                    borderRadius: '4px'
                  }}>
                    {selectedBooking.transaction_hash}
                  </div>
                </div>
              </>
            )}
          </Form>
        )}
      </Modal>
    </div>
  );
};

export default QuanLyLichDatPhongPage;
