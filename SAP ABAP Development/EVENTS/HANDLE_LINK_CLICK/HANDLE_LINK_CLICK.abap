METHODS : on_link_click FOR EVENT link_click OF cl_salv_events_table
  IMPORTING row column.

SET HANDLER on_link_click FOR lo_events.

DATA(lo_col) = CAST cl_salv_column_table( go_alv->get_columns( )->get_column( 'RACCT' ) ).
lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).

METHOD on_link_click.

    DATA(ls_out) = VALUE #( gt_out[ row ] OPTIONAL ).
    SET PARAMETER ID 'SAK'  FIELD ls_out-racct.
    CALL TRANSACTION 'FAGLL03' AND SKIP FIRST SCREEN.

  ENDMETHOD.
