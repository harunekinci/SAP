![REFERENCE INTO DATA](https://github.com/user-attachments/assets/91330221-8b0e-4e5a-8d35-94a625d17860)

-------------------------------------------------------------------------------------------------------

check lt_muhatap is not initial.
  move-corresponding lt_muhatap[ 1 ] to es_data.

  loop at lt_muhatap reference into data(r_muhatap).

    if r_muhatap->r3_user eq '3'.
      es_data-cep_telnr = r_muhatap->telnr_long.
    elseif r_muhatap->r3_user eq '1'.
      es_data-telnr = r_muhatap->telnr_long.
    endif.

  endloop. 
