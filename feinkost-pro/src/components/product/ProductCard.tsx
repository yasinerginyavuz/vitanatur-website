"use client";

import { useState } from "react";
import Link from "next/link";
import { Product, ProductVariant } from "@/types";
import { ImageCarousel } from "@/components/ui/ImageCarousel";
import { useCartStore } from "@/store/cart-store";
import { useLang } from "@/lib/i18n";

interface ProductCardProps {
  product: Product;
}

export function ProductCard({ product }: ProductCardProps) {
  const [selectedVariantId, setSelectedVariantId] = useState<string | null>(
    product.variants.length > 0 ? product.variants[0].id : null
  );
  const addItem = useCartStore((s) => s.addItem);
  const openCart = useCartStore((s) => s.openCart);
  const { t, lang } = useLang();

  const selectedVariant = product.variants.find((v) => v.id === selectedVariantId) ?? (product.variants.length > 0 ? product.variants[0] : null);
  const currentPrice = product.price;

  const isOutOfStock = product.stock === 0;
  const isLowStock = product.stock > 0 && product.stock <= product.lowStockThreshold;

  function handleAddToCart(e: React.MouseEvent) {
    e.preventDefault();
    e.stopPropagation();
    if (isOutOfStock) return;
    addItem(product, selectedVariant);
    openCart();
  }

  return (
    <Link href={`/product/${product.id}`} className="group block">
      <div className="rounded-xl overflow-hidden bg-white shadow-sm transition-all duration-300 ease-out group-hover:shadow-lg group-hover:scale-[1.02] flex flex-col h-full">
        {/* Image area */}
        <div className="relative">
          <ImageCarousel images={product.images} alt={product.name} />
          {/* Stock badges */}
          {isOutOfStock && (
            <span className="absolute top-2.5 left-2.5 px-2.5 py-1 text-xs font-semibold rounded-full bg-red-500 text-white z-10">
              {t("stock.out_of_stock")}
            </span>
          )}
          {isLowStock && (
            <span className="absolute top-2.5 left-2.5 px-2.5 py-1 text-xs font-semibold rounded-full bg-amber-500 text-white z-10">
              {t("stock.few_left")}
            </span>
          )}
        </div>

        {/* Content */}
        <div className="p-4 flex flex-col flex-1">
          <h3 className="font-serif text-lg text-espresso-600 leading-snug">
            {lang === "tr" && product.nameTr ? product.nameTr : product.name}
          </h3>
          <p className="text-sm text-sand-400 mt-0.5">{lang === "tr" && product.originTr ? product.originTr : product.origin}</p>

          {/* Variant selector */}
          {product.variants.length > 0 && (
            <div className="flex flex-wrap gap-1.5 mt-3">
              {product.variants.map((v) => (
                <button
                  key={v.id}
                  type="button"
                  onClick={(e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    setSelectedVariantId(v.id);
                  }}
                  className={`px-2.5 py-1 text-xs rounded-full border transition-colors ${
                    selectedVariant?.id === v.id
                      ? "bg-olive-500 text-white border-olive-500"
                      : "bg-cream-100 text-espresso-500 border-cream-300 hover:border-olive-400"
                  }`}
                >
                  {v.name}
                </button>
              ))}
            </div>
          )}

          {/* Price + CTA */}
          <div className="mt-auto pt-4 flex items-end justify-between gap-3">
            <span className="text-lg font-semibold text-espresso-600">
              {currentPrice.toFixed(2).replace(".", ",")} &euro;
            </span>
            <button
              type="button"
              onClick={handleAddToCart}
              disabled={isOutOfStock}
              className={[
                "px-4 py-2 text-sm font-medium rounded-lg whitespace-nowrap transition-colors",
                isOutOfStock
                  ? "bg-sand-300 text-espresso-400 cursor-not-allowed"
                  : "bg-olive-500 text-white hover:bg-olive-600 active:bg-olive-700",
              ].join(" ")}
            >
              {isOutOfStock ? t("stock.out_of_stock") : t("product.add_to_cart")}
            </button>
          </div>
        </div>
      </div>
    </Link>
  );
}
