"use client";
import { formatId } from "@/lib/formatId";
import { tranlateStatus } from "@/lib/tranlateStatus";
import type { TableColumnsType } from "antd";
import { Button, Flex, Input, message, Space, Table, Typography } from "antd";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

const { Search } = Input;

interface Post {
  codePost: string;
  title: string;
  author: string;
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  status: string;
}

interface TableData {
  postId: string;
  maBaiDang: string;
  tieuDe: string;
  nguoiDang: string;
  ngayDang: string;
  trangThai: string;
}

export default function Page() {
  const router = useRouter();
  const [data, setData] = useState<TableData[]>([]);
  const [loading, setLoading] = useState(false);
  const [originalData, setOriginalData] = useState<TableData[]>([]);

  // Fetch posts from API
  const fetchPosts = async () => {
    setLoading(true);
    try {
      const response = await fetch("/api/posts");
      const result = await response.json();

      if (result.status === "success" && result.data) {
        // Transform API data to table format
        const transformedData: TableData[] = result.data.map((post: Post) => {
          // Convert timestamp to date string
          const date = new Date(post.createdAt._seconds * 1000);
          const dateStr = date.toLocaleDateString("vi-VN");

          return {
            postId: post.codePost,
            maBaiDang: formatId.formatPostId(post.codePost),
            tieuDe: post.title,
            nguoiDang: post.author,
            ngayDang: dateStr,
            trangThai: tranlateStatus.tranlateToVietnameseStatusPost(post.status),
          };
        });

        setData(transformedData);
        setOriginalData(transformedData);
      } else {
        message.error("Không thể tải danh sách bài đăng");
      }
    } catch (error) {
      console.error("Error fetching posts:", error);
      message.error("Lỗi khi tải dữ liệu");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPosts();
  }, []);

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
            onClick={() => {
              console.log("Xem", record.postId);
              router.push(`/admin/quan-ly-bai-dang/${record.postId}`);
            }}
          >
            Xem
          </Button>
          {record.trangThai === "Đang chờ duyệt" && (
            <>
              <Button
                type="primary"
                onClick={async () => {
                  try {
                    const response = await fetch(`/api/posts/${record.postId}/approve`, {
                      method: "POST",
                    });
                    const result = await response.json();
                    if (result.status === "success") {
                      message.success("Duyệt bài đăng thành công");
                      fetchPosts();
                    } else {
                      message.error(result.message || "Có lỗi xảy ra");
                    }
                  } catch (error) {
                    console.error("Error approving post:", error);
                    message.error("Lỗi khi duyệt bài đăng");
                  }
                }}
              >
                Duyệt
              </Button>
              <Button
                danger
                onClick={async () => {
                  try {
                    const response = await fetch(`/api/posts/${record.postId}/reject`, {
                      method: "POST",
                    });
                    const result = await response.json();
                    if (result.status === "success") {
                      message.success("Từ chối bài đăng thành công");
                      fetchPosts();
                    } else {
                      message.error(result.message || "Có lỗi xảy ra");
                    }
                  } catch (error) {
                    console.error("Error rejecting post:", error);
                    message.error("Lỗi khi từ chối bài đăng");
                  }
                }}
              >
                Từ chối
              </Button>
            </>
          )}
          {record.trangThai === "Đã duyệt" && (
            <Button
              onClick={async () => {
                try {
                  const response = await fetch(`/api/posts/${record.postId}/hide`, {
                    method: "POST",
                  });
                  const result = await response.json();
                  if (result.status === "success") {
                    message.success("Ẩn bài đăng thành công");
                    fetchPosts();
                  } else {
                    message.error(result.message || "Có lỗi xảy ra");
                  }
                } catch (error) {
                  console.error("Error hiding post:", error);
                  message.error("Lỗi khi ẩn bài đăng");
                }
              }}
            >
              Ẩn
            </Button>
          )}
          {record.trangThai === "Đã từ chối" && (
            <Button
              type="primary"
              onClick={async () => {
                try {
                  const response = await fetch(`/api/posts/${record.postId}/approve`, {
                    method: "POST",
                  });
                  const result = await response.json();
                  if (result.status === "success") {
                    message.success("Duyệt bài đăng thành công");
                    fetchPosts();
                  } else {
                    message.error(result.message || "Có lỗi xảy ra");
                  }
                } catch (error) {
                  console.error("Error approving post:", error);
                  message.error("Lỗi khi duyệt bài đăng");
                }
              }}
            >
              Duyệt
            </Button>
          )}
          {record.trangThai === "Đã ẩn" && (
            <Button
              type="primary"
              onClick={async () => {
                try {
                  const response = await fetch(`/api/posts/${record.postId}/approve`, {
                    method: "POST",
                  });
                  const result = await response.json();
                  if (result.status === "success") {
                    message.success("Hiển thị lại bài đăng thành công");
                    fetchPosts();
                  } else {
                    message.error(result.message || "Có lỗi xảy ra");
                  }
                } catch (error) {
                  console.error("Error showing post:", error);
                  message.error("Lỗi khi hiển thị lại bài đăng");
                }
              }}
            >
              Hiển thị lại
            </Button>
          )}
        </Space>
      ),
    },
  ];
  const onSearch = (value: string) => {
    console.log("Tìm kiếm:", value);
    
    if (!value.trim()) {
      // If search is empty, restore original data
      setData(originalData);
      return;
    }

    // Filter data based on search term
    const filtered = originalData.filter((item) =>
      item.tieuDe.toLowerCase().includes(value.toLowerCase()) ||
      item.maBaiDang.toLowerCase().includes(value.toLowerCase()) ||
      item.nguoiDang.toLowerCase().includes(value.toLowerCase())
    );
    
    setData(filtered);
  };

  return (
    <div style={{ padding: 24 }}>
      <Typography.Title level={2}>Danh sách bài đăng</Typography.Title>
      <Flex justify="flex-end" style={{ marginBottom: 16 }}>
        <Search
          placeholder="Tìm kiếm bài đăng..."
          allowClear
          onSearch={onSearch}
          style={{ width: 300 }}
        />
      </Flex>

      <Table
        columns={columns}
        dataSource={data}
        rowKey="maBaiDang"
        pagination={{ pageSize: 10 }}
        loading={loading}
      />
    </div>
  );
}
