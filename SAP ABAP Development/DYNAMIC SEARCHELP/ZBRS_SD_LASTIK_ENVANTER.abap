report zbrs_sd_lastik_envanter.
*&---------------------------------------------------------------------*
*& Report ZBRS_SD_LASTIK_ENVANTER
*&---------------------------------------------------------------------*
*& harun.ekinci@alfayazilim.com
*&---------------------------------------------------------------------*

tables: sscrfields.

data : gt_data       type table of zbrssd0640,
       gr_werks      type range of vapma-werks,
       gr_lgort      type range of vbap-lgort,
       gr_mtart      type range of mara-mtart,
       gr_selections type ref to cl_salv_selections,
       gt_ftext      type smp_dyntxt.
data: begin of so,
        matnr     type mara-matnr,
        mtart     type mara-mtart,
        kondm     type mvke-kondm,
        tyre      type zbrsmmtyre-tyre,
        mevsim    type zbrs_sd_kullanim_kod,
        grup      type mvke-mvgr2,
        jant_capi type zbrs_sd_jantcapi,
        bsg_grup  type zbrsch_vbsg_grup,
      end of so.

ranges : gr_mvgr5 for mvke-mvgr5,
         gr_bsg_matnr for mara-matnr.

data lv_at_bsg_grup type cawn-atinn value 'BSG_GRUP'.

selection-screen begin of block 1.
select-options :  s_matnr   for so-matnr,
                  s_mtart   for so-mtart,
                  s_kondm   for so-kondm,
                  s_tyre    for so-tyre,
                  s_mevsim  for so-mevsim,
                  s_grup    for so-grup,
                  s_jcapi   for so-jant_capi,
                  s_bsggr   for so-bsg_grup matchcode object zbrsmm_bsg_grup.

parameters:     p_ebat  type bezei40 visible length 20,
                p_vkorg type vkorg, "matchcode object c_vkorg
                p_memid type text60 no-display.
selection-screen end of block 1.

class lcl_handle_events definition deferred.
data: gr_salv   type ref to cl_salv_table,
      gr_events type ref to lcl_handle_events.

class lcl_handle_events definition.
  public section.
    methods:
      on_link_click for event link_click
                    of cl_salv_events_table
        importing row column,

      on_user_command for event added_function of cl_salv_events "toolbar button user command
        importing e_salv_function .

endclass. "lcl_handle_events DEFINITION

class lcl_handle_events implementation.
  method on_link_click.
    perform link_click using row column.
  endmethod.
  method on_user_command.
    case e_salv_function.
      when 'DISP'.
        perform display_0140.
      when others.
    endcase.
  endmethod.
endclass. "lcl_handle_events IMPLEMENTATION

"Seçim ekranı button
define functionkey.
  gt_ftext-icon_id   = &1.
  gt_ftext-quickinfo = &2.
  gt_ftext-icon_text = &3.
  &4 = gt_ftext.
end-of-definition.

selection-screen function key : 1 , 2 , 3 , 4 , 5 .

initialization.
  perform init.

at selection-screen.
  perform set_selection.

at selection-screen  on value-request for s_jcapi-low.
  perform set_jantcapi.

at selection-screen  on value-request for s_jcapi-high.
  perform set_jantcapi.

at selection-screen  on value-request for s_mtart-low.
  perform set_mtart.

at selection-screen  on value-request for s_mtart-high.
  perform set_mtart.

at selection-screen  on value-request for s_kondm-low.
  perform set_kondm.

at selection-screen  on value-request for s_kondm-high.
  perform set_kondm.

at selection-screen output.
  perform get_html_viewer.

start-of-selection.
  perform  get_data.

end-of-selection.

  if p_memid is not initial.
    data: lt_data type table of zbrssd0640.
    lt_data = corresponding #( gt_data[] ).
    export itab from lt_data to memory id p_memid.
  else.
    perform  display_data.
  endif.
*&---------------------------------------------------------------------*
*&      Form  LINK_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW  text
*      -->P_COLUMN  text
*----------------------------------------------------------------------*
form link_click  using    p_row
                          p_column.
  assign component p_column of structure gt_data[ p_row ] to field-symbol(<fs_matnr>).
  check <fs_matnr> is assigned.
  set parameter id 'MAT' field <fs_matnr>.
  call transaction 'MM03' and skip first screen.
  unassign <fs_matnr>.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_data .

  data: lr_prodh4t type range of zbrssd0640-prodh4t,
        lr_matnr   type range of mara-matnr.

  "ebat tanım
  if p_ebat is not initial.
    data(lv_ebat) =  |{ p_ebat }%| .
    condense lv_ebat no-gaps.

    select distinct mvgr5 as low, 'I' as sign, 'EQ' as option
      from tvm5t
      where bezei like @lv_ebat
       and spras eq @sy-langu
      into corresponding fields of table @gr_mvgr5[].

    if gr_mvgr5[] is initial.
      exit.
    endif.
  endif.

  select single atinn into lv_at_bsg_grup
         from cabn where atnam eq 'BSG_GRUP'.

  select * from zbrssd0705 into table @data(lt_prod_gro).

  if s_bsggr[] is not initial.

    select distinct ausp~objek as low  , 'I' as sign , 'EQ' as option
      into corresponding fields of table @gr_bsg_matnr[]
      from mara
     inner join ausp     on    ausp~objek eq mara~matnr      and
                               ausp~atinn eq @lv_at_bsg_grup and
                               ausp~mafid eq 'O'             and
                               ausp~klart eq '001'
     left outer join cawn as c on c~atinn = @lv_at_bsg_grup  and
                                c~atwrt = ausp~atwrt
     left outer join cawnt as ct on ct~atinn = c~atinn       and
                                  ct~atzhl = c~atzhl         and
                                  ct~spras = @sy-langu
                                where mara~mtart in @s_mtart and
                                      c~atwrt    in @s_bsggr and
                                      mara~matnr in @s_matnr.

  endif.

  perform get_urun_list.
  perform get_0070_data.
  perform get_0397_data.
  perform get_0621_data.
  perform get_va25_data.
  perform get_0141_data.
  perform get_cubic_lock.
  perform get_bloke.

*    jant çapi verisi
  data(lt_jant)     = zcl_sd_utils=>get_characteristic_values( it_data = gt_data[]
                                                               i_atnam = 'JANT_CAPI' ).
  "kullanım
  data(lt_kullanim) = zcl_sd_utils=>get_characteristic_values( it_data = gt_data[]
                                                               i_atnam = 'KULLANIM'  ).
* Son toplamlar alınır
  loop at s_mevsim into data(ls_mevsim).
    data(lv_low)  = value #( lt_kullanim[ atwrt  = ls_mevsim-low ]-atwtb optional ).
    data(lv_high) = value #( lt_kullanim[ atwrt  = ls_mevsim-high ]-atwtb optional ).
    append value #( sign = ls_mevsim-sign option = ls_mevsim-option low = lv_low  high = lv_high ) to lr_prodh4t[].
    clear: lv_low, lv_high.
  endloop.

  "ikame
  select distinct matnr, smatn from kotd601
    inner join kondd on kondd~knumh eq kotd601~knumh
    into table  @data(lt_ikame)
    where matnr in @s_matnr
     and kappl eq 'V'
     and kschl eq 'BMZB'
     and datbi >= @sy-datum
     and datab <= @sy-datum.

  "üretim kodu
  select smatn , pmatn
    from zbrspp0001
    into table @data(lt_pmatn)
    where smatn not like '%HH'.

  "muadil için ikameye mi bakılacak üretim koduna mı ?
  select * from zbrssd0655 into table @data(lt_zbrssd0655).


  loop at gt_data assigning field-symbol(<fs_data>).

    if <fs_data>-kondm eq 'BG'.
      continue.
    endif.
    perform get_stok using <fs_data>-matnr changing <fs_data>-sat_s.

    <fs_data>-prodh4t   = value #( lt_kullanim[ matnr = <fs_data>-matnr ]-atwtb optional ).

    <fs_data>-jant_capi = conv dec07( value #( lt_jant[ matnr = <fs_data>-matnr ]-atflv optional ) ).

    <fs_data>-prodgro  = value #( lt_prod_gro[ bsg_grup = <fs_data>-bsg_grup ]-prodgro optional ).
    <fs_data>-prod_imp = switch #( <fs_data>-mtart when 'FERT' or 'HRDF' then 'PRODUCTION'
                                                   when 'HAWA' or 'HRDH' then 'IMPORT' ).

    <fs_data>-top_teyit = <fs_data>-onayexp + <fs_data>-onayoe + <fs_data>-onayrl + <fs_data>-onayot +
                          <fs_data>-teslexp + <fs_data>-tesloe + <fs_data>-teslot + <fs_data>-teslrl .

    <fs_data>-top_opsy = <fs_data>-opsetic + <fs_data>-opsoe  + <fs_data>-opsrl.

    <fs_data>-top_stok = <fs_data>-top_teyit + <fs_data>-sat_s + <fs_data>-bloke + <fs_data>-top_opsy.

    data(lv_matnr)        = conv matnr( |{ <fs_data>-matnr alpha = out }| ).
    data(lv_muadil_secim) = value #( lt_zbrssd0655[ matnr_ilk = lv_matnr(1) matnr_son = lv_matnr+6 ]-muadil optional ).

    case lv_muadil_secim.
      when '1'.
        "ikamenin stoğu var mı
        data lv_stok type zmiktar.
        data(lv_ikame) = value #( lt_ikame[ matnr = <fs_data>-matnr ]-smatn optional ).

        if s_mtart[]   is not initial or s_kondm[] is not initial or s_tyre[] is not initial or
           lr_prodh4t  is not initial or s_grup[]  is not initial.

          "filtreler girilince stoğu olanlar gelecek, filtre girilmezse stoğu olan olmayan hepsi gelecek.
          perform get_stok using lv_ikame changing lv_stok.
          if lv_stok > 0.
            <fs_data>-muadil = |{ <fs_data>-muadil } { lv_ikame alpha = out }| .
            if lv_ikame cs 'AP'.
              append value #( sign = 'I' option = 'EQ' low = lv_ikame ) to lr_matnr.
            endif.
          endif.

        else.
          <fs_data>-muadil = |{ <fs_data>-muadil } { lv_ikame alpha = out }| .
          if lv_ikame cs 'AP'.
            append value #( sign = 'I' option = 'EQ' low = lv_ikame ) to lr_matnr.
          endif.
        endif.

      when '2'. "üretim kodu
        loop at lt_pmatn into data(ls_pmatn) where pmatn = value #( lt_pmatn[ smatn = <fs_data>-matnr ]-pmatn optional ) and smatn ne <fs_data>-matnr.
          clear lv_stok.

          if s_mtart[]  is not initial or s_kondm[] is not initial or s_tyre[] is not initial or
             lr_prodh4t is not initial or s_grup[]  is not initial.

            "filtreler girilince stoğu olanlar gelecek, filtre girilmezse stoğu olan olmayan hepsi gelecek.
            perform get_stok using ls_pmatn-smatn changing lv_stok.

            if lv_stok > 0.
              <fs_data>-muadil = |{ <fs_data>-muadil } { ls_pmatn-smatn alpha = out }|.
              if ls_pmatn-smatn cs 'AP'.
                append value #( sign = 'I' option = 'EQ' low = ls_pmatn-smatn ) to lr_matnr.
              endif.
            endif.

          else.
            <fs_data>-muadil = |{ <fs_data>-muadil } { ls_pmatn-smatn alpha = out }| .
            if ls_pmatn-smatn cs 'AP'.
              append value #( sign = 'I' option = 'EQ' low = ls_pmatn-smatn ) to lr_matnr.
            endif.
          endif.
        endloop.
    endcase.

    <fs_data>-sat_a = <fs_data>-sat_s -  <fs_data>-ihr_b - <fs_data>-yen_b.

  endloop.
  case p_vkorg.
    when 'RL'.
      delete gt_data[] where kota_rl eq 0.
    when 'OE'.
      delete gt_data[] where kota_oe eq 0.
    when 'EXP'.
      delete gt_data[] where kota_exp eq 0.
  endcase.

  "Muadil tarafında AP'li kod olanlarda, AP'li kod un muadilinde de 00'lı kod yazsın
  loop at gt_data assigning <fs_data>.

    if <fs_data>-matnr in lr_matnr[].
      <fs_data>-muadil = |{ <fs_data>-muadil } { value #( lt_ikame[ smatn = <fs_data>-matnr ]-matnr optional ) alpha = out }|.
    endif.

    split <fs_data>-muadil at space into table data(lt_split).
    clear <fs_data>-muadil.
    loop at lt_split into data(lv_split) where table_line cp '*00'.
      <fs_data>-muadil = |{ <fs_data>-muadil } { lv_split }|.
    endloop.
    loop at lt_split into lv_split where table_line cp '*AP'.
      <fs_data>-muadil = |{ <fs_data>-muadil } { lv_split }|.
    endloop.
    loop at lt_split into lv_split where ( table_line np '*AP' and table_line np '*00' ).
      <fs_data>-muadil = |{ <fs_data>-muadil } { lv_split }|.
    endloop.
    refresh lt_split.
  endloop.

  "filtreler girilince stoğu olanlar gelecek, filtre girilmezse stoğu olan olmayan hepsi gelecek.
  if s_mtart[]  is not initial or s_kondm[] is not initial or s_tyre[] is not initial or
     lr_prodh4t is not initial or s_grup[]  is not initial.
    delete gt_data[] where sat_s eq 0 and muadil is initial.
  endif.

  delete gt_data[] where top_stok eq 0 and muadil is initial.
  delete gt_data[] where prodh4t  not in lr_prodh4t[] or jant_capi not in s_jcapi[].

endform.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_data.
  data: lr_column     type ref to cl_salv_column_table,
        lo_selections type ref to cl_salv_selections,
        lo_columns    type ref to cl_salv_columns_table,
        lv_text       type char10,
        lr_layout     type ref to cl_salv_layout,
        lr_layout_key type salv_s_layout_key,
        lr_display    type ref to cl_salv_display_settings,
        lo_h_header   type ref to cl_salv_form_layout_grid.


  try.

      call method cl_salv_table=>factory
        importing
          r_salv_table = gr_salv
        changing
          t_table      = gt_data[].

      data(lr_columns) = gr_salv->get_columns( ).

      define tanim.
        lr_column ?= lr_columns->get_column( &1 ).
        lr_column->set_medium_text( '' ).
        lr_column->set_short_text( '' ).
        lr_column->set_long_text( &2 ).
      end-of-definition.

      define color.
        lr_column ?= lr_columns->get_column( &1 ).
        lr_column->set_color( value #( col = &2  int = &3 ) ).
      end-of-definition.


      lo_columns = gr_salv->get_columns( ).
      lo_columns->set_optimize( ).

      tanim: 'PROD_IMP' 'PROD/IMP',
             'SAT_S' 'SAT STOK',
             'IHR_B' 'IHRC BAK',
             'YEN_B' 'YEN BAK',
             'SAT_A' 'Bakiye Çıkartılmış SAT STOK',
             'RL' 'RL',
             'EXP' 'EXP',
             'OE' 'OE',
             'OT' 'O/T',
             'AGED' 'AGED',
             'PRODGRO' 'PROD GRO',
             'ONAYEXP' 'ONAY-EXP',
             'ONAYOE' 'ONAY-OE',
             'ONAYRL' 'ONAY-RL',
             'ONAYOT' 'ONAY-OT',
             'TESLEXP' 'TESL-EXP',
             'TESLOE' 'TESL-OE',
             'TESLOT' 'TESL-OT',
             'TESLRL' 'TESL-RL',
             'OPSOE' 'OPS-OE',
             'OPSETIC' 'OPS-E-TIC',
             'OPSRL' 'OPS-RL',
             'TOP_OPSY' 'OPS-TOPLAM',
             'KOTA_RL' 'RL kalan kota',
             'KOTA_EXP' 'EXP kalan kota',
             'KOTA_OE' 'OE kalan kota',
             'BLOKE' ' Bloke stok',
             'CUBICLOCK' 'Cubic lock',
             'TOP_TEYIT' 'Toplam teyit',
             'TOP_STOK'  'Toplam stok',
             'MUADIL' 'Muadil'.

      color: 'MATNR' '5' '0',
             'MAKTX' '5' '0',
             'MTART' '5' '0',
             'KONDM' '5' '0',
             'TYRE'  '5' '0',
             'PRODH4T' '5' '0',
             'MVGR2' '5' '0',
             'PROD_IMP' '5' '0',
             'SAT_S' '5' '0',
             'IHR_B' '5' '0',
             'YEN_B' '5' '0',
             'KOTA_RL' '6' '0',
             'KOTA_EXP' '6' '0',
             'KOTA_OE' '6' '0',
             'RL' '7' '0',
             'EXP' '7' '0',
             'OE' '7' '0',
             'OT' '7' '0',
             'AGED' '7' '0',
             'PRODGRO' '7' '0',
             'ONAYEXP' '3' '0',
             'ONAYOE' '3' '0',
             'ONAYRL' '3' '0',
             'ONAYOT' '3' '0',
             'TESLEXP' '7' '1',
             'TESLOE' '7' '1',
             'TESLOT' '7' '1',
             'TESLRL' '7' '1',
             'OPSOE' '2' '0',
             'OPSETIC' '2' '0',
             'OPSRL' '2' '0',
             'TOP_TEYIT' '1' '0',
             'TOP_STOK' '4' '0'.

      create object gr_events.
      data(lr_events) = gr_salv->get_event( ).
      lr_columns->set_optimize( 'X' ).

      set handler gr_events->on_link_click   for lr_events.
      set handler gr_events->on_user_command for lr_events.

      define hotspot.
        lr_column ?= lr_columns->get_column( &1 ).
        call method lr_column->set_cell_type
          exporting
            value = if_salv_c_cell_type=>hotspot.
      end-of-definition.

      hotspot: 'MATNR'.
      lr_columns->set_optimize('X').
      data(lr_functions) = gr_salv->get_functions( ).
      lr_functions->set_all( if_salv_c_bool_sap=>true ).
      gr_salv->set_screen_status(
        exporting
          report        =   sy-repid
          pfstatus      =   'ZSTATUS'
          set_functions =   gr_salv->c_functions_all ).

      data(lv_lines) = lines( gt_data ).
      write lv_lines to lv_text left-justified.
*Header
      create object lo_h_header.
      lo_h_header->create_label( row = 1 column = 1 )->set_text( 'Bulunan malzeme sayısı:'(003) ).
      lo_h_header->create_text( row = 1 column = 2 )->set_text( lv_text ).
      lo_h_header->create_label( row = 2  column = 1 )->set_text( 'Kullanıcı:'(003) ).
      lo_h_header->create_text( row = 2 column = 2 )->set_text( sy-uname ).

      gr_salv->set_top_of_list( lo_h_header ).
      gr_salv->set_top_of_list_print( lo_h_header ).

*        lo_selections = gr_salv->get_selections( ).
*        lo_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ) .

      move sy-repid to lr_layout_key-report.
      lr_layout = gr_salv->get_layout( ).
      lr_layout->set_key( lr_layout_key ).
      lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      lr_layout->set_default( if_salv_c_bool_sap=>true ).
      lr_display = gr_salv->get_display_settings( ).
      lr_display->set_striped_pattern( if_salv_c_bool_sap=>true ).
*        -----------------------------------------------------------------

      gr_selections = gr_salv->get_selections( ).
      gr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).


      gr_salv->display( ).
*        -----------------------------------------------------------------
    catch cx_salv_msg into data(lv_cx_msg).
      message lv_cx_msg type 'E'.
    catch cx_salv_not_found into data(lv_cx_found).
      message lv_cx_found type 'E'.
    catch cx_root into data(lv_cx_root).
      message lv_cx_root type 'E'.
  endtry.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_0070_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_0070_data .

  types :  begin of type_bakiye,
             bayi_b     type vbap-kwmeng,
             filo_b     type vbap-kwmeng,
             dm_b       type vbap-kwmeng,
             diger_b    type vbap-kwmeng,
             europe_b   type vbap-kwmeng,
             others_b   type vbap-kwmeng,
             satis_stok type retme,
           end of type_bakiye.

  data: ls_type      type type_bakiye,
        lr_vkbur_oth type range of knvv-vkbur,
        lr_vkbur_eur type range of knvv-vkbur.

  data(date) = sy-datum.
  data(last) = conv datum( date - 365 ).

  lr_vkbur_eur =  value #( sign = 'I' option = 'EQ'   ( low = '6000' )
                                                      ( low = '6100' )
                                                      ( low = '6200' ) ).

  lr_vkbur_oth =  value #( sign = 'I' option = 'EQ'   ( low = '6500' )
                                                      ( low = '7000' ) ).

  select distinct
         vapma~vbeln,
         vapma~posnr,
         vapma~matnr,
         makt~maktx,
         vapma~auart,
         vapma~vkorg,
         vapma~vtweg,
         vapma~werks,
         vbak~vkbur,
         mvke~mvgr2,
         mvke~kondm,
         mara~mtart,
         tyre,
        ( vbap~kwmeng - vbap~kbmeng ) as bakiye_miktari
       from vapma inner join vbak on vapma~vbeln eq vbak~vbeln
                  inner join vbap on vapma~vbeln eq vbap~vbeln
                                 and vapma~posnr eq vbap~posnr
                  inner join mara on mara~matnr eq vbap~matnr
                  left join makt on mara~matnr eq makt~matnr and makt~spras eq 'T'
                  left join zbrsmmtyre on zbrsmmtyre~matkl eq mara~matkl
                  left join mvke on mvke~matnr = vapma~matnr
                                and mvke~vkorg = vapma~vkorg
                                and mvke~vtweg = vapma~vtweg
         into table @data(lt_0070)
          where vapma~matnr in @s_matnr
           and vapma~matnr in @gr_bsg_matnr
           and vapma~trvog eq 0
           and vbtyp ne 'H'
           and vbap~kwmeng > vbap~kbmeng
           and vbap~abgru eq @space
           and lgort in @gr_lgort
           and vapma~werks in @gr_werks
           and ( vapma~audat > @last and vapma~audat <= @date )
           and mtart in @gr_mtart
           and mtart in @s_mtart
           and mvke~kondm in @s_kondm
           and mvke~mvgr2 in @s_grup
           and mvke~mvgr5 in @gr_mvgr5
           and vbap~kondm ne 'BG'
           and tyre in @s_tyre.

  loop at lt_0070 into data(ls_0070) group by ( matnr = ls_0070-matnr ).
    assign gt_data[ matnr = ls_0070-matnr ] to field-symbol(<fs_data>).
    if <fs_data> is not assigned.
      append initial line to gt_data assigning <fs_data>.
      <fs_data> = corresponding #( ls_0070 ).
    endif.

    <fs_data>-aged = cond #( when ls_0070-matnr cp '*HH*' or ls_0070-matnr cp '*AH*' then 'AGED' else 'NONAGED' ) .

    loop at group ls_0070 into data(ls_line).
      if ( ls_line-vkorg eq 'EXP' or ls_line-vkorg eq 'EXSA' )  and
         ( ls_line-vtweg ne 'OT' ) and
         ( ls_line-vkbur in lr_vkbur_eur or ls_line-vkbur in lr_vkbur_oth ).
        <fs_data>-ihr_b = <fs_data>-ihr_b + ls_line-bakiye_miktari.
      endif.
      if ls_line-vtweg eq 'BY' or
         ls_line-vtweg eq 'FL' or
         ls_line-vtweg eq 'DM' or
         ( ( ls_line-vkorg eq 'RL' or ls_line-vkorg eq 'OTR' or ls_line-vkorg eq 'OE' ) and
           ( ls_line-vtweg ne 'BY' and ls_line-vtweg ne 'OE' and ls_line-vtweg ne 'FL' and ls_line-vtweg ne 'DM' )
         ).
        <fs_data>-yen_b = <fs_data>-yen_b + ls_line-bakiye_miktari.
      endif.
      <fs_data>-prodgro  =  switch #( ls_line-mvgr2  when 'AGL' or 'ORR' or 'ORS' then 'AGL'
                                                     when 'AGR' or 'AGT' or 'ARS' or 'ARL' then 'AGR'
                                                     when 'AGS' then 'SMALL BIAS'
                                                     when 'SLP' or 'IND' or 'MCR' or 'MCS' or 'ORN' or 'OTF' or 'OTU' or 'TUB' or 'FLP' then 'OTHERS'
                                                     when 'LTS' or 'LVR' or 'PSR' then 'PSR-LVR'
                                                     when 'TBR' then 'TBR'
                                                     when 'LSR' then 'LSR ALL' ).
    endloop.
  endloop.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_0397_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_0397_data .

  select vbbe~matnr, mtart, makt~maktx, tyre, vbak~vkorg, vbak~vtweg, sum( vmeng ) as menge
           from vbbe
           inner join vbak on vbbe~vbeln eq vbak~vbeln
           inner join mvke on mvke~matnr eq vbbe~matnr and
                              mvke~vkorg eq vbak~vkorg and
                              mvke~vtweg eq vbak~vtweg
           inner join mara on mara~matnr eq vbbe~matnr
           inner join makt on makt~matnr eq mara~matnr and spras eq 'T'
           left join zbrsmmtyre on zbrsmmtyre~matkl eq mara~matkl
           into table @data(lt_vbbe)
          where vbbe~vbtyp eq 'C'
            and vbbe~matnr in @s_matnr
            and vbbe~matnr in @gr_bsg_matnr
            and mtart  in @gr_mtart
            and mtart  in @s_mtart
            and werks  in @gr_werks
            and lgort  in @gr_lgort
            and mara~spart ne 'BG'
            and vmeng > 0
            and mvke~kondm in @s_kondm
            and tyre in @s_tyre
            and mvke~mvgr2 in @s_grup
            and mvke~mvgr5 in @gr_mvgr5
  group by vbbe~matnr, mtart, maktx, tyre, vbak~vkorg, vbak~vtweg.

  loop at lt_vbbe into data(ls_vbbe).
    assign gt_data[ matnr = ls_vbbe-matnr ] to field-symbol(<fs_out>).
    if <fs_out> is not assigned.
      append initial line to gt_data assigning <fs_out>.
      <fs_out>-matnr = ls_vbbe-matnr.
    endif.
    <fs_out>-aged = cond #( when ls_vbbe-matnr cp '*HH*' or ls_vbbe-matnr cp '*AH*' then 'AGED' else 'NONAGED' ) .
    <fs_out>-mtart = ls_vbbe-mtart.
    <fs_out>-maktx = ls_vbbe-maktx.
    <fs_out>-tyre = ls_vbbe-tyre.

    if ( ls_vbbe-vkorg eq 'EXP' and ls_vbbe-vtweg eq 'OE' ) or ls_vbbe-vkorg eq 'OE'.
      <fs_out>-onayoe = <fs_out>-onayoe + ls_vbbe-menge.
    elseif ls_vbbe-vkorg eq 'EXP' and ls_vbbe-vtweg eq 'OT'.
      <fs_out>-onayot = <fs_out>-onayot + ls_vbbe-menge.
    elseif ls_vbbe-vkorg eq 'EXP'.
      <fs_out>-onayexp = <fs_out>-onayexp + ls_vbbe-menge.
    elseif ls_vbbe-vkorg eq 'RL'.
      <fs_out>-onayrl = <fs_out>-onayrl + ls_vbbe-menge.
    endif.

    unassign <fs_out>.
  endloop.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_0621_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_0621_data .

  data: lr_vkorg type range of vbak-vkorg.

  lr_vkorg[] = value #( sign = 'I' option = 'EQ' ( low = 'RL' ) ( low = 'EXP' ) ( low = 'OE' ) ).

  select lips~matnr, lips~mtart, maktx, tyre, likp~vkorg, lips~vtweg, sum( lfimg ) as menge
    from lips
    inner join likp on likp~vbeln eq lips~vbeln
    inner join mvke on mvke~matnr eq lips~matnr and
                       mvke~vkorg eq likp~vkorg and
                       mvke~vtweg eq lips~vtweg
    inner join vbup on likp~vbeln eq vbup~vbeln
                   and lips~posnr eq vbup~posnr
    inner join makt on makt~matnr eq lips~matnr and spras eq 'T'
    left join zbrsmmtyre on zbrsmmtyre~matkl eq lips~matkl
       into table @data(lt_lips)
      where likp~vbtyp eq 'J'
        and lips~vgtyp in ('C','I','V') "Sipariş  ve hibe satınalma teslimatı
        and vbup~wbsta ne 'C' "mal hareketi olmamalı
        and lgort in @gr_lgort
        and likp~vkorg in @lr_vkorg
        and lips~matnr in @s_matnr
        and lips~matnr in @gr_bsg_matnr
        and lips~mtart in @gr_mtart
        and lips~mtart in @s_mtart
        and lips~spart ne 'BG'
        and mvke~kondm in @s_kondm
        and mvke~mvgr2 in @s_grup
        and mvke~mvgr5 in @gr_mvgr5
        and tyre in @s_tyre
  group by lips~matnr, lips~mtart, maktx, tyre, likp~vkorg, lips~vtweg.

  loop at lt_lips into data(ls_lips).
    assign gt_data[ matnr = ls_lips-matnr ] to field-symbol(<fs_out>).
    if <fs_out> is not assigned.
      append initial line to gt_data assigning <fs_out>.
      <fs_out>-matnr = ls_lips-matnr.
    endif.
    <fs_out>-aged = cond #( when ls_lips-matnr cp '*HH*' or ls_lips-matnr cp '*AH*' then 'AGED' else 'NONAGED' ) .
    <fs_out>-maktx = ls_lips-maktx.
    <fs_out>-mtart = ls_lips-mtart.
    <fs_out>-tyre = ls_lips-tyre.

    if ( ls_lips-vkorg eq 'EXP' and ls_lips-vtweg eq 'OE' ) or ls_lips-vkorg eq 'OE'.
      <fs_out>-tesloe = <fs_out>-tesloe + ls_lips-menge.
    elseif ls_lips-vkorg eq 'EXP' and ls_lips-vtweg eq 'OT'.
      <fs_out>-teslot = <fs_out>-teslot + ls_lips-menge.
    elseif ls_lips-vkorg eq 'EXP'.
      <fs_out>-teslexp = <fs_out>-teslexp + ls_lips-menge.
    elseif ls_lips-vkorg eq 'RL'.
      <fs_out>-teslrl = <fs_out>-teslrl + ls_lips-menge.
    endif.
    unassign <fs_out>.
  endloop.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_VA25_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_va25_data .

  data: lv_begda type sy-datum.

  call function 'MONTH_PLUS_DETERMINE'
    exporting
      months  = -1
      olddate = sy-datum
    importing
      newdate = lv_begda.

  select vbbe~matnr, mtart, maktx, tyre, vbak~vkorg, vbak~vtweg, sum( vmeng ) as bmeng
         from vbbe
         inner join vbak on vbbe~vbeln eq vbak~vbeln
         inner join mvke on mvke~matnr eq vbbe~matnr and
                            mvke~vkorg eq vbak~vkorg and
                            mvke~vtweg eq vbak~vtweg
         inner join mara on vbbe~matnr eq mara~matnr
         inner join makt on makt~matnr eq mara~matnr and spras eq 'T'
         left join zbrsmmtyre on zbrsmmtyre~matkl eq mara~matkl
         into table @data(lt_ops)
        where vbbe~auart in ('OPSY','EOPS')
          and vbak~vkorg in ('RL','OE')
          and vbbe~matnr in @s_matnr
          and vbbe~matnr in @gr_bsg_matnr
          and vbak~trvog eq '2'
          and angdt <= @sy-datum
          and bnddt >= @lv_begda
          and mara~spart ne 'BG'
          and mara~mtart in @s_mtart
          and mvke~kondm in @s_kondm
          and mvke~mvgr2 in @s_grup
          and mvke~mvgr5 in @gr_mvgr5
          and tyre in @s_tyre
  group by vbbe~matnr, mtart, maktx, tyre, vbak~vkorg, vbak~vtweg.

  loop at lt_ops into data(ls_ops).
    assign gt_data[ matnr = ls_ops-matnr ] to field-symbol(<fs_out>).
    if <fs_out> is not assigned.
      append initial line to gt_data assigning <fs_out>.
      <fs_out>-matnr = ls_ops-matnr.
    endif.
    <fs_out>-aged = cond #( when ls_ops-matnr cp '*HH*' or ls_ops-matnr cp '*AH*' then 'AGED' else 'NONAGED' ) .
    <fs_out>-maktx = ls_ops-maktx.
    <fs_out>-mtart = ls_ops-mtart.
    <fs_out>-tyre = ls_ops-tyre.

    if ls_ops-vkorg eq 'RL' and ls_ops-vtweg eq 'ET'.
      <fs_out>-opsetic = <fs_out>-opsetic + ls_ops-bmeng.
    elseif ls_ops-vkorg eq 'RL'.
      <fs_out>-opsrl = <fs_out>-opsrl + ls_ops-bmeng.
    elseif ls_ops-vkorg eq 'OE'.
      <fs_out>-opsoe = <fs_out>-opsoe + ls_ops-bmeng.
    endif.
    unassign <fs_out>.
  endloop.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_URUN_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_urun_list .
  data lr_wa_dyn_table type ref to data.
  field-symbols: <fs_itab> type standard table,
                 <wa_itab> type any.

  data: begin of lt_pivot occurs 0,
          matnr type mara-matnr,
          rl    type i,
          exp   type i,
          oe    type i,
          ot    type i,
        end of lt_pivot.

  types: begin of ty_mvke,
           matnr type mvke-matnr,
           kondm type mvke-kondm,
           mvgr2 type mvke-mvgr2,
           mtart type mara-mtart,
           tyre  type zbrsmmtyre-tyre,
           maktx type makt-maktx,
         end of ty_mvke.
  data: lt_mvke type sorted table of ty_mvke with non-unique key matnr.

  types: begin of ty_bsg,
           matnr type mara-matnr,
           atwrt type cawn-atwrt,
           atwtb type cawnt-atwtb,
         end of ty_bsg.
  data: lt_bsg type sorted table of ty_bsg with non-unique key matnr.

  select single variant from varid into @data(lv_variant) where report eq 'ZBRS_URUN_LISTESI'
  and variant eq 'ENVANTER'.
  if lv_variant is initial.
    message 'ZBRSSD0306 raporunda ENVANTER varyantı bulunamadı. Veriler okunamadı!' type 'I' display like 'W'.
    return.
  endif.


  cl_salv_bs_runtime_info=>set( display  = abap_false
                                metadata = abap_true
                                data     = abap_true ).

  if gr_bsg_matnr[] is initial and s_matnr is not initial.
    gr_bsg_matnr[] = s_matnr[].
  endif.

  submit zbrs_urun_listesi
  with s_matnr in gr_bsg_matnr[]
  with s_mtart in s_mtart[]
  with s_kondm in s_kondm[]
  with s_mvgr2 in s_grup[]
  with s_mvgr5 in gr_mvgr5[]
  using selection-set lv_variant and return.

  try.
      cl_salv_bs_runtime_info=>get_data_ref( importing r_data = data(lr_data) ).
      cl_salv_bs_runtime_info=>get_metadata( receiving value  = data(ls_md) ).

      assign lr_data->* to <fs_itab>.
      lt_pivot[] = corresponding #( <fs_itab> ).
      if gr_bsg_matnr[] is not initial.
        delete lt_pivot where matnr not in gr_bsg_matnr[].
      endif.

    catch cx_salv_bs_sc_runtime_info into data(lr_ealv).
      message lr_ealv type 'E'.
  endtry.
  cl_salv_bs_runtime_info=>clear_all( ).

  select distinct mvke~matnr, mvke~kondm, mvke~mvgr2, mara~mtart, tyre, maktx
    from mvke
    inner join mara on mara~matnr eq mvke~matnr
    left join makt on makt~matnr = mvke~matnr and makt~spras eq 'T'
    left join zbrsmmtyre on zbrsmmtyre~matkl eq mara~matkl
    into table @lt_mvke
    where mvke~matnr  in @s_matnr
     and mvke~matnr  in @gr_bsg_matnr
     and mvke~kondm  in @s_kondm
     and mvke~mvgr2  in @s_grup
     and mvke~mvgr5  in @gr_mvgr5
     and mara~mtart  in @s_mtart
     and vkorg       in ('RL','EXP','OE')
     and tyre        in @s_tyre.

  if lt_pivot[] is not initial.
    select distinct ausp~objek as matnr , ausp~atwrt , ct~atwtb
    from mara
    inner join ausp on ausp~objek = mara~matnr        and
                        ausp~atinn eq @lv_at_bsg_grup and
                        ausp~mafid eq 'O'             and
                        ausp~klart eq '001'
    left outer join  cawn as c  on c~atinn = @lv_at_bsg_grup   and
                                ausp~atwrt = c~atwrt
    left outer join cawnt as ct on ct~atinn = @lv_at_bsg_grup and
                                ct~atzhl = c~atzhl            and
                                ct~spras = @sy-langu
    into table @lt_bsg
    for all entries  in @lt_pivot
    where mara~matnr eq @lt_pivot-matnr
     and  mara~matnr in @s_matnr
     and  mara~mtart in @s_mtart.
  endif.

  loop at lt_pivot into data(ls_pivot) where matnr in s_matnr.
    data(ls_mvke) = value #( lt_mvke[ matnr = ls_pivot-matnr ] optional ).
    check ls_mvke is not initial.

    assign gt_data[ matnr = ls_pivot-matnr ] to field-symbol(<fs_out>).
    if <fs_out> is not assigned.
      append initial line to gt_data assigning <fs_out>.
      <fs_out>-matnr = ls_pivot-matnr.
    endif.

    <fs_out>-aged  = cond #( when ls_pivot-matnr cp '*HH*' or ls_pivot-matnr cp '*AH*' then 'AGED' else 'NONAGED' ) .
    <fs_out>-mtart = ls_mvke-mtart.
    <fs_out>-maktx = ls_mvke-maktx.
    <fs_out>-tyre  = ls_mvke-tyre.
    <fs_out>-kondm = ls_mvke-kondm.
    <fs_out>-mvgr2 = ls_mvke-mvgr2.

    <fs_out>-rl  = ls_pivot-rl.
    <fs_out>-exp = ls_pivot-exp.
    <fs_out>-oe  = ls_pivot-oe.
    <fs_out>-ot  = ls_pivot-ot.

    data(ls_bsg) = value #( lt_bsg[ matnr = ls_pivot-matnr ] optional ).
    <fs_out>-bsg_grup  = ls_bsg-atwrt.
    <fs_out>-bsg_grupt = ls_bsg-atwtb.

    unassign <fs_out>. clear ls_mvke.

  endloop.


endform.
*&---------------------------------------------------------------------*
*&      Form  GET_0141_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_0141_data .
  data lt_urun type zcl_sd_kota=>ty_senaryo_tab.

  types: begin of ty_mvke,
           matnr type mvke-matnr,
           kondm type mvke-kondm,
           mvgr2 type mvke-mvgr2,
           mtart type mara-mtart,
           tyre  type zbrsmmtyre-tyre,
           maktx type makt-maktx,
         end of ty_mvke.
  data: lt_mvke type sorted table of ty_mvke with non-unique key matnr.

  loop at gt_data into data(ls_data).
    append value #( matnr = ls_data-matnr ) to lt_urun.
  endloop.

  zcl_sd_kota=>get_kota(
    exporting
      it_urun = lt_urun      " Malzeme numarası
    importing
      et_kota = data(lt_kota)" Malzeme numarası
  ).

  check lt_kota is not initial.

  select distinct mvke~matnr, mvke~kondm, mvke~mvgr2, mara~mtart, tyre, maktx from mvke
    inner join mara on mara~matnr eq mvke~matnr
    left join makt on makt~matnr = mvke~matnr and makt~spras eq 'T'
    left join zbrsmmtyre on zbrsmmtyre~matkl eq mara~matkl
    into table @lt_mvke
    for all entries in @lt_kota
    where mvke~matnr eq @lt_kota-matnr
     and mvke~matnr in @s_matnr
     and mvke~kondm in @s_kondm
     and mvke~mvgr2 in @s_grup
     and mvke~mvgr5 in @gr_mvgr5
     and mara~mtart in @s_mtart
     and vkorg in ('RL','EXP','OE')
     and tyre in @s_tyre.

  loop at lt_kota into data(ls_141) where matnr in s_matnr.
    assign gt_data[ matnr = ls_141-matnr ] to field-symbol(<fs_data>).
    if <fs_data> is not assigned.
      append initial line to gt_data assigning <fs_data>.
      <fs_data>-matnr = ls_141-matnr.
    endif.

    data(ls_mvke) = value #( lt_mvke[ matnr = <fs_data>-matnr ] optional ).
    <fs_data>-aged = cond #( when <fs_data>-matnr cp '*HH*' or <fs_data>-matnr cp '*AH*' then 'AGED' else 'NONAGED' ) .
    <fs_data>-mtart = ls_mvke-mtart.
    <fs_data>-maktx = ls_mvke-maktx.
    <fs_data>-tyre  = ls_mvke-tyre.
    <fs_data>-kondm = ls_mvke-kondm.
    <fs_data>-mvgr2 = ls_mvke-mvgr2.

    if ls_141-vkorg eq 'RL'.
      <fs_data>-kota_rl = ls_141-kalan.
    endif.
    if ls_141-vkorg eq 'EXP'.
      <fs_data>-kota_exp = ls_141-kalan.
    endif.
    if ls_141-vkorg eq 'OE'.
      <fs_data>-kota_oe = ls_141-kalan.
    endif.

    unassign <fs_data>. clear ls_mvke.

  endloop.
endform.
*&---------------------------------------------------------------------*
*&      Form  GET_CUBIC_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_cubic_lock .

  select lips~matnr , sum( lips~lfimg ) as lfimg
      from lips inner join zbrssd0003  on lips~vbeln eq zbrssd0003~vbeln
        into  table @data(lt_lips)
    where  lips~vbeln eq ( select vbeln from zbrssd0001 where zbrssd0001~vbeln eq lips~vbeln and irdat eq '00000000' )
  group by lips~matnr.

  loop at gt_data assigning field-symbol(<fs_data>).
    <fs_data>-cubiclock = value #( lt_lips[ matnr = <fs_data>-matnr ]-lfimg  optional ).
  endloop.

endform.
*&---------------------------------------------------------------------*
*&      Form  GET_BLOKE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_bloke .

  select matnr , sum( speme ) as speme from mard into table @data(lt_mard)
   where werks in  @gr_werks
   and   lgort in  @gr_lgort
   and speme > 0
  group by matnr.

  loop at gt_data assigning field-symbol(<fs_data>).
    <fs_data>-bloke = value #( lt_mard[ matnr = <fs_data>-matnr ]-speme  optional ).
  endloop.


endform.
*&---------------------------------------------------------------------*
*&      Form  GET_STOK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_DATA>_MATNR  text
*      <--P_<FS_DATA>_SAT_S  text
*----------------------------------------------------------------------*
form get_stok  using    p_matnr type mara-matnr
               changing c_stok type zmiktar.

  data: lt_atpdsx    type table of atpds.

  call function 'ZBRSSD_ATP_CHECK'
    exporting
      i_matnr  = p_matnr
    tables
      t_atpdsx = lt_atpdsx[].

  loop at lt_atpdsx into data(ls_atpdsx) where delnr eq space
                                           and del12 = space
                                           and delkz = 'LB'.
    if ls_atpdsx-atpnr+6(4) in gr_lgort.
      c_stok = c_stok + ls_atpdsx-qty.
    endif.

  endloop.


endform.
*&---------------------------------------------------------------------*
*&      Form  GET_HTML_VIEWER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_html_viewer .

  check p_memid eq space.

  zcl_sd_utils=>prog_info_html_viewer(
    i_repid = sy-repid                                  "Program adı
    i_dynnr = sy-dynnr                                  "screen no
    i_tdname = conv #( sy-repid )                       "SO10 text adı
    i_ratio  = 50                                       "Ekranın yüzde kaçını kaplayacağı
    i_side   = cl_gui_docking_container=>dock_at_bottom "Ekranın neresinde olacağı
).
endform.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_0140
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_0140 .


  data : lv_memid type text60 value 'SIPARIS'.
  data(lt_rows) = gr_selections->get_selected_rows( ).
  data: lt_out   type table of zbrssd0570,
        lr_matnr type range of zbrssd0640-matnr,
        lr_abgru type range of vbap-abgru,
        lr_audat type range of vbak-audat.

  if lt_rows[] is initial.
    do lines( gt_data[] ) times.
      append sy-index to lt_rows.
    enddo.
  endif.

  loop at lt_rows into data(ls_cell).
    loop at gt_data into data(gs_data) from ls_cell to ls_cell.
      lr_matnr[] = value #( base lr_matnr ( sign = 'I' option = 'EQ'  low =  gs_data-matnr  ) ).
    endloop.
  endloop.

  lr_abgru = value #( sign = 'I' option = 'EQ' ( low = space )
                                               ( low = '46'  ) ).

  lr_audat = value #( sign = 'I' option = 'BT' ( low = |{ sy-datum(4) }0101| high = sy-datum ) ).

  free memory id lv_memid.
  submit zbrs_sd_rp_siplist and return with p_memid eq lv_memid
                                       with s_matnr in lr_matnr[]
                                       with s_abgru in lr_abgru[]
                                       with s_audat in lr_audat[].

  import itab to lt_out[] from memory id lv_memid.

  check lt_out[] is not initial.

  "sadece siparişler kalacak
  delete lt_out where vbtyp ne 'C'.

  data: lr_columns type ref to cl_salv_columns_table,
        lr_column  type ref to cl_salv_column_table.

  define tanim.
    lr_column ?= lr_columns->get_column( &1 ).
    lr_column->set_short_text('').
    lr_column->set_medium_text('').
    lr_column->set_long_text( &2 ).
  end-of-definition.

  try.

      cl_salv_table=>factory(
         importing
           r_salv_table = data(lr_salv)
         changing
           t_table      = lt_out[] ).

      lr_columns = lr_salv->get_columns( ).
      lr_columns->set_optimize( 'X' ).

      data(lr_functions) = lr_salv->get_functions( ).
      lr_functions->set_all( if_salv_c_bool_sap=>true ).

      data(lr_display) = lr_salv->get_display_settings( ).
      lr_display->set_striped_pattern( if_salv_c_bool_sap=>true ).

      lr_display->set_list_header( 'Sipariş Listesi (ZBRSSD0140)' ).

      lr_salv->set_screen_popup(
         start_column = 15
         end_column   = 150
         start_line   = 10
         end_line     = 20 ).

      lr_salv->display( ).


    catch cx_root into data(lx_cx).
      message lx_cx->get_text( ) type 'E'.
  endtry.

endform.
*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form init .
  gr_werks = value #( sign = 'I' option = 'EQ' ( low = '1000' )
                                                   ( low = '2000' ) ).

  gr_lgort = value #( sign = 'I' option = 'EQ'   ( low = '3100' )
                                                 ( low = '3101' ) ).

  gr_mtart = value #( sign = 'I' option = 'EQ'   ( low = 'FERT' )
                                                 ( low = 'HAWA' )
                                                 ( low = 'HRDF' )
                                                 ( low = 'HRDH' ) ).

  functionkey: '@DI@' 'BAKIM' 'Muadil Kod Kriterleri' sscrfields-functxt_01.
  functionkey: '@45@' 'BAKIM2' 'Prod Group Bakımı' sscrfields-functxt_02.

endform.
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_selection .

  case sy-ucomm.
    when 'FC01'.
      call function 'VIEW_MAINTENANCE_CALL'
        exporting
          action                       = 'S'
          view_name                    = 'ZBRSSD0655'
        exceptions
          client_reference             = 1
          foreign_lock                 = 2
          invalid_action               = 3
          no_clientindependent_auth    = 4
          no_database_function         = 5
          no_editor_function           = 6
          no_show_auth                 = 7
          no_tvdir_entry               = 8
          no_upd_auth                  = 9
          only_show_allowed            = 10
          system_failure               = 11
          unknown_field_in_dba_sellist = 12
          view_not_found               = 13
          maintenance_prohibited       = 14
          others                       = 15.

    when 'FC02'.
      call function 'VIEW_MAINTENANCE_CALL'
        exporting
          action                       = 'S'
          view_name                    = 'ZBRSSD0705'
        exceptions
          client_reference             = 1
          foreign_lock                 = 2
          invalid_action               = 3
          no_clientindependent_auth    = 4
          no_database_function         = 5
          no_editor_function           = 6
          no_show_auth                 = 7
          no_tvdir_entry               = 8
          no_upd_auth                  = 9
          only_show_allowed            = 10
          system_failure               = 11
          unknown_field_in_dba_sellist = 12
          view_not_found               = 13
          maintenance_prohibited       = 14
          others                       = 15.
  endcase.
endform.
*&---------------------------------------------------------------------*
*&      Form  SET_JANTCAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_jantcapi.

  data: begin of lt_jantcapi occurs 0,
          atflv like cawn-atflv,
        end of lt_jantcapi.

  data: begin of lt_jant occurs 0,
          jant_capi type zbrs_sd_jantcapi,
        end of lt_jant.


  data: lv_atinn  like cabn-atinn.


  select single atinn
   into lv_atinn
    from cabn
     where atnam eq 'JANT_CAPI'.

  select atflv into table lt_jantcapi
   from cawn
    where cawn~atinn  eq lv_atinn.


  loop at lt_jantcapi.
    lt_jant-jant_capi = lt_jantcapi-atflv.
    append lt_jant.
  endloop.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'JANT_CAPI'
      value_org       = 'S'
      dynpnr          = sy-dynnr
      dynpprog        = sy-repid
      dynprofield     = 'X'
    tables
      value_tab       = lt_jant
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.






endform.
*&---------------------------------------------------------------------*
*&      Form  SET_MTART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_MTART_LOW  text
*----------------------------------------------------------------------*
form set_mtart.

  data: begin of lt_mtart occurs 0,
          mtart like t134-mtart,
          mtbez like t134t-mtbez,
        end of lt_mtart.

  select mtart , mtbez
   into table @lt_mtart
    from   t134t
     where  mtart in ('HAWA','FERT','HRDF','HRDH')
      and   spras eq @sy-langu.


  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'MTART'
      value_org       = 'S'
      dynpnr          = sy-dynnr
      dynpprog        = sy-repid
      dynprofield     = 'X'
    tables
      value_tab       = lt_mtart
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
endform.
*&---------------------------------------------------------------------*
*&      Form  SET_KONDM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_kondm .

  data: begin of lt_kondm occurs 0,
          kondm like mvke-kondm,
          vtext like t178t-vtext,
        end of lt_kondm.


  select * into corresponding fields of table  lt_kondm
  from t178t
   where kondm in ('LS','DY','BS','KS','FS','SA','SG','RO')
    and  spras eq sy-langu.


  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'KONDM'
      value_org       = 'S'
      dynpnr          = sy-dynnr
      dynpprog        = sy-repid
      dynprofield     = 'X'
    tables
      value_tab       = lt_kondm
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.


endform.