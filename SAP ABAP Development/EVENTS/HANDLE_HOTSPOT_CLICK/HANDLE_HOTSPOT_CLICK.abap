-----------------------------------------------
METHODS handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id e_column_id es_row_no sender
-----------------------------------------------
 METHOD handle_hotspot_click.
    DATA: ls_col_id   TYPE lvc_s_col.

    PERFORM hotspot_click  USING   e_row_id e_column_id es_row_no..

  ENDMETHOD.

-----------------------------------------------
FORM hotspot_click  USING    p_row_id
                             p_column_id
                             ps_row_no.

  READ TABLE gt_list REFERENCE INTO
                     gr_list INDEX p_row_id.
  IF sy-subrc IS INITIAL.
    CASE p_column_id.
      WHEN 'VBELN'.
        SET PARAMETER ID 'VL' FIELD gr_list->vbeln.
        CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN .
      WHEN 'KUNRG'.
        SET PARAMETER ID 'KUN' FIELD gr_list->kunnr.
        CALL TRANSACTION 'XD03' AND SKIP FIRST SCREEN .
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
ENDFORM.                    " HOTSPOT_CLICK