# 🔍 ZCL_ABAP_NEW_SYNTAX_GUIDE

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/SYNTAX-MODERN_ABAP-2E7D32?style=for-the-badge&logo=quicklook&logoColor=white" alt="Syntax" />
  <img src="https://img.shields.io/badge/STATUS-PRODUCTION_READY-C62828?style=for-the-badge" alt="Status" />
</div>

<br/>

> **Sistem Mimarı Özeti:** Bu doküman, SAP ABAP 7.40+ versiyonlarıyla birlikte gelen modern sözdizimi (New Syntax) yapılarını, temiz kod (*Clean ABAP*) prensiplerini ve performans optimizasyon standardslarını modeller. Klasik geliştirmedeki hantal geçici değişken tanımlamaları ve iç içe uzun döngüler, uygulama katmanında bellek optimizasyonuna ve okunabilirliği yüksek deklaratif yapılara dönüştürülür.

---

## 📊 Modernizasyonun Kantitatif Etkisi

Yeni sözdiziminin sağladığı optimizasyon ve performans kazanımlarının genel analizi:

* **Ortalama Satır Tasarrufu (LOC):** %65 oranında daha az geçici değişken kullanımı ve satır içi atama esnekliği.
* **Döngü Performans Artışı:** `REDUCE`, `FOR` ve `FILTER` optimizasyonları ile **2x - 3x** daha hızlı işleme kapasitesi.
* **Bellek (Memory) Ayak İzi:** `LET` ve *Inline* deklarasyonlar ile değişkenlerin anlık olarak scoped (kapsam içi) üretilmesi ve işlem bitiminde otomatik serbest bırakılması.

---

## 🛠️ Modern ABAP Operatörleri ve Sözdizimi Yapıları

### 1️⃣ VALUE # Operatörü
Internal tablolara veri eklemek, range yapılarını doldurmak veya yapıları (structure) inline olarak üretmek için kullanılan en temel operatördür.

> [!NOTE]
> **VALUE # — Range ve Yapısal Atama Senaryoları**  
> ```abap
> lr_kunnr[] = VALUE #( sign = 'I' option = 'EQ' ( low = iv_kunnr ) ).
> 
> DATA lr_abgru TYPE RANGE OF tvaut-augru.
> lr_abgru[] = VALUE #( sign = 'I' option = 'EQ'
>                        ( low = '103' ) " İade
>                        ( low = '104' ) " İade
>                        ( low = '105' ) " İade / Miktar farkı / Bozuk mal / Hatalı Sevkiyat
>                      ).
> 
> APPEND VALUE #( BASE CORRESPONDING #( <fs_itab> )
>                 vbeln = |{ <fs_itab>-vbeln ALPHA = OUT }|
>                 knkli = |{ <fs_itab>-knkli ALPHA = OUT }|
>                 zterm = <fs_itab>-zterm
>                 textl = VALUE #( lt_t052u[ zterm = <fs_itab>-zterm ]-textl OPTIONAL )
>               ) TO et_header.
> ```

---

### 2️⃣ CORRESPONDING #
Aynı veya farklı alan isimlerine sahip yapıları ya da internal tabloları, gereksiz eşlemeler yapmadan tek bir satırda birbirine taşır.

> [!TIP]
> **CORRESPONDING # — Dinamik Eşleme ve Maskeleme Standartları**  
> ```abap
> ls_balance-documents[] = CORRESPONDING #( lt_data[] MAPPING referance = xblnr ).
> 
> lt_target = CORRESPONDING #( lt_source
>                               MAPPING matnr = material
>                                       kunnr = customer
>                               EXCEPT  erdat ernam
>                               DISCARDING DUPLICATES 
>                             ).
> ```

---

### 3️⃣ BASE Kullanımı
İçine veri aktarılacak hedef internal tablonun veya yapının mevcut içeriğini silmeden koruyarak yeni kayıtlar eklenmesini sağlar.

> [!NOTE]
> **BASE — Mevcut Veri Kümesini Koruma Mantığı**  
> ```abap
> lt_data[] = VALUE #( BASE lt_data
>                       ( kunnr = lv_kunnr mtart = 'HAWA' ) 
>                     ).
> 
> lr_matnr[] = VALUE #( BASE lr_matnr 
>                        ( sign = 'I' option = 'EQ' low = gs_data-matnr ) 
>                      ).
> 
> ls_target = CORRESPONDING #( BASE ( ls_target ) ls_source ).
> ```

---

### 4️⃣ COND & SWITCH Koşul İfadeleri
Klasik `IF-ELSE` ve `CASE` kontrol yapılarını satır içi (inline) fonksiyonel ifadelere indirger.

> [!TIP]
> **COND & SWITCH — Mantıksal Atama Blokları**  
> ```abap
> DATA(lv_status) = COND char10( WHEN lv_a = abap_true THEN 'AKTİF'
>                                 WHEN lv_b = abap_true THEN 'BEKLEMEDE'
>                                 ELSE 'PASİF' ).
> 
> DATA(lv_color) = SWITCH string( lv_type
>                                  WHEN 'A' THEN 'RED'
>                                  WHEN 'B' THEN 'BLUE'
>                                  ELSE 'BLACK' ).
> ```

---

### 5️⃣ LET ile Lokal Değişken Tanımlama
Sadece ilgili ifadenin sınırları içinde geçerli olacak ve işlem bittiğinde bellekten temizlenecek geçici lokal değişkenler üretir.

> [!NOTE]
> **LET — Kısa Ömürlü Bellek ve Hesaplama Yönetimi**  
> ```abap
> DATA(lv_total) = VALUE #( LET lv_tax = 18
>                             IN  100 + lv_tax ).
> 
> DATA(result) = VALUE ty_result( LET lv_name = TO_UPPER( iv_name )
>                                   IN  name = lv_name ).
> ```

---

### 6️⃣ FOR & FOR GROUPS
Klasik `LOOP AT` mantığını inline kurgulayarak tablolar arası hızlı veri dönüşümü ve gruplama sağlar.

> [!TIP]
> **FOR & FOR GROUPS — Döngü Optimizasyonu ve Tablo Dönüşümleri**  
> ```abap
> lr_season = VALUE #( FOR <ls_malzeme> IN lt_malzeme sign = 'I' option = 'EQ'
>                       ( low = <ls_malzeme>-sezon ) ).
> 
> DATA(lt_data_idx) = VALUE tt_data( FOR ls IN lt_source INDEX INTO lv_index
>                                     ( id = lv_index matnr = ls-matnr ) ).
> 
> lr_matnr = VALUE #( FOR GROUPS OF <wa> IN lt_siparis GROUP BY <wa>-matnr
>                      ( <wa>-matnr ) ).
> ```

---

### 7️⃣ REDUCE
Bir tablonun satırlarını tarayarak tek bir çıktı (toplam, adet veya metin birleştirme) üretir.

> [!IMPORTANT]
> **REDUCE — Agregasyon ve Kümülatif Hesaplama Standartları**  
> ```abap
> <fs_out>-ntgew = REDUCE ntgew_15( INIT val TYPE ntgew
>                                   FOR wa IN lt_lips WHERE ( vbeln = <fs_out>-vbeln )
>                                   NEXT val = val + wa-ntgew ).
> 
> DATA(lv_count) = REDUCE i( INIT x = 0 FOR ls IN lt_mara NEXT x = x + 1 ).
> 
> DATA(lv_max) = REDUCE i( INIT x = 0 
>                          FOR ls IN lt_data 
>                          NEXT x = NMAX( val1 = x val2 = ls-netwr ) ).
> ```

---

### 8️⃣ FILTER
Bir internal tabloyu, döngü kurmaya gerek kalmadan doğrudan indeks üzerinden yüksek performanslı filtreler.

> [!NOTE]
> **FILTER — Tablo Seviyesinde Yüksek Performanslı Süzme**  
> ```abap
> SELECT field1, field2 
>   FROM @itab AS a 
>   WHERE field1 <> 'SOME_VALUE' 
>   INTO TABLE @DATA(itab_filtered).
> 
> lt_values_filtered = FILTER #( lt_values IN lt_values_filter
>                                 WHERE field1 = field1
>                                   AND field2 = field2 ).
> ```

---

### 9️⃣ Table Expressions & Line Kontrolleri
Eski tip `READ TABLE` komutunu ve hantal `sy-subrc` kontrollerini tamamen ortadan kaldıran modern yapılardır.

> [!TIP]
> **Table Expressions — Doğrudan Hücre Okuma ve Varlık Doğrulama**  
> ```abap
> IF LINE_EXISTS( lt_vbak[ vbeln = lv_vbeln ] ). ENDIF.
> 
> DATA(lv_index) = LINE_INDEX( lt_vbak[ vbeln = lv_vbeln ] ).
> 
> DATA(lv_text_opt) = VALUE string( lt_t052u[ zterm = lv_zterm ]-textl OPTIONAL ).
> ```

---

### 🔟 CONV, EXACT & XSDBOOL
Veri tipi dönüşümlerini ve mantıksal boolean yönetimini tek bir satırda çözen fonksiyonel yapılardır.

> [!IMPORTANT]
> **Dönüşüm ve Tip Güvenliği Kontrolleri**  
> ```abap
> DATA(lv_char) = CONV char10( lv_num ).
> DATA(lv_matnr) = CONV matnr( |{ iv_matnr ALPHA = IN }| ).
> 
> DATA(lv_int) = EXACT i( lv_string ).
> 
> DATA(lv_found) = XSDBOOL( sy-subrc = 0 ).
> ```

---

### 1️⃣1️⃣ NEW, REF ve CAST Nesne Operatörleri
Nesne tabanlı (Object-Oriented) ABAP mimarisinde referans alma ve dinamik nesne üretimi işlemlerini kısaltır.

> [!NOTE]
> **Nesne Tabanlı Bellek ve Referans Yönetimi**  
> ```abap
> DATA(lo_obj) = NEW zcl_class( iv_kunnr = lv_kunnr ).
> 
> DATA(lr_data) = REF #( ls_data ).
> 
> DATA(lo_child) = CAST zcl_child( lo_parent ).
> ```
