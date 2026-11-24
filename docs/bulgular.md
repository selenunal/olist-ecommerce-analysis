# Bulgular: Olist Büyüme, Sadakat ve Memnuniyet Analizi

**Analiz dönemi:** Ocak 2017 – Ağustos 2018 (20 ay)
**Kapsam:** 99.092 sipariş, 93.104 tekil müşteri
**Detaylı sorgular:** `sql/03` – `sql/07` dosyaları

---

## Yönetici Özeti

1. **Büyüme durmuş.** Yıllık bazda satışlar %141 artmış görünse de bu büyümenin tamamı 2017'de gerçekleşti. 2018 başından beri aylık sipariş sayısı 6.100–7.100 bandında yatay seyrediyor.
2. **Müşteriler geri gelmiyor.** Gerçek tekrar alım oranı yalnızca %2,1. Siparişlerin %94'ü ilk kez alışveriş yapan müşterilerden geliyor. Olist her ay sıfırdan müşteri bulmak zorunda.
3. **Teslimat gecikmesi memnuniyeti yıkıyor.** Geciken siparişlerde olumsuz puan oranı %62,4, zamanında gelenlerde %9,2 (~7 kat). Geciken siparişler toplamın %6,7'si ama tüm olumsuz puanların yaklaşık üçte biri.
4. **İki teslimat krizi yaşandı.** Kasım 2017 (Black Friday) ve Şubat–Mart 2018. Mart 2018'de siparişlerin %19'u gecikti, her 5 müşteriden biri olumsuz puan verdi.
5. **Memnun müşteriler bile geri gelmiyor.** Müşterilerin %79'u memnun ama %98'i ikinci alışverişi yapmıyor. Sadakat sorunu yalnızca kötü deneyimden değil, müşteriyi geri getirecek bir mekanizmanın eksikliğinden kaynaklanıyor.

### Ana iş sorusunun cevabı

> **Büyüme sürdürülebilir mi?** Hayır. Büyüme neredeyse tamamen yeni müşteri kazanımına dayanıyor ve 2018'de durdu.
>
> **Nereye odaklanılmalı?** (1) Teslimat güvenilirliği, özellikle RJ eyaleti ve yoğun dönemler. (2) Müşteriyi ikinci alışverişe getirecek bir sadakat mekanizması.

---

## 1. Büyüme: Sipariş ve satış aylara göre nasıl değişiyor?

| Dönem | Bulgu |
|---|---|
| Ocak – Ekim 2017 | Aylık sipariş 750'den 4.478'e (~6 kat) |
| Kasım 2017 | 7.289 sipariş (+%63), Black Friday etkisi. Kalıcı değil. |
| 2018 | Aylık 6.100 – 7.100 arasında yatay. 8 ayın 5'inde büyüme negatif veya sıfıra yakın. |

- **Yıllık karşılaştırma (Ocak–Ağustos):** Sipariş +%140 (21.998 → 52.783), satış +%141 (2,99M → 7,22M R$).
- **Ortalama sepet** 20 ay boyunca 124–149 R$ arasında sabit. Satış büyümesinin tamamı sipariş sayısından geliyor.

**Neden önemli:** Yıllık rakamlar güçlü göründüğü için durgunluk gözden kaçabilir. Yıllık büyüme geçmişteki başarıyı, aylık büyüme bugünkü durumu gösteriyor.

---

## 2. Büyümenin kaynağı: Kategoriler ve bölgeler

### Kategoriler: Çeşitlendirilmiş (düşük risk)
- En büyük kategori (health_beauty) toplam satışın yalnızca %9,3'ü. İlk 10 kategori %62,5.
- **Büyüme motorları:** health_beauty (+%210) ve watches_gifts (+%242), büyümenin %23,6'sını tek başına sağladı.
- **Pay kaybedenler:** bed_bath_table (en çok sipariş alan kategori) yalnızca +%109 büyüdü.
- **Dikkat:** construction_tools %4.660 büyüdü ama toplam büyümeye katkısı %2,8 (düşük taban etkisi).

### Bölgeler: Yoğunlaşmış (yüksek risk)
- SP tek başına satışların %38,4'ü. SP + RJ + MG = %63,4.
- SP ortalamadan hızlı büyüyor (+%171), yoğunlaşma artıyor.
- RJ ikinci büyük pazar ama ilk 10 içinde en yavaş büyüyen eyalet (+%105).

---

## 3. Sadakat: Müşteriler geri geliyor mu?

| Metrik | Değer |
|---|---|
| Tek sipariş veren müşteri | %97,0 |
| Tekrar alım oranı (ilk hesap) | %3,0 |
| Aynı gün ikinci sipariş (gerçek geri dönüş değil) | 827 müşteri |
| **Gerçek tekrar alım oranı** | **%2,1** |
| Tekrar eden müşterilerin sipariş payı | ~%6 |

- Gerçek geri dönenlerin %30'u ilk 30 günde, %25'i 31–90 günde, **%45'i 90 günden sonra** döndü. Belirgin bir "fırsat penceresi" yok.

**Neden önemli:** Büyüme yeni müşteri kazanımına bağımlı. Yeni müşteri kazanımı yavaşladığında, geri gelen müşteri olmadığı için büyüme duruyor. 2018 durgunluğunun en olası açıklaması bu.

---

## 4. Memnuniyet: Müşteriler ne kadar memnun?

| Metrik | Değer |
|---|---|
| Ortalama puan | 4,16 / 5 |
| Memnuniyet oranı (4–5 puan) | %78,9 |
| Olumsuz puan oranı (1–2 puan) | %12,8 |

- **Kutuplaşmış dağılım:** 1 puan (%9,7), 2 ve 3 puandan daha yaygın. Sorun yaşayan müşteri doğrudan 1 veriyor.
- **İki kriz:** Olumsuz oran normalde %9–13 iken Kasım 2017'de %16,6'ya, Mart 2018'de %21,2'ye çıktı.
- **Toparlanma:** 2018 yazında memnuniyet %83,5 ile dönemin en iyi seviyesine ulaştı, ancak büyüme geri gelmedi.

---

## 5. Teslimat: Gecikme memnuniyeti etkiliyor mu?

| | Zamanında | Gecikti |
|---|---|---|
| Sipariş payı | %93,3 | %6,7 |
| Ortalama puan | 4,29 | 2,27 |
| Olumsuz puan oranı | %9,2 | %62,4 |

- **Aylık gecikme oranı ile olumsuz puan oranı aynı aylarda zirve yapıyor:** Kasım 2017 (%12,4 gecikme), Mart 2018 (%19,0 gecikme).
- **Şubat–Mart 2018 krizi** hacim artışından değil teslimat sorunundan kaynaklandı. Medyan teslimat süresi yalnızca 2–3 gün uzadı ama gecikme 4 katına çıktı: Sorun, müşteriye verilen tahmini tarihin tutulamaması.
- **2018 yazında lojistik iyileşti:** Medyan teslimat 7–8 gün, Haziran'da gecikme %1,2.

### Bölgesel teslimat performansı

| | SP | RJ |
|---|---|---|
| Gecikme oranı | %4,5 | %12,1 |
| Medyan teslimat | 7 gün | 12 gün |
| Olumsuz puan oranı | %10,7 | %18,3 |
| Büyüme (Oca–Ağu, yıllık) | +%171 | +%105 |

- RJ, büyük eyaletler içinde en kötü teslimat deneyimine ve en yavaş büyümeye sahip. SP'ye komşu olmasına rağmen performans çok farklı; sorun yalnızca mesafe değil.
- **İstisna:** ES yüksek gecikmeye (%10,7) rağmen hızlı büyümüş (+%162). Teslimat tek belirleyici değil.

---

## Bulguların Bağlantısı

```
Teslimat krizleri (Kasım 2017, Şubat–Mart 2018)
        ↓
Geciken siparişlerde olumsuz puan ~7 kat artıyor
        ↓
Müşterilerin %98'i geri gelmiyor (memnun olanlar dahil)
        ↓
Büyüme tamamen yeni müşteri kazanımına bağımlı
        ↓
2018'de büyüme duruyor
```

---

## Sınırlamalar

- **Veri Ağustos 2018'de bitiyor.** Son aylarda ilk alışverişini yapan müşterilerin geri dönme fırsatı olmadı; gerçek tekrar alım oranı biraz daha yüksek olabilir.
- **Korelasyon nedensellik değildir.** Gecikme ile düşük puan arasındaki ilişki çok güçlü, ancak başka faktörler (ürün kalitesi, satıcı performansı) de etkili olabilir.
- **Eksik veriler:** Maliyet ve kâr, pazarlama harcaması ve kampanya verileri bulunmuyor. Kârlılık ve müşteri kazanım maliyeti analiz edilemedi.
- **Yorum metinleri** (Portekizce) analiz edilmedi; yalnızca puanlar kullanıldı.
- 2016 ve Eylül–Ekim 2018 verileri seyrek olduğu için analiz dışında bırakıldı (349 sipariş, %0,35).