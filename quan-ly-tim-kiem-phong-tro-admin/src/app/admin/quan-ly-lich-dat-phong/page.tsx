'use client';

import { formatId } from '@/lib/formatId';
import { tranlateStatus } from '@/lib/tranlateStatus';
import { CheckCircleOutlined, CloseCircleOutlined, EyeOutlined, SafetyOutlined } from '@ant-design/icons';
import { Button, Descriptions, message, Modal, Space, Spin, Table, Tag } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import React, { useEffect, useState } from 'react';

interface BookingData {
  booking_id: string;
  owner_name: string;
  owner_phone: string;
  guest_name: string;
  guest_phone: string;
  checkin: string;
  checkout: string;
  price: string;
  status: 'pending' | 'approved'| 'cancelled';
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
      pending: { color: 'orange', text: tranlateStatus.tranlateToVietnameseStatusBooking('pending') },
      approved: { color: 'blue', text: tranlateStatus.tranlateToVietnameseStatusBooking('approved') },
      cancelled: { color: 'red', text: tranlateStatus.tranlateToVietnameseStatusBooking('cancelled') },
    };
    const config = statusConfig[status] || { color: 'default', text: status };
    return <Tag color={config.color}>{config.text}</Tag>;
  };

  const handleViewDetail = (record: BookingData) => {
    setSelectedBooking(record);
    setIsDetailModalVisible(true);
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
      width: 200,
      render: (_, record) => (
        <div>
          <div style={{ fontWeight: 500 }}>{record.owner_name}</div>
          <div style={{ fontSize: '12px', color: '#666' }}>{record.owner_phone}</div>
        </div>
      ),
    },
    {
      title: 'Người thuê',
      key: 'guest',
      width: 200,
      render: (_, record) => (
        <div>
          <div style={{ fontWeight: 500 }}>{record.guest_name}</div>
          <div style={{ fontSize: '12px', color: '#666' }}>{record.guest_phone}</div>
        </div>
      ),
    },
    {
      title: 'Phòng',
      dataIndex: 'room_name',
      key: 'room_name',
      width: 220,
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
      width: 200,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="primary"
            icon={<EyeOutlined />}
            size="small"
            onClick={() => handleViewDetail(record)}
          >
            Xem
          </Button>
          {(record.status === 'approved' || record.status === 'cancelled') && (
            <Button
              icon={<SafetyOutlined />}
              size="small"
              onClick={() => handleCheckIntegrity(record)}
              disabled={!record.transaction_hash}
            >
              Kiểm tra
            </Button>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ marginBottom: '20px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 600, margin: 0 }}>
          Quản lý đặt phòng
        </h1>
        <p style={{ color: '#666', marginTop: '8px' }}>
          Quản lý và theo dõi tất cả các đơn đặt phòng trong hệ thống
        </p>
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
        onCancel={() => setIsDetailModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setIsDetailModalVisible(false)}>
            Đóng
          </Button>,
        ]}
        width={700}
      >
        {selectedBooking && (
          <Descriptions bordered column={2}>
            <Descriptions.Item label="Booking ID" span={2}>
              <strong>{formatId.formatBookingId(selectedBooking.booking_id)}</strong>
            </Descriptions.Item>
            
            <Descriptions.Item label="Trạng thái" span={2}>
              {getStatusTag(selectedBooking.status)}
            </Descriptions.Item>

            <Descriptions.Item label="Tên phòng" span={2}>
              {selectedBooking.room_name}
            </Descriptions.Item>

            <Descriptions.Item label="Chủ căn hộ">
              {selectedBooking.owner_name}
            </Descriptions.Item>
            <Descriptions.Item label="SĐT chủ căn hộ">
              {selectedBooking.owner_phone}
            </Descriptions.Item>

            <Descriptions.Item label="Người thuê">
              {selectedBooking.guest_name}
            </Descriptions.Item>
            <Descriptions.Item label="SĐT người thuê">
              {selectedBooking.guest_phone}
            </Descriptions.Item>

            <Descriptions.Item label="Ngày check-in">
              {formatDateTime(selectedBooking.checkin)}
            </Descriptions.Item>
            <Descriptions.Item label="Ngày check-out">
              {formatDateTime(selectedBooking.checkout)}
            </Descriptions.Item>

            <Descriptions.Item label="Giá thuê" span={2}>
              <span style={{ fontSize: '16px', fontWeight: 600, color: '#1890ff' }}>
                {formatCurrency(selectedBooking.price)}
              </span>
            </Descriptions.Item>

            {selectedBooking.transaction_hash && (
              <Descriptions.Item label="Transaction Hash" span={2}>
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
            )}
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default QuanLyLichDatPhongPage;
