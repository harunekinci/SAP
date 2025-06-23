REDUCE -> <fs_out>-ntgew = reduce ntgew_15( init val type ntgew for wa in lt_lips
                                            where ( vbeln = <fs_out>-vbeln )
                                            next    val = val + wa-ntgew.
------------------------------------------------------------

FOR -> lr_season =  value #( for  <ls_malzeme> in lt_malzeme
                             sign = 'I'
                             option = 'EQ' 
                           ( low = <ls_malzeme>-sezon )  )  .

------------------------------------------------------------

FOR GROUPS -> lr_matnr  = value #( for groups of <wa> in lt_siparis
                                   group by  <wa>-matnr
                                   ( <wa>-matnr ) ).

------------------------------------------------------------

FILTER -> SELECT field1,field2 
 	    FROM @itab asa
            WHERE field1 <>'SOME_VALUE'
            INTO TABLE @DATA(itab_filtered). 

#FILTER
DATA(itab_filtered)= FILTER #( itab where field1 <>'SOME_VALUE' ).

lt_values_filtered = filter #( lt_values in lt_values_filter
                     where field1 = field1 "Primary Key Comparison here
                      and  field2 = field2 ).

------------------------------------------------------------

VALUE # -> 

  lr_matnr[] = value #( base lr_matnr ( sign = 'I' option = 'EQ' low = gs_data-matnr ) ).


------------------------------------------------------------

APPEND VALUE # ->

  lr_kunnr[] = value #( sign = 'I' option = 'EQ' ( low = i_kunnr ) ).
  append value #( sign = 'I' option = 'EQ' low = | { i_kunnr alpha = in }| ) to lr_kunnr.


------------------------------------------------------------


APPEND VALUE # ->

  append value #( base corresponding #( <fs_itab> )
                  vbeln = |{ <fs_itab>-vbeln alpha = out }|
		  knkli = |{ <fs_itab>-knkli alpha = out }|
		  zterm = <fs_itab>-zterm
                  textl = value #( lt_t052u[ zterm = <fs_itab>-zterm ]-textl optional )  ) to et_header.

------------------------------------------------------------


APPEND VALUE # ->

 data : lr_abgru type range of tvaut-augru.
        lr_abgru[] = value #( sign = 'I' option = 'EQ' ( low = '103' )    "İade - Miktar farkı    - BRISA
        					       ( low = '104' )    "İade - Bozuk mal       - BRISA
						       ( low = '104' ) ). "İade - Hatalı Sevkiyat - BRISA

------------------------------------------------------------

CORRESPONDING # ->

 ls_balance-documents[] = corresponding #( lt_data[] mapping referance   = xblnr ).

------------------------------------------------------------

BASE # ->

 lt_data[] = value #( base lt_data 
		      kunnr = lv_kunnr
                      mtart = 'HAWA' ).

------------------------------------------------------------

REPLACE ALL OCCURRENCES ->

 REPLACE ALL OCCURRENCES OF '_' IN va WITH ''.
 CONDENSE va NO-GAPS.

