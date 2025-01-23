if p_memid is not initial.				
    data: lt_data type table of zbrssd0640.				
    lt_data = corresponding #( gt_data[] ).				
    export itab from lt_data to memory id p_memid.				
  else.				
    perform  display_data.				
  endif.				
-----------------------------------------------------

cl_salv_bs_runtime_info ->  kullanarak, verisini çalmak istediğin programa hiç müdahale etmeden ekrana basmaya çalıştığı veriyi alabiliyorsun 
lv_memid değişkeni ise genelde verisini çalmak istediğin programa müdahale edip "bu parametre gelmişse veriyi ekrana basma da export ile bana ver" diye değiştirerek çağırmak için kullanılıyor. 
