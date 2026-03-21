"use client";

import { useEffect } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useAdminStore } from "@/store/admin-store";
import { categories } from "@/data/categories";
import { ProductGrid } from "@/components/product/ProductGrid";
import { CategorySlug } from "@/types";
import { useLang } from "@/lib/i18n";
import { BreadcrumbJsonLd } from "@/components/seo/JsonLd";

export default function CategoryPage() {
  const { slug } = useParams<{ slug: string }>();
  const products = useAdminStore((s) => s.products);
  const category = categories.find((c) => c.slug === slug);
  const { t, lang } = useLang();

  useEffect(() => {
    if (category) {
      const catNameKey = `cat.${category.slug}` as Parameters<typeof t>[0];
      document.title = `${t(catNameKey)} | Feinkost`;
    }
  }, [category, lang, t]);

  if (!category) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 text-center">
        <h1 className="font-serif text-2xl text-espresso-600 mb-2">
          {t("product.not_found")}
        </h1>
        <Link
          href="/"
          className="inline-block px-6 py-2.5 rounded-lg bg-olive-500 text-white font-medium hover:bg-olive-600 transition-colors"
        >
          {t("product.back_home")}
        </Link>
      </div>
    );
  }

  const filtered = products.filter((p) => p.category === (slug as CategorySlug));

  const catNameKey = `cat.${slug}` as Parameters<typeof t>[0];
  const catDescKey = `cat.${slug}.desc` as Parameters<typeof t>[0];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-16">
      {/* SEO */}
      <BreadcrumbJsonLd
        items={[
          { name: "Startseite", url: "/" },
          { name: category.name, url: `/category/${category.slug}` },
        ]}
      />

      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-sm text-sand-400 mb-8">
        <Link href="/" className="hover:text-olive-500 transition-colors">
          {t("nav.home")}
        </Link>
        <span>/</span>
        <span className="text-espresso-600">{t(catNameKey)}</span>
      </nav>

      {/* Header */}
      <div className="mb-10">
        <h1 className="font-serif text-3xl sm:text-4xl text-espresso-600">
          {t(catNameKey)}
        </h1>
        <p className="mt-2 text-sand-400 max-w-2xl">
          {t(catDescKey)}
        </p>
      </div>

      {/* Product Grid */}
      <ProductGrid products={filtered} />
    </div>
  );
}
