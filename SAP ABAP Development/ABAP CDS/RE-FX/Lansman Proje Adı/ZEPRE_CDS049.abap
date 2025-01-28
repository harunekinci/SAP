@AbapCatalog.sqlViewName: 'ZEPRE_DDL049'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Lansman-Proje Adı'
define view ZEPRE_CDS049
  as select from    vibdbe     as vbe
    left outer join zepre_t023 as T023 on  T023.bukrs = vbe.bukrs
                                       and T023.swenr = vbe.swenr
{
  vbe.bukrs,
  vbe.swenr,
  cast( case when T023.lansman_adi is null or T023.lansman_adi = '' then vbe.xwetext
                  else T023.lansman_adi end as rebdxbe  ) as xwetext


}
