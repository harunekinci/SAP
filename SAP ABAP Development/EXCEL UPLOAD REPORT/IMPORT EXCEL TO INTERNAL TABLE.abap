report zbrs_sd_ikame_upload.
*&---------------------------------------------------------------------*
*& Report ZBRS_SD_VKM_ONAY_LOG
*&---------------------------------------------------------------------*
*& harun.ekinci@alfayazilim.com  29.04.22
*&
*& Ikame upload raporu
*&
*&---------------------------------------------------------------------*

data : begin of gt_data ,
         vkorg type komgd-vkorg,
         vtweg type komgd-vtweg,
         matnr type komgd-matnr,
         kdgrp type komgd-kdgrp,
         datam type rv130-datam,
         datbi type rv130-datbi,
       end of gt_data.



selection-screen begin of block b1 with frame title text-tt1.
parameters : p_file  type rlgrap-filename obligatory default 'C:\Users\ALFA\Desktop\ikame.xlsx'.
selection-screen  uline /1(77).

selection-screen begin of line.
parameters : p_1 radiobutton group grp default 'X' .
selection-screen comment 3(70) text-001 for field p_1.
selection-screen end of line.

selection-screen begin of line.
parameters : p_2 radiobutton group grp .
selection-screen comment 3(70) text-002 for field p_2 .
selection-screen end of line.

selection-screen end of block b1 .

at selection-screen on value-request for p_file.

  call function 'F4_FILENAME'
    exporting
      field_name = 'P_FILE'
    importing
      file_name  = p_file.

start-of-selection.

  try.
      data : lv_rc     type i,
             it_files  type filetable,
             lv_action type i.
      cl_gui_frontend_services=>file_open_dialog( exporting
                                                        file_filter = |XLSX (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|
                                                        changing
                                                        file_table = it_files
                                                        rc = lv_rc
                                                        user_action = lv_action )  .


      if lv_action eq cl_gui_frontend_services=>action_ok.
        if lines( it_files ) > 0.

          data : lv_filesize type w3param-cont_len,
                 lv_filetype type w3param-cont_type,
                 it_bin_data type w3mimetabtype.
          cl_gui_frontend_services=>gui_upload( exporting
                                                filename = |{ it_files[ 1 ]-filename }|
                                                filetype = 'BIN'
                                                importing
                                                filelength = lv_filesize
                                                changing
                                                  data_tab = it_bin_data ) .

          data(lv_bin_data) = cl_bcs_convert=>solix_to_xstring( it_solix = it_bin_data ).
          data(o_excel) = new cl_fdt_xl_spreadsheet( document_name = conv #( it_files[ 1 ]-filename )
                                                     xdocument = lv_bin_data ).

          data: it_worksheet_names type if_fdt_doc_spreadsheet=>t_worksheet_names.
          o_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
            importing
              worksheet_names = it_worksheet_names ).
          if lines( it_worksheet_names ) > 0.

            data(o_worksheet_itab) = o_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( it_worksheet_names[ 1 ] ).

            assign o_worksheet_itab->* to field-symbol(<worksheet>).

            cl_demo_output=>write_data( <worksheet> ).
            data(lv_html) = cl_demo_output=>get( ).

            cl_abap_browser=>show_html( exporting
                                        title = 'Excel Worksheet'
                                        html_string = lv_html
                                        container = cl_gui_container=>default_screen ).
            write : space.
          endif.
        endif.
      endif.



    catch cx_root into data(e_text).
      message e_text->get_text( ) type 'S' display like 'E'.
  endtry.
