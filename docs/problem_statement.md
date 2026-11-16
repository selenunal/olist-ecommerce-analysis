# Problem Tanımı: Olist Büyüme, Sadakat ve Memnuniyet Analizi

## 1. Arka Plan
Olist, Brezilya'daki küçük satıcıların ürünlerini büyük online pazar yerlerinde satmasını sağlayan bir e-ticaret platformudur. Elimizde Eylül 2016 – Ekim 2018 dönemine ait 99.441 sipariş ve 96.096 tekil müşteri verisi bulunmaktadır.

Ticari direktör, sipariş sayısının arttığını ancak bu büyümenin sağlıklı ve sürdürülebilir olup olmadığından emin olmadığını belirtmiş; müşterilerin geri gelip gelmediğini ve memnun olup olmadığını anlamak istemektedir.

## 2. Ana İş Sorusu
Olist'in büyümesi sürdürülebilir mi ve müşteri sadakatini ve memnuniyetini artırmak için hangi alanlara öncelik verilmeli?

## 3. Alt Sorular
1. Sipariş sayısı ve satış tutarı aylara göre nasıl değişiyor? *(Büyüme)*
2. Büyümeye en çok hangi ürün kategorileri ve bölgeler katkı sağlıyor? *(Büyüme)*
3. Müşteriler ikinci kez alışveriş yapıyor mu? *(Sadakat)*
4. Müşteriler ne kadar memnun? *(Memnuniyet)*
5. Siparişler zamanında teslim ediliyor mu ve teslimat gecikmesi müşteri memnuniyetini etkiliyor mu? *(Operasyon)*

## 4. KPI'lar

| # | KPI | Hesaplama |
|---|-----|-----------|
| 1 | Aylık sipariş sayısı | Her ay verilen teslim edilmiş sipariş sayısı |
| 1 | Aylık satış tutarı | Her ayın siparişlerindeki ürün fiyatlarının toplamı (`price`, kargo hariç) |
| 1 | Aylık büyüme oranı | (Bu ayın değeri − geçen ayın değeri) / geçen ayın değeri |
| 1 | Ortalama sepet tutarı | Satış tutarı / sipariş sayısı |
| 2 | Kategori payı | Kategorinin satış tutarı / toplam satış tutarı |
| 2 | Eyalet payı | Eyaletin sipariş sayısı / toplam sipariş sayısı |
| 3 | Tekrar alım oranı | 2 veya daha fazla siparişi olan müşteri / toplam müşteri |
| 3 | Tekrar eden müşteri sipariş payı | Tekrar eden müşterilerin siparişleri / toplam sipariş |
| 4 | Ortalama müşteri puanı | `review_score` ortalaması (1–5) |
| 4 | Memnuniyet oranı | 4 veya 5 puan veren sipariş / puanlanan sipariş |
| 4 | Olumsuz puan oranı | 1 veya 2 puan veren sipariş / puanlanan sipariş |
| 5 | Zamanında teslim oranı | Gerçek teslim tarihi ≤ tahmini teslim tarihi olan sipariş / teslim edilen sipariş |
| 5 | Ortalama teslimat süresi | Sipariş tarihi ile müşteriye teslim tarihi arasındaki gün sayısının ortalaması |
| 5 | Gecikmeye göre puan farkı | Gecikmeli siparişlerin ortalama puanı − zamanında teslim edilenlerin ortalama puanı |

## 5. Paydaşlar

| Paydaş | Beklentisi |
|--------|------------|
| Ticari direktör | Büyümenin sağlıklı olup olmadığını ve öncelikli aksiyonları görmek |
| Pazarlama / CRM ekibi | Müşterileri geri getirmek için hangi segmentleri hedefleyeceğini bilmek |
| Lojistik / operasyon ekibi | Gecikmelerin nerede yaşandığını ve memnuniyete etkisini görmek |
| Kategori yönetimi | Hangi kategorilerin büyüdüğünü ve hangilerine yatırım yapılacağını bilmek |

## 6. Kapsam ve Varsayımlar
- **Müşteri tanımı:** Müşteriler `customer_unique_id` ile sayılacaktır. `customer_id` her siparişte yeniden oluşturulduğu için müşteri sayımında kullanılmayacaktır.
- **Sipariş durumu:** Satış, memnuniyet ve teslimat analizlerinde yalnızca `delivered` (teslim edilmiş) siparişler kullanılacaktır. Siparişlerin yaklaşık %97'si bu durumdadır.
- **Dönem:** Verinin başındaki ve sonundaki seyrek aylar Aşama 2'de incelenecek, gerekirse analiz dışında bırakılacaktır.
- **Satış tutarı:** Ürün fiyatı (`price`) olarak hesaplanacak, kargo ücreti (`freight_value`) ayrı değerlendirilecektir.
- **Kapsam dışı:**
  - Kârlılık analizi (maliyet verisi bulunmamaktadır)
  - Pazarlama kampanyalarının etkisi (kampanya verisi bulunmamaktadır)
  - Müşteri yorumlarının metin analizi (yorumlar Portekizce; yalnızca puanlar kullanılacaktır)

## 7. Beklenen Çıktılar
- Alt soruları yanıtlayan SQL ve Python analizleri
- Ticari direktör için Power BI dashboard'u
- Bulgulara dayalı önceliklendirilmiş aksiyon önerileri