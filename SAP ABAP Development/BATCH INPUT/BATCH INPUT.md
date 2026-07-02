# ✉️ BDC Yardımcı Metotları ve SALV Event Yönetimi

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-BDC-2E7D32?style=for-the-badge" alt="BDC" />
  <img src="https://img.shields.io/badge/CATEGORY-SALV_EVENT-C62828?style=for-the-badge" alt="SALV" />
</div>

<br/>

> **Sistem Mimarı Özeti:** Bu yapı, SALV Toolbar üzerinden tetiklenen kullanıcı işlemlerini Event sınıfı içerisinde yönetirken, BDC kayıtlarının oluşturulmasını da yardımcı (`bdc_dynpro` ve `bdc_field`) metotları ile merkezi hale getirir. Böylece BDC senaryoları tekrar kullanılabilir, okunabilir ve bakım yapılabilir bir yapıya kavuşur.

---

## 🛠️ Yapının Bileşenleri

| Bileşen | Görevi |
|---------|--------|
| **on_user_command** | Toolbar butonlarına basıldığında ilgili işlemi başlatır. |
| **bdc_dynpro** | Yeni bir Dynpro kaydı oluşturur (`DYNBEGIN = 'X'`). |
| **bdc_field** | Dynpro içerisine alan ve değer ekler. |
| **process_data** | BDC kaydını oluşturur ve `CALL TRANSACTION` ile çalıştırır. |
| **CONVERT_BDCMSGCOLL_TO_BAPIRET2** | BDC mesajlarını okunabilir BAPIRET2 formatına dönüştürür. |

---

## 💻 İşleyiş

```text
SALV Toolbar
      │
      ▼
on_user_command
      │
      ▼
LOOP GT_DATA
      │
      ▼
PROCESS_DATA
      │
      ▼
BDC_DYNPRO
BDC_FIELD
      │
      ▼
CALL TRANSACTION VB11
      │
      ▼
BDC Mesajları
      │
      ▼
BAPIRET2
      │
      ▼
Status Güncelle
      │
      ▼
SALV Refresh
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `bdc_dynpro` ve `bdc_field` metotları sayesinde tüm BDC kayıt oluşturma işlemleri tek noktadan yönetilir. Yeni ekran veya alan eklemek yalnızca bu yardımcı metotların çağrılmasıyla mümkündür.

> [!TIP]
> `VALUE #( BASE ... )` kullanımı APPEND yerine immutable yapıyı desteklediğinden kod okunabilirliğini artırır.

> [!TIP]
> `CONVERT_BDCMSGCOLL_TO_BAPIRET2` fonksiyonu kullanılarak teknik BDC mesajları kullanıcı dostu hale getirilebilir.

> [!WARNING]
> Her işlem sonunda `GT_BDCTABLE` mutlaka temizlenmelidir. Aksi halde önceki BDC kayıtları sonraki işlemde tekrar çalıştırılabilir.

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

    TYPES:
      BEGIN OF ty_header,
        columnname TYPE lvc_fname,
        columntext TYPE scrtext_l,
      END OF ty_header,
      ty_header_tab TYPE TABLE OF ty_header,
      ty_items_tab  TYPE TABLE OF zbrssd0601,
      ty_log_tab    TYPE TABLE OF zbrssd0602_log.

    METHODS on_user_command
      FOR EVENT added_function OF cl_salv_events
      IMPORTING
        e_salv_function.

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
        lr_columns->set_optimize( 'X' ).

        DATA lr_content TYPE REF TO cl_salv_form_element.

        PERFORM create_alv_form_content_tol
          USING space
          CHANGING lr_content.

        gr_salv->set_top_of_list( lr_content ).

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.



  METHOD bdc_field.

    gt_bdctable =
      VALUE #(
        BASE gt_bdctable
        (
          fnam = fnam
          fval = fval
        ) ).

  ENDMETHOD.



  METHOD bdc_dynpro.

    gt_bdctable =
      VALUE #(
        BASE gt_bdctable
        (
          program  = program
          dynpro   = dynpro
          dynbegin = 'X'
        ) ).

  ENDMETHOD.

ENDCLASS.
```

```abap
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

  lcl_handle_events=>bdc_dynpro(
    program = 'SAPLV14A'
    dynpro  = '0100' ).

  IF p_1 = 'X'.

    lcl_handle_events=>bdc_field(
      fnam = 'BDC_CURSOR'
      fval = 'RV130-SELKZ(01)' ).

  ELSE.

    lcl_handle_events=>bdc_field(
      fnam = 'BDC_CURSOR'
      fval = 'RV130-SELKZ(02)' ).

    lcl_handle_events=>bdc_field(
      fnam = 'RV130-SELKZ(02)'
      fval = 'X' ).

  ENDIF.

  lcl_handle_events=>bdc_field(
    fnam = 'BDC_OKCODE'
    fval = '=WEIT' ).

  lcl_handle_events=>bdc_dynpro(
    program = 'SAPMV13D'
    dynpro  = COND #(
                WHEN p_1 = 'X'
                THEN '1601'
                ELSE '1602' ) ).

  lcl_handle_events=>bdc_field(
    fnam = 'BDC_OKCODE'
    fval = '/00' ).

  lcl_handle_events=>bdc_field(
    fnam = 'KOMGD-VKORG'
    fval = is_data-vkorg ).

  lcl_handle_events=>bdc_field(
    fnam = 'KOMGD-VTWEG'
    fval = is_data-vtweg ).

  IF p_2 = 'X'.

    lcl_handle_events=>bdc_field(
      fnam = 'KOMGD-KDGRP'
      fval = is_data-kdgrp ).

  ENDIF.

  lcl_handle_events=>bdc_field(
    fnam = 'D000-DATAB'
    fval = |{ is_data-datab DATE = USER }| ).

  lcl_handle_events=>bdc_field(
    fnam = 'D000-DATBI'
    fval = |{ is_data-datbi DATE = USER }| ).

  lcl_handle_events=>bdc_field(
    fnam = 'MV13D-SUGRV'
    fval = '0004' ).

  lcl_handle_events=>bdc_field(
    fnam = 'KOMGD-MATNR(01)'
    fval = |{ is_data-matnr ALPHA = IN }| ).

  lcl_handle_events=>bdc_field(
    fnam = 'KONDD-SMATN(01)'
    fval = |{ is_data-smatn ALPHA = IN }| ).

  lcl_handle_events=>bdc_field(
    fnam = 'KONDD-SUGRD(01)'
    fval = '0004' ).

  lcl_handle_events=>bdc_dynpro(
    program = 'SAPMV13D'
    dynpro  = COND #(
                WHEN p_1 = 'X'
                THEN '1601'
                ELSE '1602' ) ).

  lcl_handle_events=>bdc_field(
    fnam = 'BDC_OKCODE'
    fval = '=SICH' ).

  CALL TRANSACTION 'VB11'
    USING lcl_handle_events=>gt_bdctable
    OPTIONS FROM l_ctu_params
    MESSAGES INTO lt_mes_tab.

  CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
    TABLES
      imt_bdcmsgcoll = lt_mes_tab
      ext_return     = lt_return.

  LOOP AT lt_return INTO DATA(ls_data)
       WHERE type = 'E'.

    is_data-status2 = ls_data-message.
    is_data-status  = '1'.

    EXIT.

  ENDLOOP.

  IF sy-subrc <> 0.
    is_data-status = '3'.
  ENDIF.

  REFRESH lcl_handle_events=>gt_bdctable[].

ENDFORM.
```
