  loop at lt_rows into data(ls_row).
          loop at gt_header into data(ls_item) from ls_row to ls_row.
            data(it_fields) = value ty_it_fields( ( tabname = 'ZBRSSD0650' fieldname = 'ONAYNO' value = ls_item-onayno  field_obl = abap_true fieldtext = 'Yeni onay numarası' ) ).

            call function 'POPUP_GET_VALUES'
              exporting
                popup_title     = 'Merkezi Faturalama Onay Seçim Ekranı'
              tables
                fields          = it_fields
              exceptions
                error_in_fields = 1
                others          = 2.

            case sy-ucomm.
              when 'FURT'.
                ls_item-onayno = value #( it_fields[ 1 ]-value ).
                update zbrssd0650 set onayno = ls_item-onayno where vbeln in s_vbeln.
                message 'Onay numarası güncellendi !' type 'S'.
              when 'CANC'.
                leave screen.
              when others.
            endcase.


"POP-UP TABLE

data: lr_columns type ref to cl_salv_columns_table,
      lr_column  type ref to cl_salv_column_table.

    define tanim.
      lr_column ?= lr_columns->get_column( &1 ).
      lr_column->set_short_text('').
      lr_column->set_medium_text('').
      lr_column->set_long_text( &2 ).
    end-of-definition.

    try.

        cl_salv_table=>factory(
           importing
             r_salv_table = data(lr_salv)
           changing
             t_table      = gt_out[] ).

        lr_columns = lr_salv->get_columns( ).
        lr_columns->set_optimize( 'X' ).

        data(lr_functions) = lr_salv->get_functions( ).
        lr_functions->set_all( if_salv_c_bool_sap=>true ).

        data(lr_display) = lr_salv->get_display_settings( ).
        lr_display->set_striped_pattern( if_salv_c_bool_sap=>true ).

        lr_salv->set_screen_popup(
           start_column = 15
           end_column   = 80
           start_line   = 10
           end_line     = 20 ).

        lr_salv->display( ).

      catch cx_root into data(lx_cx).
        message lx_cx->get_text( ) type 'E'.
    endtry.


"Message Kullanımı 
message lv_cx_msg type 'E'. - > MESAJA TIKLANINCA UZUN HATAYI GOSTERIR.

message lv_cx_msg->get_text( ) type 'E'.
