-- =============================================
-- 07_teslimat_analizi.sql
-- Aşama 3 - Alt soru 5: Siparişler zamanında teslim ediliyor mu
--                       ve gecikme memnuniyeti etkiliyor mu?
-- KPI'lar: Zamanında teslim oranı, gecikmeye göre puan farkı
-- Gecikme tanımı: Teslim tarihi > müşteriye söylenen tahmini teslim tarihi (is_late)
-- =============================================
-- 5a. Zamanında ve geciken siparişlerin memnuniyet karşılaştırması
SELECT CASE
        WHEN o.is_late = 1 THEN 'gecikti'
        ELSE 'zamaninda'
    END AS teslimat_durumu,
    COUNT(*) AS siparis_sayisi,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pay_yuzde,
    ROUND(AVG(r.review_score), 2) AS ortalama_puan,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN r.review_score <= 2 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS olumsuz_yuzde
FROM clean.orders AS o
    JOIN clean.reviews AS r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
    AND o.is_late IS NOT NULL
GROUP BY teslimat_durumu;

-- 5b. Aylık gecikme oranı ve teslimat süresi
-- Amaç: Şubat-Mart 2018'deki memnuniyet düşüşü gecikmelerle mi ilgili?
SELECT
    o.order_month,
    COUNT(*) AS teslim_edilen,
    ROUND(100.0 * SUM(o.is_late) / COUNT(*), 1) AS gecikme_yuzde,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY o.delivery_days) AS medyan_teslim_gun
FROM clean.orders AS o
WHERE o.order_status = 'delivered'
  AND o.is_late IS NOT NULL
GROUP BY o.order_month
ORDER BY o.order_month;
-- BULGULAR - Alt soru 5 (5a, 5b)
-- 1. Geciken siparişler (%6,7) ortalama 2,27 puan alırken zamanında gelenler 4,29 aldı.
--    Olumsuz puan oranı: gecikenlerde %62,4, zamanında gelenlerde %9,2 (~7 kat).
-- 2. Geciken siparişler tüm siparişlerin %6,7'si ama olumsuz puanların ~1/3'ü.
-- 3. Aylık gecikme oranı ile olumsuz puan oranı aynı aylarda zirve yapıyor:
--    Kasım 2017 (%12,4 gecikme / %16,6 olumsuz), Mart 2018 (%19,0 / %21,2).
-- 4. Şubat-Mart 2018 krizi teslimat kaynaklı (hacim artışı yok). -> Alt soru 4 açık sorusu cevaplandı.
-- 5. Mart 2018'de medyan teslimat yalnızca 2-3 gün uzadı ama gecikme 4 katına çıktı:
--    sorun mutlak süreden çok, müşteriye verilen tahmini tarihin tutulamaması.
-- 6. 2018 yazında lojistik iyileşti: medyan teslimat 7-8 gün, Haziran'da gecikme %1,2.
-- NOT: İlişki çok güçlü ancak korelasyon nedensellik değildir; "güçlü ilişki" olarak raporlanmalı.