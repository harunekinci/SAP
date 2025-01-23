data: jant_capi type zbrs_sd_jantcapi.
at selection-screen.
    perform set_selection.

  at selection-screen  on value-request for s_jcapi-low.
    perform set_jantcapi.

  at selection-screen  on value-request for s_jcapi-high.
    perform set_jantcapi.

form set_jantcapi.

    data: begin of lt_jantcapi occurs 0,
            atflv like cawn-atflv,
          end of lt_jantcapi.

    data: begin of lt_jant occurs 0,
            jant_capi type zbrs_sd_jantcapi,
          end of lt_jant.


    data: lv_atinn  like cabn-atinn.


    select single atinn
     into lv_atinn
      from cabn
       where atnam eq 'JANT_CAPI'.

    select atflv into table lt_jantcapi
     from cawn
      where cawn~atinn  eq lv_atinn.


    loop at lt_jantcapi.
      lt_jant-jant_capi = lt_jantcapi-atflv.
      append lt_jant.
    endloop.

    call function 'F4IF_INT_TABLE_VALUE_REQUEST'
      exporting
        retfield        = 'JANT_CAPI'
        value_org       = 'S'
        dynpnr          = sy-dynnr
        dynpprog        = sy-repid
        dynprofield     = 'X'
      tables
        value_tab       = lt_jant
      exceptions
        parameter_error = 1
        no_values_found = 2
        others          = 3.

  endform.
