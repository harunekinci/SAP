-----------------------------------------------
methods on_double_click.

  perform double_click using row column.

endmethod.
-----------------------------------------------

create object gr_events.

  data : gr_salv type ref to cl_salv_table.

  data(lr_events) = gr_salv->get_event( ).
  set handler gr_events->on_double_click for lr_events.

form double_click  using     p_row
                             p_column.

  assign component p_column of structure gt_header[ p_row ] to field-symbol(<fs_value>).
  check <fs_value> is assigned.


  case p_column.
    when 'VBELN' or 'CMDOC'.
      set parameter id 'AUN' field <fs_value>.
      call transaction 'VA03' and skip first screen.
    when 'VBELF_B' or 'VBELF_A'.
      set parameter id 'VF' field <fs_value>.
      call transaction 'VF03' and skip first screen.
    when 'BELNR_B' or 'BELNR_A'.
      assign component 'GJAHR' of structure gt_header[ p_row ] to field-symbol(<fs_gjahr>).
      set parameter id 'BLN' field <fs_value>.
      set parameter id 'BUK' field '0210'.
      set parameter id 'GJR' field <fs_gjahr>.
      call transaction 'FB03' and skip first screen.
    when others.
  endcase.

  unassign <fs_value>.

endform.

data(ls_out) = value #( gt_data[ p_row ] optional ).
set parameter id 'AUN' field ls_out-vbeln.
call transaction 'VA03' and skip first screen.
