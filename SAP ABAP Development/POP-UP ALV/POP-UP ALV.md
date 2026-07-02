# ✉️ POPUP Kullanımları

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-POPUP-2E7D32?style=for-the-badge" alt="Technique" />
  <img src="https://img.shields.io/badge/CATEGORY-UI-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** ABAP'ta kullanıcıdan veri almak, tablo göstermek veya mesaj vermek amacıyla farklı Popup yöntemleri kullanılabilir. En sık kullanılan yöntemler `POPUP_GET_VALUES`, `CL_SALV_TABLE->SET_SCREEN_POPUP` ve standart `MESSAGE` ifadeleridir.

---

## 🛠️ Popup Türleri

| Yöntem | Açıklama |
|--------|----------|
| **POPUP_GET_VALUES** | Kullanıcıdan tek veya birden fazla alan için giriş alır. |
| **CL_SALV_TABLE->SET_SCREEN_POPUP** | Internal Table verisini ALV Popup olarak gösterir. |
| **MESSAGE** | Hata, bilgi, uyarı ve başarı mesajlarını görüntüler. |

---

## 💻 POPUP_GET_VALUES

```abap
DATA(it_fields) = VALUE ty_it_fields(
  (
    tabname   = 'ZBRSSD0650'
    fieldname = 'ONAYNO'
    value     = ls_item-onayno
    field_obl = abap_true
    fieldtext = 'Yeni onay numarası'
  )
).

CALL FUNCTION 'POPUP_GET_VALUES'
  EXPORTING
    popup_title = 'Merkezi Faturalama Onay Seçim Ekranı'
  TABLES
    fields      = it_fields.

CASE sy-ucomm.
  WHEN 'FURT'.

    ls_item-onayno = it_fields[ 1 ]-value.

    UPDATE zbrssd0650
       SET onayno = ls_item-onayno
     WHERE vbeln IN s_vbeln.

    MESSAGE 'Onay numarası güncellendi!' TYPE 'S'.

  WHEN 'CANC'.
    LEAVE SCREEN.

ENDCASE.
```

---

## 💻 ALV Popup

```abap
cl_salv_table=>factory(
  IMPORTING
    r_salv_table = DATA(lr_salv)
  CHANGING
    t_table      = gt_out ).

lr_salv->set_screen_popup(
  start_column = 15
  end_column   = 80
  start_line   = 10
  end_line     = 20 ).

lr_salv->display( ).
```

---

## 💻 MESSAGE Kullanımı

```abap
MESSAGE lv_cx_msg TYPE 'E'.
```

> Exception nesnesinin uzun metnini (Long Text) görüntülemek için kullanılır.

```abap
MESSAGE lv_cx_msg->get_text( ) TYPE 'E'.
```

> Sadece exception'ın kısa mesajını ekrana basar.

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `POPUP_GET_VALUES` döndükten sonra kullanıcı işlemi `SY-UCOMM` üzerinden kontrol edilmelidir (`FURT`, `CANC` vb.).

> [!TIP]
> `SET_SCREEN_POPUP` sayesinde ayrı bir Dynpro geliştirmeden ALV verisi Popup penceresinde gösterilebilir.

> [!TIP]
> Exception nesnesi (`CX_ROOT`) mevcutsa, `MESSAGE exception TYPE 'E'` kullanımı uzun hata metninin görüntülenmesini sağlar.

> [!WARNING]
> Popup işlemleri dialog (foreground) ortamında çalışır. Background Job içerisinde kullanılmaları Dump oluşmasına neden olabilir.
