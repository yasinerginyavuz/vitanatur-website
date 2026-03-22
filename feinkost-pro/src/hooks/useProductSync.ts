"use client";

import { useEffect } from "react";
import { useAdminStore } from "@/store/admin-store";

/**
 * Hook that fetches products from Supabase on mount.
 * Use this in ConditionalShell or root layout to hydrate the store.
 */
export function useProductSync() {
  const fetchProducts = useAdminStore((s) => s.fetchProducts);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);
}
