-- =============================================
-- 06_memnuniyet_analizi.sql
-- Aşama 3 - Alt soru 4: Müşteriler ne kadar memnun?
-- KPI'lar: Ortalama puan, memnuniyet oranı (4-5), olumsuz puan oranı (1-2)
-- Not: Sipariş başına tek yorum (clean.reviews), yalnızca teslim edilen siparişler
-- =============================================
-- 4a. Puan dağılımı
SELECT r.review_score,
    COUNT(*) AS siparis_sayisi,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pay_yuzde
FROM clean.reviews AS r
    JOIN clean.orders AS o ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score;
-- 4b. Aylık memnuniyet trendi
SELECT o.order_month,
    COUNT(*) AS puanlanan_siparis,
    ROUND(AVG(r.review_score), 2) AS ortalama_puan,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN r.review_score >= 4 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS memnuniyet_yuzde,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN r.review_score <= 2 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS olumsuz_yuzde
FROM clean.reviews AS r
    JOIN clean.orders AS o ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_month
ORDER BY o.order_month;
-- =============================================
-- BULGULAR - Alt soru 4
-- =============================================
-- 1. Ortalama puan 4,16; memnuniyet oranı (4-5) %78,9; olumsuz oran (1-2) %12,8.
-- 2. Kutuplaşmış dağılım (J şekli): 1 puan (%9,7), 2 (%3,1) ve 3 (%8,3) puandan daha yaygın.
--    Sorun yaşayan müşteri doğrudan 1 veriyor. Her 10 siparişten biri 1 puan.
-- 3. Normal dönem (Oca-Eki 2017): olumsuz oran %9-13.
-- 4. Kriz 1 (Kas 2017 - Oca 2018): Black Friday yük artışıyla olumsuz oran %16,6'ya çıktı.
-- 5. Kriz 2 (Şub-Mar 2018): Olumsuz oran %19,4 ve %21,2 (her 5 siparişten biri).
--    Sipariş hacminde artış yok, başka bir sebep olmalı.
--    AÇIK SORU: Teslimat gecikmeleriyle ilişkili mi? -> Alt soru 5
-- 6. Toparlanma (Nis-Ağu 2018): Memnuniyet %83,5 ile dönemin en iyi seviyesi.
--    Ancak büyüme geri gelmedi.
-- SONUÇ: Müşterilerin %79'u memnun ama %98'i geri gelmiyor.
--        Sadakat sorunu yalnızca kötü deneyimden kaynaklanmıyor;
--        müşteriyi geri getirecek bir mekanizma eksik görünüyor.