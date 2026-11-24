-- =============================================
-- 05_sadakat_analizi.sql
-- Aşama 3 - Alt soru 3: Müşteriler ikinci kez alışveriş yapıyor mu?
-- KPI'lar: Tekrar alım oranı, tekrar eden müşterilerin sipariş payı
-- Not: Müşteri = customer_unique_id (Aşama 2 kararı)
-- =============================================
-- 3a. Müşterilerin sipariş sayısına göre dağılımı
WITH musteri AS (
    SELECT customer_unique_id,
        COUNT(*) AS siparis_sayisi
    FROM clean.orders
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
)
SELECT siparis_sayisi,
    COUNT(*) AS musteri_sayisi,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS musteri_payi_yuzde
FROM musteri
GROUP BY siparis_sayisi
ORDER BY siparis_sayisi;

-- 3b. İkinci siparişe kadar geçen süre
-- Amaç: Geri gelen müşteriler ilk alışverişten kaç gün sonra dönüyor?
WITH sirali AS (
    SELECT
        customer_unique_id,
        purchase_ts,
        ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY purchase_ts) AS sira
    FROM clean.orders
    WHERE order_status = 'delivered'
),
ilk_iki AS (
    SELECT
        customer_unique_id,
        MAX(CASE WHEN sira = 1 THEN purchase_ts END) AS ilk_siparis,
        MAX(CASE WHEN sira = 2 THEN purchase_ts END) AS ikinci_siparis
    FROM sirali
    WHERE sira <= 2
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*) AS ikinci_siparis_veren,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ikinci_siparis::date - ilk_siparis::date) AS medyan_gun,
    SUM(CASE WHEN ikinci_siparis::date - ilk_siparis::date = 0 THEN 1 ELSE 0 END)              AS ayni_gun,
    SUM(CASE WHEN ikinci_siparis::date - ilk_siparis::date BETWEEN 1 AND 30 THEN 1 ELSE 0 END)  AS gun_1_30,
    SUM(CASE WHEN ikinci_siparis::date - ilk_siparis::date BETWEEN 31 AND 90 THEN 1 ELSE 0 END) AS gun_31_90,
    SUM(CASE WHEN ikinci_siparis::date - ilk_siparis::date > 90 THEN 1 ELSE 0 END)              AS gun_90_ustu
FROM ilk_iki
WHERE ikinci_siparis IS NOT NULL;

-- =============================================
-- BULGULAR - Alt soru 3
-- =============================================
-- 1. Müşterilerin %97,0'si yalnızca bir kez alışveriş yaptı
--    (93.104 müşteriden 90.315'i). Tekrar alım oranı: %3,0.
-- 2. Tekrar eden müşterilerin siparişleri toplam siparişin yalnızca ~%6'sı.
--    Büyüme neredeyse tamamen yeni müşteri kazanımına dayanıyor.
-- 3. "Geri gelen" 2.789 müşterinin 827'si (%30) ikinci siparişi AYNI GÜN verdi.
--    Bunlar gerçek geri dönüş değil, aynı alışverişte bölünmüş siparişler.
--    Gerçek tekrar alım oranı: %2,1 (1.962 müşteri).
-- 4. Gerçek geri dönenlerin %30'u ilk 30 günde, %25'i 31-90 günde,
--    %45'i 90 günden sonra döndü. Belirgin bir "fırsat penceresi" yok.
-- 5. Medyan (29 gün) aynı gün siparişleri içerdiği için yanıltıcı;
--    gerçek geri dönenlerin medyanı 31-90 gün aralığında.
-- NOT: Veri Ağustos 2018'de bittiği için son aylarda alışveriş yapanların
--      geri dönme şansı olmadı; gerçek oran biraz daha yüksek olabilir.
-- SONUÇ: 2018'deki büyüme durgunluğunun en olası açıklaması bu.
--        Yeni müşteri kazanımı yavaşlayınca, geri gelen müşteri olmadığı için büyüme durdu.