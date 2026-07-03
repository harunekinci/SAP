# 📊 SAP ABAP CDS View (Gerçek Hayat Örneği)

<br/>

<div align="center">

<img src="https://img.shields.io/badge/SAP-ABAP_7.50+-008FD3?style=for-the-badge&logo=sap&logoColor=white" />
<img src="https://img.shields.io/badge/HANA-CDS-success?style=for-the-badge" />
<img src="https://img.shields.io/badge/REAL_PROJECT-Business_View-blue?style=for-the-badge" />

</div>

<br/>

> **Amaç:** CDS View kullanılarak farklı SAP tablolarının tek bir veri modeli altında birleştirilmesi, JOIN, CASE, CAST, Session Variable ve filtreleme gibi CDS özelliklerinin gerçek proje örneği üzerinden gösterilmesi.

---

# 📋 Kullanılan CDS Özellikleri

| Özellik | Açıklama |
|----------|----------|
| Annotation | CDS metadata tanımları |
| LEFT OUTER JOIN | Birden fazla tabloyu ilişkilendirme |
| CASE | Koşullu alan oluşturma |
| CAST | Veri tipi dönüşümü |
| CONCAT / CONCAT_WITH_SPACE | Metin birleştirme |
| DISTINCT | Tekrarlayan kayıtları kaldırma |
| Session Variable | Oturum dili bilgisi |
| WHERE | Veri filtreleme |

---

# 🔄 CDS Yapısı

```text
Business Partner
        │
        ▼
Kimlik Bilgileri
        │
        ▼
Adres Bilgileri
        │
        ▼
Telefon / Mail
        │
        ▼
Şehir Bilgisi
        │
        ▼
Tek CDS View
```

---

# 💡 Kullanım Notları

> [!TIP]
> CDS View içerisinde JOIN işlemleri sayesinde birçok tablo tek sorguda okunabilir.

> [!TIP]
> CASE ifadeleri ile iş kuralları doğrudan veritabanında çalıştırılabilir.

> [!TIP]
> CAST kullanılarak alanlar DDIC veri tiplerine dönüştürülebilir.

> [!IMPORTANT]
> `$session.system_language` kullanımı sayesinde kullanıcı giriş diline göre açıklamalar otomatik getirilebilir.

> [!WARNING]
> Çok fazla JOIN kullanılan CDS'lerde filtreleme (`WHERE`) mümkün olduğunca erken yapılmalıdır.

---

# 💻 CDS Örneği 1 - Müşteri Bilgileri

```abap
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
                          and but0id.type = 'ZTCKN'
      left outer join dfkkbptaxnum
                          on but000.partner = dfkkbptaxnum.partner
                         and dfkkbptaxnum.taxtype = 'TR2'
      left outer join but0id as pasaport
                          on but000.partner = pasaport.partner
                         and pasaport.type = 'FS0002'
      left outer join kna1
                          on but000.partner = kna1.kunnr
      left outer join adrc
                          on kna1.adrnr = adrc.addrnumber
      left outer join adr2
                          on kna1.adrnr = adr2.addrnumber
                         and adr2.r3_user = '3'
      left outer join adr6
                          on kna1.adrnr = adr6.addrnumber
                         and adr6.flgdefault = 'X'
      left outer join t005u
                          on t005u.mandt = but000.client
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

    cast(
        case
            when but000.xsexm = 'X' then '2'
            when but000.xsexf = 'X' then '1'
        end
    as bu_sexid ) as SEX,

    cast(
        case
            when but000.type = '1'
                then concat_with_space( but000.name_first, but000.name_last, 1 )
            else concat(
                    concat( but000.name_org1, but000.name_org2 ),
                    concat( but000.name_org3, but000.name_org4 ) )
        end
    as zepcrm_dd138 ) as MUSTERIAD,

    cast(
        case
            when but000.type = '1'
                then but000.name_first
            else concat(
                    concat( but000.name_org1, but000.name_org2 ),
                    concat( but000.name_org3, but000.name_org4 ) )
        end
    as zepcrm_dd138 ) as MUSTERI_AD,

    cast(
        case
            when but000.type = '1'
                then but000.name_last
        end
    as zepcrm_dd138 ) as MUSTERI_SOYAD,

    cast( but0id.idnumber as zepcrm_dd140 ) as TCKN,
    cast( dfkkbptaxnum.taxnum as zepcrm_dd141 ) as VERGINO,
    cast( pasaport.idnumber as zepcrm_dd142 ) as PASAPORTNO,

    cast(
        case
            when but0id.idnumber is not null then but0id.idnumber
            when dfkkbptaxnum.taxnum is not null then dfkkbptaxnum.taxnum
            when pasaport.idnumber is not null then pasaport.idnumber
        end
    as zepcrm_dd143 ) as TCKN_VERGI_PASS,

    cast( adr2.telnr_long as zepcrm_dd139 ) as TELNR_LONG,
    cast( adr2.tel_number as zepcrm_dd139 ) as TEL_NUMBER,

    adr2.country as TEL_COUNTRY,

    cast( adr6.smtp_addr as zepcrm_dd144 ) as SMTP_ADDR,

    cast(
        concat_with_space(
            concat_with_space(
                adrc.street,
                adrc.str_suppl1,
                1
            ),
            adrc.str_suppl2,
            1
        )
    as zepcrm_dd145 ) as ADRES,

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
```

---

# 💻 CDS Örneği 2 - Müşteri İletişim Form Listesi

```abap
@AbapCatalog.sqlViewName: 'ZEPCRM_DDL004'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Müşteri İletişim Form Listesi'

define view ZEPCRM_CDS004
as
select
  from zepcrm_t010   as ZCRMT010
       left outer join zepcrm_t001   as ZCRMT001
            on ZCRMT010.potansiyel_musteri_id = ZCRMT001.potansiyel_musteri_id
       left outer join zepcrm_ddl003 as ZCRMDDL003
            on ZCRMT010.musteri_gelis_id = ZCRMDDL003.musteri_gelis_id
       left outer join zepcrm_t003   as ZCRMT003
            on ZCRMT010.potansiyel_musteri_id = ZCRMT003.potansiyet_musteri_id
       left outer join zepcrm_t039   as ZCRMT039
            on ZCRMT010.proje = ZCRMT039.swenr
       left outer join usr21 as USR21
            on ZCRMT010.musteri_temsilcisi = USR21.bname
       left outer join adrp as ADRP
            on USR21.persnumber = ADRP.persnumber
       left outer join t002t as T002T
            on ZCRMT010.dil = T002T.sprsl
           and T002T.spras = $session.system_language
       left outer join zepre_t023 as ZRET023
            on ZCRMT010.proje = ZRET023.swenr
       left outer join vibdbe as VIBDBE
            on ZCRMT010.proje = VIBDBE.swenr
       left outer join zepcrm_ddl014 as TEMSILCI
            on ZCRMT010.potansiyel_musteri_id = TEMSILCI.potansiyel_musteri_id
       left outer join v_usr_name as MUSTERITEMSILCI
            on TEMSILCI.musteri_temsilcisi = MUSTERITEMSILCI.bname
       left outer join zepcrm_t014 as ZCRMT014
            on ZCRMT010.daire_tipi = ZCRMT014.daire_tip_id
           and ZCRMT014.langu = $session.system_language
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

    ZCRMDDL003.aktivite_sayisi as aranma_sayisi,
    ZCRMT010.musteri_kampanya_id,
    ZCRMDDL003.aktivite_sayisi,

    case
        when ZCRMDDL003.aktivite_sayisi > 0 then ZCRMDDL003.durum
        when ZCRMT010.musteri_temsilcisi <> ' ' then 2
        else 1
    end as DURUM_NO,

    case
        when ZCRMDDL003.aktivite_sayisi > 0 then
            case
                when ZCRMDDL003.durum = 3 then 'İletişim Kuruldu'
                when ZCRMDDL003.durum = 6 then 'Ulaşılamadı'
                when ZCRMDDL003.durum = 5 then 'Tekrar Aranacak'
                when ZCRMDDL003.durum = 7 then 'Hatalı İletişim Bilgisi'
            end
        when ZCRMT010.musteri_temsilcisi <> ' ' then 'Atama Yapıldı'
        else 'Yeni'
    end as DURUM,

    concat_with_space( ADRP.name_first, ADRP.name_last, 1 ) as MUSTERI_TEMSILCI,

    T002T.sptxt as DIL_TANIM,

    case
        when ZRET023.lansman_adi is not null then ZRET023.lansman_adi
        when VIBDBE.xwetext is not null then VIBDBE.xwetext
        when ZCRMT039.lansman_adi is not null then ZCRMT039.lansman_adi
    end as PROJE_TANIM,

    ZCRMDDL003.ilk_aktivite_zamani,
    ZCRMDDL003.son_aktivite_zamani,

    MUSTERITEMSILCI.bname as SON_MUSTERI_TEMSILCISI,
    MUSTERITEMSILCI.name_text as SON_MUSTERI_TEMSILCI,

    ZCRMDDL003.aktivite_id,
    ZCRMDDL003.aktivite_zamani,
    ZCRMDDL003.ulasilamama_sayisi,

    ZCRMT003.maksimum_fiyat,
    ZCRMT003.minimum_fiyat,
    ZCRMT003.minimum_taksit,
    ZCRMT003.maksimum_taksit,
    ZCRMT003.taksit_tutari_belirtmedi,

    ZCRMT010.daire_tipi as WEBFORM_DAIRE_TIP_ID,
    ZCRMT014.daire_tipi as WEBFORM_DAIRE_TIPI
}
where silindi <> 'X'
```
