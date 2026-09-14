CREATE SEQUENCE "public"."invoices_invoice_number_seq" AS integer INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1 NO CYCLE;

CREATE TABLE "public"."categories" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "name"       text                     NOT NULL,
  "slug"       text                     NOT NULL,
  "created_at" timestamp with time zone DEFAULT now(),
  CONSTRAINT "categories_name_key" UNIQUE (name),
  CONSTRAINT "categories_pkey" PRIMARY KEY (id),
  CONSTRAINT "categories_slug_key" UNIQUE (slug)
);

ALTER TABLE "public"."categories"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."invoices" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "order_id"       uuid,
  "invoice_number" integer                  NOT NULL DEFAULT nextval('public.invoices_invoice_number_seq'::regclass),
  "control_number" text,
  "subtotal_ves"   numeric(10,2)            NOT NULL,
  "tax_ves"        numeric(10,2)            NOT NULL,
  "total_ves"      numeric(10,2)            NOT NULL,
  "pdf_url"        text,
  "issued_at"      timestamp with time zone DEFAULT now(),
  CONSTRAINT "invoices_invoice_number_key" UNIQUE (invoice_number),
  CONSTRAINT "invoices_order_id_key" UNIQUE (order_id),
  CONSTRAINT "invoices_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."invoices"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."order_items" (
  "id"             uuid          NOT NULL DEFAULT gen_random_uuid(),
  "order_id"       uuid,
  "product_id"     uuid,
  "quantity"       integer       NOT NULL,
  "unit_price_usd" numeric(10,2) NOT NULL,
  "subtotal_usd"   numeric(10,2) NOT NULL,
  CONSTRAINT "order_items_pkey" PRIMARY KEY (id),
  CONSTRAINT "order_items_quantity_check" CHECK ((quantity > 0))
);

ALTER TABLE "public"."order_items"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."orders" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "customer_name"     text                     NOT NULL,
  "customer_rif_ci"   text                     NOT NULL,
  "customer_phone"    text                     NOT NULL,
  "customer_address"  text,
  "total_usd"         numeric(10,2)            NOT NULL,
  "bcv_rate_applied"  numeric(10,2),
  "total_ves"         numeric(10,2),
  "status"            text                     NOT NULL DEFAULT 'pending_whatsapp'::text,
  "payment_method"    text,
  "payment_reference" text,
  "created_at"        timestamp with time zone DEFAULT now(),
  "updated_at"        timestamp with time zone DEFAULT now(),
  CONSTRAINT "orders_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."orders"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."products" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "category_id" uuid,
  "part_number" text                     NOT NULL,
  "name"        text                     NOT NULL,
  "brand"       text                     NOT NULL,
  "price_usd"   numeric(10,2)            NOT NULL,
  "stock"       integer                  NOT NULL DEFAULT 0,
  "images"      text[]                   DEFAULT '{}'::text[],
  "description" text,
  "is_active"   boolean                  DEFAULT true,
  "created_at"  timestamp with time zone DEFAULT now(),
  "updated_at"  timestamp with time zone DEFAULT now(),
  CONSTRAINT "products_part_number_key" UNIQUE (part_number),
  CONSTRAINT "products_pkey" PRIMARY KEY (id),
  CONSTRAINT "products_stock_check" CHECK ((stock >= 0))
);

ALTER TABLE "public"."products"
  ENABLE ROW LEVEL SECURITY;

ALTER SEQUENCE "public"."invoices_invoice_number_seq" OWNED BY "public"."invoices"."invoice_number";

ALTER TABLE "public"."invoices"
  ADD CONSTRAINT "invoices_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;

ALTER TABLE "public"."order_items"
  ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;

ALTER TABLE "public"."products"
  ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;

ALTER TABLE "public"."order_items"
  ADD CONSTRAINT "order_items_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;

CREATE POLICY "Permitir lectura pública de categorías" ON "public"."categories"
  FOR SELECT
  TO PUBLIC
  USING (true);

CREATE POLICY "Permitir inserción de items de orden" ON "public"."order_items"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (true);

CREATE POLICY "Permitir inserción de órdenes" ON "public"."orders"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (true);

CREATE POLICY "Permitir lectura pública de productos activos" ON "public"."products"
  FOR SELECT
  TO PUBLIC
  USING ((is_active = true));

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."invoices_invoice_number_seq" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."categories" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."invoices" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."order_items" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."orders" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."products" TO "anon", "authenticated", "postgres", "service_role";

