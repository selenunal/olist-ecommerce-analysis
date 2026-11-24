-- =============================================
-- 04_kategori_bolge_analizi.sql
-- Aşama 3 - Alt soru 2: Büyümeye en çok hangi kategoriler ve bölgeler katkı sağlıyor?
-- KPI'lar: Kategori payı, eyalet payı
-- =============================================

-- 2a. En çok satan 10 kategori
SELECT
    oi.category,
    COUNT(DISTINCT oi.order_id)      AS siparis_sayisi,
    ROUND(SUM(oi.price)::numeric, 0) AS satis_tutari,
    ROUND((100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER ())::numeric, 1) AS satis_payi_yuzde
FROM clean.order_items AS oi
JOIN clean.orders AS o
  ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.category
ORDER BY satis_tutari DESC
LIMIT 10;


-- 2b. Büyümeye en çok katkı sağlayan 10 kategori (Oca-Ağu 2017 vs 2018)
WITH yillik AS (
    SELECT
        oi.category,
        SUM(CASE WHEN EXTRACT(YEAR FROM o.order_month) = 2017 THEN oi.price ELSE 0 END) AS satis_2017,
        SUM(CASE WHEN EXTRACT(YEAR FROM o.order_month) = 2018 THEN oi.price ELSE 0 END) AS satis_2018
    FROM clean.order_items AS oi
    JOIN clean.orders AS o
      ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND EXTRACT(MONTH FROM o.order_month) <= 8
    GROUP BY oi.category
)
SELECT
    category,
    ROUND(satis_2017::numeric, 0)                AS satis_2017,
    ROUND(satis_2018::numeric, 0)                AS satis_2018,
    ROUND((satis_2018 - satis_2017)::numeric, 0) AS artis,
    ROUND((100.0 * (satis_2018 - satis_2017) / NULLIF(satis_2017, 0))::numeric, 1) AS buyume_yuzde,
    ROUND((100.0 * (satis_2018 - satis_2017) / SUM(satis_2018 - satis_2017) OVER ())::numeric, 1) AS buyumeye_katki_yuzde
FROM yillik
ORDER BY artis DESC
LIMIT 10;
-- BULGULAR - Kategoriler
-- 1. Satışlar çeşitlendirilmiş: En büyük kategori (health_beauty) payı %9,3.
--    İlk 10 kategori toplam satışın %62,5'i, kalan 64 kategori %37,5'i.
-- 2. Sipariş ve satış sıralaması farklı:
--    bed_bath_table en çok sipariş alan (9.267) ama sepeti düşük (~110 R$).
--    watches_gifts daha az sipariş (5.491) ama sepeti yüksek (~212 R$).
-- 3. Büyüme motorları (Oca-Ağu 2017 -> 2018, toplam büyüme %141):
--    health_beauty (+%210) ve watches_gifts (+%242) büyümenin %23,6'sını sağladı.
-- 4. Pay kaybedenler: bed_bath_table (+%109), furniture_decor (+%123),
--    computers_accessories (+%131), sports_leisure (+%138) ortalamanın altında büyüdü.
-- 5. construction_tools %4.660 büyüdü ama katkısı yalnızca %2,8 (düşük taban etkisi).
--    Büyüme yüzdesi tek başına yanıltıcı; büyümeye katkı ile birlikte değerlendirilmeli.

-- 2c. Eyaletlere göre satış payı ve büyüme
WITH eyalet AS (
    SELECT
        o.customer_state,
        COUNT(DISTINCT o.order_id) AS siparis_sayisi,
        SUM(oi.price)              AS satis,
        SUM(CASE WHEN EXTRACT(YEAR FROM o.order_month) = 2017
                  AND EXTRACT(MONTH FROM o.order_month) <= 8 THEN oi.price ELSE 0 END) AS satis_2017,
        SUM(CASE WHEN EXTRACT(YEAR FROM o.order_month) = 2018 THEN oi.price ELSE 0 END) AS satis_2018
    FROM clean.orders AS o
    JOIN clean.order_items AS oi
      ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_state
)
SELECT
    customer_state,
    siparis_sayisi,
    ROUND(satis::numeric, 0) AS satis_tutari,
    ROUND((100.0 * satis / SUM(satis) OVER ())::numeric, 1) AS satis_payi_yuzde,
    ROUND((100.0 * SUM(satis) OVER (ORDER BY satis DESC) / SUM(satis) OVER ())::numeric, 1) AS kumulatif_pay_yuzde,
    ROUND((100.0 * (satis_2018 - satis_2017) / NULLIF(satis_2017, 0))::numeric, 1) AS buyume_yuzde
FROM eyalet
ORDER BY satis DESC
LIMIT 10;

-- BULGULAR - Eyaletler
-- 1. Satışlar coğrafi olarak yoğunlaşmış: SP tek başına %38,4.
--    SP + RJ = %51,6, ilk 3 eyalet (SP, RJ, MG) = %63,4, ilk 10 = %87,9.
--    Kalan 17 eyalet yalnızca %12,1.
-- 2. İlk 10 eyaletin çoğu güney/güneydoğu bölgesinde. Kuzeydoğudan yalnızca BA.
-- 3. SP ortalamadan hızlı büyüyor (+%171 vs toplam +%141): yoğunlaşma artıyor.
-- 4. RJ ikinci büyük pazar ama ilk 10 içinde en yavaş büyüyen (+%105).
--    AÇIK SORU: Teslimat sorunlarıyla ilişkili mi? -> Alt soru 5'te kontrol edilecek.
-- RİSK: Kategori dağılımı çeşitli (düşük risk), coğrafi dağılım yoğun (yüksek risk).