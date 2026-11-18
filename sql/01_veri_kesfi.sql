-- =============================================
-- 01_veri_kesfi.sql
-- Aşama 2A: Veri keşfi
-- =============================================
-- 1. Aylık sipariş sayıları
-- Amaç: Verinin başında ve sonunda seyrek aylar var mı?
SELECT DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS ay,
    COUNT(*) AS siparis_sayisi
FROM orders
GROUP BY ay
ORDER BY ay;
-- BULGU: 2016 yılı düzensiz (Eyl: 4, Eki: 324, Kas: 0, Ara: 1).
--        Eylül-Ekim 2018 eksik (16 ve 4 sipariş), veri toplama tarihi burada kesilmiş.
-- KARAR: Analiz dönemi Ocak 2017 - Ağustos 2018 (20 ay) olarak belirlendi.
--        Dışarıda kalan: 349 sipariş (%0,35).
-- 2. Sipariş tarihlerinde eksik değerler
-- Amaç: Hangi tarih kolonlarında boş değer var?

SELECT order_status,
    COUNT(*) AS toplam,
    SUM(
        CASE
            WHEN order_approved_at IS NULL THEN 1
            ELSE 0
        END
    ) AS onay_bos,
    SUM(
        CASE
            WHEN order_delivered_carrier_date IS NULL THEN 1
            ELSE 0
        END
    ) AS kargoya_verilis_bos,
    SUM(
        CASE
            WHEN order_delivered_customer_date IS NULL THEN 1
            ELSE 0
        END
    ) AS teslim_bos
FROM orders
GROUP BY order_status
ORDER BY toplam DESC;
-- BULGU: Eksik tarihlerin büyük kısmı sipariş sürecine göre mantıklı
--        (örn. shipped siparişlerin teslim tarihi henüz yok).
--        Ancak 8 delivered siparişin teslim tarihi boş (veri kalitesi sorunu).
--        6 canceled siparişin teslim tarihi dolu (muhtemelen iade).
-- KARAR: Teslimat analizlerinde yalnızca teslim tarihi dolu olan
--        delivered siparişler kullanılacak.

-- 3. Teslimat sürelerinin mantık kontrolü
-- Amaç: Tarihler mantıklı mı, uç değerler var mı?
SELECT
    COUNT(*) AS teslim_edilen_siparis,
    SUM(CASE WHEN order_delivered_customer_date::date < order_purchase_timestamp::date
             THEN 1 ELSE 0 END) AS teslim_siparisten_once,
    MIN(order_delivered_customer_date::date - order_purchase_timestamp::date) AS en_kisa_gun,
    MAX(order_delivered_customer_date::date - order_purchase_timestamp::date) AS en_uzun_gun,
    ROUND(AVG(order_delivered_customer_date::date - order_purchase_timestamp::date), 1) AS ortalama_gun
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- BULGU: 96.470 teslim edilmiş siparişte mantıksız tarih yok
--        (teslim tarihi sipariş tarihinden önce olan kayıt: 0).
--        Ortalama teslimat 12,5 gün, en uzun 210 gün (uç değer).
-- KARAR: Uç değerler silinmeyecek (gerçek müşteri deneyimi).
--        Teslimat süresinde ortalamayla birlikte medyan da raporlanacak.

-- 4. Teslimat süresinin dağılımı
-- Amaç: Uç değerler ne kadar yaygın? Tipik teslimat süresi ne?
SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gun) AS medyan_gun,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY gun) AS yuzde90_gun,
    SUM(CASE WHEN gun > 30 THEN 1 ELSE 0 END) AS otuz_gunden_uzun,
    SUM(CASE WHEN gun > 60 THEN 1 ELSE 0 END) AS altmis_gunden_uzun
FROM (
    SELECT order_delivered_customer_date::date - order_purchase_timestamp::date AS gun
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
) AS teslimatlar;
-- BULGU: Medyan teslimat 10 gün, ortalama 12,5 gün (sağa çarpık dağılım).
--        Siparişlerin %90'ı 23 gün içinde teslim ediliyor.
--        30 günden uzun: 4.294 sipariş (~%4,5), 60 günden uzun: 298 (~%0,3).
-- NOT:   Uzun teslimatların müşteri puanına etkisi Aşama 3'te incelenecek.

-- 5. Yorum tablosunun yapısı
-- Amaç: Her siparişin tek bir yorumu mu var?
SELECT
    COUNT(*)                  AS yorum_satiri,
    COUNT(DISTINCT order_id)  AS yorumlanan_siparis,
    COUNT(DISTINCT review_id) AS farkli_yorum_id
FROM order_reviews;
-- BULGU: 99.224 yorum satırı, 98.673 yorumlanan sipariş, 98.410 farklı yorum.
--        551 ek satır: bazı siparişlerin birden fazla yorumu var.
--        768 siparişin hiç yorumu yok.
-- RİSK:  Siparişlerle birleştirince (JOIN) satırlar çoğalır, satış iki kez sayılabilir.
-- KARAR: Her sipariş için en son yorum kullanılacak (Aşama 2B).
--        Yorumsuz siparişler memnuniyet hesaplarına dahil edilmeyecek.

-- 6a. Kategori bilgisi eksik ürünler
SELECT
    COUNT(*) AS urun_sayisi,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS kategori_bos,
    COUNT(DISTINCT product_category_name) AS kategori_sayisi
FROM products;

-- 6b. Çeviri tablosunda karşılığı olmayan kategoriler
SELECT DISTINCT p.product_category_name
FROM products AS p
LEFT JOIN product_category_name_translation AS t
       ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
  AND p.product_category_name IS NOT NULL;

  -- BULGU: 32.951 ürün, 73 kategori. 610 ürünün kategorisi boş (~%1,9).
--        2 kategorinin İngilizce çevirisi yok:
--        portateis_cozinha_e_preparadores_de_alimentos, pc_gamer
-- KARAR: Boş kategoriler 'unknown' olarak işaretlenecek (satış toplamından düşmemesi için).
--        Eksik çeviriler elle eklenecek (Aşama 2B).