-- =============================================
-- 02_temizleme.sql
-- Aşama 2B: Temiz view'lerin oluşturulması
-- Kaynak kararlar: 01_veri_kesfi.sql
-- =============================================
-- Temiz view'ler için ayrı bir şema
CREATE SCHEMA IF NOT EXISTS clean;
-- ---------------------------------------------
-- 1. clean.orders
-- - Tarihler text yerine gerçek tarih tipine çevrildi
-- - Analiz dönemi: Ocak 2017 - Ağustos 2018
-- - Gerçek müşteri kimliği (customer_unique_id) ve eyalet eklendi
-- - Teslimat süresi ve gecikme bilgisi hesaplandı
-- ---------------------------------------------
CREATE OR REPLACE VIEW clean.orders AS
SELECT o.order_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    o.order_status,
    o.order_purchase_timestamp::timestamp AS purchase_ts,
    o.order_approved_at::timestamp AS approved_ts,
    o.order_delivered_carrier_date::timestamp AS carrier_ts,
    o.order_delivered_customer_date::timestamp AS delivered_ts,
    o.order_estimated_delivery_date::timestamp AS estimated_delivery_ts,
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)::date AS order_month,
    o.order_delivered_customer_date::date - o.order_purchase_timestamp::date AS delivery_days,
    CASE
        WHEN o.order_delivered_customer_date IS NULL THEN NULL
        WHEN o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date THEN 1
        ELSE 0
    END AS is_late
FROM public.orders AS o
    LEFT JOIN public.customers AS c ON o.customer_id = c.customer_id
WHERE o.order_purchase_timestamp::timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp::timestamp < '2018-09-01';
-- ---------------------------------------------
-- 2. clean.order_items
-- - Her ürüne İngilizce kategori adı eklendi
-- - Kategorisi boş ürünler 'unknown' olarak işaretlendi
-- - Çevirisi eksik 2 kategori elle çevrildi
-- - Sadece analiz dönemindeki siparişler (clean.orders) alındı
-- ---------------------------------------------
CREATE OR REPLACE VIEW clean.order_items AS
SELECT oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    COALESCE(
        t.product_category_name_english,
        CASE
            p.product_category_name
            WHEN 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'portable_kitchen_food_preparers'
            WHEN 'pc_gamer' THEN 'pc_gamer'
        END,
        'unknown'
    ) AS category
FROM public.order_items AS oi
    LEFT JOIN public.products AS p ON oi.product_id = p.product_id
    LEFT JOIN public.product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE oi.order_id IN (
        SELECT order_id
        FROM clean.orders
    );
-- ---------------------------------------------
-- 3. clean.reviews
-- - Her sipariş için yalnızca en son yanıtlanan yorum tutuldu
--   (bazı siparişlerin birden fazla yorumu vardı)
-- - Tarihler gerçek tarih tipine çevrildi
-- - Sadece analiz dönemindeki siparişler (clean.orders) alındı
-- ---------------------------------------------
CREATE OR REPLACE VIEW clean.reviews AS
SELECT order_id,
    review_id,
    review_score,
    review_creation_ts,
    review_answer_ts
FROM (
        SELECT order_id,
            review_id,
            review_score,
            review_creation_date::timestamp AS review_creation_ts,
            review_answer_timestamp::timestamp AS review_answer_ts,
            ROW_NUMBER() OVER (
                PARTITION BY order_id
                ORDER BY review_answer_timestamp::timestamp DESC,
                    review_id
            ) AS rn
        FROM public.order_reviews
        WHERE order_id IN (
                SELECT order_id
                FROM clean.orders
            )
    ) AS sirali_yorumlar
WHERE rn = 1;