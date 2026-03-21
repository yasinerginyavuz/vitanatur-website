"use client";

import { useEffect } from "react";
import { Product } from "@/types";

const BASE_URL = process.env.NEXT_PUBLIC_SITE_URL || "https://feinkost.de";

function useJsonLd(id: string, schema: Record<string, unknown>) {
  useEffect(() => {
    let script = document.getElementById(id) as HTMLScriptElement | null;
    if (!script) {
      script = document.createElement("script");
      script.id = id;
      script.type = "application/ld+json";
      document.head.appendChild(script);
    }
    script.textContent = JSON.stringify(schema);
    return () => {
      script?.remove();
    };
  }, [id, schema]);
}

/* ── Organization ── */
export function OrganizationJsonLd() {
  useJsonLd("ld-organization", {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "Feinkost",
    url: BASE_URL,
    logo: `${BASE_URL}/logo.png`,
    description:
      "Premium mediterrane und orientalische Feinkost. Handverlesene Gewürze, Trockenfrüchte, Öle und Spezialitäten.",
    contactPoint: {
      "@type": "ContactPoint",
      contactType: "customer service",
      availableLanguage: ["German", "Turkish"],
    },
    sameAs: [],
  });
  return null;
}

/* ── WebSite with SearchAction ── */
export function WebSiteJsonLd() {
  useJsonLd("ld-website", {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: "Feinkost",
    url: BASE_URL,
    description:
      "Premium mediterrane und orientalische Feinkost. Handverlesene Gewürze, Trockenfrüchte, Öle und Spezialitäten direkt aus dem Orient.",
    inLanguage: ["de", "tr"],
    potentialAction: {
      "@type": "SearchAction",
      target: {
        "@type": "EntryPoint",
        urlTemplate: `${BASE_URL}/search?q={search_term_string}`,
      },
      "query-input": "required name=search_term_string",
    },
  });
  return null;
}

/* ── LocalBusiness ── */
export function LocalBusinessJsonLd() {
  useJsonLd("ld-localbusiness", {
    "@context": "https://schema.org",
    "@type": "Store",
    name: "Feinkost",
    url: BASE_URL,
    image: `${BASE_URL}/logo.png`,
    description:
      "Premium mediterrane und orientalische Feinkost. Handverlesene Gewürze, Trockenfrüchte, Öle und Spezialitäten.",
    priceRange: "€€",
    servesCuisine: ["Türkisch", "Mediterran", "Orientalisch"],
    currenciesAccepted: "EUR",
    paymentAccepted: "Cash, Credit Card, PayPal",
    address: {
      "@type": "PostalAddress",
      addressCountry: "DE",
    },
  });
  return null;
}

/* ── Product ── */
export function ProductJsonLd({ product }: { product: Product }) {
  useJsonLd(`ld-product-${product.id}`, {
    "@context": "https://schema.org",
    "@type": "Product",
    name: product.name,
    description: product.description,
    image: product.images[0] ? `${BASE_URL}${product.images[0]}` : "",
    sku: product.id,
    brand: {
      "@type": "Brand",
      name: "Feinkost",
    },
    category: product.category,
    offers: {
      "@type": "Offer",
      url: `${BASE_URL}/product/${product.id}`,
      price: product.price.toFixed(2),
      priceCurrency: "EUR",
      availability: product.inStock
        ? "https://schema.org/InStock"
        : "https://schema.org/OutOfStock",
      seller: {
        "@type": "Organization",
        name: "Feinkost",
      },
      shippingDetails: {
        "@type": "OfferShippingDetails",
        shippingDestination: {
          "@type": "DefinedRegion",
          addressCountry: "DE",
        },
      },
    },
    weight: {
      "@type": "QuantitativeValue",
      value: product.weight,
    },
    countryOfOrigin: {
      "@type": "Country",
      name: product.origin,
    },
  });
  return null;
}

/* ── BreadcrumbList ── */
export function BreadcrumbJsonLd({
  items,
}: {
  items: { name: string; url: string }[];
}) {
  useJsonLd("ld-breadcrumb", {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.name,
      item: item.url.startsWith("http") ? item.url : `${BASE_URL}${item.url}`,
    })),
  });
  return null;
}
