-----------------------------------------------
methods on_double_click
      for event double_click of cl_salv_events_table
      importing
          !row
          !column.
-----------------------------------------------
method on_double_click.

    try.
        data(ls_out) = gt_out[ row ].
      catch cx_sy_itab_line_not_found.
        return.
    endtry.

    case column.
      when 'CUSTOMER_ORDER'.
        set parameter id 'AUN' field ls_out-customer_order.
        call transaction 'VA03' and skip first screen.

      when 'TRD_SERVICE_ORDER'.
        set parameter id 'AUN' field ls_out-trd_service_order.
        call transaction 'VA03' and skip first screen.

      when 'DEALER_SERVICE_ORDER'.
        set parameter id 'AUN' field ls_out-dealer_service_order.
        call transaction 'VA03' and skip first screen.
    endcase.

endmethod.
