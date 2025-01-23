*&---------------------------------------------------------------------*
*& Müşteri iletişim bilgileri raporu
*&
*&---------------------------------------------------------------------*
*& said.can@alfayazilim.com  19.01.2019
*&
*&---------------------------------------------------------------------*
report zbrs_musteri_iletisim.

data: gr_salv type ref to cl_salv_table.

data : begin of gt_mail occurs 0,
         addrnumber type adr6-addrnumber,
         consnumber type adr6-consnumber,
         remark     type adrt-remark,
         flgdefault type adr6-flgdefault,
         smtp_addr  type adr6-smtp_addr,
       end of gt_mail.

data : gt_out type table of zmus_iletisim_out.

data : lv_mail type char100.
data: begin of so,
        kunnr type kna1-kunnr,
        ktokd type kna1-ktokd,
        regio type kna1-regio,
      end of so.
field-symbols: <fs_data> type ref to data,
               <fs_1>    type any table,
               <fs_2>,
               <fs_3>.
selection-screen begin of block as01 with frame title text-001.
select-options: s_kunnr for so-kunnr,
                s_ktokd for so-ktokd,
                s_regio for so-regio.
parameters p_memid type char30 no-display.
selection-screen end of block as01.
***************************************

start-of-selection.
  perform get_data.

end-of-selection.
  if p_memid is not initial.
    export gt_itab from gt_out[] to memory id p_memid.
  else.
*    perform display_data.
  endif.

****************************************
form get_data.


  if p_memid is initial.
    perform get_mail.
    perform dynamic_struct. "harun.ekinci@alfayazilim.com 26.10.22
  else.
    perform get_mail.
  endif.

endform.

form display_data.
  data : lr_functions  type ref to cl_salv_functions_list,
         lr_layout     type ref to cl_salv_layout,
         lr_layout_key type salv_s_layout_key,
         lr_display    type ref to cl_salv_display_settings.

  define tanim.
    lr_column ?= lr_columns->get_column( &1 ).
    lr_column->set_medium_text( '' ).
    lr_column->set_short_text( '' ).
    lr_column->set_long_text( &2 ).
  end-of-definition.

  try.

      call method cl_salv_table=>factory
        importing
          r_salv_table = gr_salv
        changing
          t_table      = gt_out[].
*--------------------------------------------------------------------*
*change description of text column
* Get the column object
      data: lr_columns type ref to cl_salv_columns_table,
            lr_column  type ref to cl_salv_column_table,
            ls_color   type lvc_s_colo.

      lr_columns = gr_salv->get_columns( ).
      lr_columns->set_optimize( 'X' ).
*
      tanim 'TELNUMBER' 'Telefon numaraları'.
      tanim 'SMTP_ADDR' 'E-Mail adresleri'.
*--------------------------------------------------------------------*
** Get functions details
      lr_functions = gr_salv->get_functions( ).
** Activate All Buttons in Tool Bar
      lr_functions->set_all( if_salv_c_bool_sap=>true ).

******* Layout Settings  *******
      move sy-repid to lr_layout_key-report.
      "Set Report ID as Layout Key"

      lr_layout = gr_salv->get_layout( ).
      "Get Layout of Table"
      lr_layout->set_key( lr_layout_key ).
      "Set Report Id to Layout"
      lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none )
 .

      lr_layout->set_default( if_salv_c_bool_sap=>true ).

      lr_display = gr_salv->get_display_settings( ).
      lr_display->set_striped_pattern( if_salv_c_bool_sap=>true ).

      lr_display->set_list_header( 'Müşteri iletişim adres email raporu' ).

      gr_salv->display( ).

    catch cx_salv_not_found into data(lv_cx).
      message lv_cx->get_text( ) type 'E'.
  endtry.

endform.
*&---------------------------------------------------------------------*
*&      Form  DYNAMIC_STRUCT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form dynamic_struct .
  "Dynamic ALV
  data: lr_functions  type ref to cl_salv_functions_list,
        lr_layout     type ref to cl_salv_layout,
        lr_layout_key type salv_s_layout_key,
        lr_display    type ref to cl_salv_display_settings.

  data: lr_columns type ref to cl_salv_columns_table,
        lr_column  type ref to cl_salv_column_table,
        ls_color   type lvc_s_colo.

  define tanim.
    lr_column ?= lr_columns->get_column( &1 ).
    lr_column->set_medium_text( '' ).
    lr_column->set_short_text( '' ).
    lr_column->set_long_text( &2 ).
  end-of-definition.

  data: lt_data type ref to data.
  data: new_line type ref to data.
  data: lt_fieldcat type lvc_t_fcat.

  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name = 'ZMUS_ILETISIM_OUT'
    changing
      ct_fieldcat      = lt_fieldcat.

  do 60 times.
    append value #( fieldname = |SMTP_ADDR{ conv numc2( sy-index ) }|
                    inttype = 'C'
                    col_pos = sy-index + 30
                    intlen = '120'
                  ) to lt_fieldcat.
  enddo.

  assign lt_data to <fs_data>.

  call method cl_alv_table_create=>create_dynamic_table
    exporting
      it_fieldcatalog           = lt_fieldcat
    importing
      ep_table                  = <fs_data>
    exceptions
      generate_subpool_dir_full = 1
      others                    = 2.

  assign <fs_data>->* to <fs_1>.
  create data new_line like line of <fs_1>.

  assign new_line->*  to <fs_2>.

  <fs_1> = corresponding #( gt_out ).

  loop at <fs_1> assigning <fs_2>.
    assign component 'ADRNR' of structure <fs_2> to field-symbol(<fs_adrnr>).

    data(lv_say) = conv numc2( 0 ).
    loop at gt_mail into data(ls_mail) where addrnumber eq <fs_adrnr>.
      add 1 to lv_say.
      assign component |SMTP_ADDR{ conv numc2( lv_say ) }| of structure <fs_2> to field-symbol(<fs_mail>).
      <fs_mail> =  |{ ls_mail-smtp_addr  } |
                      && cond #( when ls_mail-flgdefault eq abap_true then | (Default)| else space )
                      && cond #( when ls_mail-remark ne space then | (not:{ ls_mail-remark })| else space ).
    endloop.
    unassign  <fs_adrnr>.

  endloop.

*------------------------------------------------------------------------------------------------
  try.
      call method cl_salv_table=>factory
        importing
          r_salv_table = gr_salv
        changing
          t_table      = <fs_1>[].

      lr_columns = gr_salv->get_columns( ).
      lr_columns->set_optimize( 'X' ).

      tanim : 'KUNNR'      'Müşteri',
              'LAND1'      'Ülke',
              'NAME1'      'Ad',
              'NAME2'      'Ad 2',
              'ADRNR'      'Adres',
              'ORT01'      'Kent',
              'PSTLZ'      'Posta k.',
              'REGIO'      'İl',
              'REGIOGROUP' 'Bölgesel y. grp.',
              'STREET'     'Sokak',
              'STR_SUPPL1' 'Sokak 2',
              'CITY1'      'Yerleşim yeri',
              'CITY2'      'Mahalle',
              'COUNTRY'    'BSI: Country indicator',
              'TELF1'      '1.Telefon ',
              'FAX_NUMBER' 'Faks',
              'KTOKD'      'Müşteri hsp grp.',
              'STCD1'      'Vergi 1',
              'STCD2'      'Vergi 2',
              'TELNUMBER'  'Telefon numaraları',
              'SMTP_ADDR'  'E-Mail adresleri'.

      do 60 times.
        data(lv_fieldname) = conv lvc_fname( |SMTP_ADDR{ conv numc2( sy-index ) }| ) .
        data(lv_coltext)   = conv char40( |Mail { sy-index } | ) .
        tanim : lv_fieldname  lv_coltext.

        data(lv_where) = |{ lv_fieldname } ne space| .

        loop at <fs_1> transporting no fields where (lv_where).
          exit.
        endloop.

*     "Girilen mail kadar mail sütunu görünmeli.
        if sy-subrc ne 0.
          lr_column ?= lr_columns->get_column( lv_fieldname ).
          lr_column->set_visible( abap_false ).
        endif.

      enddo.

      "Varsayılan mail adresi çakışmaması için arkaplanda gizlenir.
      lr_column ?= lr_columns->get_column( 'SMTP_ADDR' ).
      lr_column->set_visible( value = abap_false ).

*------------------------------------------------------------------------------------------------

      lr_functions = gr_salv->get_functions( ).
      lr_functions->set_all( if_salv_c_bool_sap=>true ).

      move sy-repid to lr_layout_key-report.

      lr_layout = gr_salv->get_layout( ).
      lr_layout->set_key( lr_layout_key ).
      lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none )
 .
      lr_layout->set_default( if_salv_c_bool_sap=>true ).

      lr_display = gr_salv->get_display_settings( ).
      lr_display->set_striped_pattern( if_salv_c_bool_sap=>true ).

      lr_display->set_list_header( 'Müşteri iletişim adres email raporu' ).

      gr_salv->display( ).

    catch cx_salv_not_found into data(lv_cx).
      message lv_cx->get_text( ) type 'E'.
  endtry.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_mail .

  select kna1~*,adrc~*
       from kna1
      inner join adrc on kna1~adrnr eq adrc~addrnumber
      into corresponding fields of table @gt_out
      where kunnr in @s_kunnr
        and ktokd in @s_ktokd
        and regio in @s_regio.
  if sy-subrc eq 0.
    select adr6~addrnumber, adr6~consnumber,remark,flgdefault,smtp_addr
      from adr6 left join adrt on adr6~addrnumber eq adrt~addrnumber
                              and adr6~consnumber eq adrt~consnumber
                              and adrt~comm_type eq 'INT'
      into corresponding fields of table @gt_mail
      for all entries in @gt_out
      where adr6~addrnumber eq @gt_out-adrnr
        and adr6~persnumber eq @space
        and adr6~flg_nouse eq @space.

    select adr2~addrnumber, adr2~consnumber,remark,flgdefault,tel_number,dft_receiv
     from adr2 left join adrt on adr2~addrnumber eq adrt~addrnumber
                             and adr2~consnumber eq adrt~consnumber
                             and adrt~comm_type eq 'TEL'
     into table @data(lt_tel)
     for all entries in @gt_out
     where adr2~addrnumber eq @gt_out-adrnr
      and adr2~persnumber eq @space
      and adr2~flg_nouse eq @space.

    data: lv_say  type i.
    loop at gt_out assigning field-symbol(<fs_out>).

      clear lv_say.
      loop at gt_mail into data(ls_mail)  where addrnumber eq <fs_out>-adrnr.
        if <fs_out>-smtp_addr is not initial.
          <fs_out>-smtp_addr = |{ <fs_out>-smtp_addr } / |.
        endif.

        <fs_out>-smtp_addr = |{ <fs_out>-smtp_addr } |
                          && |{ ls_mail-smtp_addr  } |
                          && cond #( when ls_mail-flgdefault eq abap_true then | (Default)| else space )
                          && cond #( when ls_mail-remark ne space then | (not:{ ls_mail-remark })| else space ).

        lv_mail  = <fs_out>-smtp_addr.
        add 1 to lv_say.

      endloop.

      if  lv_say eq 1.
        replace '(Default)'  in <fs_out>-smtp_addr with ''.
      endif.

      clear lv_say.
      loop at lt_tel into data(ls_tel) where addrnumber eq <fs_out>-adrnr.
        if <fs_out>-telnumber is not initial.
          <fs_out>-telnumber = |{ <fs_out>-telnumber } / |.
        endif.
        <fs_out>-telnumber = |{ <fs_out>-telnumber } |
                          && |{ ls_tel-tel_number }|
                          && cond #( when ls_tel-flgdefault eq abap_true then | (Default)| else space )
                          && cond #( when ls_tel-dft_receiv eq abap_true then | (Mobil)| else space )
                          && cond #( when ls_tel-remark ne space then | (not:{ ls_tel-remark })| else space ).
        add 1 to lv_say.
      endloop.
      if  lv_say eq 1.
        replace '(Default)'  in <fs_out>-telnumber with ''.
      endif.

    endloop.

  endif.
endform.