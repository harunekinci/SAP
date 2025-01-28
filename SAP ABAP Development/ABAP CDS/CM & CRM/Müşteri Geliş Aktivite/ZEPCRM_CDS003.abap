@AbapCatalog.sqlViewName: 'ZEPCRM_DDL003'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Müşteri Geliş Aktivite'
define view ZEPCRM_CDS003
as
select
  from ZEPCRM_DDL016 {
    mandt,
    aktivite_id,
    musteri_id,
    musteri_gelis_id,
    aktivite_sayisi,
    AKTIVITE_ZAMANI,
    ilk_aktivite_zamani,
    son_aktivite_zamani,
    durum,
    ULASILAMAMA_SAYISI
} 
