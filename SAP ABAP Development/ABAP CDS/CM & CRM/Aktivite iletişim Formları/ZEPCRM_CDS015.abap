@AbapCatalog.sqlViewName: 'ZEPCRM_DDL015'
@AbapCatalog.compiler.compareFilter: true
@EndUserText.label: 'Aktivite iletişim Formları'
define view ZEPCRM_CDS015 
as
select  
  from zepcrm_t006 left outer join
       zepcrm_t038 on zepcrm_t006.aktivite_id = zepcrm_t038.aktivite_id
{
    zepcrm_t006.mandt,
    zepcrm_t006.aktivite_id,
    aktivite_turu,
    musteri_id,
    case when zepcrm_t038.musteri_gelis_id is not null then zepcrm_t038.musteri_gelis_id else zepcrm_t006.musteri_gelis_id end as musteri_gelis_id,
    case when tekrar_arama = 'X' then son_zaman else baslangic_zamani end as BASLANGIC_ZAMANI,
    durum,
    tekrar_arama,
    ulasilamama_sayisi
}
