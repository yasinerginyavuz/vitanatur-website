-- ============================================================================
-- Feinkost-Pro: Complete Supabase Migration
-- ============================================================================
-- This migration creates all tables, indexes, RLS policies, and triggers
-- required for the Feinkost-Pro e-commerce application.
--
-- Run this file against your Supabase project:
--   psql -h <host> -U postgres -d postgres -f migration.sql
--   or paste into the Supabase SQL Editor.
-- ============================================================================

-- Enable UUID extension (used for order_items primary key)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. CATEGORIES
-- ============================================================================
-- Stores product categories (Gewürze, Trockenfrüchte, etc.).
-- The slug acts as a human-readable primary key referenced by products.

CREATE TABLE IF NOT EXISTS categories (
  slug        TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  name_tr     TEXT,
  description    TEXT,
  description_tr TEXT,
  image       TEXT DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  categories IS 'Product categories for the shop (e.g. Gewürze, Nüsse).';
COMMENT ON COLUMN categories.slug IS 'URL-friendly unique identifier, also used as the PK.';
COMMENT ON COLUMN categories.name IS 'Display name in German.';
COMMENT ON COLUMN categories.name_tr IS 'Display name in Turkish (optional).';

-- ============================================================================
-- 2. PRODUCTS
-- ============================================================================
-- Core product catalog. Each product belongs to exactly one category.

CREATE TABLE IF NOT EXISTS products (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  name_tr      TEXT,
  description     TEXT,
  description_tr  TEXT,
  price        DECIMAL(10,2) NOT NULL,
  category     TEXT NOT NULL REFERENCES categories(slug) ON DELETE RESTRICT ON UPDATE CASCADE,
  weight       TEXT,
  origin       TEXT,
  origin_tr    TEXT,
  in_stock     BOOLEAN DEFAULT true,
  featured     BOOLEAN DEFAULT false,
  stock        INTEGER DEFAULT 50,
  low_stock_threshold INTEGER DEFAULT 5,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  products IS 'Main product catalog. Price is the base / default variant price.';
COMMENT ON COLUMN products.id IS 'Short human-readable ID like gew-001, tro-002.';
COMMENT ON COLUMN products.category IS 'FK to categories.slug.';
COMMENT ON COLUMN products.weight IS 'Default weight/volume label (e.g. 250g, 750ml).';
COMMENT ON COLUMN products.origin IS 'Country of origin.';
COMMENT ON COLUMN products.featured IS 'When true the product appears in the featured section on the homepage.';

-- ============================================================================
-- 3. PRODUCT_VARIANTS
-- ============================================================================
-- Size/weight variants for each product (e.g. 250g, 500g, 1kg).

CREATE TABLE IF NOT EXISTS product_variants (
  id          TEXT PRIMARY KEY,
  product_id  TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
  name        TEXT NOT NULL,
  price       DECIMAL(10,2) NOT NULL,
  weight      TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  product_variants IS 'Size / weight variants for a product (e.g. 250g at 6€, 500g at 10€).';
COMMENT ON COLUMN product_variants.id IS 'Composite ID like gew-001-250g.';
COMMENT ON COLUMN product_variants.name IS 'Short display label shown in the variant picker (e.g. "500g", "5L").';

-- ============================================================================
-- 4. PRODUCT_IMAGES
-- ============================================================================
-- Ordered list of images for each product. The first image (sort_order = 0)
-- is the primary / hero image.

CREATE TABLE IF NOT EXISTS product_images (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id  TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
  url         TEXT NOT NULL,
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (product_id, sort_order)
);

COMMENT ON TABLE  product_images IS 'Ordered gallery images for a product.';
COMMENT ON COLUMN product_images.sort_order IS '0-based display order. The image at 0 is the primary/hero image.';

-- ============================================================================
-- 5. ORDERS
-- ============================================================================
-- Customer orders with shipping details, totals, and status tracking.

CREATE TABLE IF NOT EXISTS orders (
  id                    TEXT PRIMARY KEY,
  customer_first_name   TEXT NOT NULL,
  customer_last_name    TEXT NOT NULL,
  customer_email        TEXT NOT NULL,
  customer_phone        TEXT,
  shipping_street       TEXT NOT NULL,
  shipping_city         TEXT NOT NULL,
  shipping_postal_code  TEXT NOT NULL,
  shipping_country      TEXT DEFAULT 'DE',
  payment_method        TEXT DEFAULT 'card',
  subtotal              DECIMAL(10,2) NOT NULL,
  shipping_cost         DECIMAL(10,2) NOT NULL DEFAULT 0,
  total                 DECIMAL(10,2) NOT NULL,
  status                TEXT NOT NULL DEFAULT 'new',
  notes                 TEXT,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  orders IS 'Customer orders placed through the checkout flow.';
COMMENT ON COLUMN orders.id IS 'Human-readable order ID like FK-M1A2B3.';
COMMENT ON COLUMN orders.status IS 'Order lifecycle: new -> processing -> shipped -> delivered | cancelled.';
COMMENT ON COLUMN orders.payment_method IS 'One of: card, paypal, sofort.';
COMMENT ON COLUMN orders.shipping_country IS 'ISO 3166-1 alpha-2 country code, defaults to DE (Germany).';

-- ============================================================================
-- 6. ORDER_ITEMS
-- ============================================================================
-- Individual line items within an order.

CREATE TABLE IF NOT EXISTS order_items (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id      TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
  product_id    TEXT NOT NULL,
  product_name  TEXT NOT NULL,
  variant_name  TEXT,
  quantity      INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price    DECIMAL(10,2) NOT NULL,
  total_price   DECIMAL(10,2) NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  order_items IS 'Line items belonging to an order. Stores a snapshot of product/variant info at time of purchase.';
COMMENT ON COLUMN order_items.product_name IS 'Denormalized product name at time of order (protects against future renames).';
COMMENT ON COLUMN order_items.variant_name IS 'Variant label at time of order (e.g. "500g"). NULL if no variant was selected.';

-- ============================================================================
-- INDEXES
-- ============================================================================
-- Speed up the most common query patterns.

-- Products: filter by category (category page), filter by featured (homepage)
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(featured) WHERE featured = true;

-- Product variants: lookup by product
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id);

-- Product images: lookup and ordering by product
CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON product_images(product_id, sort_order);

-- Orders: filter/sort by status and creation date (admin dashboard)
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status_created ON orders(status, created_at DESC);

-- Order items: lookup by order
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

-- ============================================================================
-- TRIGGER: auto-update updated_at on products
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Products: keep updated_at current on every UPDATE
CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Orders: keep updated_at current on every UPDATE
CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================
-- Enable RLS on every table. Policies follow the principle of least privilege:
--   * Public catalog tables (categories, products, variants, images):
--       - SELECT allowed for everyone (anon + authenticated)
--       - INSERT / UPDATE / DELETE restricted to authenticated or service_role
--   * Order tables (orders, order_items):
--       - INSERT allowed for anon (customers placing orders without accounts)
--       - SELECT / UPDATE / DELETE restricted to service_role only (admin)

-- ---------- categories ----------
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "categories: anyone can read"
  ON categories FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "categories: service_role and authenticated can insert"
  ON categories FOR INSERT
  TO authenticated, service_role
  WITH CHECK (true);

CREATE POLICY "categories: service_role and authenticated can update"
  ON categories FOR UPDATE
  TO authenticated, service_role
  USING (true) WITH CHECK (true);

CREATE POLICY "categories: service_role and authenticated can delete"
  ON categories FOR DELETE
  TO authenticated, service_role
  USING (true);

-- ---------- products ----------
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "products: anyone can read"
  ON products FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "products: service_role and authenticated can insert"
  ON products FOR INSERT
  TO authenticated, service_role
  WITH CHECK (true);

CREATE POLICY "products: service_role and authenticated can update"
  ON products FOR UPDATE
  TO authenticated, service_role
  USING (true) WITH CHECK (true);

CREATE POLICY "products: service_role and authenticated can delete"
  ON products FOR DELETE
  TO authenticated, service_role
  USING (true);

-- ---------- product_variants ----------
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "product_variants: anyone can read"
  ON product_variants FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "product_variants: service_role and authenticated can insert"
  ON product_variants FOR INSERT
  TO authenticated, service_role
  WITH CHECK (true);

CREATE POLICY "product_variants: service_role and authenticated can update"
  ON product_variants FOR UPDATE
  TO authenticated, service_role
  USING (true) WITH CHECK (true);

CREATE POLICY "product_variants: service_role and authenticated can delete"
  ON product_variants FOR DELETE
  TO authenticated, service_role
  USING (true);

-- ---------- product_images ----------
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "product_images: anyone can read"
  ON product_images FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "product_images: service_role and authenticated can insert"
  ON product_images FOR INSERT
  TO authenticated, service_role
  WITH CHECK (true);

CREATE POLICY "product_images: service_role and authenticated can update"
  ON product_images FOR UPDATE
  TO authenticated, service_role
  USING (true) WITH CHECK (true);

CREATE POLICY "product_images: service_role and authenticated can delete"
  ON product_images FOR DELETE
  TO authenticated, service_role
  USING (true);

-- ---------- orders ----------
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Anon users can INSERT orders (place orders without an account)
CREATE POLICY "orders: anon can insert"
  ON orders FOR INSERT
  TO anon, authenticated, service_role
  WITH CHECK (true);

-- Only service_role can read, update, or delete orders (admin operations)
CREATE POLICY "orders: service_role can read"
  ON orders FOR SELECT
  TO service_role
  USING (true);

CREATE POLICY "orders: service_role can update"
  ON orders FOR UPDATE
  TO service_role
  USING (true) WITH CHECK (true);

CREATE POLICY "orders: service_role can delete"
  ON orders FOR DELETE
  TO service_role
  USING (true);

-- ---------- order_items ----------
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Anon users can INSERT order items (as part of placing an order)
CREATE POLICY "order_items: anon can insert"
  ON order_items FOR INSERT
  TO anon, authenticated, service_role
  WITH CHECK (true);

-- Only service_role can read, update, or delete order items
CREATE POLICY "order_items: service_role can read"
  ON order_items FOR SELECT
  TO service_role
  USING (true);

CREATE POLICY "order_items: service_role can update"
  ON order_items FOR UPDATE
  TO service_role
  USING (true) WITH CHECK (true);

CREATE POLICY "order_items: service_role can delete"
  ON order_items FOR DELETE
  TO service_role
  USING (true);

-- ============================================================================
-- DONE
-- ============================================================================
-- Migration complete. Run seed.sql next to populate categories and products.
