FUNCTION zeppcrm_fg026_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_OBJECT_ID) TYPE  CRMT_OBJECT_ID OPTIONAL
*"     VALUE(IV_DURUM_KODU) TYPE  CRMST_STATUS_BTIL OPTIONAL
*"  EXPORTING
*"     VALUE(EV_MESSAGE) TYPE  BAPIRET2
*"----------------------------------------------------------------------

  DATA: lr_core TYPE REF TO cl_crm_bol_core.

  DATA: ls_attr TYPE crmst_status_btil.

  CHECK iv_object_id IS NOT INITIAL.

  DATA(lr_tools_bol) = NEW zcl_crm_bol_tools( ).
  DATA(lr_adminh) = lr_tools_bol->get_oppt_btadminh( iv_object_id ).

  CHECK lr_adminh IS BOUND.

  TRY.
      DATA(lr_status_h) = lr_adminh->get_related_entity( EXPORTING iv_relation_name = 'BTHeaderStatusSet' ).

      CHECK lr_status_h IS BOUND.
      DATA(lr_current_status) = lr_status_h->get_related_entity( EXPORTING iv_relation_name = 'BTStatusHCurrent' ).

      CHECK lr_current_status IS BOUND.
      lr_current_status->get_properties(
        IMPORTING
          es_attributes = ls_attr
      ).

      ls_attr-act_status = iv_durum_kodu-status.

      lr_current_status->set_properties( ls_attr ).
      lr_core = cl_crm_bol_core=>get_instance( ).
      lr_core->modify( ).

      DATA(lr_tx) = lr_current_status->get_transaction( ).
      IF lr_tx->check_save_needed( ) EQ abap_true.
        IF lr_tx->check_save_possible( ) EQ abap_true.
          DATA(lv_success) = lr_tx->save( ).
          IF lv_success EQ abap_true.
            lr_tx->commit( ).
          ELSE.
            lr_tx->rollback( ).
          ENDIF.
        ENDIF.
      ENDIF.

    CATCH cx_crm_genil_model_error.
  ENDTRY.

  ev_message = COND #( WHEN lv_success NE abap_true THEN VALUE #( type = 'E' id = 'ZEPCRM' number = '000' message = |{ iv_object_id } Nolu Belge güncellenemedi!| )
                                                    ELSE VALUE #( type = 'S' id = 'ZEPCRM' number = '000' message = |{ iv_object_id } Nolu Belge başarılı şekilde güncellendi!| ) ).



ENDFUNCTION.