"use client";

import { useCartStore } from "@/store/cart-store";
import { X, Minus, Plus, ShoppingBag } from "lucide-react";
import { Button } from "@/components/ui/Button";
import { WhatsAppButton } from "@/components/cart/WhatsAppButton";
import { useRouter } from "next/navigation";
import { useLang } from "@/lib/i18n";

export function CartDrawer() {
  const { items, isOpen, closeCart, removeItem, updateQuantity, totalPrice } =
    useCartStore();
  const router = useRouter();
  const { t, lang } = useLang();

  function handleCheckout() {
    closeCart();
    router.push("/checkout");
  }

  if (!isOpen) return null;

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 z-50 bg-espresso-700/30 backdrop-blur-sm animate-fade-in"
        onClick={closeCart}
      />

      {/* Drawer */}
      <aside className="fixed top-0 right-0 z-50 h-full w-full max-w-md bg-cream-50 shadow-2xl flex flex-col animate-slide-in-right">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5 border-b border-sand-200">
          <h2 className="font-serif text-lg font-semibold text-espresso-600">
            {t("cart.title")}
          </h2>
          <button
            onClick={closeCart}
            className="p-1.5 text-espresso-400 hover:text-espresso-600 transition-colors"
            aria-label={t("cart.close")}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Items */}
        <div className="flex-1 overflow-y-auto px-6 py-4">
          {items.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full gap-4 text-sand-400">
              <ShoppingBag className="w-12 h-12 stroke-[1.25]" />
              <p className="text-sm font-medium">{t("cart.empty")}</p>
            </div>
          ) : (
            <ul className="space-y-4">
              {items.map((item) => {
                const price = item.variant?.price ?? item.product.price;
                const variantLabel = item.variant?.name ?? "";
                const itemKey = `${item.product.id}-${item.variant?.id ?? "default"}`;

                return (
                  <li
                    key={itemKey}
                    className="flex gap-4 py-3 border-b border-sand-100 last:border-0"
                  >
                    {/* Thumbnail */}
                    <div className="w-16 h-16 rounded-lg overflow-hidden bg-cream-200 shrink-0">
                      {item.product.images.length > 0 ? (
                        <img
                          src={item.product.images[0]}
                          alt={item.product.name}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-sand-300 text-xs">—</div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-espresso-600 truncate">
                        {lang === "tr" && item.product.nameTr ? item.product.nameTr : item.product.name}
                      </p>
                      {variantLabel && (
                        <p className="text-xs text-sand-400 mt-0.5">
                          {variantLabel}
                        </p>
                      )}
                      <p className="text-xs text-espresso-400 mt-0.5">
                        {price.toFixed(2)} &euro;
                      </p>
                      <div className="flex items-center gap-2 mt-2">
                        <button
                          onClick={() =>
                            updateQuantity(
                              item.product.id,
                              item.variant?.id ?? null,
                              item.quantity - 1
                            )
                          }
                          className="w-7 h-7 flex items-center justify-center rounded-md border border-sand-200 text-espresso-400 hover:bg-sand-100 transition-colors"
                        >
                          <Minus className="w-3 h-3" />
                        </button>
                        <span className="text-sm font-medium text-espresso-600 w-6 text-center">
                          {item.quantity}
                        </span>
                        <button
                          onClick={() =>
                            updateQuantity(
                              item.product.id,
                              item.variant?.id ?? null,
                              item.quantity + 1
                            )
                          }
                          className="w-7 h-7 flex items-center justify-center rounded-md border border-sand-200 text-espresso-400 hover:bg-sand-100 transition-colors"
                        >
                          <Plus className="w-3 h-3" />
                        </button>
                      </div>
                    </div>
                    <div className="text-right shrink-0">
                      <p className="text-sm font-semibold text-espresso-600">
                        {(price * item.quantity).toFixed(2)} &euro;
                      </p>
                      <button
                        onClick={() =>
                          removeItem(item.product.id, item.variant?.id ?? null)
                        }
                        className="text-[11px] text-brick-500 hover:text-brick-600 mt-1 transition-colors"
                      >
                        {t("cart.remove")}
                      </button>
                    </div>
                  </li>
                );
              })}
            </ul>
          )}
        </div>

        {/* Footer */}
        {items.length > 0 && (
          <div className="border-t border-sand-200 px-6 py-5 space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-espresso-400">
                {t("cart.subtotal")}
              </span>
              <span className="text-lg font-semibold text-espresso-600">
                {totalPrice().toFixed(2)} &euro;
              </span>
            </div>
            <Button variant="primary" size="lg" className="w-full" onClick={handleCheckout}>
              {t("cart.checkout")}
            </Button>
            <WhatsAppButton />
            <p className="text-[11px] text-center text-espresso-400">
              {t("cart.shipping_note")}
            </p>
          </div>
        )}
      </aside>
    </>
  );
}
