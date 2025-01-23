data: lo_log     type ref to cl_ptu_message.

create object lo_log.

 call method lo_log->add_text
          exporting
            iv_type     = 'E'
            iv_text     = lv_text.
            "iv_cumulate = abap_true. "aynı mesajları 1 defa göster

if lo_log->has_messages( ) eq abap_true.
    call method lo_log->display_log
      exporting
        iv_as_popup      = 'X'
        iv_use_grid      = 'X'.
        iv_force_display = 'X'.
endif.
