# ✉️ DATE RANGE (İlk / Son Gün Hesaplama)

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-DATE__RANGE-2E7D32?style=for-the-badge" alt="Technique" />
  <img src="https://img.shields.io/badge/CATEGORY-DATE-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** ABAP'ta belirli bir aya ait ilk ve son günü hesaplamak için en yaygın yöntemlerden biri `LAST_DAY_OF_MONTHS` Function Module'ünü kullanmaktır. Geçmiş aya ait tarih aralığı ise mevcut ayın ilk gününden bir gün çıkarılarak kolayca elde edilebilir. Bu tarihler genellikle Select-Option Range oluştururken kullanılır.

---

## 🛠️ Kullanılan Yapılar

| Yapı | Açıklama |
|------|----------|
| **LAST_DAY_OF_MONTHS** | Verilen tarihin bulunduğu ayın son gününü döndürür. |
| **CONCATENATE** | Ayın ilk gününü (`YYYYMM01`) oluşturmak için kullanılır. |
| **VALUE #( )** | Date Range oluşturmak için modern ABAP sözdizimi. |
| **CONV** | String ifadesini `DATS` tipine dönüştürür. |

---

## 💻 Mevcut Ayın İlk ve Son Günü

```abap
DATA: first_date TYPE datum,
      last_date  TYPE datum.

DATA lr_fkdat TYPE RANGE OF datum.

CALL FUNCTION 'LAST_DAY_OF_MONTHS'
  EXPORTING
    day_in            = sy-datum
  IMPORTING
    last_day_of_month = last_date.

CONCATENATE last_date+0(6) '01'
       INTO first_date.

lr_fkdat = VALUE #(
  ( sign   = 'I'
    option = 'BT'
    low    = first_date
    high   = last_date )
).
```

---

## 💻 Geçen Ayın İlk ve Son Günü

```abap
DATA(lv_last_date) =
  CONV datum( |{ sy-datum(6) }01| ).

lv_last_date = lv_last_date - 1.

DATA(lv_first_date) =
  CONV datum( |{ lv_last_date(6) }01| ).
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `LAST_DAY_OF_MONTHS` ay uzunluğunu (28, 29, 30 veya 31 gün) otomatik olarak hesaplar. Manuel tarih hesaplamasına gerek kalmaz.

> [!TIP]
> Geçen ayın son günü, mevcut ayın ilk gününden **1 gün çıkarılarak** güvenli şekilde elde edilebilir.

> [!TIP]
> `VALUE #( )` kullanılarak oluşturulan Date Range, doğrudan `SELECT-OPTIONS` veya `WHERE ... IN` ifadelerinde kullanılabilir.
