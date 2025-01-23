-----------------------------------------------
methods on_double_click
      for event double_click
          of cl_salv_events_table
      importing
          !row
          !column.
-----------------------------------------------
method on_double_click.

 read table gt_out into data(ls_out) index row .

    case column.
      when 'VBELNF'.
        set parameter id 'VF' field ls_out-vbelnf.
        call transaction 'VF03' and skip first screen.

      when others.
        set parameter id 'AUN' field ls_out-vbelns.
        call transaction 'VA03' and skip first screen.
    endcase.


endmethod.

