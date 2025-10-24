"use client";

import theme from "@/theme/themeConfig";
import { ConfigProvider } from "antd";
import viVN from "antd/locale/vi_VN";
import React from "react";

export function AntdProvider({ children }) {
  return (
    <ConfigProvider
      locale={viVN}
      theme={theme}
    >
      {children}
    </ConfigProvider>
  );
}

export default AntdProvider;
