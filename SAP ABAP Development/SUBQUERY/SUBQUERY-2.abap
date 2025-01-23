select single prsdt
  from vbkd
  into @gs_sales_header_in-price_date
  where posnr eq '000000' 
   and  vbeln eq ( select  vbeln from zbrs_ofk_log_b_h where panid eq @gt_input-panid ).
