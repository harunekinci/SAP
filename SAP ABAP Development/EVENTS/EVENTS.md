# 🖱️ ALV Event Kullanımı (SALV & OO ALV)

<br/>

> **Özet:** ALV Event'leri, kullanıcının ALV ekranı üzerinde gerçekleştirdiği işlemleri yakalamak için kullanılır. Toolbar butonları, çift tıklama, hotspot, veri değişikliği ve ekran olayları gibi birçok işlem event mekanizması sayesinde yönetilebilir.

---

## 📌 Eventler

| Event | Açıklama |
|--------|----------|
| **added_function** | Toolbar'a eklenen özel butonları yakalar. |
| **double_click** | Hücre veya satıra çift tıklanmasını yakalar. |
| **hotspot_click** | Hotspot olarak işaretlenen alanların tıklanmasını yakalar. |
| **toolbar** | OO ALV'de toolbar'a buton eklemek için kullanılır. |
| **user_command** | Toolbar butonuna basıldıktan sonra çalışır. |
| **data_changed** | Edit edilen hücre değişikliklerini yakalar. |
| **data_changed_finished** | Değişiklik tamamlandıktan sonra çalışır. |
| **top_of_page** | ALV'nin üst kısmına başlık veya özet bilgi eklemek için kullanılır. |
| **end_of_list** | Listenin sonuna bilgi eklemek için kullanılır. |
| **before_user_command** | Komut çalışmadan önce tetiklenir. |
| **after_user_command** | Komut tamamlandıktan sonra tetiklenir. |

---

# ➜ Added Function (Toolbar Butonu)

Toolbar'a eklenen özel butonların tıklanmasını yakalamak için kullanılır.

## Event Tanımı

```abap
METHODS on_added_function
  FOR EVENT added_function OF cl_salv_events_table
  IMPORTING
    e_salv_function.
```

## Event Implementation

```abap
METHOD on_added_function.

  CASE e_salv_function.

    WHEN 'CREATE'.

      create_orders( ).

  ENDCASE.

ENDMETHOD.
```

## Event Registration

```abap
DATA(lo_events) = go_alv->get_event( ).

SET HANDLER on_added_function FOR lo_events.
```

## Örnek

```abap
METHOD create_orders.

  DATA(lt_rows) = go_alv->get_selections( )->get_selected_rows( ).

  IF lt_rows IS INITIAL.
    MESSAGE 'İşlemek istediğiniz satırları seçiniz.' TYPE 'I'.
    RETURN.
  ENDIF.

  DATA(lv_not_created) = abap_false.

  LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<row>).

    ASSIGN gt_out[ <row> ] TO FIELD-SYMBOL(<ls_out>).

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    DATA(lo_order) = NEW zcl_sd_trendyol( <ls_out>-trd_order_no ).

    IF lo_order->ms_order-customer_order IS INITIAL OR
       lo_order->ms_order-trd_service_order IS INITIAL OR
       lo_order->ms_order-dealer_service_order IS INITIAL.
      lv_not_created = abap_true.
    ENDIF.

  ENDLOOP.

  IF lv_not_created = abap_false.
    MESSAGE 'Seçtiğiniz satırlardaki tüm siparişler işlenmiş.' TYPE 'I'.
    RETURN.
  ENDIF.

  LOOP AT lt_rows ASSIGNING <row>.

    ASSIGN gt_out[ <row> ] TO <ls_out>.

    lo_order = NEW zcl_sd_trendyol( <ls_out>-trd_order_no ).

    lo_order->create_orders( ).

    MOVE-CORRESPONDING lo_order->ms_order TO <ls_out>.

  ENDLOOP.

  go_alv->get_columns( )->set_optimize( ).

  go_alv->refresh(
    s_stable = VALUE #( row = abap_true
                        col = abap_true )
    refresh_mode = if_salv_c_refresh=>soft ).

ENDMETHOD.
```

---

# ➜ Double Click

ALV üzerinde çift tıklama işlemlerini yakalar.

## Event Tanımı

```abap
METHODS on_double_click
  FOR EVENT double_click OF cl_salv_events_table
  IMPORTING
    row
    column.
```

## Örnek 1

```abap
METHOD on_double_click.

  READ TABLE gt_out INTO DATA(ls_out) INDEX row.

  CASE column.

    WHEN 'VBELNF'.

      SET PARAMETER ID 'VF' FIELD ls_out-vbelnf.
      CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

    WHEN OTHERS.

      SET PARAMETER ID 'AUN' FIELD ls_out-vbelns.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDMETHOD.
```

---

## Örnek 2

```abap
METHOD on_double_click.

  TRY.

      DATA(ls_out) = gt_out[ row ].

    CATCH cx_sy_itab_line_not_found.
      RETURN.

  ENDTRY.

  CASE column.

    WHEN 'CUSTOMER_ORDER'.

      SET PARAMETER ID 'AUN' FIELD ls_out-customer_order.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    WHEN 'TRD_SERVICE_ORDER'.

      SET PARAMETER ID 'AUN' FIELD ls_out-trd_service_order.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    WHEN 'DEALER_SERVICE_ORDER'.

      SET PARAMETER ID 'AUN' FIELD ls_out-dealer_service_order.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDMETHOD.
```

---

## Örnek 3 (FORM)

```abap
METHOD on_double_click.

  PERFORM double_click USING row column.

ENDMETHOD.
```

```abap
DATA(lr_events) = gr_salv->get_event( ).

SET HANDLER gr_events->on_double_click FOR lr_events.
```

```abap
FORM double_click USING
      p_row
      p_column.

  ASSIGN COMPONENT p_column
         OF STRUCTURE gt_header[ p_row ]
         TO FIELD-SYMBOL(<fs_value>).

  CHECK <fs_value> IS ASSIGNED.

  CASE p_column.

    WHEN 'VBELN' OR 'CMDOC'.

      SET PARAMETER ID 'AUN' FIELD <fs_value>.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    WHEN 'VBELF_B' OR 'VBELF_A'.

      SET PARAMETER ID 'VF' FIELD <fs_value>.
      CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

    WHEN 'BELNR_B' OR 'BELNR_A'.

      ASSIGN COMPONENT 'GJAHR'
             OF STRUCTURE gt_header[ p_row ]
             TO FIELD-SYMBOL(<fs_gjahr>).

      SET PARAMETER ID 'BLN' FIELD <fs_value>.
      SET PARAMETER ID 'BUK' FIELD '0210'.
      SET PARAMETER ID 'GJR' FIELD <fs_gjahr>.

      CALL TRANSACTION 'FB03'
        AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
```

---

## OPTIONAL Kullanımı

```abap
DATA(ls_out) = VALUE #( gt_data[ p_row ] OPTIONAL ).

SET PARAMETER ID 'AUN' FIELD ls_out-vbeln.

CALL TRANSACTION 'VA03'
  AND SKIP FIRST SCREEN.
```

---

# ➜ Hotspot Click (OO ALV)

## Event Tanımı

```abap
METHODS handle_hotspot_click
  FOR EVENT hotspot_click OF cl_gui_alv_grid
  IMPORTING
    e_row_id
    e_column_id
    es_row_no
    sender.
```

## Event

```abap
METHOD handle_hotspot_click.

  PERFORM hotspot_click
    USING
      e_row_id
      e_column_id
      es_row_no.

ENDMETHOD.
```

## FORM

```abap
FORM hotspot_click USING
      p_row_id
      p_column_id
      ps_row_no.

  READ TABLE gt_list
       REFERENCE INTO gr_list
       INDEX p_row_id.

  IF sy-subrc IS INITIAL.

    CASE p_column_id.

      WHEN 'VBELN'.

        SET PARAMETER ID 'VL' FIELD gr_list->vbeln.

        CALL TRANSACTION 'VL03N'
          AND SKIP FIRST SCREEN.

      WHEN 'KUNRG'.

        SET PARAMETER ID 'KUN' FIELD gr_list->kunnr.

        CALL TRANSACTION 'XD03'
          AND SKIP FIRST SCREEN.

    ENDCASE.

  ENDIF.

ENDFORM.
```

---

# ➜ Toolbar (OO ALV)

Toolbar'a dinamik buton eklemek için kullanılır.

```abap
METHOD handle_toolbar.

  APPEND VALUE stb_button(
      function = 'CREATE'
      icon     = icon_create
      text     = 'Create' )
      TO e_object->mt_toolbar.

ENDMETHOD.
```

---

# ➜ User Command (OO ALV)

Toolbar butonuna basıldıktan sonra çalışır.

```abap
METHOD handle_user_command.

  CASE e_ucomm.

    WHEN 'CREATE'.

      MESSAGE 'Butona basıldı.' TYPE 'S'.

  ENDCASE.

ENDMETHOD.
```

---

# ➜ Data Changed

Edit edilen hücreleri yakalar.

```abap
METHOD handle_data_changed.

  LOOP AT er_data_changed->mt_good_cells
       INTO DATA(ls_cell).

    WRITE:
      / ls_cell-row_id,
        ls_cell-fieldname,
        ls_cell-value.

  ENDLOOP.

ENDMETHOD.
```

---

# ➜ Data Changed Finished

Tüm değişiklikler tamamlandıktan sonra çalışır.

```abap
METHOD handle_data_changed_finished.

  MESSAGE 'Veriler güncellendi.' TYPE 'S'.

ENDMETHOD.
```

---

# ➜ Top Of Page

ALV'nin üst kısmına bilgi eklemek için kullanılır.

```abap
DATA(lo_header) = NEW cl_salv_form_layout_grid( ).

lo_header->create_label(
  row = 1
  column = 1
  text = 'Satış Siparişleri' ).

go_alv->set_top_of_list( lo_header ).
```

---

# ➜ End Of List

Listenin sonuna bilgi eklemek için kullanılır.

```abap
DATA(lo_footer) = NEW cl_salv_form_layout_grid( ).

lo_footer->create_label(
  row = 1
  column = 1
  text = 'Toplam Kayıt : 120' ).

go_alv->set_end_of_list( lo_footer ).
```

---

# ➜ Before User Command

Komut çalışmadan önce tetiklenir.

```abap
METHOD before_user_command.

  WRITE 'Komut çalışacak'.

ENDMETHOD.
```

---

# ➜ After User Command

Komut tamamlandıktan sonra çalışır.

```abap
METHOD after_user_command.

  WRITE 'Komut tamamlandı'.

ENDMETHOD.
```

---

## 💡 Notlar

- `added_function` SALV toolbar butonlarını yönetmek için kullanılır.
- `double_click` en sık kullanılan ALV eventlerinden biridir.
- `hotspot_click` yalnızca hotspot olarak tanımlanan kolonlarda çalışır.
- `toolbar` event'i sayesinde standart toolbar'a yeni butonlar eklenebilir.
- `user_command`, toolbar butonlarının iş mantığını içerir.
- `data_changed` edit işlemlerini doğrulamak için kullanılır.
- `top_of_page` ve `end_of_list` rapora başlık veya özet bilgi eklemek için idealdir.
- Event'lerin çalışabilmesi için mutlaka `SET HANDLER` ile register edilmesi gerekir.
