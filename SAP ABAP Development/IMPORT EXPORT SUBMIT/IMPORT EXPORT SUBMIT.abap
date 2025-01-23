function zbrs_sd_lastik_envanter.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MATNR) TYPE  MARA-MATNR OPTIONAL
*"  TABLES
*"      ET_DATA STRUCTURE  ZBRSSD0640 OPTIONAL
*"----------------------------------------------------------------------



  data : lv_memid type text60 value 'ZSD_ENVANTER',
         lr_matnr type range of zbrssd0640-matnr,
         lt_data  type table of zbrssd0640.

  if i_matnr is not initial.
    lr_matnr[] = value #( sign = 'I' option = 'EQ' ( low = i_matnr )  ).
  endif.

  free memory id lv_memid.
  export lt_data[] to memory id lv_memid.

  submit zbrs_sd_lastik_envanter and return with s_matnr in lr_matnr[]
                                            with p_memid eq lv_memid.

  import itab to lt_data[] from memory id lv_memid.

  et_data[] = corresponding #( lt_data ).


endfunction.