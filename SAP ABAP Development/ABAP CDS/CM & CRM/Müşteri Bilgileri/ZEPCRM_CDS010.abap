@AbapCatalog.sqlViewName: 'ZEPCRM_DDL010'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Müşteri Bilgileri'
define view ZEPCRM_CDS010
as
select distinct
 from but000               left outer join
      but0id               on but000.partner = but0id.partner
                          and but0id.type = 'ZTCKN' left outer join
      dfkkbptaxnum         on but000.partner = dfkkbptaxnum.partner
                          and dfkkbptaxnum.taxtype = 'TR2' left outer join
      but0id   as pasaport on but000.partner = pasaport.partner
                          and pasaport.type = 'FS0002' left outer join
      kna1                 on but000.partner = kna1.kunnr left outer join
      adrc                 on kna1.adrnr = adrc.addrnumber left outer join
      adr2                 on kna1.adrnr = adr2.addrnumber
                          and adr2.r3_user = '3' left outer join
      adr6                 on kna1.adrnr = adr6.addrnumber
                          and adr6.flgdefault = 'X' left outer join
      t005u                on t005u.mandt = but000.client
                          and t005u.land1 = adrc.country
                          and t005u.bland = adrc.region
                          and t005u.spras = $session.system_language
{
    but000.client as MANDT,
    but000.partner,
    but000.partner_guid,
    but000.type,
    but000.natio,
    but000.birthdt,
    cast( case when but000.xsexm = 'X' then '2'
               when but000.xsexf = 'X' then '1' end as bu_sexid) as SEX,
    cast( case when but000.type = '1' then concat_with_space( but000.name_first, but000.name_last, 1 )
               else  concat( concat(  but000.name_org1, but000.name_org2 ), concat(  but000.name_org3, but000.name_org4 ) ) end as zepcrm_dd138 )  as MUSTERIAD,
    cast( case when but000.type = '1' then but000.name_first
               else  concat( concat(  but000.name_org1, but000.name_org2 ), concat(  but000.name_org3, but000.name_org4 ) ) end as zepcrm_dd138 )  as MUSTERI_AD,
    cast( case when but000.type = '1' then but000.name_last end as zepcrm_dd138 )  as MUSTERI_SOYAD,
    cast( but0id.idnumber as zepcrm_dd140 ) as tckn,
    cast( dfkkbptaxnum.taxnum as zepcrm_dd141 ) as vergino,
    cast( pasaport.idnumber as zepcrm_dd142 ) as pasaportno,
    cast( case when but0id.idnumber is not null then but0id.idnumber
               when dfkkbptaxnum.taxnum is not null then dfkkbptaxnum.taxnum
               when pasaport.idnumber is not null then pasaport.idnumber end as zepcrm_dd143 ) as tckn_vergi_pass,
    cast( adr2.telnr_long as zepcrm_dd139 ) as telnr_long,
    cast( adr2.tel_number as zepcrm_dd139 ) as tel_number,
    adr2.country as tel_country,
    cast( adr6.smtp_addr as zepcrm_dd144 ) as smtp_addr,
    cast( concat_with_space(concat_with_space(adrc.street,  adrc.str_suppl1, 1), adrc.str_suppl2, 1 ) as zepcrm_dd145 ) as ADRES,
    cast( city1 as zepcrm_dd146 ) as ILCE,
    cast( t005u.bezei as zepcrm_dd147 ) as IL,
    but000.crusr,
    but000.crdat,
    but000.crtim,
    but000.chusr,
    but000.chdat,
    but000.chtim

}
where but000.partner like '120%'
