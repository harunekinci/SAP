@AbapCatalog.sqlViewName: 'ZEPRE_DDL066'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'İade ve Virman Listesi'
define view ZEPRE_CDS066 
as 
select 
from zepre_t299
{
    key iade_id as iade_virman_id,
    recnnr,
    partner,
    musteriad,
    swenr,
    xwetext,
    cast('' as recnnr) as recnnr2,
    cast('' as zepre_dd564) as partner2,
    cast('' as zepre_dd563) as musteriad2,
    isltr,
    tarih,
    tutar,
    case when acikl = '' or acikl is null then 'İade İşlemi'
         else acikl end as acikl,
    banka,
    iban,
    hesapadi,
    onay,
    durum,
    silindi,
    dilekce_no,
    bukrs
}
union all
select
  from zepre_t315
{
    key virman_id as iade_virman_id,
    recnnr,
    partner,
    musteriad,
    swenr,
    xwetext,
    recnnr2,
    partner2,
    musteriad2,
    cast('VİRMAN' as zepre_dd570) as ISLTR,
    tarih,
    tutar,
    case when acikl = '' or acikl is null then 'Virman İşlemi'
         else acikl end as acikl,
    cast('' as zepre_dd870) as banka,
    cast('' as iban) as Iban,
    cast('' as char40) as hesapadi,
    onay,
    durum,
    silindi,
    dilekce_no,
    bukrs
}
