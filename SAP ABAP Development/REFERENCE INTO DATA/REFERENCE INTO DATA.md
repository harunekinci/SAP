# ✉️ LOOP AT REFERENCE INTO

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-REFERENCE__INTO-2E7D32?style=for-the-badge" alt="Technique" />
  <img src="https://img.shields.io/badge/CATEGORY-INTERNAL_TABLE-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `LOOP AT ... REFERENCE INTO`, Internal Table satırlarını kopyalamak yerine referans (Reference Variable) üzerinden okumayı sağlar. Büyük tablolar üzerinde gereksiz veri kopyalamasını engelleyerek daha okunabilir ve performanslı bir erişim yöntemi sunar. Özellikle nesne tabanlı ABAP ve modern sözdiziminde önerilen yaklaşımlardan biridir.

---

## 🛠️ Kullanılan Yapılar

| Yapı | Açıklama |
|------|----------|
| **REFERENCE INTO** | Satırı referans değişkeni üzerinden okur. |
| **CONSTANTS** | Magic Number yerine anlamlı sabitler tanımlar. |
| **VALUE #( )** | Internal Table oluşturmak için modern ABAP sözdizimi. |
| **CORRESPONDING #( )** | Aynı isimli alanları otomatik eşler. |

---

## 💻 Örnek Kullanım

```abap
CONSTANTS:
  BEGIN OF lc_tel_type,
    landline TYPE c LENGTH 1 VALUE '1',
    mobile   TYPE c LENGTH 1 VALUE '3',
  END OF lc_tel_type.

TYPES:
  BEGIN OF ty_muhatap,
    tel_type   TYPE c LENGTH 1,
    telnr_long TYPE string,
  END OF ty_muhatap,
  tt_muhatap TYPE STANDARD TABLE OF ty_muhatap WITH EMPTY KEY.

DATA(lt_muhatap) = VALUE tt_muhatap(
  ( tel_type = lc_tel_type-landline
    telnr_long = '+905551112233' )

  ( tel_type = lc_tel_type-mobile
    telnr_long = '+905329998877' )
).

LOOP AT lt_muhatap REFERENCE INTO DATA(lr_muhatap).

  CASE lr_muhatap->tel_type.

    WHEN lc_tel_type-mobile.
      es_data-cep_telnr = lr_muhatap->telnr_long.

    WHEN lc_tel_type-landline.
      es_data-telnr = lr_muhatap->telnr_long.

  ENDCASE.

ENDLOOP.
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `REFERENCE INTO` satırın referansını döndürür. Alan erişimleri `->` operatörü ile yapılır.

> [!TIP]
> `'1'`, `'2'`, `'3'` gibi Magic Number kullanmak yerine `CONSTANTS` tanımlanması kodun okunabilirliğini ve bakımını artırır.

> [!TIP]
> Büyük Internal Table'larda `REFERENCE INTO`, satır kopyalamadığı için `INTO` kullanımına göre daha verimlidir.

> [!WARNING]
> Döngü tamamlandıktan sonra referans değişkeni yalnızca ilgili satırın yaşam süresi boyunca geçerlidir. Referansın geçerliliği, tablo üzerinde yapılan yapısal değişikliklerden etkilenebilir.
