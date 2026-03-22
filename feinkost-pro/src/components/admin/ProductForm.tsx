"use client";

import { useState, useEffect } from "react";
import { Plus, Trash2, X, CheckCircle } from "lucide-react";
import { CategorySlug, Product, ProductVariant } from "@/types";
import { useAdminStore } from "@/store/admin-store";
import { useLang } from "@/lib/i18n";
import { Button } from "@/components/ui/Button";
import { DragDropZone } from "./DragDropZone";

const categories: { slug: CategorySlug; labelKey: "cat.gewuerze" | "cat.trockenfruechte" | "cat.fruehstueck" | "cat.oele" | "cat.nuesse" | "cat.spezialitaeten" }[] = [
  { slug: "gewuerze", labelKey: "cat.gewuerze" },
  { slug: "trockenfruechte", labelKey: "cat.trockenfruechte" },
  { slug: "fruehstueck", labelKey: "cat.fruehstueck" },
  { slug: "oele", labelKey: "cat.oele" },
  { slug: "nuesse", labelKey: "cat.nuesse" },
  { slug: "spezialitaeten", labelKey: "cat.spezialitaeten" },
];

interface ProductFormProps {
  product: Product | null;
  onClose: () => void;
}

export function ProductForm({ product, onClose }: ProductFormProps) {
  const updateProduct = useAdminStore((s) => s.updateProduct);
  const addProduct = useAdminStore((s) => s.addProduct);
  const { t } = useLang();

  const isCreateMode = product === null;

  const [name, setName] = useState(product?.name ?? "");
  const [nameTr, setNameTr] = useState(product?.nameTr ?? "");
  const [description, setDescription] = useState(product?.description ?? "");
  const [descriptionTr, setDescriptionTr] = useState(
    product?.descriptionTr ?? ""
  );
  const [price, setPrice] = useState(product?.price.toString() ?? "0");

  // Ana fiyat değişince ilk varyantın fiyatını da güncelle
  const handlePriceChange = (newPrice: string) => {
    setPrice(newPrice);
    const num = parseFloat(newPrice);
    if (!isNaN(num) && variants.length > 0) {
      setVariants((prev) =>
        prev.map((v, i) => (i === 0 ? { ...v, price: num } : v))
      );
    }
  };
  const [category, setCategory] = useState<CategorySlug>(product?.category ?? "gewuerze");
  const [weight, setWeight] = useState(product?.weight ?? "");
  const [origin, setOrigin] = useState(product?.origin ?? "");
  const [images, setImages] = useState<string[]>(product ? [...product.images] : []);
  const [variants, setVariants] = useState<ProductVariant[]>(
    product ? [...product.variants] : []
  );
  const [inStock, setInStock] = useState(product?.inStock ?? true);
  const [featured, setFeatured] = useState(product?.featured ?? false);
  const [stock, setStock] = useState(product?.stock?.toString() ?? "50");
  const [lowStockThreshold, setLowStockThreshold] = useState(product?.lowStockThreshold?.toString() ?? "5");
  // Ensure defaults for new products
  const [showSuccess, setShowSuccess] = useState(false);

  // Lock body scroll when modal is open
  useEffect(() => {
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = "";
    };
  }, []);

  const addVariant = () => {
    setVariants((prev) => [
      ...prev,
      { id: `var_${Date.now()}`, name: "", price: 0, weight: "" },
    ]);
  };

  const removeVariant = (index: number) => {
    setVariants((prev) => prev.filter((_, i) => i !== index));
  };

  const updateVariant = (
    index: number,
    field: keyof ProductVariant,
    value: string | number
  ) => {
    setVariants((prev) =>
      prev.map((v, i) => (i === index ? { ...v, [field]: value } : v))
    );
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const stockNum = parseInt(stock, 10) || (isCreateMode ? 50 : 0);
    const thresholdNum = parseInt(lowStockThreshold, 10) || 5;
    const newPrice = parseFloat(price) || 0;
    const oldPrice = product?.price ?? 0;

    // Sync variant prices: if main price changed, update variants whose price matched the old price
    const syncedVariants = variants.map((v) => {
      if (v.price === oldPrice && newPrice !== oldPrice) {
        return { ...v, price: newPrice };
      }
      return v;
    });

    const productData = {
      name,
      nameTr: nameTr || undefined,
      description,
      descriptionTr: descriptionTr || undefined,
      price: newPrice,
      category,
      images,
      variants: syncedVariants,
      weight,
      origin,
      inStock: stockNum > 0,
      featured,
      stock: stockNum,
      lowStockThreshold: thresholdNum,
    };

    if (isCreateMode) {
      addProduct({
        id: `new-${Date.now()}`,
        ...productData,
        nameTr: productData.nameTr,
        descriptionTr: productData.descriptionTr,
      } as Product);
    } else {
      updateProduct(product.id, productData);
    }

    setShowSuccess(true);
    setTimeout(() => {
      setShowSuccess(false);
      onClose();
    }, 1200);
  };

  const inputClass =
    "w-full bg-sand-100 border border-sand-200 rounded-lg px-4 py-2.5 text-espresso-700 placeholder:text-espresso-400/50 focus:outline-none focus:ring-2 focus:ring-olive-400/40 focus:border-olive-400 transition-colors text-sm";
  const labelClass = "block text-sm font-medium text-espresso-600 mb-1.5";

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-espresso-700/50 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative z-10 w-full max-w-3xl mx-4 my-6 max-h-[calc(100vh-3rem)] overflow-y-auto bg-white rounded-2xl shadow-2xl border border-sand-200 animate-scale-in">
        {/* Header */}
        <div className="sticky top-0 z-20 bg-white border-b border-sand-200 rounded-t-2xl px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {product?.images[0] && (
              <img
                src={product.images[0]}
                alt=""
                className="w-10 h-10 rounded-lg object-cover border border-sand-200"
              />
            )}
            <div>
              <h2 className="font-serif text-lg font-bold text-espresso-700">
                {isCreateMode ? t("admin.add_product") : t("admin.edit_product")}
              </h2>
              <p className="text-xs text-espresso-400">{product?.name ?? t("admin.new_product")}</p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-9 h-9 rounded-lg flex items-center justify-center text-espresso-400 hover:bg-sand-100 hover:text-espresso-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-8">
          {/* Basic Info */}
          <section className="space-y-5">
            <h3 className="font-serif text-base font-semibold text-espresso-700 border-b border-sand-200 pb-2">
              {t("admin.product_details")}
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
              <div>
                <label className={labelClass}>{t("admin.name_de")} *</label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="ör. Sumak Baharatı"
                  className={inputClass}
                />
              </div>
              <div>
                <label className={labelClass}>{t("admin.name_tr")}</label>
                <input
                  type="text"
                  value={nameTr}
                  onChange={(e) => setNameTr(e.target.value)}
                  placeholder="ör. Sumak"
                  className={inputClass}
                />
              </div>
            </div>

            <div>
              <label className={labelClass}>{t("admin.desc_de")}</label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Almanca ürün açıklaması..."
                rows={3}
                className={[inputClass, "resize-none"].join(" ")}
              />
            </div>

            <div>
              <label className={labelClass}>{t("admin.desc_tr")}</label>
              <textarea
                value={descriptionTr}
                onChange={(e) => setDescriptionTr(e.target.value)}
                placeholder="Ürün açıklaması Türkçe..."
                rows={3}
                className={[inputClass, "resize-none"].join(" ")}
              />
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              <div>
                <label className={labelClass}>{t("admin.price")} *</label>
                <input
                  type="number"
                  required
                  step="0.01"
                  min="0"
                  value={price}
                  onChange={(e) => handlePriceChange(e.target.value)}
                  placeholder="0,00"
                  className={inputClass}
                />
              </div>

              <div>
                <label className={labelClass}>{t("admin.category")} *</label>
                <select
                  value={category}
                  onChange={(e) =>
                    setCategory(e.target.value as CategorySlug)
                  }
                  className={inputClass}
                >
                  {categories.map((c) => (
                    <option key={c.slug} value={c.slug}>
                      {t(c.labelKey)}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className={labelClass}>{t("admin.weight")}</label>
                <input
                  type="text"
                  value={weight}
                  onChange={(e) => setWeight(e.target.value)}
                  placeholder="ör. 250g"
                  className={inputClass}
                />
              </div>

              <div>
                <label className={labelClass}>{t("admin.origin")}</label>
                <input
                  type="text"
                  value={origin}
                  onChange={(e) => setOrigin(e.target.value)}
                  placeholder="ör. Türkiye"
                  className={inputClass}
                />
              </div>
            </div>

            {/* Stock Fields */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              <div>
                <label className={labelClass}>{t("stock.current")}</label>
                <input
                  type="number"
                  min="0"
                  value={stock}
                  onChange={(e) => {
                    setStock(e.target.value);
                    const val = parseInt(e.target.value, 10);
                    setInStock(!isNaN(val) && val > 0);
                  }}
                  placeholder="50"
                  className={inputClass}
                />
              </div>
              <div>
                <label className={labelClass}>{t("stock.threshold")}</label>
                <input
                  type="number"
                  min="0"
                  value={lowStockThreshold}
                  onChange={(e) => setLowStockThreshold(e.target.value)}
                  placeholder="5"
                  className={inputClass}
                />
              </div>
            </div>

            {/* Toggles */}
            <div className="flex flex-wrap gap-6">
              <label className="flex items-center gap-2.5 cursor-pointer group">
                <div className="relative">
                  <input
                    type="checkbox"
                    checked={featured}
                    onChange={(e) => setFeatured(e.target.checked)}
                    className="sr-only peer"
                  />
                  <div className="w-10 h-6 bg-sand-300 rounded-full peer-checked:bg-olive-500 transition-colors" />
                  <div className="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow-sm peer-checked:translate-x-4 transition-transform" />
                </div>
                <span className="text-sm font-medium text-espresso-600 group-hover:text-espresso-700">
                  {t("admin.featured")}
                </span>
              </label>
            </div>
          </section>

          {/* Variants */}
          <section className="space-y-4">
            <div className="flex items-center justify-between border-b border-sand-200 pb-2">
              <h3 className="font-serif text-base font-semibold text-espresso-700">
                {t("admin.variants")}
              </h3>
              <button
                type="button"
                onClick={addVariant}
                className="inline-flex items-center gap-1.5 text-sm font-medium text-olive-600 hover:text-olive-700 transition-colors"
              >
                <Plus className="w-4 h-4" />
                {t("admin.add_variant")}
              </button>
            </div>

            {variants.length === 0 && (
              <p className="text-sm text-espresso-400 italic">
                {t("admin.no_variants")}
              </p>
            )}

            <div className="space-y-3">
              {variants.map((variant, index) => (
                <div
                  key={variant.id}
                  className="grid grid-cols-[1fr_90px_90px_36px] gap-3 items-end bg-cream-50 rounded-lg p-3 border border-sand-100"
                >
                  <div>
                    <label className="text-xs font-medium text-espresso-500 mb-1 block">
                      {t("admin.variant_name")}
                    </label>
                    <input
                      type="text"
                      value={variant.name}
                      onChange={(e) =>
                        updateVariant(index, "name", e.target.value)
                      }
                      placeholder="Varyant adı"
                      className={[inputClass, "py-2"].join(" ")}
                    />
                  </div>
                  <div>
                    <label className="text-xs font-medium text-espresso-500 mb-1 block">
                      {t("admin.variant_price")}
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      min="0"
                      value={variant.price || ""}
                      onChange={(e) =>
                        updateVariant(
                          index,
                          "price",
                          parseFloat(e.target.value) || 0
                        )
                      }
                      placeholder="EUR"
                      className={[inputClass, "py-2"].join(" ")}
                    />
                  </div>
                  <div>
                    <label className="text-xs font-medium text-espresso-500 mb-1 block">
                      {t("admin.variant_weight")}
                    </label>
                    <input
                      type="text"
                      value={variant.weight}
                      onChange={(e) =>
                        updateVariant(index, "weight", e.target.value)
                      }
                      placeholder="g"
                      className={[inputClass, "py-2"].join(" ")}
                    />
                  </div>
                  <button
                    type="button"
                    onClick={() => removeVariant(index)}
                    className="mb-0.5 w-9 h-9 flex items-center justify-center rounded-lg text-brick-500 hover:bg-brick-300/10 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          </section>

          {/* Images */}
          <section className="space-y-4">
            <h3 className="font-serif text-base font-semibold text-espresso-700 border-b border-sand-200 pb-2">
              {t("admin.images")}
            </h3>

            {/* Current images */}
            {images.length > 0 && (
              <div>
                <p className="text-xs font-medium text-espresso-500 mb-2">
                  {t("admin.current_images")}
                </p>
                <div className="grid grid-cols-4 sm:grid-cols-6 gap-2">
                  {images.map((src, idx) => (
                    <div
                      key={idx}
                      className="relative group aspect-square rounded-lg overflow-hidden border border-sand-200 bg-cream-50"
                    >
                      <img
                        src={src}
                        alt={`Görsel ${idx + 1}`}
                        className="w-full h-full object-cover"
                      />
                      <button
                        type="button"
                        onClick={() =>
                          setImages((prev) =>
                            prev.filter((_, i) => i !== idx)
                          )
                        }
                        className="absolute top-1 right-1 w-5 h-5 rounded-full bg-espresso-700/70 text-white flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-brick-600"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Drop zone for new images */}
            <DragDropZone
              images={[]}
              onImagesChange={(newImages) =>
                setImages((prev) => [...prev, ...newImages])
              }
            />
          </section>

          {/* Buttons */}
          <div className="flex items-center gap-3 pt-2 border-t border-sand-200">
            <Button type="submit" size="lg">
              {showSuccess ? (
                <span className="flex items-center gap-2">
                  <CheckCircle className="w-4 h-4" />
                  {t("admin.saved")}
                </span>
              ) : (
                t("admin.save")
              )}
            </Button>
            <Button type="button" variant="secondary" size="lg" onClick={onClose}>
              {t("admin.cancel")}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
