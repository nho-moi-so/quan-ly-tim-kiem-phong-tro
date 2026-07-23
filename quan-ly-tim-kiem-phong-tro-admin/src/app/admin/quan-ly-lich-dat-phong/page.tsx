'use client';

import { formatId } from '@/lib/formatId';
import { tranlateStatus } from '@/lib/tranlateStatus';
import { CheckCircleOutlined, CloseCircleOutlined, EyeOutlined } from '@ant-design/icons';
import { Button, Col, DatePicker, Descriptions, Divider, Form, Input, InputNumber, message, Modal, Row, Spin, Table, Tag } from 'antd';
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
  status: string;
  room_name: string;
  transaction_hash?: string;
}



const QuanLyLichDatPhongPage: React.FC = () => {
  const [bookings, setBookings] = useState<BookingData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedBooking, setSelectedBooking] = useState<BookingData | null>(null);
  const [isDetailModalVisible, setIsDetailModalVisible] = useState(false);
  const [isVerifyingIntegrity, setIsVerifyingIntegrity] = useState(false);

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
      created: { color: 'orange', text: tranlateStatus.tranlateToVietnameseStatusBooking('created') },
      active: { color: 'blue', text: tranlateStatus.tranlateToVietnameseStatusBooking('active') },
      completed: { color: 'green', text: tranlateStatus.tranlateToVietnameseStatusBooking('completed') },
      cancelled: { color: 'red', text: tranlateStatus.tranlateToVietnameseStatusBooking('cancelled') },
    };
    const config = statusConfig[status?.toLowerCase()] || { color: 'default', text: status };
    return <Tag color={config.color}>{config.text}</Tag>;
  };

  const handleViewDetail = (record: BookingData) => {
    setSelectedBooking(record);
    setIsDetailModalVisible(true);
  };

  const handleSave = async () => {
    if (!selectedBooking) return;
    try {
      setIsVerifyingIntegrity(true);
      const values = {
        booking_id: selectedBooking.booking_id,
        owner_email: selectedBooking.owner_email,
        guest_email: selectedBooking.guest_email,
        checkin: selectedBooking.checkin ? dayjs(selectedBooking.checkin) : undefined,
        checkout: selectedBooking.checkout ? dayjs(selectedBooking.checkout) : undefined,
        price: typeof selectedBooking.price === 'string' ? parseInt(selectedBooking.price, 10) : selectedBooking.price,
        room_name: selectedBooking.room_name,
      };
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
                <li>Tổng giá: {values.price} VND</li>
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
      title: 'ID',
      dataIndex: 'booking_id',
      key: 'booking_id',
      width: 120,
      fixed: 'left',
      render: (id) => formatId.formatBookingId(id),
    },
    {
      title: 'Chủ căn hộ',
      key: 'owner',
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
    },
    {
      title: 'Check-in',
      dataIndex: 'checkin',
      key: 'checkin',
      render: (date) => {
        if (!date) return '—';
        const d = dayjs(date);
        return (
          <div>
            <div style={{ fontWeight: 600 }}>{d.format('HH:mm')}</div>
            <div style={{ fontSize: '13px', color: '#666' }}>{d.format('DD/MM/YYYY')}</div>
          </div>
        );
      },
    },
    {
      title: 'Check-out',
      dataIndex: 'checkout',
      key: 'checkout',
      render: (date) => {
        if (!date) return '—';
        const d = dayjs(date);
        return (
          <div>
            <div style={{ fontWeight: 600 }}>{d.format('HH:mm')}</div>
            <div style={{ fontSize: '13px', color: '#666' }}>{d.format('DD/MM/YYYY')}</div>
          </div>
        );
      },
    },
    {
      title: 'Tổng giá',
      dataIndex: 'price',
      key: 'price',
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
          scroll={{ x: 'max-content' }}
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
        }}
        footer={[
          <Button key="close" onClick={() => {
            setIsDetailModalVisible(false);
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
          <Descriptions bordered size="small" column={2} labelStyle={{ width: '130px' }}>
            <Descriptions.Item label="Booking ID" span={2}>
              {formatId.formatBookingId(selectedBooking.booking_id)}
            </Descriptions.Item>

            <Descriptions.Item label="Trạng thái">
              {getStatusTag(selectedBooking.status)}
            </Descriptions.Item>

            <Descriptions.Item label="Tên phòng">
              {selectedBooking.room_name}
            </Descriptions.Item>

            <Descriptions.Item label="Chủ căn hộ" span={2}>
              <div style={{ fontWeight: 500 }}>{selectedBooking.owner_name}</div>
              <div style={{ fontSize: 13, color: '#666' }}>{selectedBooking.owner_email || '—'}</div>
              <div style={{ fontSize: 13, color: '#666' }}>{selectedBooking.owner_phone || '—'}</div>
            </Descriptions.Item>

            <Descriptions.Item label="Người thuê" span={2}>
              <div style={{ fontWeight: 500 }}>{selectedBooking.guest_name}</div>
              <div style={{ fontSize: 13, color: '#666' }}>{selectedBooking.guest_email || '—'}</div>
              <div style={{ fontSize: 13, color: '#666' }}>{selectedBooking.guest_phone || '—'}</div>
            </Descriptions.Item>

            <Descriptions.Item label="Nhận phòng">
              {selectedBooking.checkin ? formatDateTime(selectedBooking.checkin) : '—'}
            </Descriptions.Item>

            <Descriptions.Item label="Trả phòng">
              {selectedBooking.checkout ? formatDateTime(selectedBooking.checkout) : '—'}
            </Descriptions.Item>

            <Descriptions.Item label="Giá thuê" span={2}>
              <span style={{ fontWeight: 'bold', color: '#1890ff', fontSize: 16 }}>
                {formatCurrency(selectedBooking.price)}
              </span>
            </Descriptions.Item>

            {/* {selectedBooking.transaction_hash && (
              <Descriptions.Item label="Blockchain Hash" span={2}>
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
              </Descriptions.Item>
            )} */}
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default QuanLyLichDatPhongPage;
