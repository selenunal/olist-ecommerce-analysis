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