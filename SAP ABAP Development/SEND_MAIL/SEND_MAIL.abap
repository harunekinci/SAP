  if p_job eq abap_true and sy-batch eq abap_true.

    data(lv_filename) = conv text50( |AKSARAY_{ p_date }| ).


    zcl_sd_utils=>conv_data_to_excel(
        exporting
         it_coltext = value #(
                               ( columnname = 'AUBEL'        columntext = 'Plan no' )
                               ( columnname = 'VBELN'        columntext = 'Invoice no' )
                               ( columnname = 'FKDAT'        columntext = 'Invoice date' )
                               ( columnname = 'MATNR'        columntext = 'Sales code' )
                               ( columnname = 'MAKTX'        columntext = 'Definition' )
                               ( columnname = 'FKIMG'        columntext = 'Quantity' )
                               ( columnname = 'LANDX'        columntext = 'Country' )
                               ( columnname = 'NAME1'        columntext = 'Customer' )
                               ( columnname = 'BSJ_GRUP_TXT' columntext = 'BSG group' )
                               ( columnname = 'VTEXT4'       columntext = 'w/nw' )
                               ( columnname = 'BEZEI'        columntext = 'Region' )
                               )
*          i_addzip = abap_true " dosyayı ziple
          i_filename = lv_filename
        importing
         e_error = data(lv_error)
         et_excel = data(lt_excel)
         e_zip_size = data(lv_size)
         changing
           it_data = gt_out[] ).


    if lv_error is initial.
      zcl_simple_send_mail=>send_mail(
      exporting
        i_sender     = conv #( '<m.hizmet@brisa.com.tr>'  )
        i_sender_name = conv #( 'Brisa Bilgilendirme Servisi' )
        i_subject     = conv #( |Aksaray ürünleri ihracat verileri| )
        i_mail_group  = 'SD_AKSRY_IHR'
        t_text        = value #( ( line = |Sayın İlgili,| )
                                 ( line = || )
                                 ( line = | { lv_first_date date = user } - { lv_last_date date = user } tarihleri arası Aksaray fabrikası ürünleri ihracat adetleri ektedir.| )
                                 ( line = || )
                                 ( line = |Bilgilerinize.| )
                           )
        t_attach      = value #( ( att_title = |{ lv_filename }.xls|
                                   att_type = 'XLS'
                                   attachx = lt_excel )
                                   )   ).
    endif.
  endif.