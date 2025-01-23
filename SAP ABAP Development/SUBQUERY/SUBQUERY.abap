select value_old, value_new, username, udate, utime
  from zchdr_cdpos into corresponding fields of table @gt_out
  where objectid in ( select vbeln from vbap where vbeln in @s_vbeln and abgru eq '46' ) 
   and  objectclas eq 'VERKBELEG'
   and  tabname    eq 'VBAK'
   and  fname      eq 'VDATU'. 
 
                       