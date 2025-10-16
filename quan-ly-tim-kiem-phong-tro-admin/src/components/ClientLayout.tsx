"use client";

import { usePathname } from "next/navigation";
import { AppLayout } from "@/components";

export default function ClientLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const noLayout = pathname.startsWith("/auth"); 

  return noLayout ? <>{children}</> : <AppLayout>{children}</AppLayout>;
}
