@AbapCatalog.sqlViewName: 'ZEPCRM_DDL004'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Müşteri İletişim Form Listesi'
define view ZEPCRM_CDS004  
as
select
  from zepcrm_t010    as  ZCRMT010          left outer join
       zepcrm_t001    as  ZCRMT001          on ZCRMT010.potansiyel_musteri_id = ZCRMT001.potansiyel_musteri_id left outer join
       zepcrm_ddl003  as  zcrmddl003        on ZCRMT010.musteri_gelis_id = zcrmddl003.musteri_gelis_id left outer join
       zepcrm_t003    as  ZCRMT003          on ZCRMT010.potansiyel_musteri_id = ZCRMT003.potansiyet_musteri_id left outer join
       zepcrm_t039    as  zcrmt039          on ZCRMT010.proje = zcrmt039.swenr left outer join
       usr21          as  USR21             on ZCRMT010.musteri_temsilcisi = USR21.bname left outer join
       adrp           as  ADRP              on USR21.persnumber = ADRP.persnumber left outer join
       t002t          as  T002T             on ZCRMT010.dil = T002T.sprsl
                                           and T002T.spras = $session.system_language left outer join
       zepre_t023     as  ZRET023           on ZCRMT010.proje = ZRET023.swenr left outer join
       vibdbe         as  VIBDBE            on ZCRMT010.proje = VIBDBE.swenr left outer join
       zepcrm_ddl014  as  TEMSILCI          on ZCRMT010.potansiyel_musteri_id = TEMSILCI.potansiyel_musteri_id left outer join
       v_usr_name     as  MUSTERITEMSILCI   on TEMSILCI.musteri_temsilcisi = MUSTERITEMSILCI.bname left outer join
       zepcrm_t014    as  zcrmt014          on ZCRMT010.daire_tipi = zcrmt014.daire_tip_id
                                           and zcrmt014.langu = $session.system_language
{
    ZCRMT010.mandt,
    ZCRMT010.musteri_gelis_id,
    ZCRMT010.musteri_gelis_no,
    ZCRMT010.potansiyel_musteri_id,
    ZCRMT010.gelis_zamani,
    ZCRMT010.kaynak,
    ZCRMT010.kaynak_yeri,
    ZCRMT010.anahtar_kelime,
    ZCRMT010.icerik,
    ZCRMT010.kampanya,
    ZCRMT010.url,
    ZCRMT010.mesaj,
    ZCRMT010.dil,
    ZCRMT010.proje,
    ZCRMT010.musteri_temsilcisi,
    ZCRMT010.atanma_zamani,
    ZCRMT010.silen,
    ZCRMT010.silme_zamani,
    ZCRMT010.silindi,
    ZCRMT010.gelis_sekli,
    ZCRMT010.form_tipi,
    ZCRMT001.potansiyel_musteri_no,
    ZCRMT001.ad,
    ZCRMT001.soyad,
    ZCRMT001.cep_tel,
    ZCRMT001.e_posta,
    ZCRMT001.tckn_vergi_no,
    ZCRMT001.meslek,
    zcrmddl003.aktivite_sayisi as aranma_sayisi,
    ZCRMT010.musteri_kampanya_id,
    zcrmddl003.aktivite_sayisi,
    case when zcrmddl003.aktivite_sayisi > 0 then zcrmddl003.durum
         when ZCRMT010.musteri_temsilcisi <> ' ' then 2
         else 1 end as DURUM_NO,
    case when zcrmddl003.aktivite_sayisi > 0 then case when zcrmddl003.durum = 3 then 'İletişim Kuruldu'
                                                       when zcrmddl003.durum = 6 then 'Ulaşılamadı'
                                                       when zcrmddl003.durum = 5 then 'Tekrar Aranacak'
                                                       when zcrmddl003.durum = 7 then 'Hatalı İletişim Bilgisi' end
         when ZCRMT010.musteri_temsilcisi <> ' ' then 'Atama Yapıldı'
         else 'Yeni' end as DURUM,
    concat_with_space( ADRP.name_first, ADRP.name_last,1 ) as MUSTERI_TEMSILCI,
    T002T.sptxt as DIL_TANIM,
    case when ZRET023.lansman_adi is not null then ZRET023.lansman_adi
         when VIBDBE.xwetext is not null then VIBDBE.xwetext
         when zcrmt039.lansman_adi is not null then zcrmt039.lansman_adi  end as PROJE_TANIM,
    zcrmddl003.ilk_aktivite_zamani,
    zcrmddl003.son_aktivite_zamani,
    MUSTERITEMSILCI.bname as SON_MUSTERI_TEMSILCISI,
    MUSTERITEMSILCI.name_text as SON_MUSTERI_TEMSILCI,
    zcrmddl003.aktivite_id,
    zcrmddl003.aktivite_zamani,
    zcrmddl003.ulasilamama_sayisi,
    ZCRMT003.maksimum_fiyat,
    ZCRMT003.minimum_fiyat,
    ZCRMT003.minimum_taksit,
    ZCRMT003.maksimum_taksit,
    ZCRMT003.taksit_tutari_belirtmedi,
    ZCRMT010.daire_tipi as webform_daire_tip_id,
    zcrmt014.daire_tipi as webform_daire_tipi

}
where silindi <> 'X' 
