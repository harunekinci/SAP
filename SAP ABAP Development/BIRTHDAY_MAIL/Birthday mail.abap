*&---------------------------------------------------------------------*
*& Report ZDEMO_BIRTHDAY_MAIL
*&---------------------------------------------------------------------*
REPORT zdemo_birthday_mail.

CLASS lcl_birthday_mail DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS send_mail.
ENDCLASS.

CLASS lcl_birthday_mail IMPLEMENTATION.
  METHOD send_mail.
    " 1. Mime Repository'den Görseli Al
    DATA(lv_url) = '/sap/bc/bsp/sap/zhr_dogumgun/dogumgunu.jpg'.
    DATA(lo_mr_api) = cl_mime_repository_api=>if_mr_api~get_api( ).
    DATA: lv_content TYPE xstring.

    lo_mr_api->get(
      EXPORTING
        i_url              = lv_url
      IMPORTING
        e_content          = lv_content
      EXCEPTIONS
        parameter_missing  = 1
        error_occured      = 2
        not_found          = 3
        permission_failure = 4
        OTHERS             = 5
    ).
    IF sy-subrc <> 0.
      MESSAGE 'Görsel Mime Repository''de bulunamadı!' TYPE 'E'.
      RETURN;
    ENDIF.

    " 2. XSTRING'i Manuel Döngü Yerine Standart Fonksiyonla SOLIX'e Çevir
    DATA: lt_solix TYPE solix_tab,
          lv_len   TYPE i.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_content
      IMPORTING
        output_length = lv_len
      TABLES
        binary_tab    = lt_solix.

    " 3. HTML ve Görseli cl_gbt_multirelated_service ile Birleştir
    DATA(lo_mime_helper) = NEW cl_gbt_multirelated_service( ).
    DATA(lv_content_id)  = 'img_happy.jpg'.

    lo_mime_helper->add_binary_part(
      content      = lt_solix
      filename     = 'img_happy.jpg'
      extension    = 'JPG'
      description  = 'Doğum Günü Görseli'
      content_type = 'image/jpeg'
      length       = lv_len
      content_id   = lv_content_id
    ).

    " 4. HTML Body Oluştur (String Expression ve Şablon Kullanımı)
    DATA(lt_soli) = VALUE soli_tab(
      ( line = '<html><body>' )
      ( line = '<p style="font-family:Roboto,Comic Sans MS; font-size:14px; color:#333333; font-style:italic;">' )
      ( line = '<b>Dear Celebrity,</b><br><br>' )
      ( line = |<img alt="Dogum Gunu" src="cid:{ lv_content_id }" /><br><br>| )
      ( line = 'Regards,<br><b>Harun EKINCI</b></p>' )
      ( line = '</body></html>' )
    ).

    lo_mime_helper->set_main_html(
      content     = lt_soli
      filename    = 'sapwebform.htm'
      description = 'Doğum Gününüz Kutlu Olsun!'
    ).

    " 5. BCS ile Mail Gönderimi
    TRY.
        DATA(lo_bcs) = cl_bcs=>create_persistent( ).
        
        DATA(lo_doc_bcs) = cl_document_bcs=>create_from_multirelated(
          i_subject           = 'Doğum Gününüz Kutlu Olsun'
          i_multirel_service  = lo_mime_helper
        ).
        lo_bcs->set_document( lo_doc_bcs ).

        " Gönderici ve Alıcı Ayarları
        DATA(lo_sender) = cl_cam_address_bcs=>create_internet_address( 'hekinci@emlakinsaat.com.tr' ).
        lo_bcs->set_sender( lo_sender ).

        DATA(lo_recipient) = cl_cam_address_bcs=>create_internet_address( 'hekinci@emlakinsaat.com.tr' ).
        lo_bcs->add_recipient( lo_recipient ).

        " Maili Gönder
        IF lo_bcs->send( ) = abap_true.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_bcs INTO DATA(lx_bcs).
        ROLLBACK WORK.
        MESSAGE lx_bcs->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  lcl_birthday_mail=>send_mail( ).
