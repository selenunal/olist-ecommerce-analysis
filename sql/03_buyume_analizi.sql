-- =============================================
-- 03_buyume_analizi.sql
-- Aşama 3 - Alt soru 1: Sipariş sayısı ve satış tutarı aylara göre nasıl değişiyor?
-- KPI'lar: Aylık sipariş sayısı, aylık satış tutarı, ortalama sepet, aylık büyüme oranı
-- =============================================
WITH aylik AS (
    SELECT o.order_month,
        COUNT(DISTINCT o.order_id) AS siparis_sayisi,
        ROUND(SUM(oi.price)::numeric, 0) AS satis_tutari
    FROM clean.orders AS o
        JOIN clean.order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_month
)
SELECT order_month,
    siparis_sayisi,
    satis_tutari,
    ROUND(satis_tutari / siparis_sayisi, 1) AS ortalama_sepet,
    ROUND(
        100.0 * (
            siparis_sayisi - LAG(siparis_sayisi) OVER (
                ORDER BY order_month
            )
        ) / LAG(siparis_sayisi) OVER (
            ORDER BY order_month
        ),
        1
    ) AS siparis_buyume_yuzde
FROM aylik
ORDER BY order_month;
-- 1b. Yıllık karşılaştırma (aynı dönem: Ocak-Ağustos)
-- Amaç: 2018'in ilk 8 ayını 2017'nin aynı dönemiyle karşılaştırmak
SELECT EXTRACT(
        YEAR
        FROM o.order_month
    ) AS yil,
    COUNT(DISTINCT o.order_id) AS siparis_sayisi,
    ROUND(SUM(oi.price)::numeric, 0) AS satis_tutari
FROM clean.orders AS o
    JOIN clean.order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND EXTRACT(
        MONTH
        FROM o.order_month
    ) <= 8
GROUP BY yil
ORDER BY yil;
-- =============================================
-- BULGULAR - Alt soru 1
-- =============================================
-- 1. 2017'de hızlı büyüme: Aylık sipariş 750'den (Ocak) 4.478'e (Ekim) çıktı (~6 kat).
-- 2. Kasım 2017: 7.289 sipariş (+%63). Black Friday etkisi, Aralık'ta %24 düşüş.
--    Kalıcı büyüme değil, tek seferlik kampanya etkisi.
-- 3. 2018'de durgunluk: Aylık sipariş 6.100-7.100 bandında yatay.
--    8 ayın 5'inde aylık büyüme negatif veya sıfıra yakın.
-- 4. Yıllık bazda (Oca-Ağu): Sipariş +%140 (21.998 -> 52.783),
--    satış +%141 (2,99M -> 7,22M R$). Yıllık rakam güçlü ama ivme durmuş.
-- 5. Ortalama sepet 20 ay boyunca 124-149 R$ arasında sabit.
--    Satış büyümesinin tamamı sipariş sayısından geliyor.
-- NOT: Ağustos 2018 rakamı, henüz teslim edilmemiş siparişler nedeniyle
--      gerçekte biraz daha yüksek olabilir.
-- SONRAKİ SORU: Büyüme neden durdu? -> Alt soru 3 (müşteri sadakati)