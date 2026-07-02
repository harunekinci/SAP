# ✉️ BDC Yardımcı Sınıfı (Reusable BDC Builder)

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-BDC-2E7D32?style=for-the-badge" alt="BDC" />
  <img src="https://img.shields.io/badge/CATEGORY-CALL_TRANSACTION-C62828?style=for-the-badge" alt="BDC Builder" />
</div>

<br/>

> **Sistem Mimarı Özeti:** BDC (Batch Data Communication) kayıtları oluşturulurken aynı `BDC_DYNPRO` ve `BDC_FIELD` satırlarının sürekli tekrar yazılması yerine yardımcı (helper) bir sınıf oluşturularak ekran ve alan bilgileri merkezi olarak yönetilebilir. Böylece BDC kodu daha okunabilir, tekrar kullanılabilir ve bakım maliyeti düşük hale gelir.

---

## 🛠️ Yardımcı Metotlar

### 1️⃣ `BDC_DYNPRO`

| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| **PROGRAM** | `BDCDATA-PROGRAM` | İşlem yapılacak program |
| **DYNPRO** | `BDCDATA-DYNPRO` | Screen numarası |

---

### 2️⃣ `BDC_FIELD`

| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| **FNAM** | `BDCDATA-FNAM` | Screen alanı |
| **FVAL** | `TYPE DATA` | Yazılacak değer |

---

## 💻 Kullanım Akışı

```text
Toolbar Event
      │
      ▼
Process_Data
      │
      ▼
BDC_DYNPRO()
      │
      ▼
BDC_FIELD()
      │
      ▼
CALL TRANSACTION
      │
      ▼
BDC Mesajlarını Oku
      │
      ▼
BAPIRET2'ye Çevir
      │
      ▼
ALV Status Güncelle
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `BDCDATA` tablosunu oluşturan kodlar merkezi metotlar içerisine alınarak tekrar eden kod blokları azaltılabilir.

> [!TIP]
> `VALUE #( BASE gt_bdctable ... )` kullanımı klasik `APPEND` yapısına göre daha okunabilir ve modern ABAP söz dizimine uygundur.

> [!TIP]
> `CALL TRANSACTION` sonrasında oluşan `BDCMSGCOLL` mesajları `CONVERT_BDCMSGCOLL_TO_BAPIRET2` fonksiyonu ile standart `BAPIRET2` formatına dönüştürülebilir.

> [!WARNING]
> Her işlem sonunda `GT_BDCTABLE` temizlenmelidir. Aksi halde sonraki BDC çalıştırmalarında önceki ekran kayıtları da kullanılacağı için beklenmeyen sonuçlar oluşabilir.

---

## 💻 Kod

```abap
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.

    CLASS-DATA gt_bdctable TYPE TABLE OF bdcdata.

    CLASS-METHODS bdc_dynpro
      IMPORTING
        program TYPE bdcdata-program
        dynpro  TYPE bdcdata-dynpro.

    CLASS-METHODS bdc_field
      IMPORTING
        fnam TYPE bdcdata-fnam
        fval TYPE data.

    METHODS on_user_command
      FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

ENDCLASS.

CLASS lcl_handle_events IMPLEMENTATION.

  METHOD on_user_command.

    CASE e_salv_function.

      WHEN 'IMP'.

        LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>)
             WHERE status = '2'.

          PERFORM process_data USING <fs_data>.

        ENDLOOP.

        gr_salv->refresh(
          refresh_mode = if_salv_c_refresh=>full ).

        DATA(lr_columns) = gr_salv->get_columns( ).

        lr_columns->set_optimize( abap_true ).

        DATA lr_content TYPE REF TO cl_salv_form_element.

        PERFORM create_alv_form_content_tol
          USING space
          CHANGING lr_content.

        gr_salv->set_top_of_list( lr_content ).

    ENDCASE.

  ENDMETHOD.

  METHOD bdc_dynpro.

    gt_bdctable = VALUE #(
      BASE gt_bdctable
      (
        program  = program
        dynpro   = dynpro
        dynbegin = abap_true
      ) ).

  ENDMETHOD.

  METHOD bdc_field.

    gt_bdctable = VALUE #(
      BASE gt_bdctable
      (
        fnam = fnam
        fval = fval
      ) ).

  ENDMETHOD.

ENDCLASS.

FORM process_data USING is_data LIKE gt_data.

  DATA:
    l_ctu_params TYPE ctu_params,
    lt_mes_tab   TYPE TABLE OF bdcmsgcoll,
    lt_return    TYPE TABLE OF bapiret2.

  l_ctu_params-dismode = 'N'.
  l_ctu_params-updmode = 'S'.

  lcl_handle_events=>bdc_dynpro(
    program = 'SAPMV13D'
    dynpro  = '0100' ).

  lcl_handle_events=>bdc_field(
    fnam = 'BDC_CURSOR'
    fval = 'D000-KSCHL' ).

  lcl_handle_events=>bdc_field(
    fnam = 'BDC_OKCODE'
    fval = '=ANTA' ).

  lcl_handle_events=>bdc_field(
    fnam = 'D000-KSCHL'
    fval = 'BMZB' ).

  "... diğer BDC ekranları ...

  CALL TRANSACTION 'VB11'
    USING lcl_handle_events=>gt_bdctable
    OPTIONS FROM l_ctu_params
    MESSAGES INTO lt_mes_tab.

  CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
    TABLES
      imt_bdcmsgcoll = lt_mes_tab
      ext_return     = lt_return.

  LOOP AT lt_return INTO DATA(ls_return)
       WHERE type = 'E'.

    is_data-status  = '1'.
    is_data-status2 = ls_return-message.

    EXIT.

  ENDLOOP.

  IF sy-subrc <> 0.
    is_data-status = '3'.
  ENDIF.

  REFRESH lcl_handle_events=>gt_bdctable.

ENDFORM.
```
