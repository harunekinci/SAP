REPORT PROGRAM 	ZBRS_MUSTERI_ILETISIM

do 60 times.
        data(lv_fieldname) = conv lvc_fname( |SMTP_ADDR{ conv numc2( sy-index ) }| ) .
        data(lv_coltext)   = conv char40( |Mail { sy-index } | ) .
        tanim : lv_fieldname  lv_coltext.
      enddo.

      "Girilen mail kadar mail sütunu görünmeli.
      do ( 60 - lv_say ) times.
        add 1 to lv_say.
        lr_column ?= lr_columns->get_column( |SMTP_ADDR{ conv numc2( lv_say ) }| ).
        lr_column->set_visible( value = space ).
      enddo.
