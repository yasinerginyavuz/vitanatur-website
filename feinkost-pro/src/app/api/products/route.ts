import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase";
import { validateSession } from "@/lib/auth";
import { Product } from "@/types";
import { products as initialProducts } from "@/data/products";

// --- Supabase row types (snake_case) ---

interface ProductRow {
  id: string;
  name: string;
  name_tr: string | null;
  description: string;
  description_tr: string | null;
  price: number;
  category: string;
  weight: string;
  origin: string;
  origin_tr: string | null;
  in_stock: boolean;
  featured: boolean;
  stock: number;
  low_stock_threshold: number;
}

interface VariantRow {
  id: string;
  product_id: string;
  name: string;
  price: number;
  weight: string;
}

interface ImageRow {
  id: string;
  product_id: string;
  url: string;
  sort_order: number;
}

/** Map a Supabase product row + related rows to the frontend Product type */
function toProduct(
  row: ProductRow,
  variants: VariantRow[],
  images: ImageRow[]
): Product {
  return {
    id: row.id,
    name: row.name,
    nameTr: row.name_tr ?? undefined,
    description: row.description,
    descriptionTr: row.description_tr ?? undefined,
    price: Number(row.price),
    category: row.category as Product["category"],
    images: images
      .sort((a, b) => a.sort_order - b.sort_order)
      .map((img) => img.url),
    variants: variants.map((v) => ({
      id: v.id,
      name: v.name,
      price: Number(v.price),
      weight: v.weight,
    })),
    weight: row.weight,
    origin: row.origin,
    originTr: row.origin_tr ?? undefined,
    inStock: row.in_stock,
    featured: row.featured,
    stock: row.stock,
    lowStockThreshold: row.low_stock_threshold,
  };
}

/**
 * GET /api/products
 * Returns all products with variants and images, matching the frontend Product type.
 * Falls back to initialProducts if Supabase is not configured.
 */
export async function GET() {
  // Fallback when Supabase is not configured
  if (!supabaseAdmin) {
    return NextResponse.json(initialProducts);
  }

  try {
    // Fetch all three tables in parallel
    const [productsRes, variantsRes, imagesRes] = await Promise.all([
      supabaseAdmin.from("products").select("*"),
      supabaseAdmin.from("product_variants").select("*"),
      supabaseAdmin.from("product_images").select("*").order("sort_order"),
    ]);

    if (productsRes.error) throw productsRes.error;
    if (variantsRes.error) throw variantsRes.error;
    if (imagesRes.error) throw imagesRes.error;

    const productRows: ProductRow[] = productsRes.data;
    const variantRows: VariantRow[] = variantsRes.data;
    const imageRows: ImageRow[] = imagesRes.data;

    // If the products table is empty, fall back to initial data
    if (productRows.length === 0) {
      return NextResponse.json(initialProducts);
    }

    // Group variants and images by product_id for fast lookup
    const variantsByProduct = new Map<string, VariantRow[]>();
    for (const v of variantRows) {
      const arr = variantsByProduct.get(v.product_id) ?? [];
      arr.push(v);
      variantsByProduct.set(v.product_id, arr);
    }

    const imagesByProduct = new Map<string, ImageRow[]>();
    for (const img of imageRows) {
      const arr = imagesByProduct.get(img.product_id) ?? [];
      arr.push(img);
      imagesByProduct.set(img.product_id, arr);
    }

    const products: Product[] = productRows.map((row) =>
      toProduct(
        row,
        variantsByProduct.get(row.id) ?? [],
        imagesByProduct.get(row.id) ?? []
      )
    );

    return NextResponse.json(products);
  } catch (err) {
    console.error("[GET /api/products] Supabase error:", err);
    // Fallback to static data on DB error so the site never breaks
    return NextResponse.json(initialProducts);
  }
}

/**
 * POST /api/products
 * Create a new product. Requires admin auth.
 */
export async function POST(request: Request) {
  const authHeader = request.headers.get("Authorization");
  const token = authHeader?.replace("Bearer ", "") ?? null;

  if (!validateSession(token)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  if (!supabaseAdmin) {
    return NextResponse.json(
      { error: "Database not configured" },
      { status: 503 }
    );
  }

  try {
    const body: Product = await request.json();

    // Insert main product row
    const { error: productError } = await supabaseAdmin
      .from("products")
      .insert({
        id: body.id,
        name: body.name,
        name_tr: body.nameTr ?? null,
        description: body.description,
        description_tr: body.descriptionTr ?? null,
        price: body.price,
        category: body.category,
        weight: body.weight,
        origin: body.origin,
        origin_tr: body.originTr ?? null,
        in_stock: body.inStock,
        featured: body.featured,
        stock: body.stock,
        low_stock_threshold: body.lowStockThreshold,
      });

    if (productError) throw productError;

    // Insert variants
    if (body.variants.length > 0) {
      const { error: variantError } = await supabaseAdmin
        .from("product_variants")
        .insert(
          body.variants.map((v) => ({
            id: v.id,
            product_id: body.id,
            name: v.name,
            price: v.price,
            weight: v.weight,
          }))
        );
      if (variantError) throw variantError;
    }

    // Insert images
    if (body.images.length > 0) {
      const { error: imageError } = await supabaseAdmin
        .from("product_images")
        .insert(
          body.images.map((url, idx) => ({
            product_id: body.id,
            url,
            sort_order: idx,
          }))
        );
      if (imageError) throw imageError;
    }

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error("[POST /api/products] Error:", err);
    return NextResponse.json(
      { error: "Failed to create product" },
      { status: 500 }
    );
  }
}

/**
 * DELETE /api/products
 * Delete a product by id (passed as ?id=xxx). Requires admin auth.
 */
export async function DELETE(request: Request) {
  const authHeader = request.headers.get("Authorization");
  const token = authHeader?.replace("Bearer ", "") ?? null;

  if (!validateSession(token)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  if (!supabaseAdmin) {
    return NextResponse.json(
      { error: "Database not configured" },
      { status: 503 }
    );
  }

  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get("id");

    if (!id) {
      return NextResponse.json(
        { error: "Missing product id" },
        { status: 400 }
      );
    }

    // Delete in order: images -> variants -> product (FK constraints)
    await supabaseAdmin
      .from("product_images")
      .delete()
      .eq("product_id", id);

    await supabaseAdmin
      .from("product_variants")
      .delete()
      .eq("product_id", id);

    const { error } = await supabaseAdmin
      .from("products")
      .delete()
      .eq("id", id);

    if (error) throw error;

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error("[DELETE /api/products] Error:", err);
    return NextResponse.json(
      { error: "Failed to delete product" },
      { status: 500 }
    );
  }
}
