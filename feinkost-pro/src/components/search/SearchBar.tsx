"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { Search, X } from "lucide-react";
import Image from "next/image";
import { useAdminStore } from "@/store/admin-store";
import { useLang } from "@/lib/i18n";
import { searchProducts } from "@/lib/search";
import { Product } from "@/types";

const MAX_RESULTS = 6;

interface SearchBarProps {
  /** Pre-fill the input (used on /search page) */
  initialQuery?: string;
  /** Whether the bar is always expanded (e.g. on /search page) */
  alwaysExpanded?: boolean;
}

export function SearchBar({ initialQuery = "", alwaysExpanded = false }: SearchBarProps) {
  const router = useRouter();
  const { t, lang } = useLang();
  const products = useAdminStore((s) => s.products);

  const [query, setQuery] = useState(initialQuery);
  const [debouncedQuery, setDebouncedQuery] = useState(initialQuery);
  const [results, setResults] = useState<Product[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(-1);
  const [mobileExpanded, setMobileExpanded] = useState(alwaysExpanded);

  const containerRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  // Debounce the query (300ms)
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(query);
    }, 300);
    return () => clearTimeout(timer);
  }, [query]);

  // Search when debounced query changes
  useEffect(() => {
    if (!debouncedQuery.trim()) {
      setResults([]);
      setIsOpen(false);
      return;
    }
    const matched = searchProducts(products, debouncedQuery, lang);
    setResults(matched.slice(0, MAX_RESULTS));
    setIsOpen(true);
    setSelectedIndex(-1);
  }, [debouncedQuery, products, lang]);

  // Click-outside detection
  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
        if (!alwaysExpanded) {
          setMobileExpanded(false);
        }
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [alwaysExpanded]);

  // Navigate to product
  const goToProduct = useCallback(
    (product: Product) => {
      setIsOpen(false);
      setQuery("");
      if (!alwaysExpanded) setMobileExpanded(false);
      router.push(`/product/${product.id}`);
    },
    [router, alwaysExpanded]
  );

  // Navigate to search page
  const goToSearchPage = useCallback(() => {
    if (!query.trim()) return;
    setIsOpen(false);
    if (!alwaysExpanded) setMobileExpanded(false);
    router.push(`/search?q=${encodeURIComponent(query.trim())}`);
  }, [query, router, alwaysExpanded]);

  // Keyboard navigation
  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Escape") {
      setIsOpen(false);
      inputRef.current?.blur();
      if (!alwaysExpanded) setMobileExpanded(false);
      return;
    }

    if (e.key === "Enter") {
      if (selectedIndex >= 0 && selectedIndex < results.length) {
        goToProduct(results[selectedIndex]);
      } else {
        goToSearchPage();
      }
      return;
    }

    if (e.key === "ArrowDown") {
      e.preventDefault();
      setSelectedIndex((prev) =>
        prev < results.length - 1 ? prev + 1 : prev
      );
      return;
    }

    if (e.key === "ArrowUp") {
      e.preventDefault();
      setSelectedIndex((prev) => (prev > 0 ? prev - 1 : -1));
      return;
    }
  }

  function handleMobileToggle() {
    setMobileExpanded(true);
    // Focus the input after it becomes visible
    setTimeout(() => inputRef.current?.focus(), 100);
  }

  function handleClear() {
    setQuery("");
    setDebouncedQuery("");
    setResults([]);
    setIsOpen(false);
    inputRef.current?.focus();
  }

  const getLocalizedName = (p: Product) =>
    lang === "tr" && p.nameTr ? p.nameTr : p.name;

  const getLocalizedCategory = (p: Product) =>
    t(`cat.${p.category}` as Parameters<typeof t>[0]);

  return (
    <div ref={containerRef} className="relative">
      {/* Mobile: search icon toggle (hidden when alwaysExpanded or when expanded) */}
      {!alwaysExpanded && !mobileExpanded && (
        <button
          onClick={handleMobileToggle}
          className="lg:hidden p-2 text-espresso-500 hover:text-espresso-700 transition-colors"
          aria-label={t("search.placeholder")}
        >
          <Search className="w-5 h-5" />
        </button>
      )}

      {/* Search input — always visible on desktop, toggled on mobile */}
      <div
        className={`${
          alwaysExpanded
            ? "flex"
            : mobileExpanded
            ? "flex absolute top-0 left-0 right-0 z-50 lg:relative lg:flex"
            : "hidden lg:flex"
        } items-center`}
      >
        <div className="relative w-full min-w-[200px] lg:min-w-[280px] xl:min-w-[340px]">
          <div className="relative flex items-center">
            <Search className="absolute left-3 w-4 h-4 text-sand-400 pointer-events-none" />
            <input
              ref={inputRef}
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onFocus={() => {
                if (debouncedQuery.trim() && results.length > 0) {
                  setIsOpen(true);
                }
              }}
              onKeyDown={handleKeyDown}
              placeholder={t("search.placeholder")}
              className="w-full pl-9 pr-9 py-2 text-sm rounded-lg border border-sand-200 bg-white/80 text-espresso-600 placeholder:text-sand-400 focus:outline-none focus:ring-2 focus:ring-olive-500/40 focus:border-olive-400 transition-all"
              aria-label={t("search.placeholder")}
              autoComplete="off"
            />
            {query && (
              <button
                onClick={handleClear}
                className="absolute right-2 p-1 text-sand-400 hover:text-espresso-500 transition-colors"
                aria-label="Clear"
              >
                <X className="w-4 h-4" />
              </button>
            )}
          </div>

          {/* Dropdown results */}
          {isOpen && results.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-lg border border-sand-200 shadow-xl z-[100] overflow-hidden max-h-[400px] overflow-y-auto">
              {results.map((product, index) => (
                <button
                  key={product.id}
                  onClick={() => goToProduct(product)}
                  onMouseEnter={() => setSelectedIndex(index)}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 text-left transition-colors ${
                    index === selectedIndex
                      ? "bg-cream-100"
                      : "hover:bg-cream-50"
                  }`}
                >
                  {/* Thumbnail */}
                  <div className="w-10 h-10 rounded-md overflow-hidden bg-sand-100 flex-shrink-0">
                    {product.images[0] && (
                      <Image
                        src={product.images[0]}
                        alt={getLocalizedName(product)}
                        width={40}
                        height={40}
                        className="w-full h-full object-cover"
                      />
                    )}
                  </div>
                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-espresso-600 truncate">
                      {getLocalizedName(product)}
                    </p>
                    <p className="text-xs text-sand-400 truncate">
                      {getLocalizedCategory(product)}
                    </p>
                  </div>
                  {/* Price */}
                  <span className="text-sm font-semibold text-espresso-500 flex-shrink-0">
                    {(product.variants.length > 0 ? product.variants[0].price : product.price).toFixed(2).replace(".", ",")} &euro;
                  </span>
                </button>
              ))}
              {/* "View all results" link */}
              <button
                onClick={goToSearchPage}
                className="w-full px-3 py-2.5 text-sm text-center text-olive-600 hover:bg-cream-50 border-t border-sand-100 font-medium transition-colors"
              >
                {t("search.results")} &quot;{query}&quot;
              </button>
            </div>
          )}
        </div>

        {/* Mobile close button */}
        {!alwaysExpanded && mobileExpanded && (
          <button
            onClick={() => {
              setMobileExpanded(false);
              setIsOpen(false);
            }}
            className="lg:hidden ml-2 p-2 text-espresso-500 hover:text-espresso-700 transition-colors flex-shrink-0"
            aria-label={t("menu.close")}
          >
            <X className="w-5 h-5" />
          </button>
        )}
      </div>
    </div>
  );
}
