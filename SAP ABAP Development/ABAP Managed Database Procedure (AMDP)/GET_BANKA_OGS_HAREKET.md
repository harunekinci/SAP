# ✉️ GET_BANKA_OGS_HAREKET

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-AMDP_HDB-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP AMDP" />
  <img src="https://img.shields.io/badge/METHOD-GET__BANKA__OGS__HAREKET-2E7D32?style=for-the-badge&logo=opsgenie&logoColor=white" alt="Method" />
  <img src="https://img.shields.io/badge/STATUS-READY_FOR_PROD-C62828?style=for-the-badge" alt="Status" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `get_banka_ogs_hareket`, SAP HANA veritabanı seviyesinde (SQLScript) çalışan ve banka OGS/HGS hareketlerini işleyen bir AMDP Table Function metodudur. `znet_eho_t_c_064` ve `zeppm_t010` tablolarını kullanarak ham banka açıklamalarından string ayrıştırma (substring/locate) yöntemleriyle plaka, geçiş zamanı, geçiş noktası ve tutar bilgilerini dinamik olarak normalize eder.

---

## 🛠️ SE24 / SE11: AMDP Database Function Yapısı

Metodun bağımlılıkları ve veri tabanı opsiyonları:

### 1️⃣ Veritabanı ve Dil Konfigürasyonu
    
<table>
  <thead>
    <tr style="background-color: #1F4E79; color: white;">
      <th>Özellik</th>
      <th>Değer / Tip</th>
      <th>Açıklama</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>FOR HDB</b></td>
      <td><code>HANA Database</code></td>
      <td>Bu metot sadece SAP HANA veritabanı katmanında yürütülür.</td>
    </tr>
    <tr>
      <td><b>LANGUAGE</b></td>
      <td><code>SQLSCRIPT</code></td>
      <td>Veritabanı prosedür dili olarak SQLScript mimarisi kullanılır.</td>
    </tr>
    <tr>
      <td><b>OPTIONS</b></td>
      <td><code>READ-ONLY</code></td>
      <td>Metot veri manipülasyonu yapamaz, sadece performanslı okuma sağlar.</td>
    </tr>
  </tbody>
</table>

### 2️⃣ Kullanılan Bağımlılıklar (USING)

<table>
  <thead>
    <tr style="background-color: #2e7d32; color: white;">
      <th>Tablo Adı</th>
      <th>Rolü</th>
      <th>Açıklama</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>znet_eho_t_c_064</b></td>
      <td><code>Ana Tablo (bankahareket)</code></td>
      <td>Banka hareketlerinin ve ham işlem açıklamalarının tutulduğu log tablosu.</td>
    </tr>
    <tr>
      <td><b>zeppm_t010</b></td>
      <td><code>Eşleştirme Tablosu (gecisnokta)</code></td>
      <td>Hesap kodu (hkont) ve işlem tipine göre geçiş noktası / iade koşullarını belirleyen tanım tablosu.</td>
    </tr>
  </tbody>
</table>

---

## 🗂️ İşlevsel Dönüşüm Mantığı (Parsing Mechanics)

### `SQLSCRIPT` *Dinamik String Fonksiyonları*
* **Plaka Ayıklama:** Banka açıklamasındaki `' Plaka '` ifadesinin konumunu bularak (`locate`) string içerisinden 8 karakterli araç plakasını (`substring` & `trim`) otomatik olarak çeker.
* **Geçiş Zamanı:** Açıklama alanındaki `' Nolu Ürün ile '` ve `' de '` belirteçleri arasındaki zaman damgasını yakalar ve `YYYYMMDDHH24MISS` formatına (`to_char`) dönüştürür.
* **Tutar & İade Yönetimi:** `zeppm_t010` tablosunda ilgili işlem `iade = 'X'` olarak işaretlenmişse, tutarı `-1` ile çarparak ters kayıt (iade) tutarını hesaplar.

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> **String Parsing ve Veri Kalitesi Riskleri** > `bankahareket.aciklama` alanındaki metinsel yapıların (Örn: ' Plaka ' veya ' Nolu Ürün ile ') format değiştirmesi durumunda `locate` fonksiyonları hatalı indis dönebilir. Banka entegrasyon şablonlarının sabitliği bu metodun kararlılığı için kritiktir.

> [!TIP]
> **Performans ve Sıralama (Order By)** > Sorgu sonucunda üretilen veri kümesi, `gecis_zamani desc` ifadesiyle veritabanı katmanında kronolojik olarak sıralanarak uygulama katmanına (ABAP) iletilir. Bu sayede en güncel geçişler her zaman en üstte yer alır.

> [!WARNING]
> **Tarih ve İşlem Tipi Filtreleri (Hardcoded Constraints)** > Fonksiyon içerisinde `'20220401'` tarihinden önceki fiziksel işlemler filtrelenmiş ve `'GECURUNSATIS'` gibi spesifik işlem tipleri kapsam dışı bırakılmıştır. Yeni geliştirme veya canlıya geçiş senaryolarında bu filtrelerin dinamik parametreye taşınması gerekebilir.

```sql
METHOD get_banka_ogs_hareket BY DATABASE FUNCTION
                               FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY
                             USING znet_eho_t_c_064 zeppm_t010.

  RETURN select *
           from (SELECT bankahareket.mandt,
                        (SELECT sysuuid FROM dummy) AS tasit_hgs_id,
                        trim(SUBSTRING( bankahareket.aciklama, locate( bankahareket.aciklama, ' Plaka ' ) - 8, 8 ) ) as plaka,
                        to_char( substring( bankahareket.aciklama, locate( bankahareket.aciklama, ' Nolu Ürün ile ' ) + 15, locate( bankahareket.aciklama, ' de ' ) - locate( bankahareket.aciklama, ' Nolu Ürün ile ' ) - 15 ), 'YYYYMMDDHH24MISS' )
                        as gecis_zamani,
                        case when gecisnokta.islem_aciklama is not null then gecisnokta.islem_aciklama
                             else bankahareket.islem_tipi end  as gecis_noktasi,
                        case when gecisnokta.iade = 'X' THEN bankahareket.tutar * -1
                             else bankahareket.tutar end as tutar,
                        bankahareket.aciklama
                   from znet_eho_t_c_064        as bankahareket left outer join
                        zeppm_t010              as gecisnokta   on bankahareket.hkont = gecisnokta.hkont
                                                               and bankahareket.islem_tipi = gecisnokta.islem_tipi
                  where bankahareket.hkont in ( select hkont from zeppm_t010 )
                    and locate( bankahareket.aciklama, ' Plaka ' ) <> 0
                    and bankahareket.fiziksel_islem_tarihi < '20220401'
                    and bankahareket.islem_tipi not in ('GECURUNSATIS','GECURUNSATISIPTAL')
                 )
            order by gecis_zamani desc;
ENDMETHOD.
