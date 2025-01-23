-----------------------------------------------
methods:
      on_link_click for event link_click of cl_salv_events_table "Hotspot Handler
        importing row column.
-----------------------------------------------
method on_link_click.
 
 perform link_click using row column.

endmethod.
-----------------------------------------------

form link_click  using p_row  p_column.
  
  data(ls_out) = value #( gt_out[ p_row ] optional ).
  set parameter id 'AUN'  field ls_out-vbeln.
  call transaction 'VA03' and skip first screen.

endform.

