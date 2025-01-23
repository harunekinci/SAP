-----------------------------------------------
methods on_added_function for event added_function of cl_salv_events_table
  importing
   e_salv_function.

-----------------------------------------------

method on_added_function.

  case e_salv_function.

   when 'CREATE'.
   create_orders( ).

endmethod.

-----------------------------------------------

  method create_orders.

    data(lt_rows) = go_alv->get_selections( )->get_selected_rows( ).

    if lt_rows is initial.
      message 'İşlemek istediğiniz satırları seçiniz.' type 'I'.
      return.
    endif.

    data(lv_not_created) = abap_false.

    loop at lt_rows assigning field-symbol(<row>).

      assign gt_out[ <row> ] to field-symbol(<ls_out>).
      if sy-subrc <> 0.
        continue.
      endif.

      "Silinen siparişlerin kontrolü için class kullanıldı
      data(lo_order) = new zcl_sd_trendyol( <ls_out>-trd_order_no ).

      if lo_order->ms_order-customer_order       is initial or
         lo_order->ms_order-trd_service_order    is initial or
         lo_order->ms_order-dealer_service_order is initial.
        lv_not_created = abap_true.
      endif.

    endloop.

    if lv_not_created = abap_false.
      message 'Seçtiğiniz satırlardaki tüm siparişler işlenmiş.' type 'I'.
      return.
    endif.

    loop at lt_rows assigning <row>.

      assign gt_out[ <row> ] to <ls_out>.

      lo_order = new zcl_sd_trendyol( <ls_out>-trd_order_no ).

      lo_order->create_orders( ).

      move-corresponding lo_order->ms_order to <ls_out>.

    endloop.

    go_alv->get_columns( )->set_optimize( ).

    go_alv->refresh( s_stable     = value #( row = abap_true
                                             col = abap_true )
                     refresh_mode = if_salv_c_refresh=>soft ).

-----------------------------------------------

"Evenlter
  data(lo_events) = go_alv->get_event( ).
  set handler on_added_function for lo_events.

  endmethod.