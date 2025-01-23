data : lv_rc     type i,
       it_files  type filetable,
       lv_action type i.
try.
*file open dialog
    cl_gui_frontend_services=>file_open_dialog( exporting
                                                 file_filter = | xlsx (*.xlsx)\|*.xlsx\| { cl_gui_frontend_services=>filetype_all } |
                                                 changing
                                                 file_table = it_files
                                                 rc = lv_rc
                                                 user_action = lv_action ).
    if lv_action eq cl_gui_frontend_services=>action_ok.

      if lines( it_files ) > 0.
	*read file and GUI upload
        data : lv_filesize type w3param-cont_len,
               lv_filetype type w3param-cont_type,
               it_bin_data type w3mimetabtype.

        cl_gui_frontend_services=>gui_upload( exporting
                                              filename = |{ it_files[ 1 ]-filename }|
                                              filetype = 'BIN'
                                              importing
                                              filelength = lv_filesize
                                              changing
                                              data_tab = it_bin_data ).


* solix -> xstring
        data(lv_bin_data) = cl_bcs_convert=>solix_to_xstring( it_solix = it_bin_data ).

* create spreadsheet ref object
        data(o_excel) = new cl_fdt_xl_spreadsheet( document_name = conv #( it_files[ 1 ]-filename )
                                                   xdocument     = lv_bin_data ).

* get first worksheet name
        data : it_worksheet_names type if_fdt_doc_spreadsheet=>t_worksheet_names.

        o_excel->if_fdt_doc_spreadsheet~get_worksheet_names( importing  worksheet_names = it_worksheet_names ).

        if lines( it_worksheet_names ) > 0 .

*first worksheet ref to itab
          data(o_worksheet_itab) = o_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( it_worksheet_names[ 1 ] ).

* ref to generic field symbol (excel data)
          assign o_worksheet_itab->* to field-symbol(<worksheet>).

* output data
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

  catch cx_root into data(lv_msg).
    message lv_msg->get_text( ) type 'S' display like 'E'.
endtry.
