data : first_date type datum,
       last_date  type datum.

data : lr_fkdat type range of datum.

call function 'LAST_DAY_OF_MONTHS'
  exporting
    day_in            = sy-datum
  importing
    last_day_of_month = last_date.

concatenate last_date+0(6) '01' into first_date.

lr_fkdat = value #( ( sign = 'I' option = 'BT' low = first_date high = last_date ) ).

data(lv_last_date)  = conv datum( |{ sy-datum(6) }01| )."Mevcut ayın ilk günü
lv_last_date        = lv_last_date - 1.                 "Geçen ayın son günü

data(lv_first_date) = conv datum( |{ lv_last_date(6) }01| ). "Geçen ayın ilk günü
