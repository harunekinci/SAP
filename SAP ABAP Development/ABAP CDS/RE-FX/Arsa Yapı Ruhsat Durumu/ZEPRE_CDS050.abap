@AbapCatalog.sqlViewName: 'ZEPRE_DDL050'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tüm Sözleşmeler --> Gayrimenkul'
define view ZEPRE_CDS050
as
select 
  from vicncn           as      VICNCN          left outer join
       tiv2f            as      TIV2F           on vicncn.recntype = tiv2f.smvart
                                               and tiv2f.spras = $session.system_language left outer join
       zepre_t059       as      ZEK059          on vicncn.zzcontractstat = ZEK059.zzcontractstat left outer join
       vibdobjass       as      VIBDOB          on vicncn.objnr = VIBDOB.objnrsrc left outer join
       vibdro           as      VIBDRO          on VIBDOB.objnrtrg = vibdro.objnr left outer join
       vibdpr           as      VIBDPR          on VIBDOB.objnrtrg = vibdpr.objnr left outer join
       vibdbe           as      VIBDBE          on VIBDOB.objnrtrg = vibdbe.objnr left outer join
       vibdpr           as      VIBDRA          on vibdro.sgrnr = VIBDRA.sgrnr
                                               and vibdro.swenr = VIBDRA.swenr left outer join
       vibdbe           as      VIBDBEO         on vibdro.swenr = VIBDBEO.swenr left outer join
       vibdbe           as      VIBDBER         on vibdpr.swenr = VIBDBER.swenr left outer join
       zepre_t023       as      ZEK023          on vibdro.swenr = ZEK023.swenr left outer join
       zepre_t007       as      ZEK007          on vibdro.sharing_status = ZEK007.sharing_status left outer join
       zepre_t032       as      ZEK032          on vicncn.recnnr = ZEK032.sozlesme left outer join
       vibpobjrel       as      VIBPOBJREL      on vicncn.intreno = vibpobjrel.intreno left outer join
       zepre_t009       as      ARSAIL          on vibdpr.state = ARSAIL.state left outer join
       zepre_t010       as      ARSAILCE        on vibdpr.state = ARSAILCE.state
                                               and vibdpr.district = ARSAILCE.district left outer join
       zepre_t009       as      BBIL            on VIBDRA.state = BBIL.state left outer join
       zepre_t010       as      BBILCE          on VIBDRA.state = BBILCE.state
                                               and VIBDRA.district = BBILCE.district left outer join
       but000           as      BUT000          on vibpobjrel.partner = but000.partner left outer join 
       but0id           as      BUT0ID          on but000.partner = but0id.partner
                                               and but0id.type = 'ZTCKN' left outer join
       dfkkbptaxnum     as      dfkkbptaxnum    on but000.partner = dfkkbptaxnum.partner
                                               and dfkkbptaxnum.taxtype = 'TR2' left outer join
       zepre_t071       as      muhatappay      on vibpobjrel.partner = muhatappay.muhatap
                                               and vicncn.recnnr = muhatappay.sozlesme
{ 
       vicncn.intreno as INTRENOCN,
       vicncn.bukrs,    
       vicncn.recnnr,
       vicncn.recntype,
       tiv2f.xmbez as SOZLESME_TURU,
       vibpobjrel.role,
       vibpobjrel.partner,
       but000.partner_guid,
       vibpobjrel.validfrom as validfrom_jrel,
       vibpobjrel.validto as validto_jrel,
       but0id.idnumber as TCKN,
       dfkkbptaxnum.taxnum as VKN,
       cast( concat(  concat_with_space(but000.name_first, but000.name_last, 1) ,
                concat( concat(  but000.name_org1, but000.name_org2 ), concat(  but000.name_org3, but000.name_org4 ) ) ) as zepcrm_dd138 ) as musteriad,
       case when vibdbe.intreno <> ' ' then vibdbe.swenr
            when vibdro.intreno <> ' ' then vibdro.swenr
            when vibdpr.intreno <> ' ' then vibdpr.swenr end as SWENR,
       vibdro.smenr,
       vibdpr.sgrnr,
       vibdro.intreno as ROINTRENO,
       case when ZEK023.lansman_adi <> ' ' then ZEK023.lansman_adi
            when VIBDBEO.xwetext <> ' ' then VIBDBEO.xwetext
            when VIBDBER.xwetext <> ' ' then VIBDBER.xwetext
            when vibdbe.xwetext <> ' ' then vibdbe.xwetext end as PROJE,
       case when vibdro.intreno <> ' ' then BBIL.statet
            when vibdpr.intreno <> ' ' then ARSAIL.statet end as IL,
       case when vibdro.intreno <> ' ' then BBILCE.districtt
            when vibdpr.intreno <> ' ' then ARSAILCE.districtt end as ILCE,
       case when vibdro.intreno <> ' ' then VIBDRA.blok_index
            when vibdpr.intreno <> ' ' then vibdpr.blok_index end as ADA_NO,
       case when vibdro.intreno <> ' ' then VIBDRA.parcel
            when vibdpr.intreno <> ' ' then vibdpr.parcel end as PARSEL,
       vibdro.block_no as BLOK,
       cast( ltrim(vibdro.apartmentno, '0') as zepre_dd1412 ) as KAPI,
       VIBDBEO.usgfunction,
       vibdro.sharing_status,
       ZEK007.sharing_statust as PAYLASIM_DURUM,
       vicncn.zzcontlawstat,
       vicncn.zzcontractstat, 
       ZEK059.zzcontractstatt as SOZLESME_DURUMU,
       vibdro.zzdeliver_d,
       VIBDOB.objasstype,
       VIBDOB.validfrom,
       VIBDOB.validto,
       vicncn.recnend1st,
       cast( case when vibdbe.pyp <> ' ' then vibdbe.pyp
                  when VIBDBEO.pyp <> ' ' then VIBDBEO.pyp
                  when VIBDBER.pyp <> ' ' then VIBDBER.pyp end as rebdbeno ) as pyp,
       case when muhatappay.muhatap is not null then muhatappay.hisse_pay
            else 1 end as hisse_pay,
       case when muhatappay.muhatap is not null then muhatappay.hisse_payda
            else 1 end as hisse_payda,
       case when recntype = 'ZBKS' or recntype = 'ZARK' or recntype = 'ZAVM' or recntype = 'ZKRB' then '18' 
            else ZEK032.kdvorani end as kdvorani,
       ZEK032.satalsoz,
       ZEK032.satsek,
       ZEK032.satis_kampanyasi,
       ZEK032.rfha,
       ZEK032.satis_tarihi,
       vicncn.recnbeg,
       ZEK032.soz_onay_tarihi,
       cast( case when vicncn.zzcontractstat <> '00000009' and vibpobjrel.validto <> '99991231' then 'X' end as zepre_dd1411 ) as devir
      
} 
  
  
