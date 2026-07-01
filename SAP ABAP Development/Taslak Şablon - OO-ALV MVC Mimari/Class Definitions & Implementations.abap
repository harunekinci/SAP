*&---------------------------------------------------------------------*
*& Include          ZDEVELOPMENT_01_OOALV_MVC_CLS
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES & GLOBAL DATA
*----------------------------------------------------------------------*
tables: bsid, sscrfields.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
selection-screen begin of block b1 with frame title text-001.
parameters     p_bukrs type bsid-bukrs obligatory default '1000'.
select-options s_kunnr for  bsid-kunnr.
selection-screen end of block b1.

selection-screen function key 1.

*----------------------------------------------------------------------*
* CLASS DEFINITIONS (Deferred)
*----------------------------------------------------------------------*
class lcl_controller definition deferred.
class lcl_model      definition deferred.
class lcl_view       definition deferred.

*----------------------------------------------------------------------*
* GLOBAL CONTROLLER INSTANCE
*----------------------------------------------------------------------*
data: go_controller type ref to lcl_controller.

*----------------------------------------------------------------------*
* LCL_MODEL DEFINITION
*----------------------------------------------------------------------*
class lcl_model definition.
  public section.
    types: begin of ty_bsid,
             bukrs type bsid-bukrs,
             kunnr type bsid-kunnr,
             belnr type bsid-belnr,
             gjahr type bsid-gjahr,
             blart type bsid-blart,
             bldat type bsid-bldat,
             budat type bsid-budat,
             waers type bsid-waers,
             dmbtr type bsid-dmbtr,
           end of ty_bsid.
    types tt_bsid type standard table of ty_bsid with empty key.
    types tt_kunnr_range type range of bsid-kunnr.

    data: mt_outdat type tt_bsid.

    methods: retrieve_data
      importing iv_bukrs type bsid-bukrs
                it_kunnr type tt_kunnr_range.

    methods: post_documents
      importing it_rows type lvc_t_row
                io_log  type ref to cl_ptu_message.
endclass.

*----------------------------------------------------------------------*
* LCL_VIEW DEFINITION
*----------------------------------------------------------------------*
class lcl_view definition.
  public section.
    data  mo_grid       type ref to cl_gui_alv_grid.

    methods constructor    importing io_controller type ref to lcl_controller.
    methods display_alvdat changing  ct_outtab     type standard table.

    " OO-ALV Events
    methods handle_toolbar for event toolbar of cl_gui_alv_grid
      importing e_object e_interactive.

    methods handle_user_command for event user_command of cl_gui_alv_grid
      importing e_ucomm.

    methods handle_double_click for event double_click of cl_gui_alv_grid
      importing e_row e_column.

    methods handle_hotspot_click for event hotspot_click of cl_gui_alv_grid
      importing e_row_id e_column_id.

    methods handle_data_changed for event data_changed of cl_gui_alv_grid
      importing er_data_changed.

  private section.
    data: mo_controller type ref to lcl_controller,
          mo_container  type ref to cl_gui_custom_container,
          mt_fcat       type lvc_t_fcat.

    methods: prepare_fcatdat.
endclass.

*----------------------------------------------------------------------*
* LCL_CONTROLLER DEFINITION
*----------------------------------------------------------------------*
class lcl_controller definition.
  public section.
    data mo_model type ref to lcl_model.
    data mo_view  type ref to lcl_view.
    data go_log   type ref to cl_ptu_message.

    methods constructor.
    methods initialization.
    methods at_selection_screen changing cv_ucomm type sy-ucomm.
    methods run importing iv_bukrs type bsid-bukrs
                          it_kunnr type lcl_model=>tt_kunnr_range.
    methods has_data returning value(rv_has_data) type abap_bool.
    methods render_screen.
    methods on_user_command importing iv_ucomm type sy-ucomm.

    methods on_double_click
      importing iv_row_index type lvc_index
                iv_fieldname type fieldname.

    methods on_hotspot_click
      importing iv_row_index type lvc_index
                iv_fieldname type fieldname.

    methods on_data_changed
      importing ir_data_changed type ref to cl_alv_changed_data_protocol.
endclass.

*----------------------------------------------------------------------*
* LCL_MODEL IMPLEMENTATION
*----------------------------------------------------------------------*
class lcl_model implementation.
  method retrieve_data.
    free mt_outdat.

    select bukrs, kunnr, belnr, gjahr, blart, bldat, budat, waers, dmbtr
      from bsid
      where bukrs = @iv_bukrs
        and kunnr in @it_kunnr
      into table @mt_outdat.
  endmethod.

  method post_documents.
    if it_rows is initial or mt_outdat is initial.
      return.
    endif.

    loop at it_rows into data(ls_row).
      assign mt_outdat[ ls_row-index ] to field-symbol(<fs_out>).
      if sy-subrc <> 0.
        continue.
      endif.

      " Business Logic / BAPI süreçleri burada koşturulabilir.
      " Örnek log yazımı:
      " io_log->add_message( iv_msgty = 'S' iv_text = |{ <fs_out>-belnr } işlendi.| ).
    endloop.
  endmethod.
endclass.

*----------------------------------------------------------------------*
* LCL_VIEW IMPLEMENTATION
*----------------------------------------------------------------------*
class lcl_view implementation.
  method constructor.
    me->mo_controller = io_controller.
  endmethod.

  method prepare_fcatdat.
    free me->mt_fcat.

    call function 'LVC_FIELDCATALOG_MERGE'
      exporting
        i_structure_name = 'BSID'
      changing
        ct_fieldcat      = me->mt_fcat
      exceptions
        others           = 3.

    delete me->mt_fcat where fieldname <> 'BUKRS' and fieldname <> 'KUNNR'
                         and fieldname <> 'BELNR' and fieldname <> 'GJAHR'
                         and fieldname <> 'BLDAT' and fieldname <> 'BUDAT'
                         and fieldname <> 'BLART' and fieldname <> 'DMBTR'.

    loop at me->mt_fcat reference into data(lr_fcat).
      case lr_fcat->fieldname.
        when 'BELNR' or 'KUNNR'.
          lr_fcat->hotspot = abap_true.
        when 'BLART'.
          lr_fcat->edit    = abap_true.
      endcase.
    endloop.
  endmethod.

  method display_alvdat.
    if mo_container is initial.
      me->prepare_fcatdat( ).

      mo_container = new #( container_name = 'CC_CONT' ).
      mo_grid      = new #( i_parent = mo_container ).

      set handler me->handle_toolbar       for mo_grid.
      set handler me->handle_user_command  for mo_grid.
      set handler me->handle_double_click  for mo_grid.
      set handler me->handle_hotspot_click for mo_grid.
      set handler me->handle_data_changed  for mo_grid.

      data(ls_layout)  = value lvc_s_layo( zebra = 'X' cwidth_opt = 'X' sel_mode = 'A' ).
      data(ls_variant) = value disvariant( report = sy-repid ).

      mo_grid->set_table_for_first_display(
        exporting is_variant          = ls_variant
                  is_layout           = ls_layout
        changing  it_fieldcatalog     = me->mt_fcat
                  it_outtab           = ct_outtab ).

      mo_grid->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).
    else.
      mo_grid->refresh_table_display( i_soft_refresh = 'X' ).
    endif.
  endmethod.

  method handle_toolbar.
    append value stb_button( function  = 'CREATE'
                             icon      = icon_create
                             text      = 'Belge Yarat'
                             quickinfo = 'Yeni Belge İşlemi'
                             butn_type = 0 ) to e_object->mt_toolbar.
  endmethod.

  method handle_user_command.
    mo_controller->on_user_command( iv_ucomm = e_ucomm ).
  endmethod.

  method handle_double_click.
    mo_controller->on_double_click( iv_row_index = e_row-index
                                    iv_fieldname = e_column-fieldname ).
  endmethod.

  method handle_hotspot_click.
    mo_controller->on_hotspot_click( iv_row_index = e_row_id-index
                                     iv_fieldname = e_column_id-fieldname ).
  endmethod.

  method handle_data_changed.
    mo_controller->on_data_changed( ir_data_changed = er_data_changed ).
  endmethod.
endclass.

*----------------------------------------------------------------------*
* LCL_CONTROLLER IMPLEMENTATION
*----------------------------------------------------------------------*
class lcl_controller implementation.
  method constructor.
    me->mo_model = new #( ).
    me->mo_view  = new #( io_controller = me ).
    me->go_log   = new #( ).
  endmethod.

  method initialization.
    sscrfields-functxt_01 = value smp_dyntxt( icon_id   = '@36@'
                                              icon_text = 'Bakım Ekranı' ).
  endmethod.

  method at_selection_screen.
    if cv_ucomm = 'FC01'.
      call function 'VIEW_MAINTENANCE_CALL'
        exporting
          action                         = 'U'
          view_name                      = 'ZKLM_V_FIORI_USR'
          no_warning_for_clientindep     = 'X'
          generate_maint_tool_if_missing = 'X'.
      exit.
    endif.
  endmethod.

  method run.
    mo_model->retrieve_data( iv_bukrs = iv_bukrs
                             it_kunnr = it_kunnr ).
  endmethod.

  method has_data.
    rv_has_data = xsdbool( lines( mo_model->mt_outdat ) > 0 ).
  endmethod.

  method render_screen.
    mo_view->display_alvdat( changing ct_outtab = mo_model->mt_outdat ).
  endmethod.

  METHOD on_user_command.
    CASE iv_ucomm.
      WHEN 'CREATE'.
        " Örnek log sıfırlama metodu çağrısı

        go_log->delete_messages( ).

        IF mo_view->mo_grid IS BOUND.
          mo_view->mo_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_selected_rows) ).
        ENDIF.

        IF lt_selected_rows IS INITIAL.
          MESSAGE 'Lütfen işlem yapmak için satır seçiniz!' TYPE 'E' DISPLAY LIKE 'I'.
          RETURN.
        ENDIF.

        mo_model->post_documents( it_rows = lt_selected_rows
                                  io_log  = go_log  ).

        render_screen( ).
    ENDCASE.
  ENDMETHOD.

  method on_double_click.
    check iv_row_index > 0.
    if not line_exists( mo_model->mt_outdat[ iv_row_index ] ).
      return.
    endif.

    message |Satır: { iv_row_index } Kolon: { iv_fieldname }| type 'I'.
  endmethod.

  method on_hotspot_click.
    check iv_row_index > 0.
    assign mo_model->mt_outdat[ iv_row_index ] to field-symbol(<ls_data>).
    check sy-subrc = 0.

    case iv_fieldname.
      when 'BELNR'.
        set parameter id 'BLN' field <ls_data>-belnr.
        set parameter id 'BUK' field <ls_data>-bukrs.
        set parameter id 'GJR' field <ls_data>-gjahr.
        call transaction 'FB03' and skip first screen.
      when 'KUNNR'.
        set parameter id 'KUN' field <ls_data>-kunnr.
        call transaction 'FD03' and skip first screen.
    endcase.
  endmethod.

  method on_data_changed.
    loop at ir_data_changed->mt_good_cells assigning field-symbol(<ls_cell>).
      assign mo_model->mt_outdat[ <ls_cell>-row_id ] to field-symbol(<ls_data>).
      if sy-subrc = 0.
        case <ls_cell>-fieldname.
          when 'BLART'.
            data(lv_old_value) = <ls_data>-blart.
            <ls_data>-blart = <ls_cell>-value. " Update model data
            message |[Değişim Hücresi] Satır: { <ls_cell>-row_id } | &
                    |Eski: { lv_old_value } -> Yeni: { <ls_cell>-value }| type 'S'.
        endcase.
      endif.
    endloop.
  endmethod.
endclass.