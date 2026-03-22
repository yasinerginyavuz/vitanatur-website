-- ============================================================================
-- Feinkost-Pro: Products Migration to Supabase
-- ============================================================================
-- This migration:
--   1. Adds missing columns (stock, low_stock_threshold, origin_tr) to products table
--   2. Seeds ALL 70 products with complete data
--   3. Seeds all product_variants
--   4. Seeds all product_images
--
-- Prerequisites: Run migration.sql first (creates tables, RLS, indexes).
-- Run this in the Supabase SQL Editor or via psql.
-- ============================================================================

BEGIN;

-- ============================================================================
-- STEP 1: Add missing columns to products table
-- ============================================================================
-- The original migration.sql is missing stock, low_stock_threshold, and origin_tr
-- which are part of the Product TypeScript type.

ALTER TABLE products ADD COLUMN IF NOT EXISTS origin_tr TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS stock INTEGER NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS low_stock_threshold INTEGER NOT NULL DEFAULT 5;

COMMENT ON COLUMN products.origin_tr IS 'Country of origin in Turkish.';
COMMENT ON COLUMN products.stock IS 'Current stock quantity. 0 means out of stock.';
COMMENT ON COLUMN products.low_stock_threshold IS 'When stock falls to or below this number, product is flagged as low stock.';

-- Add index for low stock queries (admin dashboard)
CREATE INDEX IF NOT EXISTS idx_products_low_stock ON products(stock, low_stock_threshold);

-- ============================================================================
-- STEP 2: Seed categories (upsert to be idempotent)
-- ============================================================================

INSERT INTO categories (slug, name, description, image) VALUES
  ('gewuerze',       'Gewuerze',        'Handverlesene Gewuerze aus dem Orient',          ''),
  ('trockenfruechte','Trockenfruechte', 'Sonnengetrocknete Fruechte hoechster Qualitaet', ''),
  ('fruehstueck',    'Fruehstueck',     'Traditionelle Fruehstuecksspezialitaeten',       ''),
  ('oele',           'Oele',            'Kaltgepresste Premiumoele',                      ''),
  ('nuesse',         'Nuesse',          'Erlesene Nuesse aus dem Mittelmeerraum',         ''),
  ('spezialitaeten', 'Spezialitaeten',  'Handgefertigte Delikatessen',                    '')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================================
-- STEP 3: Seed ALL 70 products (upsert)
-- ============================================================================

-- Clear existing product data for clean re-seed
DELETE FROM product_images;
DELETE FROM product_variants;
DELETE FROM products;

-- ---------- Gewuerze (10 products) ----------

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-001', 'Sumak', 'Sumak',
 'Hochwertiger Sumak aus der Suedosttuerkei, schonend gemahlen aus reifen Sumachfruechten. Verleiht Salaten, gegrilltem Fleisch und Dips eine fruchtig-sauerliche Note.',
 E'G\u00fcneydoğu T\u00fcrkiye''nin olgun sumak meyvelerinden \u00f6zenle \u00f6ğ\u00fct\u00fcm\u00fc\u015f birinci s\u0131n\u0131f sumak. Salatalara, \u0131zgara etlere ve dip soslara meyvemsi ek\u015fi bir lezzet katar.',
 6.00, 'gewuerze', '250g', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-002', 'Isot Biber', E'\u0130sot Biber',
 E'Traditionell sonnengetrockneter Isot Biber aus der Region \u015eanl\u0131urfa mit rauchig-herber Schaerfe. Ideal zum Wuerzen von Kebab, Eintoepfen und orientalischen Vorspeisen.',
 E'\u015eanl\u0131urfa y\u00f6resinden geleneksel g\u00fcne\u015fte kurutulmu\u015f isot biber, dumans\u0131 ve buruk ac\u0131l\u0131ğ\u0131yla. Kebap, g\u00fcve\u00e7 ve oryantal mezelerin vazge\u00e7ilmezi.',
 5.00, 'gewuerze', '200g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-003', 'Knoblauchpulver', E'Sar\u0131msak Tozu',
 'Feines Knoblauchpulver aus tuerkischem Anbau, schonend getrocknet und gemahlen. Praktisch fuer Marinaden, Saucen und ueberall dort, wo intensives Knoblaucharoma gewuenscht ist.',
 E'T\u00fcrk tar\u0131m\u0131ndan ince sar\u0131msak tozu, \u00f6zenle kurutulmu\u015f ve \u00f6ğ\u00fct\u00fclm\u00fc\u015f. Marinalar, soslar ve yoğun sar\u0131msak aromas\u0131 istenen her yerde kullan\u0131\u015fl\u0131.',
 5.00, 'gewuerze', '200g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-004', 'Petersilie getrocknet', E'Kurutulmu\u015f Maydanoz',
 'Schonend getrocknete Petersilie aus der Tuerkei, die ihr volles Aroma bewahrt. Perfekt zum Verfeinern von Suppen, Salaten und Fleischgerichten.',
 E'T\u00fcrkiye''den \u00f6zenle kurutulmu\u015f, aromas\u0131n\u0131 koruyan maydanoz. \u00c7orbalar, salatalar ve et yemeklerini tatland\u0131rmak i\u00e7in m\u00fckemmel.',
 5.00, 'gewuerze', '150g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-005', 'Dill Spitzen', 'Dereotu',
 'Aromatische Dillspitzen aus tuerkischem Anbau, sorgfaeltig getrocknet fuer langanhaltenden Geschmack. Unverzichtbar fuer Joghurtdips, Fischgerichte und frische Salate.',
 E'T\u00fcrk tar\u0131m\u0131ndan aromatik dereotu, uzun \u00f6m\u00fcrl\u00fc lezzet i\u00e7in \u00f6zenle kurutulmu\u015f. Yoğurtlu diplar, bal\u0131k yemekleri ve taze salatalar i\u00e7in vazge\u00e7ilmez.',
 5.00, 'gewuerze', '100g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-006', 'Chili ganz scharf', E'B\u00fct\u00fcn Ac\u0131 Biber',
 'Ganze getrocknete Chilischoten mit intensiver Schaerfe aus der Tuerkei. Zum Einlegen, Kochen oder als dekorative Wuerzzutat fuer scharfe Gerichte geeignet.',
 E'T\u00fcrkiye''den yoğun ac\u0131l\u0131ğa sahip b\u00fct\u00fcn kurutulmu\u015f ac\u0131 biberler. Tur\u015fu, yemek veya ac\u0131l\u0131 yemekler i\u00e7in dekoratif baharat olarak uygun.',
 5.00, 'gewuerze', '150g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-007', 'Scharfe Paprikapaste', E'Ac\u0131 Biber Sal\u00e7as\u0131',
 'Wuerzige Paprikapaste aus sonnengereiften tuerkischen Paprikaschoten mit kraeftiger Schaerfe. Vielseitig einsetzbar als Brotaufstrich, Marinade oder Basis fuer Eintoepfe und Saucen.',
 E'G\u00fcne\u015fte olgunla\u015fm\u0131\u015f T\u00fcrk biberlerinden kuvvetli ac\u0131l\u0131kta biber sal\u00e7as\u0131. Ekmek \u00fcst\u00fc, marine veya g\u00fcve\u00e7 ve sos yap\u0131m\u0131nda \u00e7ok y\u00f6nl\u00fc kullan\u0131m.',
 8.00, 'gewuerze', '1000g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-008', E'S\u00fc\u00dfe Paprikapaste', E'Tatl\u0131 Biber Sal\u00e7as\u0131',
 'Milde Paprikapaste aus aromatischen tuerkischen Paprika, ohne Schaerfe und mit fruchtiger Suesse. Hervorragend als Aufstrich, zum Kochen oder als Zutat in Mezze-Gerichten.',
 E'Aromatik T\u00fcrk biberlerinden ac\u0131s\u0131z, meyvemsi tatl\u0131l\u0131kta biber sal\u00e7as\u0131. Ekmek \u00fcst\u00fc, yemek pi\u015firme veya meze yap\u0131m\u0131nda harika.',
 8.00, 'gewuerze', '1000g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-009', 'Tomatenmark', E'Domates Sal\u00e7as\u0131',
 'Konzentriertes Tomatenmark aus sonnengereiften tuerkischen Tomaten, dreifach eingekocht fuer intensiven Geschmack. Unverzichtbare Grundzutat fuer Saucen, Suppen und traditionelle tuerkische Gerichte.',
 E'G\u00fcne\u015fte olgunla\u015fm\u0131\u015f T\u00fcrk domateslerinden \u00fc\u00e7 kez kaynat\u0131lm\u0131\u015f konsantre domates sal\u00e7as\u0131. Soslar, \u00e7orbalar ve geleneksel T\u00fcrk yemekleri i\u00e7in vazge\u00e7ilmez temel malzeme.',
 8.00, 'gewuerze', '1000g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('gew-010', 'Sumak Eksisi', E'Sumak Ek\u015fisi',
 'Traditioneller Sumak-Essig aus der Tuerkei, hergestellt aus fermentierten Sumachfruechten. Verleiht Salaten und Fleischgerichten eine einzigartig fruchtig-saure Wuerze.',
 E'Fermente sumak meyvelerinden yap\u0131lm\u0131\u015f geleneksel T\u00fcrk sumak sirkesi. Salatalara ve et yemeklerine e\u015fsiz meyvemsi ek\u015fi bir tat verir.',
 15.00, 'gewuerze', '250ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

-- ---------- Trockenfruechte (8 products) ----------

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-001', 'Getrocknete Aprikosen', E'Kuru Kay\u0131s\u0131',
 'Premium-Aprikosen aus Malatya, dem weltbesten Anbaugebiet, schonend sonnengetrocknet ohne Schwefelzusatz. Honigsuess und naehrstoffreich als Snack, im Muesli oder zum Backen.',
 E'D\u00fcnyan\u0131n en iyi kay\u0131s\u0131 b\u00f6lgesi Malatya''dan, k\u00fck\u00fcrt katk\u0131s\u0131z g\u00fcne\u015fte kurutulmu\u015f premium kay\u0131s\u0131lar. Bal tatl\u0131l\u0131ğ\u0131nda ve besin değeri y\u00fcksek, at\u0131\u015ft\u0131rmal\u0131k, m\u00fcsli veya f\u0131r\u0131nc\u0131l\u0131k i\u00e7in.',
 8.00, 'trockenfruechte', '400g', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-002', 'Getrocknete Maulbeeren', 'Kuru Dut',
 'Naturbelassene weisse Maulbeeren aus den Hochebenen Zentralanatoliens mit karamelliger Natursuesse. Reich an Eisen und Ballaststoffen, ideal als gesunder Snack oder Topping fuer Joghurt.',
 E'\u0130\u00e7 Anadolu yaylalar\u0131ndan doğal karamel tatl\u0131l\u0131ğ\u0131nda beyaz dutlar. Demir ve lif a\u00e7\u0131s\u0131ndan zengin, sağl\u0131kl\u0131 at\u0131\u015ft\u0131rmal\u0131k veya yoğurt \u00fcst\u00fc i\u00e7in ideal.',
 6.00, 'trockenfruechte', '200g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-003', 'Getrocknete Feigen', E'Kuru \u0130ncir',
 'Erstklassige Feigen aus der Aegaeis-Region rund um Aydin, natuerlich in der Sonne getrocknet. Samtig-suesser Geschmack und zarte Textur, reich an Ballaststoffen und Mineralstoffen.',
 E'Ayd\u0131n \u00e7evresindeki Ege b\u00f6lgesinden birinci s\u0131n\u0131f incirler, doğal g\u00fcne\u015fte kurutulmu\u015f. Kadifemsi tatl\u0131 lezzet ve yumu\u015fak dokusuyla lif ve mineraller a\u00e7\u0131s\u0131ndan zengin.',
 7.00, 'trockenfruechte', '400g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-004', 'Kernlose schwarze Trauben', E'\u00c7ekirdeksiz Siyah \u00dczm',
 'Kernlose schwarze Trauben aus der Tuerkei, schonend getrocknet mit intensiv fruchtigem Geschmack. Vielseitig verwendbar als Snack, im Muesli, beim Backen oder in herzhaften Gerichten.',
 E'T\u00fcrkiye''den \u00f6zenle kurutulmu\u015f, yoğun meyvemsi lezzetli \u00e7ekirdeksiz siyah \u00fcz\u00fcmler. At\u0131\u015ft\u0131rmal\u0131k, m\u00fcsli, f\u0131r\u0131nc\u0131l\u0131k veya tuzlu yemeklerde \u00e7ok y\u00f6nl\u00fc kullan\u0131m.',
 5.00, 'trockenfruechte', '400g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-005', 'Getrocknete Sauerkirschen', E'Kuru Vi\u015fne',
 'Sonnengetrocknete Sauerkirschen aus der Tuerkei mit intensiv fruchtig-sauerlichem Aroma. Perfekt als Snack, zum Backen oder als besondere Zutat in Salaten und Desserts.',
 E'T\u00fcrkiye''den g\u00fcne\u015fte kurutulmu\u015f, yoğun meyvemsi ek\u015fi aromal\u0131 vi\u015fneler. At\u0131\u015ft\u0131rmal\u0131k, f\u0131r\u0131nc\u0131l\u0131k veya salata ve tatl\u0131larda \u00f6zel malzeme olarak m\u00fckemmel.',
 7.00, 'trockenfruechte', '200g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-006', 'Medjool Datteln Choice', 'Medjool Hurma Choice',
 'Handverlesene Medjool-Datteln der Gueteklasse Choice aus dem Jordantal mit weichem, karamellartigem Fruchtfleisch. Natuerliche Suesse ohne Zusaetze, ideal als gesunder Snack oder Zuckeralternative.',
 E''\u00dcrd\u00fcn Vadisi''nden el se\u00e7me Choice kalite Medjool hurmalar\u0131, yumu\u015fak karamelli meyvesiyle. Katk\u0131s\u0131z doğal tatl\u0131l\u0131k, sağl\u0131kl\u0131 at\u0131\u015ft\u0131rmal\u0131k veya \u015feker alternatifi olarak ideal.',
 12.00, 'trockenfruechte', '500g', 'Jordanien', E'\u00dcrd\u00fcn', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-007', 'Medjool Datteln Premium Jumbo', 'Medjool Hurma Premium Jumbo',
 'Extragrosse Premium-Jumbo-Medjool-Datteln, sorgfaeltig selektiert aus den besten Ernten Jordaniens. Besonders saftig, suess und fleischig – die Koenigin unter den Datteln fuer hoechste Ansprueche.',
 E'\u00dcrd\u00fcn''\u00fcn en iyi hasatlar\u0131ndan \u00f6zenle se\u00e7ilmi\u015f ekstra b\u00fcy\u00fck Premium Jumbo Medjool hurmalar\u0131. \u00d6zellikle sulu, tatl\u0131 ve etli \u2014 en y\u00fcksek standartlar i\u00e7in hurmalar\u0131n krali\u00e7esi.',
 18.00, 'trockenfruechte', '500g', 'Jordanien', E'\u00dcrd\u00fcn', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('tro-008', 'Aegyptische Premium Datteln', E'M\u0131s\u0131r Premium Hurma',
 'Erstklassige aegyptische Datteln mit honigartiger Suesse und zartschmelzendem Fruchtfleisch. In der Grosspackung besonders geeignet fuer Familien, zum Backen oder als taeglicher Energielieferant.',
 E'Bal tatl\u0131l\u0131ğ\u0131nda ve yumu\u015fac\u0131k meyvesiyle birinci s\u0131n\u0131f M\u0131s\u0131r hurmalar\u0131. Aileler i\u00e7in, f\u0131r\u0131nc\u0131l\u0131k veya g\u00fcnl\u00fck enerji kaynağ\u0131 olarak b\u00fcy\u00fck pakette \u00f6zellikle uygun.',
 15.00, 'trockenfruechte', '750g', E'Aegypten', E'M\u0131s\u0131r', true, false, 50, 5);

-- ---------- Fruehstueck (9 products) ----------

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('fru-001', 'Tahini', 'Tahin',
 'Cremiges Tahini aus 100% gerostetem Sesam, traditionell in einer Steinmuehle gemahlen. Unverzichtbar fuer Hummus, Dressings und als nahrhafter Brotaufstrich zum Fruehstueck.',
 E'%100 kavrulmu\u015f susamdan, geleneksel ta\u015f değirmeninde \u00f6ğ\u00fct\u00fclm\u00fc\u015f kremsi tahin. Humus, sos yap\u0131m\u0131 ve kahvalt\u0131da besleyici ekmek \u00fcst\u00fc s\u00fcrme olarak vazge\u00e7ilmez.',
 11.00, 'fruehstueck', '935g', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('fru-002', 'Traubenmelasse', E'\u00dczm Pekmezi',
 'Naturreine Traubenmelasse (Pekmez) aus eingedicktem Traubenmost, ganz ohne Zuckerzusatz hergestellt. Reich an Eisen und Kalzium, traditionell zum Fruehstueck mit Tahini genossen.',
 E'\u015eeker katk\u0131s\u0131z, kaynat\u0131lm\u0131\u015f \u00fcz\u00fcm \u015f\u0131ras\u0131ndan yap\u0131lm\u0131\u015f saf \u00fcz\u00fcm pekmezi. Demir ve kalsiyum a\u00e7\u0131s\u0131ndan zengin, geleneksel olarak kahvalt\u0131da tahinle birlikte t\u00fcketilir.',
 10.00, 'fruehstueck', '1kg', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('fru-003', 'Johannisbrotmelasse', E'Ke\u00e7iboynuzu Pekmezi',
 'Traditionelle Johannisbrotmelasse aus der Tuerkei mit mild-suessem, malzigem Geschmack. Natuerlich reich an Mineralstoffen und vielseitig einsetzbar als Brotaufstrich oder zum Suessen von Getraenken.',
 E'T\u00fcrkiye''den hafif tatl\u0131, malt\u0131ms\u0131 lezzetiyle geleneksel ke\u00e7iboynuzu pekmezi. Doğal mineral a\u00e7\u0131s\u0131ndan zengin, ekmek \u00fcst\u00fc veya i\u00e7ecek tatland\u0131r\u0131c\u0131s\u0131 olarak \u00e7ok y\u00f6nl\u00fc.',
 10.00, 'fruehstueck', '620g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('fru-004', E'Karakovan Bl\u00fctenhonig', E'Karakovan \u00c7i\u00e7ek Bal\u0131',
 E'Naturbelassener Karakovan-Bl\u00fctenhonig von wild lebenden Bienen aus den Bergregionen der tuerkischen Schwarzmeerkueste. Kaltgeschleudert und ungefiltert fuer ein einzigartiges, vielschichtiges Bl\u00fctenaroma.',
 E'T\u00fcrk Karadeniz k\u0131y\u0131lar\u0131n\u0131n dağ b\u00f6lgelerinden yaban ar\u0131lar\u0131n\u0131n topladığ\u0131 doğal karakovan \u00e7i\u00e7ek bal\u0131. Soğuk s\u0131k\u0131m ve s\u00fcz\u00fclmemi\u015f, e\u015fsiz \u00e7ok katmanl\u0131 \u00e7i\u00e7ek aromas\u0131.',
 25.00, 'fruehstueck', '850g', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('fru-005', E'Alter Ka\u015far-K\u00e4se', E'Eski Ka\u015far Peyniri',
 E'Mindestens sechs Monate gereifter Ka\u015far-K\u00e4se mit kraeftigem, wuerzigem Geschmack und fester Konsistenz. Perfekt zum Fruehstueck, zum Ueberbacken oder als aromatischer Snack zu Tee.',
 E'En az alt\u0131 ay olgunla\u015ft\u0131r\u0131lm\u0131\u015f, g\u00fc\u00e7l\u00fc baharatl\u0131 lezzet ve sert k\u0131vaml\u0131 ka\u015far peyniri. Kahvalt\u0131da, graten yap\u0131m\u0131nda veya \u00e7ayla aromatik at\u0131\u015ft\u0131rmal\u0131k olarak m\u00fckemmel.',
 10.00, 'fruehstueck', '500g', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('fru-006', E'K\u00fcnefe-K\u00e4se', E'K\u00fcnefe Peyniri',
 E'Spezieller Fadenk\u00e4se fuer die Zubereitung von traditionellem K\u00fcnefe-Dessert mit zartem Schmelz. Mild im Geschmack und perfekt zum Ueberbacken zwischen knusprigen Kaday\u0131f-Faeden.',
 E'Geleneksel k\u00fcnefe tatl\u0131s\u0131 yap\u0131m\u0131 i\u00e7in \u00f6zel tel peynir, zarif erime \u00f6zelliğiyle. Hafif lezzetli ve \u00e7\u0131t\u0131r kaday\u0131f telleri aras\u0131nda graten i\u00e7in m\u00fckemmel.',
 8.00, 'fruehstueck', '400g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('fru-007', 'Dil Peyniri', 'Dil Peyniri',
 E'Traditioneller tuerkischer Fadenk\u00e4se mit mild-salzigem Geschmack und elastischer, faseriger Textur. Vielseitig einsetzbar zum Fruehstueck, in B\u00f6rek oder als Zutat fuer warme Gerichte.',
 E'Hafif tuzlu lezzet ve elastik lifli dokusuyla geleneksel T\u00fcrk tel peyniri. Kahvalt\u0131da, b\u00f6rek i\u00e7inde veya s\u0131cak yemek malzemesi olarak \u00e7ok y\u00f6nl\u00fc kullan\u0131m.',
 8.00, 'fruehstueck', '400g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-1', 'Dana Kavurma (Rindfleisch-Schmortopf)', 'Dana Kavurma',
 'Traditionell langsam geschmortes tuerkisches Rindfleisch, vakuumverpackt fuer optimale Frische. Ein deftiger Klassiker der tuerkischen Kueche, ideal zum Fruehstueck mit Eiern oder als herzhafte Beilage.',
 E'Geleneksel y\u00f6ntemle yava\u015f pi\u015firilmi\u015f T\u00fcrk dana kavurmas\u0131, tazeliğini korumak i\u00e7in vakumlu ambalajda. Kahvalt\u0131da yumurtayla veya doyurucu garnit\u00fcr olarak m\u00fckemmel.',
 18.00, 'fruehstueck', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-5', 'Tuerkische Butter', E'Tereyağ\u0131',
 'Handgemachte tuerkische Butter aus traditioneller Herstellung, besonders cremig und aromatisch. Perfekt zum Fruehstueck auf frischem Brot oder zum Verfeinern von Gerichten.',
 E'Geleneksel \u00fcretimle yap\u0131lm\u0131\u015f el yap\u0131m\u0131 T\u00fcrk tereyağ\u0131, \u00f6zellikle kremsi ve aromatik. Kahvalt\u0131da taze ekmek \u00fcst\u00fcne veya yemekleri lezzetlendirmek i\u00e7in ideal.',
 14.00, 'fruehstueck', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

-- ---------- Oele (3 products) ----------

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('oel-001', E'Natives Oliven\u00f6l Extra', E'Nat\u00fcrel S\u0131zma Zeytinyağ\u0131',
 E'Kaltgepresstes natives Oliven\u00f6l Extra aus griechischen Oliven mit fruchtigem Aroma und niedriger S\u00e4ure. Hervorragend fuer Salate, zum Kochen und als hochwertiges Alltagsoel.',
 E'Yunan zeytinlerinden soğuk s\u0131k\u0131m nat\u00fcrel s\u0131zma zeytinyağ\u0131, meyvemsi aroma ve d\u00fc\u015f\u00fck asitlik. Salatalar, yemek pi\u015firme ve g\u00fcnl\u00fck kullan\u0131m i\u00e7in y\u00fcksek kaliteli yağ.',
 12.00, 'oele', '750ml', 'Griechenland', 'Yunanistan', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('oel-003', E'Schwarzk\u00fcmmel\u00f6l', E'\u00c7\u00f6rekotu Yağ\u0131',
 'Kaltgepresstes Schwarzkuemmeloel aus aegyptischem Nigella Sativa, gewonnen in kleinen Chargen. Seit Jahrtausenden als Heilmittel geschaetzt, ideal pur oder zum Verfeinern von Salaten.',
 E'M\u0131s\u0131r''dan Nigella Sativa''dan k\u00fc\u00e7\u00fck partiler halinde elde edilmi\u015f soğuk s\u0131k\u0131m \u00e7\u00f6rekotu yağ\u0131. Binlerce y\u0131ld\u0131r \u015fifa kaynağ\u0131, saf veya salata i\u00e7in ideal.',
 10.00, 'oele', '125ml', E'Aegypten', E'M\u0131s\u0131r', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('oel-004', 'Apfelessig', 'Elma Sirkesi',
 'Naturtrueber Apfelessig aus der Tuerkei, traditionell aus frischen Aepfeln vergoren und ungefiltert. Vielseitig verwendbar in Dressings, Marinaden und als wohltuendes Hausmittel.',
 E'T\u00fcrkiye''den taze elmalardan geleneksel fermantasyonla yap\u0131lm\u0131\u015f doğal bulan\u0131k elma sirkesi. Sos yap\u0131m\u0131, marine ve sağl\u0131kl\u0131 ev ilac\u0131 olarak \u00e7ok y\u00f6nl\u00fc.',
 15.00, 'oele', '500ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

-- ---------- Nuesse (10 products) ----------

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-001', 'Antep-Pistazien', E'Antep F\u0131st\u0131ğ\u0131',
 'Leuchtend gruene Pistazien aus Gaziantep, der Welthauptstadt der Pistazien, von Hand geerntet und schonend geroestet. Ungesalzen und naturbelassen, perfekt als Snack oder zum Verfeinern von Desserts.',
 E'F\u0131st\u0131ğ\u0131n d\u00fcnya ba\u015fkenti Gaziantep''ten el toplamas\u0131, \u00f6zenle kavrulmu\u015f parlak ye\u015fil Antep f\u0131st\u0131ğ\u0131. Tuzsuz ve doğal, at\u0131\u015ft\u0131rmal\u0131k veya tatl\u0131 s\u00fcslemesi i\u00e7in m\u00fckemmel.',
 25.00, 'nuesse', '700g', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-002', 'Walnusskerne', E'Ceviz \u0130\u00e7i',
 'Helle Walnusskerne aus Usbekistan mit mildem, buttrigem Geschmack ohne Bitterkeit. Ideal fuer Baklava, Salate, zum Backen oder als nahrhafter Snack zwischendurch.',
 E'\u00d6zbekistan''dan ac\u0131l\u0131ğ\u0131 olmayan, hafif tereyağ\u0131ms\u0131 lezzetli a\u00e7\u0131k renkli ceviz i\u00e7leri. Baklava, salata, f\u0131r\u0131nc\u0131l\u0131k veya besleyici at\u0131\u015ft\u0131rmal\u0131k i\u00e7in ideal.',
 15.00, 'nuesse', '750g', 'Usbekistan', E'\u00d6zbekistan', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-003', 'Cashewkerne', 'Kaju',
 'Knackige Cashewkerne aus Vietnam, schonend geroestet fuer vollen nussigen Geschmack. Beliebter Snack und vielseitige Zutat fuer asiatische Gerichte, Salate und vegane Kueche.',
 E'Vietnam''dan \u00f6zenle kavrulmu\u015f, dolu f\u0131nd\u0131ks\u0131 lezzetli \u00e7\u0131t\u0131r kaju. Pop\u00fcler at\u0131\u015ft\u0131rmal\u0131k ve Asya mutfağ\u0131, salata ve vegan yemekler i\u00e7in \u00e7ok y\u00f6nl\u00fc malzeme.',
 15.00, 'nuesse', '800g', 'Vietnam', 'Vietnam', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-004', 'Geroestete Mandeln', E'Kavrulmu\u015f Badem',
 'Knusprig geroestete Mandeln aus der Tuerkei mit suesslich-mildem Geschmack und feinem Roestaroma. Hervorragend als Snack, zum Backen und fuer orientalische Gerichte.',
 E'T\u00fcrkiye''den tatl\u0131ms\u0131 hafif lezzet ve ince kavurma aromal\u0131 \u00e7\u0131t\u0131r kavrulmu\u015f bademler. At\u0131\u015ft\u0131rmal\u0131k, f\u0131r\u0131nc\u0131l\u0131k ve oryantal yemekler i\u00e7in harika.',
 15.00, 'nuesse', '800g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-005', E'Giresun Haseln\u00fcsse', E'Giresun F\u0131nd\u0131ğ\u0131',
 'Premium-Haselnuesse aus Giresun an der Schwarzmeerkueste, dem renommiertesten Anbaugebiet weltweit. Besonders gross, aromatisch und knackig – pur, im Muesli oder zum Backen ein Genuss.',
 E'D\u00fcnyan\u0131n en prestijli f\u0131nd\u0131k b\u00f6lgesi Karadeniz k\u0131y\u0131s\u0131ndaki Giresun''dan premium f\u0131nd\u0131klar. \u00d6zellikle iri, aromatik ve \u00e7\u0131t\u0131r \u2014 saf, m\u00fcslide veya f\u0131r\u0131nc\u0131l\u0131kta lezzet.',
 22.00, 'nuesse', '600g', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-006', 'Geroestete Kichererbsen', E'Kavrulmu\u015f Leblebi',
 'Traditionell geroestete Kichererbsen (Leblebi) aus der Tuerkei, knusprig und proteinreich. Ein beliebter orientalischer Snack, der auch als gesunde Alternative zu Chips ueberzeugt.',
 E'T\u00fcrkiye''den geleneksel kavrulmu\u015f nohut (leblebi), \u00e7\u0131t\u0131r ve protein a\u00e7\u0131s\u0131ndan zengin. Pop\u00fcler oryantal at\u0131\u015ft\u0131rmal\u0131k, ayn\u0131 zamanda cips alternatifi olarak sağl\u0131kl\u0131 se\u00e7enek.',
 9.00, 'nuesse', '800g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-007', E'K\u00fcrbiskerne', E'Kabak \u00c7ekirdeği',
 'Naturbelassene Kuerbiskerne aus der Tuerkei, leicht geroestet mit nussigem Geschmack. Reich an Zink und Magnesium, ideal als Snack, im Salat oder auf frischem Brot.',
 E'T\u00fcrkiye''den doğal kabak \u00e7ekirdekleri, hafif kavrulmu\u015f f\u0131nd\u0131ks\u0131 lezzetle. \u00c7inko ve magnezyum a\u00e7\u0131s\u0131ndan zengin, at\u0131\u015ft\u0131rmal\u0131k, salata veya taze ekmek \u00fcst\u00fc i\u00e7in ideal.',
 8.00, 'nuesse', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-008', 'Geroesteter Mais', E'Kavrulmu\u015f M\u0131s\u0131r',
 'Knusprig geroesteter Mais aus der Tuerkei mit herzhaftem Geschmack und angenehm krosser Textur. Ein beliebter Knabbersnack fuer gesellige Runden und als Alternative zu klassischen Nuessen.',
 E'T\u00fcrkiye''den tuzlu lezzet ve ho\u015f \u00e7\u0131t\u0131r dokuyla k\u0131zart\u0131lm\u0131\u015f kavrulmu\u015f m\u0131s\u0131r. Sosyal anlarda pop\u00fcler \u00e7erez ve klasik kuruyemi\u015flere alternatif.',
 6.00, 'nuesse', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('nus-009', E'Gemischte N\u00fcsse', E'Kar\u0131\u015f\u0131k Kuruyemi\u015f',
 'Sorgfaeltig zusammengestellte Mischung aus Pistazien, Mandeln, Cashews, Haselnuessen und Walnuessen. Ein abwechslungsreicher Premium-Snack fuer Nussliebhaber, perfekt fuer unterwegs und zu Hause.',
 E'F\u0131st\u0131k, badem, kaju, f\u0131nd\u0131k ve cevizden \u00f6zenle haz\u0131rlanm\u0131\u015f kar\u0131\u015f\u0131m. M\u00fckemmel at\u0131\u015ft\u0131rmal\u0131k i\u00e7in dengeli kuruyemi\u015f kar\u0131\u015f\u0131m\u0131.',
 14.00, 'nuesse', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-8', 'Dermann Nussmischung', E'Dermann Kar\u0131\u015f\u0131k Kuruyemi\u015f',
 'Premium-Nussmischung der Marke Dermann, frisch geroestet und sorgfaeltig zusammengestellt. Eine ausgewogene Mischung verschiedener Nuesse fuer den perfekten Knabberspass.',
 E'Dermann markas\u0131n\u0131n taze kavrulmu\u015f ve \u00f6zenle haz\u0131rlanm\u0131\u015f premium kar\u0131\u015f\u0131k kuruyemi\u015fi. M\u00fckemmel at\u0131\u015ft\u0131rmal\u0131k i\u00e7in dengeli kuruyemi\u015f kar\u0131\u015f\u0131m\u0131.',
 20.00, 'nuesse', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

-- ---------- Spezialitaeten (7 + 18 yeni = 25 products) ----------

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('spe-001', 'Kavurma', 'Kavurma',
 'Traditionelle tuerkische Kavurma aus zartem Lammfleisch, langsam im eigenen Fett geschmort und konserviert. Ein deftiger Genuss zum Fruehstueck mit Eiern oder als herzhafte Beilage.',
 E'Yumu\u015fak kuzu etinden kendi yağ\u0131nda yava\u015f pi\u015firilmi\u015f ve korunmu\u015f geleneksel T\u00fcrk kavurmas\u0131. Kahvalt\u0131da yumurtayla veya doyurucu garnit\u00fcr olarak lezzetli.',
 5.00, 'spezialitaeten', '130g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('spe-002', 'Tarhana', 'Tarhana',
 'Handgemachtes Tarhana aus fermentiertem Getreide, Joghurt und Gemuese nach anatolischem Traditionsrezept. Einfach mit Wasser aufgekocht ergibt es eine aromatische, naehrende Suppe in wenigen Minuten.',
 E'Anadolu geleneğiyle fermente tah\u0131l, yoğurt ve sebzeden el yap\u0131m\u0131 tarhana. Suyla kaynat\u0131ld\u0131ğ\u0131nda birka\u00e7 dakikada aromatik besleyici \u00e7orba olur.',
 8.00, 'spezialitaeten', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('spe-003', 'Granatapfelsirup', E'Nar Ek\u015fisi',
 'Dickfluessiger Granatapfelsirup aus der Tuerkei, hergestellt aus konzentriertem Granatapfelsaft ohne Zusaetze. Unverzichtbar fuer Salate, Marinaden und als suess-saure Verfeinerung orientalischer Gerichte.',
 E'Katk\u0131s\u0131z konsantre nar suyundan yap\u0131lm\u0131\u015f koyu k\u0131vaml\u0131 T\u00fcrk nar ek\u015fisi. Salatalar, marineler ve oryantal yemeklerin tatl\u0131-ek\u015fi tat verici olarak vazge\u00e7ilmezi.',
 7.00, 'spezialitaeten', '500ml', 'Tuerkei', E'T\u00fcrkiye', true, true, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('spe-004', 'Schwarzer Maulbeersaft', E'Karadut \u00d6z\u00fc',
 E'Konzentrierter schwarzer Maulbeersaft (Karadut \u00d6z\u00fc) aus der Tuerkei, reich an Antioxidantien und Vitaminen. Verduennt als erfrischendes Getraenk oder pur als natuerliches Staerkungsmittel geniessen.',
 E'Antioksidan ve vitamin a\u00e7\u0131s\u0131ndan zengin, T\u00fcrkiye''den konsantre karadut \u00f6z\u00fc suyu. Seyreltilmi\u015f ferahalt\u0131c\u0131 i\u00e7ecek veya saf doğal g\u00fc\u00e7lendirici olarak t\u00fcketilir.',
 9.00, 'spezialitaeten', '250ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('spe-005', E'T\u00fcrkischer Kaffee \u00c7ifte Kavrulmu\u015f', E'T\u00fcrk Kahvesi \u00c7ifte Kavrulmu\u015f',
 'Doppelt geroesteter tuerkischer Kaffee mit besonders intensivem, vollmundigem Aroma. Fein gemahlen fuer die traditionelle Zubereitung im Cezve, ein Klassiker der tuerkischen Kaffeekultur.',
 E'\u00d6zellikle yoğun, dolgun aromal\u0131 \u00e7ift kavrulmu\u015f T\u00fcrk kahvesi. Cezve''de geleneksel demleme i\u00e7in ince \u00f6ğ\u00fct\u00fclm\u00fc\u015f, T\u00fcrk kahve k\u00fclt\u00fcr\u00fcn\u00fcn klasiği.',
 5.00, 'spezialitaeten', '100g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('spe-006', E'T\u00fcrkischer Kaffee Damla Sak\u0131zl\u0131', E'T\u00fcrk Kahvesi Damla Sak\u0131zl\u0131',
 'Tuerkischer Kaffee mit Mastix (Damla Sakizi), der ihm ein einzigartiges harziges Aroma verleiht. Eine besondere Spezialitaet, die im Cezve zubereitet wird und mit ihrem Duft begeistert.',
 E'E\u015fsiz re\u00e7inemsi aroma veren damla sak\u0131zl\u0131 T\u00fcrk kahvesi. Cezve''de demlenen ve kokusuyla b\u00fcy\u00fcleyen \u00f6zel bir lezzet.',
 5.00, 'spezialitaeten', '100g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('spe-007', E'T\u00fcrkischer Kaffee Osmanl\u0131 Dibek', E'T\u00fcrk Kahvesi Osmanl\u0131 Dibek',
 E'Osmanischer Dibek-Kaffee, traditionell im Steinm\u00f6rser gemahlen mit einer Mischung aus Kaffee und aromatischen Gew\u00fcrzen. Milder als klassischer tuerkischer Kaffee, mit samtig-weichem Geschmack und langem Abgang.',
 E'Ta\u015f havanda geleneksel \u00f6ğ\u00fct\u00fclm\u00fc\u015f, kahve ve aromatik baharat kar\u0131\u015f\u0131ml\u0131 Osmanl\u0131 dibek kahvesi. Klasik T\u00fcrk kahvesinden daha yumu\u015fak, kadifemsi lezzet ve uzun b\u0131rak\u0131\u015fl\u0131.',
 5.00, 'spezialitaeten', '100g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

-- Neue Gewuerze
INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-2', 'Muskatnuss ganz', E'B\u00fct\u00fcn Hindistan Cevizi',
 'Ganze Muskatnuesse aus Indien, frisch gerieben fuer ein intensives, warm-wuerziges Aroma. Ideal zum Verfeinern von Bechamelsosse, Kartoffelgerichten und Wintergetraenken.',
 E'Hindistan''dan b\u00fct\u00fcn muskat cevizi, taze rendelendiğinde yoğun ve s\u0131cak baharatl\u0131 aroma verir. Be\u015famel sos, patatesli yemekler ve k\u0131\u015f i\u00e7ecekleri i\u00e7in ideal.',
 10.00, 'gewuerze', E'8 St\u00fcck', 'Indien', 'Hindistan', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-3', 'Steinsalz', 'Kaya Tuzu',
 'Naturbelassenes, unraffiniertes Steinsalz aus der Tuerkei mit natuerlichem Mineralgehalt. Vielseitig einsetzbar in der Kueche und als edle Wuerze fuer Salate und gegrilltes Fleisch.',
 E'T\u00fcrkiye''den doğal mineral i\u00e7eriğiyle rafine edilmemi\u015f kaya tuzu. Mutfakta \u00e7ok y\u00f6nl\u00fc kullan\u0131ma sahip, salata ve \u0131zgara et i\u00e7in zarif bir baharat.',
 5.00, 'gewuerze', '300g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

-- Neue Trockenfruechte
INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-4', 'Getrocknete Weintrauben', E'Kurutulmu\u015f \u00dczm',
 'Sonnengetrocknete tuerkische Weintrauben, natuerlich suess und voller Geschmack. Perfekt als Snack, im Muesli, zum Backen oder fuer orientalische Reisgerichte.',
 E'G\u00fcne\u015fte kurutulmu\u015f T\u00fcrk \u00fcz\u00fcm\u00fc, doğal tatl\u0131l\u0131ğ\u0131 ve dolu lezzetiyle. At\u0131\u015ft\u0131rmal\u0131k, m\u00fcsli, f\u0131r\u0131nc\u0131l\u0131k veya oryantal pirin\u00e7 yemekleri i\u00e7in m\u00fckemmel.',
 10.00, 'trockenfruechte', '500g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-6', E'Getrocknete Paprika f\u00fcr Dolma', E'K\u00f6y Dolmas\u0131 Kuru Biber',
 'Traditionell getrocknete rote Paprikaschoten aus dem tuerkischen Dorf, speziell zum Fuellen mit Reis und Gewuerzen. Authentische Zutat fuer klassisches Dolma nach Dorfart.',
 E'T\u00fcrk k\u00f6y\u00fcnden geleneksel kurutulmu\u015f k\u0131rm\u0131z\u0131 biberler, pirin\u00e7 ve baharatla doldurmak i\u00e7in \u00f6zel. K\u00f6y usul\u00fc klasik dolma i\u00e7in otantik malzeme.',
 10.00, 'trockenfruechte', '400g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-7', 'Getrocknete Feigen', E'Kuru \u0130ncir',
 'Sonnengetrocknete tuerkische Feigen, natuerlich suess und zart im Biss. Hervorragend als Snack, zum Kaese oder als natuerliche Suesse in Desserts und Backwaren.',
 E'G\u00fcne\u015fte kurutulmu\u015f T\u00fcrk inciri, doğal tatl\u0131l\u0131ğ\u0131 ve yumu\u015fak dokusuyla. At\u0131\u015ft\u0131rmal\u0131k, peynir yan\u0131nda veya tatl\u0131 ve hamur i\u015flerinde doğal tatland\u0131r\u0131c\u0131 olarak harika.',
 0.00, 'trockenfruechte', '500g', 'Tuerkei', E'T\u00fcrkiye', false, false, 50, 5);

-- Neue Spezialitaeten
INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-9', E'Z\u00fchre Ana Tannenzapfen Paste', E'Z\u00fchre Ana \u00c7am Kozalağ\u0131 Macunu',
 E'Traditionelle Tannenzapfen-Paste von Z\u00fchre Ana, ein nat\u00fcrliches Kr\u00e4uterprodukt aus der T\u00fcrkei. GMP-zertifiziert, hergestellt nach \u00fcberliefertem Rezept f\u00fcr das Wohlbefinden.',
 E'Z\u00fchre Ana''n\u0131n geleneksel \u00e7am kozalağ\u0131 macunu, T\u00fcrkiye''den doğal bitkisel \u00fcr\u00fcn. GMP sertifikal\u0131, sağl\u0131k ve esenlik i\u00e7in kadim tarifle \u00fcretilmi\u015ftir.',
 18.00, 'spezialitaeten', '240g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-10', E'Z\u00fchre Ana Bromelain Sirup', E'Z\u00fchre Ana Bromelain \u015eurubu',
 E'Bromelain-Sirup von Z\u00fchre Ana auf Ananas-Basis, ein nat\u00fcrliches Nahrungserg\u00e4nzungsmittel. Sorgf\u00e4ltig hergestellt f\u00fcr die t\u00e4gliche Einnahme als wohltuende Erg\u00e4nzung.',
 E'Z\u00fchre Ana''n\u0131n ananas bazl\u0131 bromelain \u015furubu, doğal g\u0131da takviyesi. G\u00fcnl\u00fck kullan\u0131m i\u00e7in \u00f6zenle \u00fcretilmi\u015f sağl\u0131kl\u0131 destek \u00fcr\u00fcn\u00fc.',
 20.00, 'spezialitaeten', '500ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-11', E'Z\u00fchre Ana Schwarzer Maulbeer-Extrakt', E'Z\u00fchre Ana Karadut \u00d6z\u00fc',
 E'Schwarzer Maulbeer-Extrakt von Z\u00fchre Ana, ein traditionelles Naturprodukt ohne k\u00fcnstliche Verdickungsmittel. Reich an nat\u00fcrlichen Inhaltsstoffen und seit Generationen als Hausmittel gesch\u00e4tzt.',
 E'Z\u00fchre Ana''n\u0131n yapay koyu\u015ft\u0131r\u0131c\u0131 i\u00e7ermeyen karadut \u00f6z\u00fc, geleneksel doğal \u00fcr\u00fcn. Doğal bile\u015fenler a\u00e7\u0131s\u0131ndan zengin, nesillerdir ev ilac\u0131 olarak değer g\u00f6rmektedir.',
 15.00, 'spezialitaeten', '500ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-12', E'Z\u00fchre Ana Kids Echinacea Sirup', E'Z\u00fchre Ana \u00c7ocuk Ekinezya \u015eurubu',
 E'Kinder-Echinacea-Sirup von Z\u00fchre Ana mit Ingwer, ein pflanzliches Nahrungserg\u00e4nzungsmittel speziell f\u00fcr Kinder. Sanfte Kr\u00e4uterformel zur Unterst\u00fctzung des Wohlbefindens.',
 E'Z\u00fchre Ana''n\u0131n zencefilli \u00e7ocuk ekinezya \u015furubu, \u00e7ocuklara \u00f6zel bitkisel g\u0131da takviyesi. Esenliği desteklemek i\u00e7in yumu\u015fak bitkisel form\u00fcl.',
 15.00, 'spezialitaeten', '150ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-13', E'Z\u00fchre Ana Ananas Essig', E'Z\u00fchre Ana Ananas Sirkesi',
 'Ananas-Essig von Zuehre Ana, natuerlich fermentiert aus frischen Ananas. Ein besonderer Essig mit fruchtigem Aroma fuer Salate, Marinaden und als erfrischende Zutat.',
 E'Z\u00fchre Ana''n\u0131n taze ananaslardan doğal fermantasyonla \u00fcretilmi\u015f ananas sirkesi. Salatalar, marineler ve ferahalt\u0131c\u0131 i\u00e7erik olarak meyvemsi aromal\u0131 \u00f6zel bir sirke.',
 15.00, 'spezialitaeten', '250ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-14', E'Anadoa Paste mit Extrakten \u2013 Speziell f\u00fcr M\u00e4nner', E'Anadoa Erkeklere \u00d6zel Macun',
 E'Premium-Kr\u00e4uterpaste von Anadoa mit nat\u00fcrlichen Extrakten, speziell f\u00fcr M\u00e4nner entwickelt. Hochwertige Rezeptur mit ausgew\u00e4hlten Zutaten in Premium-Qualit\u00e4t.',
 E'Anadoa''n\u0131n doğal ekstraktl\u0131 premium bitkisel macunu, erkeklere \u00f6zel form\u00fcl. Se\u00e7kin malzemelerle premium kalitede \u00fcretilmi\u015f y\u00fcksek kaliteli re\u00e7ete.',
 0.00, 'spezialitaeten', '240g', 'Tuerkei', E'T\u00fcrkiye', false, false, 0, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-15', E'Z\u00fchre Ana Extrakt aus Tropischen Fr\u00fcchten', E'Z\u00fchre Ana Tropik Meyve Ekstrakt\u0131',
 E'Tropischer Fruchtextrakt von Z\u00fchre Ana mit Passionsfrucht, Mango, Mandarine, Ananas und Limette. Eine exotische Mischung nat\u00fcrlicher Fruchtextrakte.',
 E'Z\u00fchre Ana''n\u0131n \u00e7ark\u0131felek meyvesi, mango, mandalina, ananas ve misket limonu i\u00e7eren tropik meyve ekstrakt\u0131. Doğal meyve \u00f6zlerinin egzotik kar\u0131\u015f\u0131m\u0131.',
 0.00, 'spezialitaeten', '500ml', 'Tuerkei', E'T\u00fcrkiye', false, false, 0, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-16', E'Z\u00fchre Ana Weissdorn Essig', E'Z\u00fchre Ana Al\u0131\u00e7 Sirkesi',
 E'Weissdorn-Essig von Z\u00fchre Ana, nat\u00fcrlich fermentiert aus Weissdornfr\u00fcchten. Ein traditionelles Naturprodukt, das seit Jahrhunderten in der t\u00fcrkischen Naturheilkunde gesch\u00e4tzt wird.',
 E'Z\u00fchre Ana''n\u0131n al\u0131\u00e7 meyvesinden doğal fermantasyonla \u00fcretilmi\u015f al\u0131\u00e7 sirkesi. Y\u00fczy\u0131llard\u0131r T\u00fcrk doğal t\u0131bb\u0131nda değer g\u00f6ren geleneksel doğal \u00fcr\u00fcn.',
 15.00, 'spezialitaeten', '250ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-17', E'Z\u00fchre Ana Apfelessig', E'Z\u00fchre Ana Elma Sirkesi',
 E'Naturtrueber Apfelessig von Z\u00fchre Ana, traditionell aus frischen Aepfeln nat\u00fcrlich fermentiert. Vielseitig verwendbar in Salaten, Marinaden und als wohltuendes Hausmittel.',
 E'Z\u00fchre Ana''n\u0131n taze elmalardan doğal fermantasyonla \u00fcretilmi\u015f doğal bulan\u0131k elma sirkesi. Salatalarda, marinelerde ve sağl\u0131kl\u0131 ev ilac\u0131 olarak \u00e7ok y\u00f6nl\u00fc kullan\u0131m.',
 15.00, 'spezialitaeten', '250ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-18', E'Z\u00fchre Ana Schwarzer Aprikosen Extrakt', E'Z\u00fchre Ana Kuru Kay\u0131s\u0131 Ekstrakt\u0131',
 E'Schwarzer Aprikosen-Extrakt von Z\u00fchre Ana, ein nat\u00fcrliches Nahrungserg\u00e4nzungsmittel aus konzentrierten Aprikosen. Hergestellt aus t\u00fcrkischen Aprikosen nach traditioneller Methode.',
 E'Z\u00fchre Ana''n\u0131n konsantre kay\u0131s\u0131lardan \u00fcretilmi\u015f doğal g\u0131da takviyesi kuru kay\u0131s\u0131 ekstrakt\u0131. Geleneksel y\u00f6ntemle T\u00fcrk kay\u0131s\u0131lar\u0131ndan \u00fcretilmi\u015ftir.',
 0.00, 'spezialitaeten', '500ml', 'Tuerkei', E'T\u00fcrkiye', false, false, 0, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-19', E'Z\u00fchre Ana Detox Gold Essig', E'Z\u00fchre Ana Detox Gold Sirkesi',
 E'Detox-Essigmischung von Z\u00fchre Ana mit Goldpflaume, Zitrone, Aprikose, gr\u00fcnem Tee, Ingwer, gr\u00fcnem Apfel und Sandelholzharz. Nat\u00fcrlich fermentierte Premium-Komposition f\u00fcr das Wohlbefinden.',
 E'Z\u00fchre Ana''n\u0131n can eriği, limon, kay\u0131s\u0131, ye\u015fil \u00e7ay, zencefil, ye\u015fil elma ve sandaloz sak\u0131z\u0131 i\u00e7eren detox sirke kar\u0131\u015f\u0131m\u0131. Esenlik i\u00e7in doğal fermente premium kompozisyon.',
 15.00, 'spezialitaeten', '250ml', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-20', E'Z\u00fchre Ana Kids Kakaopaste', E'Z\u00fchre Ana \u00c7ocuk Kakao Macunu',
 E'Kakaopaste von Z\u00fchre Ana speziell f\u00fcr Kinder, ein hologrammkontrolliertes Qualit\u00e4tsprodukt. Leckere Schokoladenpaste mit sorgf\u00e4ltig ausgew\u00e4hlten Zutaten f\u00fcr die Kleinen.',
 E'Z\u00fchre Ana''n\u0131n \u00e7ocuklara \u00f6zel kakao macunu, hologram kontroll\u00fc kalite \u00fcr\u00fcn\u00fc. K\u00fc\u00e7\u00fckler i\u00e7in \u00f6zenle se\u00e7ilmi\u015f malzemelerle haz\u0131rlanm\u0131\u015f lezzetli \u00e7ikolata macunu.',
 18.00, 'spezialitaeten', '330g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-21', E'Z\u00fchre Ana Bromelain Tabletten', E'Z\u00fchre Ana Bromelain Tablet',
 E'Bromelain-Nahrungserg\u00e4nzungsmittel von Z\u00fchre Ana mit Quercetin und Chrompicolinat. 60 Tabletten \u00e0 1250 mg f\u00fcr die t\u00e4gliche Nahrungserg\u00e4nzung.',
 E'Z\u00fchre Ana''n\u0131n Quercetin ve Krom Pikolinat i\u00e7eren bromelain g\u0131da takviyesi. G\u00fcnl\u00fck takviye i\u00e7in 1250 mg''l\u0131k 60 tablet.',
 18.00, 'spezialitaeten', '60 Tabletten / 1250mg', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-22', E'Z\u00fchre Ana Omega 3 Fisch\u00f6l Kapseln', E'Z\u00fchre Ana Omega 3 Bal\u0131k Yağ\u0131',
 E'Omega-3-Fisch\u00f6lkapseln von Z\u00fchre Ana mit DHA und EPA. 200 Weichgelatinekapseln, hologrammkontrolliert f\u00fcr h\u00f6chste Qualit\u00e4tssicherung.',
 E'Z\u00fchre Ana''n\u0131n DHA ve EPA i\u00e7eren Omega 3 bal\u0131k yağ\u0131 kaps\u00fclleri. 200 yumu\u015fak jelatin kaps\u00fcl, en y\u00fcksek kalite g\u00fcvencesi i\u00e7in hologram kontroll\u00fc.',
 25.00, 'spezialitaeten', '200 Kapseln', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-23', E'Z\u00fchre Ana Propolis Paste', E'Z\u00fchre Ana Propolis Macunu',
 E'Propolis-Paste von Z\u00fchre Ana mit Beta-Glucan, GMP-zertifiziert und halal. Traditionelle Kr\u00e4uterpaste mit Propolis f\u00fcr das t\u00e4gliche Wohlbefinden.',
 E'Z\u00fchre Ana''n\u0131n Beta-Gl\u00fckan i\u00e7eren propolis macunu, GMP sertifikal\u0131 ve helal. G\u00fcnl\u00fck esenlik i\u00e7in propolisli geleneksel bitkisel macun.',
 15.00, 'spezialitaeten', '240g', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-24', E'Z\u00fchre Ana Magnesium Tabletten', E'Z\u00fchre Ana Magnezyum Tablet',
 E'Magnesium-Nahrungserg\u00e4nzungsmittel von Z\u00fchre Ana mit Taurat-, Bisglycinat- und Malat-Formen. 60 Tabletten \u00e0 1650 mg f\u00fcr eine optimale Magnesiumversorgung.',
 E'Z\u00fchre Ana''n\u0131n Taurat, Bisglisinat ve Malat formlar\u0131n\u0131 i\u00e7eren magnezyum g\u0131da takviyesi. Optimum magnezyum desteği i\u00e7in 1650 mg''l\u0131k 60 tablet.',
 15.00, 'spezialitaeten', '60 Tabletten / 1650mg', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-25', E'Z\u00fchre Ana Vitamin B12 Tabletten', E'Z\u00fchre Ana B12 Tablet',
 'Vitamin B12 (Cyanocobalamin) Nahrungsergaenzungsmittel von Zuehre Ana. 60 Tabletten a 300 mg zur Unterstuetzung des Energiestoffwechsels und Nervensystems.',
 E'Z\u00fchre Ana''n\u0131n B12 vitamini (Siyanokobalamin) g\u0131da takviyesi. Enerji metabolizmas\u0131 ve sinir sistemi desteği i\u00e7in 300 mg''l\u0131k 60 tablet.',
 18.00, 'spezialitaeten', '60 Tabletten / 300mg', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

INSERT INTO products (id, name, name_tr, description, description_tr, price, category, weight, origin, origin_tr, in_stock, featured, stock, low_stock_threshold) VALUES
('yeni-26', E'Z\u00fchre Ana Collagen Tabletten', E'Z\u00fchre Ana Kolajen Tablet',
 'Kollagen-Tabletten von Zuehre Ana mit Keratin und D-Biotin, Typ I, II, III, V und X. 60 Tabletten a 1000 mg fuer Haut, Haare und Gelenke.',
 E'Z\u00fchre Ana''n\u0131n Keratin ve D-Biotin i\u00e7eren kolajen tabletleri, Tip I, II, III, V ve X. Cilt, sa\u00e7 ve eklem sağl\u0131ğ\u0131 i\u00e7in 1000 mg''l\u0131k 60 tablet.',
 25.00, 'spezialitaeten', '60 Tabletten / 1000mg', 'Tuerkei', E'T\u00fcrkiye', true, false, 50, 5);

-- ============================================================================
-- STEP 4: Seed product_variants (only for products that have variants)
-- ============================================================================

-- gew-001: Sumak
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-001-250g', 'gew-001', '250g', 6.00, '250g'),
('gew-001-500g', 'gew-001', '500g', 10.00, '500g');

-- gew-002: Isot Biber
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-002-200g', 'gew-002', '200g', 5.00, '200g'),
('gew-002-500g', 'gew-002', '500g', 10.00, '500g');

-- gew-003: Knoblauchpulver
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-003-200g', 'gew-003', '200g', 5.00, '200g');

-- gew-004: Petersilie getrocknet
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-004-150g', 'gew-004', '150g', 5.00, '150g');

-- gew-005: Dill Spitzen
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-005-100g', 'gew-005', '100g', 5.00, '100g');

-- gew-006: Chili ganz scharf
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-006-150g', 'gew-006', '150g', 5.00, '150g');

-- gew-007: Scharfe Paprikapaste
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-007-1000g', 'gew-007', '1000g', 8.00, '1000g');

-- gew-008: Suesse Paprikapaste
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-008-1000g', 'gew-008', '1000g', 8.00, '1000g');

-- gew-009: Tomatenmark
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-009-1000g', 'gew-009', '1000g', 8.00, '1000g');

-- gew-010: Sumak Eksisi
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('gew-010-250ml', 'gew-010', '250ml', 15.00, '250ml');

-- tro-001: Getrocknete Aprikosen
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-001-400g', 'tro-001', '400g', 8.00, '400g'),
('tro-001-1kg', 'tro-001', '1kg', 18.00, '1kg');

-- tro-002: Getrocknete Maulbeeren
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-002-200g', 'tro-002', '200g', 6.00, '200g');

-- tro-003: Getrocknete Feigen
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-003-400g', 'tro-003', '400g', 7.00, '400g'),
('tro-003-1kg', 'tro-003', '1kg', 15.00, '1kg');

-- tro-004: Kernlose schwarze Trauben
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-004-400g', 'tro-004', '400g', 5.00, '400g');

-- tro-005: Getrocknete Sauerkirschen
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-005-200g', 'tro-005', '200g', 7.00, '200g');

-- tro-006: Medjool Datteln Choice
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-006-500g', 'tro-006', '500g', 12.00, '500g'),
('tro-006-1kg', 'tro-006', '1kg', 22.00, '1kg');

-- tro-007: Medjool Datteln Premium Jumbo
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-007-500g', 'tro-007', '500g', 18.00, '500g'),
('tro-007-1kg', 'tro-007', '1kg', 32.00, '1kg');

-- tro-008: Aegyptische Premium Datteln
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('tro-008-750g', 'tro-008', '750g', 15.00, '750g'),
('tro-008-5kg', 'tro-008', '5kg', 60.00, '5kg');

-- fru-001: Tahini
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('fru-001-935g', 'fru-001', '935g', 11.00, '935g');

-- fru-002: Traubenmelasse
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('fru-002-1kg', 'fru-002', '1kg', 10.00, '1kg');

-- fru-003: Johannisbrotmelasse
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('fru-003-620g', 'fru-003', '620g', 10.00, '620g');

-- fru-004: Karakovan Bluetenhonig
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('fru-004-850g', 'fru-004', '850g', 25.00, '850g');

-- fru-005: Alter Kasar-Kaese
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('fru-005-500g', 'fru-005', '500g', 10.00, '500g');

-- fru-006: Kuenefe-Kaese
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('fru-006-400g', 'fru-006', '400g', 8.00, '400g');

-- fru-007: Dil Peyniri
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('fru-007-400g', 'fru-007', '400g', 8.00, '400g');

-- oel-001: Natives Olivenoel Extra
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('oel-001-750ml', 'oel-001', '750ml', 12.00, '750ml'),
('oel-001-5L', 'oel-001', '5L', 55.00, '5L');

-- oel-003: Schwarzkuemmeloel
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('oel-003-125ml', 'oel-003', '125ml', 10.00, '125ml');

-- oel-004: Apfelessig
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('oel-004-500ml', 'oel-004', '500ml', 15.00, '500ml');

-- nus-001: Antep-Pistazien
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-001-700g', 'nus-001', '700g', 25.00, '700g');

-- nus-002: Walnusskerne
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-002-750g', 'nus-002', '750g', 15.00, '750g');

-- nus-003: Cashewkerne
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-003-800g', 'nus-003', '800g', 15.00, '800g');

-- nus-004: Geroestete Mandeln
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-004-800g', 'nus-004', '800g', 15.00, '800g');

-- nus-005: Giresun Haselnuesse
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-005-600g', 'nus-005', '600g', 22.00, '600g');

-- nus-006: Geroestete Kichererbsen
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-006-800g', 'nus-006', '800g', 9.00, '800g');

-- nus-007: Kuerbiskerne
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-007-500g', 'nus-007', '500g', 8.00, '500g');

-- nus-008: Geroesteter Mais
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-008-500g', 'nus-008', '500g', 6.00, '500g');

-- nus-009: Gemischte Nuesse
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('nus-009-500g', 'nus-009', '500g', 14.00, '500g');

-- spe-001: Kavurma
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('spe-001-130g', 'spe-001', '130g', 5.00, '130g');

-- spe-002: Tarhana
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('spe-002-500g', 'spe-002', '500g', 8.00, '500g');

-- spe-003: Granatapfelsirup
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('spe-003-500ml', 'spe-003', '500ml', 7.00, '500ml');

-- spe-004: Schwarzer Maulbeersaft
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('spe-004-250ml', 'spe-004', '250ml', 9.00, '250ml');

-- spe-005: Tuerkischer Kaffee Cifte Kavrulmus
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('spe-005-100g', 'spe-005', '100g', 5.00, '100g');

-- spe-006: Tuerkischer Kaffee Damla Sakizli
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('spe-006-100g', 'spe-006', '100g', 5.00, '100g');

-- spe-007: Tuerkischer Kaffee Osmanli Dibek
INSERT INTO product_variants (id, product_id, name, price, weight) VALUES
('spe-007-100g', 'spe-007', '100g', 5.00, '100g');

-- NOTE: yeni-1 through yeni-26 have empty variants arrays, so no variant rows needed.

-- ============================================================================
-- STEP 5: Seed product_images
-- ============================================================================

-- gew-001
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-001', '/images/gewuerze/sumak.jpeg', 0),
('gew-001', '/images/gewuerze/sumak-2.jpeg', 1);

-- gew-002
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-002', '/images/gewuerze/isot-biber.jpeg', 0),
('gew-002', '/images/gewuerze/isot-biber-2.jpeg', 1);

-- gew-003
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-003', '/images/gewuerze/knoblauchpulver.jpeg', 0);

-- gew-004
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-004', '/images/gewuerze/petersilie.jpeg', 0);

-- gew-005
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-005', '/images/gewuerze/dill.jpeg', 0);

-- gew-006
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-006', '/images/gewuerze/chili-ganz.jpeg', 0);

-- gew-007
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-007', '/images/gewuerze/scharfe-paprikapaste.jpeg', 0);

-- gew-008
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-008', '/images/gewuerze/suesse-paprikapaste.jpeg', 0);

-- gew-009
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-009', '/images/gewuerze/tomatenmark.jpeg', 0);

-- gew-010
INSERT INTO product_images (product_id, url, sort_order) VALUES
('gew-010', '/images/gewuerze/sumak-eksisi.jpeg', 0),
('gew-010', '/images/gewuerze/sumak-eksisi-2.jpeg', 1);

-- tro-001
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-001', '/images/trockenfruechte/aprikosen.jpeg', 0),
('tro-001', '/images/trockenfruechte/aprikosen-2.jpeg', 1);

-- tro-002
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-002', '/images/trockenfruechte/maulbeeren.jpeg', 0),
('tro-002', '/images/trockenfruechte/maulbeeren-2.jpeg', 1);

-- tro-003
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-003', '/images/trockenfruechte/feigen.jpeg', 0);

-- tro-004
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-004', '/images/trockenfruechte/schwarze-trauben.jpeg', 0);

-- tro-005
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-005', '/images/trockenfruechte/sauerkirschen.jpeg', 0);

-- tro-006
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-006', '/images/trockenfruechte/medjool-choice.jpeg', 0);

-- tro-007
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-007', '/images/trockenfruechte/medjool-premium.jpeg', 0),
('tro-007', '/images/trockenfruechte/medjool-premium-2.jpeg', 1);

-- tro-008
INSERT INTO product_images (product_id, url, sort_order) VALUES
('tro-008', '/images/trockenfruechte/aegyptische-datteln.jpeg', 0),
('tro-008', '/images/trockenfruechte/aegyptische-datteln-2.jpeg', 1),
('tro-008', '/images/trockenfruechte/aegyptische-datteln-3.jpeg', 2);

-- fru-001
INSERT INTO product_images (product_id, url, sort_order) VALUES
('fru-001', '/images/fruehstueck/tahini.jpeg', 0),
('fru-001', '/images/fruehstueck/tahini-2.jpeg', 1);

-- fru-002
INSERT INTO product_images (product_id, url, sort_order) VALUES
('fru-002', '/images/fruehstueck/traubenmelasse.jpeg', 0),
('fru-002', '/images/fruehstueck/traubenmelasse-2.jpeg', 1);

-- fru-003
INSERT INTO product_images (product_id, url, sort_order) VALUES
('fru-003', '/images/fruehstueck/johannisbrotmelasse.jpeg', 0),
('fru-003', '/images/fruehstueck/johannisbrotmelasse-2.jpeg', 1);

-- fru-004
INSERT INTO product_images (product_id, url, sort_order) VALUES
('fru-004', '/images/fruehstueck/honig.jpeg', 0),
('fru-004', '/images/fruehstueck/honig-2.jpeg', 1);

-- fru-005
INSERT INTO product_images (product_id, url, sort_order) VALUES
('fru-005', '/images/fruehstueck/eski-kasar.jpeg', 0),
('fru-005', '/images/fruehstueck/eski-kasar-2.jpeg', 1);

-- fru-006
INSERT INTO product_images (product_id, url, sort_order) VALUES
('fru-006', '/images/fruehstueck/kunefe-peyniri.jpeg', 0),
('fru-006', '/images/fruehstueck/kunefe-peyniri-2.jpeg', 1);

-- fru-007
INSERT INTO product_images (product_id, url, sort_order) VALUES
('fru-007', '/images/fruehstueck/dil-peyniri.jpeg', 0);

-- oel-001
INSERT INTO product_images (product_id, url, sort_order) VALUES
('oel-001', '/images/oele/olivenoel-750ml.jpeg', 0),
('oel-001', '/images/oele/olivenoel-750ml-2.jpeg', 1);

-- oel-003
INSERT INTO product_images (product_id, url, sort_order) VALUES
('oel-003', '/images/oele/schwarzkuemmeloel.jpeg', 0),
('oel-003', '/images/oele/schwarzkuemmeloel-2.jpeg', 1);

-- oel-004
INSERT INTO product_images (product_id, url, sort_order) VALUES
('oel-004', '/images/oele/apfelessig.jpeg', 0);

-- nus-001
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-001', '/images/nuesse/antep-pistazien.jpeg', 0),
('nus-001', '/images/nuesse/antep-pistazien-2.jpeg', 1);

-- nus-002
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-002', '/images/nuesse/walnusskerne.jpeg', 0),
('nus-002', '/images/nuesse/walnusskerne-2.jpeg', 1),
('nus-002', '/images/nuesse/walnusskerne-3.jpeg', 2);

-- nus-003
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-003', '/images/nuesse/cashewkerne.jpeg', 0),
('nus-003', '/images/nuesse/cashewkerne-2.jpeg', 1);

-- nus-004
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-004', '/images/nuesse/mandeln.jpeg', 0),
('nus-004', '/images/nuesse/mandeln-2.jpeg', 1);

-- nus-005
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-005', '/images/nuesse/haselnuesse.jpeg', 0),
('nus-005', '/images/nuesse/haselnuesse-2.jpeg', 1);

-- nus-006
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-006', '/images/nuesse/leblebi.jpeg', 0),
('nus-006', '/images/nuesse/leblebi-2.jpeg', 1);

-- nus-007
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-007', '/images/nuesse/kuerbiskerne.jpeg', 0);

-- nus-008
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-008', '/images/nuesse/corn-nuts.jpeg', 0);

-- nus-009
INSERT INTO product_images (product_id, url, sort_order) VALUES
('nus-009', '/images/nuesse/gemischte-nuesse.jpeg', 0);

-- spe-001
INSERT INTO product_images (product_id, url, sort_order) VALUES
('spe-001', '/images/spezialitaeten/kavurma.jpeg', 0),
('spe-001', '/images/spezialitaeten/kavurma-2.jpeg', 1);

-- spe-002
INSERT INTO product_images (product_id, url, sort_order) VALUES
('spe-002', '/images/spezialitaeten/tarhana.jpeg', 0),
('spe-002', '/images/spezialitaeten/tarhana-2.jpeg', 1);

-- spe-003
INSERT INTO product_images (product_id, url, sort_order) VALUES
('spe-003', '/images/spezialitaeten/granatapfelsirup.jpeg', 0);

-- spe-004
INSERT INTO product_images (product_id, url, sort_order) VALUES
('spe-004', '/images/spezialitaeten/karadut-oezu.jpeg', 0);

-- spe-005
INSERT INTO product_images (product_id, url, sort_order) VALUES
('spe-005', '/images/spezialitaeten/kaffee-cifte.jpeg', 0);

-- spe-006
INSERT INTO product_images (product_id, url, sort_order) VALUES
('spe-006', '/images/spezialitaeten/kaffee-damla.jpeg', 0),
('spe-006', '/images/spezialitaeten/kaffee-damla-2.jpeg', 1);

-- spe-007
INSERT INTO product_images (product_id, url, sort_order) VALUES
('spe-007', '/images/spezialitaeten/kaffee-dibek.jpeg', 0),
('spe-007', '/images/spezialitaeten/kaffee-dibek-2.jpeg', 1);

-- yeni-1: Dana Kavurma
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-1', '/images/yeni-urunler/dana-kavurma.jpeg', 0);

-- yeni-2: Muskatnuss ganz
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-2', '/images/yeni-urunler/muskat-tane.jpeg', 0);

-- yeni-3: Steinsalz
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-3', '/images/yeni-urunler/kaya-tuzu.jpeg', 0);

-- yeni-4: Getrocknete Weintrauben
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-4', '/images/yeni-urunler/kurutulmus-uzum.jpeg', 0);

-- yeni-5: Tuerkische Butter
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-5', '/images/yeni-urunler/tereyagi.jpeg', 0);

-- yeni-6: Getrocknete Paprika fuer Dolma
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-6', '/images/yeni-urunler/koy-dolmasi-biber.jpeg', 0);

-- yeni-7: Getrocknete Feigen (yeni)
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-7', '/images/yeni-urunler/koy-dolmasi-incir.jpeg', 0);

-- yeni-8: Dermann Nussmischung
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-8', '/images/yeni-urunler/dermann-kuruyemis.jpeg', 0);

-- yeni-9: Zuehre Ana Tannenzapfen Paste
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-9', '/images/yeni-urunler/zuhre-ana-tannenzapfen.jpeg', 0);

-- yeni-10: Zuehre Ana Bromelain Sirup
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-10', '/images/yeni-urunler/zuhre-ana-bromelain-surup.jpeg', 0);

-- yeni-11: Zuehre Ana Schwarzer Maulbeer-Extrakt
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-11', '/images/yeni-urunler/zuhre-ana-karadut-ozu.jpeg', 0);

-- yeni-12: Zuehre Ana Kids Echinacea Sirup
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-12', '/images/yeni-urunler/zuhre-ana-kids-ekinezya.jpeg', 0);

-- yeni-13: Zuehre Ana Ananas Essig
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-13', '/images/yeni-urunler/zuhre-ana-ananas-sirkesi.jpeg', 0);

-- yeni-14: Anadoa Paste fuer Maenner
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-14', '/images/yeni-urunler/anadoa-paste-maenner.jpeg', 0);

-- yeni-15: Zuehre Ana Tropische Fruechte Extrakt
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-15', '/images/yeni-urunler/zuhre-ana-tropik-meyve.jpeg', 0);

-- yeni-16: Zuehre Ana Weissdorn Essig
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-16', '/images/yeni-urunler/zuhre-ana-alic-sirkesi.jpeg', 0);

-- yeni-17: Zuehre Ana Apfelessig
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-17', '/images/yeni-urunler/zuhre-ana-elma-sirkesi.jpeg', 0);

-- yeni-18: Zuehre Ana Schwarzer Aprikosen Extrakt
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-18', '/images/yeni-urunler/zuhre-ana-kayisi-ekstrakt.jpeg', 0);

-- yeni-19: Zuehre Ana Detox Gold Essig
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-19', '/images/yeni-urunler/zuhre-ana-detox-gold.jpeg', 0);

-- yeni-20: Zuehre Ana Kids Kakaopaste
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-20', '/images/yeni-urunler/zuhre-ana-kids-kakaopaste.jpeg', 0);

-- yeni-21: Zuehre Ana Bromelain Tabletten
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-21', '/images/yeni-urunler/zuhre-ana-bromelain-tablet.jpeg', 0);

-- yeni-22: Zuehre Ana Omega 3 Fischoel Kapseln
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-22', '/images/yeni-urunler/zuhre-ana-omega3.jpeg', 0);

-- yeni-23: Zuehre Ana Propolis Paste
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-23', '/images/yeni-urunler/zuhre-ana-propolis.jpeg', 0);

-- yeni-24: Zuehre Ana Magnesium Tabletten
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-24', '/images/yeni-urunler/zuhre-ana-magnezyum.jpeg', 0);

-- yeni-25: Zuehre Ana Vitamin B12 Tabletten
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-25', '/images/yeni-urunler/zuhre-ana-b12.jpeg', 0);

-- yeni-26: Zuehre Ana Collagen Tabletten
INSERT INTO product_images (product_id, url, sort_order) VALUES
('yeni-26', '/images/yeni-urunler/zuhre-ana-collagen.jpeg', 0);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Quick check: should return 70
-- SELECT COUNT(*) AS product_count FROM products;
-- SELECT COUNT(*) AS variant_count FROM product_variants;
-- SELECT COUNT(*) AS image_count FROM product_images;

COMMIT;

-- ============================================================================
-- DONE
-- ============================================================================
-- After running this migration, verify with:
--   SELECT COUNT(*) FROM products;           -- Expected: 70
--   SELECT COUNT(*) FROM product_variants;   -- Expected: 44
--   SELECT COUNT(*) FROM product_images;     -- Expected: 96
--   SELECT category, COUNT(*) FROM products GROUP BY category ORDER BY category;
-- ============================================================================
