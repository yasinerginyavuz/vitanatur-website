"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useAdminStore } from "@/store/admin-store";
import { categories } from "@/data/categories";
import { ProductVariant } from "@/types";
import { ImageCarousel } from "@/components/ui/ImageCarousel";
import { useCartStore } from "@/store/cart-store";
import { useLang } from "@/lib/i18n";
import { trackViewItem } from "@/lib/analytics";
import { ProductJsonLd, BreadcrumbJsonLd } from "@/components/seo/JsonLd";

export default function ProductDetailPage() {
  const { id } = useParams<{ id: string }>();
  const products = useAdminStore((s) => s.products);
  const product = products.find((p) => p.id === id);
  const { t, lang } = useLang();

  const addItem = useCartStore((s) => s.addItem);
  const openCart = useCartStore((s) => s.openCart);

  const [selectedVariantId, setSelectedVariantId] = useState<string | null>(
    product && product.variants.length > 0 ? product.variants[0].id : null
  );
  const [quantity, setQuantity] = useState(1);

  // Derive variant from current product data so admin price changes are reflected
  const selectedVariant = product
    ? product.variants.find((v) => v.id === selectedVariantId) ?? (product.variants.length > 0 ? product.variants[0] : null)
    : null;

  useEffect(() => {
    if (product) {
      const name = lang === "tr" && product.nameTr ? product.nameTr : product.name;
      document.title = `${name} | Vitanatur`;

      trackViewItem({
        id: product.id,
        name: product.name,
        price: product.price,
        category: product.category,
      });
    }
  }, [product, lang]);

  if (!product) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 text-center">
        <h1 className="font-serif text-2xl text-espresso-600 mb-2">
          {t("product.not_found")}
        </h1>
        <p className="text-sand-400 mb-6">
          {t("product.not_found_desc")}
        </p>
        <Link
          href="/"
          className="inline-block px-6 py-2.5 rounded-lg bg-olive-500 text-white font-medium hover:bg-olive-600 transition-colors"
        >
          {t("product.back_home")}
        </Link>
      </div>
    );
  }

  const category = categories.find((c) => c.slug === product.category);
  const currentPrice = product.price;
  const currentWeight = selectedVariant ? selectedVariant.weight : product.weight;
  const isOutOfStock = product.stock === 0;
  const isLowStock = product.stock > 0 && product.stock <= product.lowStockThreshold;

  function handleAddToCart() {
    if (!product || isOutOfStock) return;
    addItem(product, selectedVariant, quantity);
    openCart();
    setQuantity(1);
  }

  const productName = lang === "tr" && product.nameTr ? product.nameTr : product.name;
  const productDescription = lang === "tr" && product.descriptionTr ? product.descriptionTr : product.description;

  const breadcrumbItems = [
    { name: t("nav.home"), url: "/" },
    ...(category
      ? [{ name: category.name, url: `/category/${category.slug}` }]
      : []),
    { name: product.name, url: `/product/${product.id}` },
  ];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-16">
      {/* SEO */}
      <ProductJsonLd product={product} />
      <BreadcrumbJsonLd items={breadcrumbItems} />

      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-sm text-sand-400 mb-8">
        <Link href="/" className="hover:text-olive-500 transition-colors">
          {t("nav.home")}
        </Link>
        <span>/</span>
        {category && (
          <>
            <Link
              href={`/category/${category.slug}`}
              className="hover:text-olive-500 transition-colors"
            >
              {t(`cat.${category.slug}` as Parameters<typeof t>[0])}
            </Link>
            <span>/</span>
          </>
        )}
        <span className="text-espresso-600">{lang === "tr" && product.nameTr ? product.nameTr : product.name}</span>
      </nav>

      {/* Main content */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-16">
        {/* Left: Image */}
        <div className="rounded-xl overflow-hidden bg-white shadow-sm">
          <ImageCarousel images={product.images} alt={product.name} />
        </div>

        {/* Right: Details */}
        <div className="flex flex-col">
          <h1 className="font-serif text-3xl sm:text-4xl text-espresso-600 leading-tight">
            {lang === "tr" && product.nameTr ? product.nameTr : product.name}
          </h1>
          <p className="mt-1 text-sand-400">{lang === "tr" && product.originTr ? product.originTr : product.origin}</p>

          <p className="mt-6 text-espresso-500 leading-relaxed">
            {lang === "tr" && product.descriptionTr ? product.descriptionTr : product.description}
          </p>

          {/* Price */}
          <div className="mt-6">
            <span className="text-2xl font-semibold text-espresso-600">
              {currentPrice.toFixed(2).replace(".", ",")} &euro;
            </span>
            <span className="ml-2 text-sm text-sand-400">{currentWeight}</span>
          </div>

          {/* Stock status badges */}
          {isOutOfStock && (
            <div className="mt-3">
              <span className="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-semibold bg-red-100 text-red-700">
                {t("stock.out_of_stock")}
              </span>
            </div>
          )}
          {isLowStock && (
            <div className="mt-3">
              <span className="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-semibold bg-amber-100 text-amber-700">
                {t("stock.only_left").replace("{count}", String(product.stock))}
              </span>
            </div>
          )}

          {/* Variant selector */}
          {product.variants.length > 0 && (
            <div className="mt-6">
              <p className="text-sm font-medium text-espresso-500 mb-2">
                {t("product.weight_select")}
              </p>
              <div className="flex flex-wrap gap-2">
                {product.variants.map((v) => (
                  <button
                    key={v.id}
                    type="button"
                    onClick={() => setSelectedVariantId(v.id)}
                    className={`px-4 py-2 text-sm rounded-full border transition-colors ${
                      selectedVariant?.id === v.id
                        ? "bg-olive-500 text-white border-olive-500"
                        : "bg-cream-100 text-espresso-500 border-cream-300 hover:border-olive-400"
                    }`}
                  >
                    {v.name}
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Quantity selector */}
          {!isOutOfStock && (
            <div className="mt-6">
              <p className="text-sm font-medium text-espresso-500 mb-2">{t("product.quantity")}</p>
              <div className="inline-flex items-center border border-cream-300 rounded-lg overflow-hidden">
                <button
                  type="button"
                  onClick={() => setQuantity((q) => Math.max(1, q - 1))}
                  aria-label={t("product.quantity") + " -"}
                  className="w-10 h-10 flex items-center justify-center text-espresso-500 hover:bg-cream-100 transition-colors"
                >
                  &minus;
                </button>
                <span className="w-12 h-10 flex items-center justify-center text-sm font-medium text-espresso-600 border-x border-cream-300">
                  {quantity}
                </span>
                <button
                  type="button"
                  onClick={() => setQuantity((q) => Math.min(product.stock, q + 1))}
                  aria-label={t("product.quantity") + " +"}
                  className="w-10 h-10 flex items-center justify-center text-espresso-500 hover:bg-cream-100 transition-colors"
                >
                  +
                </button>
              </div>
            </div>
          )}

          {/* Add to cart */}
          <button
            type="button"
            onClick={handleAddToCart}
            disabled={isOutOfStock}
            className={[
              "mt-8 w-full sm:w-auto px-10 py-3.5 rounded-lg font-medium text-base transition-colors shadow-sm",
              isOutOfStock
                ? "bg-sand-300 text-espresso-400 cursor-not-allowed"
                : "bg-olive-500 text-white hover:bg-olive-600 active:bg-olive-700",
            ].join(" ")}
          >
            {isOutOfStock ? t("stock.out_of_stock") : t("product.add_to_cart")}
          </button>

          {/* Product details */}
          <div className="mt-10 pt-8 border-t border-cream-300 space-y-3">
            <div className="flex items-center gap-2 text-sm">
              <span className="text-sand-400">{t("product.origin")}:</span>
              <span className="text-espresso-600 font-medium">
                {lang === "tr" && product.originTr ? product.originTr : product.origin}
              </span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <span className="text-sand-400">{t("product.weight")}:</span>
              <span className="text-espresso-600 font-medium">
                {currentWeight}
              </span>
            </div>
            {category && (
              <div className="flex items-center gap-2 text-sm">
                <span className="text-sand-400">{t("product.category")}:</span>
                <Link
                  href={`/category/${category.slug}`}
                  className="text-olive-500 font-medium hover:underline"
                >
                  {t(`cat.${category.slug}` as Parameters<typeof t>[0])}
                </Link>
              </div>
            )}
            <div className="flex items-center gap-2 text-sm">
              <span className="text-sand-400">{t("product.availability")}:</span>
              <span
                className={`font-medium ${
                  isOutOfStock
                    ? "text-brick-500"
                    : isLowStock
                    ? "text-amber-600"
                    : "text-olive-500"
                }`}
              >
                {isOutOfStock
                  ? t("stock.out_of_stock")
                  : isLowStock
                  ? t("stock.only_left").replace("{count}", String(product.stock))
                  : t("stock.in_stock")}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
