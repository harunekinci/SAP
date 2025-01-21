class lcl_handle_events definition.
  public section.
    class-data gt_bdctable  type table of bdcdata.

    class-methods bdc_dynpro      importing program type bdcdata-program
                                            dynpro  type bdcdata-dynpro.


    class-methods bdc_field      importing fnam type bdcdata-fnam
                                           fval type data .
    types: begin of ty_header,
             columnname type lvc_fname,
             columntext type scrtext_l,
           end of ty_header,
           ty_header_tab type table of ty_header,
           ty_items_tab  type table of zbrssd0601,
           ty_log_tab    type table of zbrssd0602_log.
    methods:
      on_user_command for event added_function of cl_salv_events "toolbar button user command
        importing e_salv_function .

endclass.

class lcl_handle_events implementation.
 
 method on_user_command.
    case e_salv_function.
      when 'IMP'.

        loop at gt_data assigning field-symbol(<fs_data>) where status eq '2'.
          perform process_data using <fs_data> .
        endloop.

        gr_salv->refresh( refresh_mode = if_salv_c_refresh=>full ).
        data(lr_columns) = gr_salv->get_columns( ).
        lr_columns->set_optimize( 'X' ).

        data: lr_content type ref to cl_salv_form_element .
        perform create_alv_form_content_tol using space changing lr_content.
        gr_salv->set_top_of_list( lr_content ).

      when others.
    endcase.
  endmethod.

  method bdc_field.
    gt_bdctable = value #( base gt_bdctable ( fnam  = fnam fval = fval ) ).
  endmethod.

  method bdc_dynpro.
    gt_bdctable = value #( base gt_bdctable ( program  = program dynpro = dynpro dynbegin = 'X' ) ).
  endmethod.

endclass.

form process_data using is_data like gt_data .
  data : l_ctu_params type ctu_params,
         lt_mes_tab   type table of bdcmsgcoll,
         lt_return    type table of bapiret2.

  l_ctu_params-dismode = 'N'.
  l_ctu_params-updmode = 'S'.

  lcl_handle_events=>bdc_dynpro( program = 'SAPMV13D' dynpro = '0100' ).
  lcl_handle_events=>bdc_field( fnam = 'BDC_CURSOR' fval = 'D000-KSCHL' ).
  lcl_handle_events=>bdc_field( fnam = 'BDC_OKCODE' fval = '=ANTA' ).
  lcl_handle_events=>bdc_field( fnam = 'D000-KSCHL' fval = 'BMZB' ).

  lcl_handle_events=>bdc_dynpro( program = 'SAPLV14A'  dynpro = '0100' ).
  if p_1 eq 'X'.
    lcl_handle_events=>bdc_field( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(01)' ).
  else.
    lcl_handle_events=>bdc_field( fnam = 'BDC_CURSOR' fval = 'RV130-SELKZ(02)' ).
    lcl_handle_events=>bdc_field( fnam = 'RV130-SELKZ(02)' fval = 'X' ).
  endif.

  lcl_handle_events=>bdc_field( fnam = 'BDC_OKCODE' fval = '=WEIT' ).

  lcl_handle_events=>bdc_dynpro( program = 'SAPMV13D'  dynpro = cond #( when p_1 eq 'X' then '1601' else '1602' ) ).

  lcl_handle_events=>bdc_field( fnam = 'BDC_OKCODE' fval = '/00' ).
  lcl_handle_events=>bdc_field( fnam = 'KOMGD-VKORG' fval =  is_data-vkorg  ).
  lcl_handle_events=>bdc_field( fnam = 'KOMGD-VTWEG' fval = is_data-vtweg   ).

  if p_2 eq 'X'.
    lcl_handle_events=>bdc_field( fnam = 'KOMGD-KDGRP' fval = is_data-kdgrp   ).
  endif.

  lcl_handle_events=>bdc_field( fnam = 'D000-DATAB' fval = |{ is_data-datab date = user }| ).
  lcl_handle_events=>bdc_field( fnam = 'D000-DATBI'  fval = |{ is_data-datbi date = user }|  ).
  lcl_handle_events=>bdc_field( fnam = 'MV13D-SUGRV' fval = '0004').
  lcl_handle_events=>bdc_field( fnam = 'KOMGD-MATNR(01)' fval =  |{ is_data-matnr alpha = in }|  ).
  lcl_handle_events=>bdc_field( fnam = 'KONDD-SMATN(01)' fval =  |{ is_data-smatn alpha = in }|  ).
  lcl_handle_events=>bdc_field( fnam = 'KONDD-SUGRD(01)'fval = '0004' ).

  lcl_handle_events=>bdc_dynpro( program = 'SAPMV13D'  dynpro = cond #( when p_1 eq 'X' then '1601' else '1602' ) ).
  lcl_handle_events=>bdc_field( fnam = 'BDC_OKCODE' fval = '=SICH' ).


  call transaction 'VB11' using lcl_handle_events=>gt_bdctable options from l_ctu_params messages into lt_mes_tab .

  call function 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
    tables
      imt_bdcmsgcoll = lt_mes_tab
      ext_return     = lt_return.

  loop at lt_return into data(ls_data) where type eq 'E'.
    is_data-status2 = ls_data-message.
    is_data-status = '1'.
    exit.
  endloop.
  if sy-subrc ne 0.
    is_data-status = '3'.
  endif.

  refresh lcl_handle_events=>gt_bdctable[].

endform.









