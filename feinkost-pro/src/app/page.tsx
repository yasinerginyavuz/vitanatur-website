"use client";

import Link from "next/link";
import { useAdminStore } from "@/store/admin-store";
import { categories } from "@/data/categories";
import { ProductGrid } from "@/components/product/ProductGrid";
import { ImagePlaceholder } from "@/components/ui/ImagePlaceholder";
import { useLang } from "@/lib/i18n";
import { BreadcrumbJsonLd } from "@/components/seo/JsonLd";

export default function HomePage() {
  const products = useAdminStore((s) => s.products);
  const featuredProducts = products.filter((p) => p.featured);
  const { t } = useLang();

  return (
    <>
      {/* SEO */}
      <BreadcrumbJsonLd items={[{ name: "Startseite", url: "/" }]} />
      {/* ---- Hero ---- */}
      <section className="relative bg-cream-100 overflow-hidden">
        <div className="absolute inset-0 opacity-[0.03]" style={{
          backgroundImage: "radial-gradient(circle, currentColor 0.5px, transparent 0.5px)",
          backgroundSize: "18px 18px",
        }} />
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 sm:py-32 lg:py-40 text-center">
          <h1 className="font-serif text-4xl sm:text-5xl lg:text-6xl text-espresso-600 leading-tight tracking-tight">
            {t("hero.title")}
          </h1>
          <p className="mt-4 text-lg sm:text-xl text-sand-400 max-w-xl mx-auto">
            {t("hero.subtitle")}
          </p>
          <Link
            href="#sortiment"
            className="mt-8 inline-block px-8 py-3.5 rounded-lg bg-olive-500 text-white font-medium transition-colors hover:bg-olive-600 active:bg-olive-700 shadow-sm"
          >
            {t("hero.cta")}
          </Link>
        </div>
      </section>

      {/* ---- Featured Products ---- */}
      <section id="sortiment" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
        <h2 className="font-serif text-3xl sm:text-4xl text-espresso-600 mb-10 text-center">
          {t("home.featured")}
        </h2>
        <ProductGrid products={featuredProducts} />
      </section>

      {/* ---- Categories Showcase ---- */}
      <section className="bg-cream-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
          <h2 className="font-serif text-3xl sm:text-4xl text-espresso-600 mb-10 text-center">
            {t("home.categories")}
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {categories.map((cat) => {
              const categoryProduct = products.find(p => p.category === cat.slug && p.images.length > 0);
              const categoryImage = categoryProduct?.images[0];

              return (
                <Link
                  key={cat.slug}
                  href={`/category/${cat.slug}`}
                  className="group relative rounded-xl overflow-hidden aspect-[4/3] bg-white shadow-sm transition-all duration-300 hover:shadow-lg hover:scale-[1.02]"
                >
                  {categoryImage ? (
                    <img src={categoryImage} alt={t(`cat.${cat.slug}` as Parameters<typeof t>[0])} className="absolute inset-0 w-full h-full object-cover" />
                  ) : (
                    <ImagePlaceholder />
                  )}
                  <div className="absolute inset-0 bg-gradient-to-t from-espresso-700/70 via-espresso-700/20 to-transparent" />
                  <div className="absolute bottom-0 left-0 right-0 p-5">
                    <h3 className="font-serif text-xl text-white mb-1">
                      {t(`cat.${cat.slug}` as Parameters<typeof t>[0])}
                    </h3>
                    <p className="text-sm text-cream-200 leading-relaxed">
                      {t(`cat.${cat.slug}.desc` as Parameters<typeof t>[0])}
                    </p>
                  </div>
                </Link>
              );
            })}
          </div>
        </div>
      </section>

      {/* ---- Trust Bar ---- */}
      <section className="border-t border-cream-300">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-8 text-center">
            {[
              {
                icon: (
                  <svg className="w-7 h-7 text-olive-500 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0H6.375c-.621 0-1.125-.504-1.125-1.125V14.25m17.25 0V6.375c0-.621-.504-1.125-1.125-1.125H15.75M2.25 14.25h3.86c.5 0 .979.19 1.342.525l1.178 1.089a1.875 1.875 0 002.59.017l1.217-1.106c.363-.335.842-.525 1.342-.525h3.86" />
                  </svg>
                ),
                titleKey: "trust.shipping" as const,
                descKey: "trust.shipping_desc" as const,
              },
              {
                icon: (
                  <svg className="w-7 h-7 text-olive-500 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 01-1.043 3.296 3.745 3.745 0 01-3.296 1.043A3.745 3.745 0 0112 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 01-3.296-1.043 3.745 3.745 0 01-1.043-3.296A3.745 3.745 0 013 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 011.043-3.296 3.746 3.746 0 013.296-1.043A3.746 3.746 0 0112 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 013.296 1.043 3.746 3.746 0 011.043 3.296A3.745 3.745 0 0121 12z" />
                  </svg>
                ),
                titleKey: "trust.quality" as const,
                descKey: "trust.quality_desc" as const,
              },
              {
                icon: (
                  <svg className="w-7 h-7 text-olive-500 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                ),
                titleKey: "trust.delivery" as const,
                descKey: "trust.delivery_desc" as const,
              },
            ].map((item) => (
              <div key={item.titleKey} className="flex flex-col items-center gap-3">
                {item.icon}
                <h3 className="font-semibold text-espresso-600">{t(item.titleKey)}</h3>
                <p className="text-sm text-sand-400">{t(item.descKey)}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
