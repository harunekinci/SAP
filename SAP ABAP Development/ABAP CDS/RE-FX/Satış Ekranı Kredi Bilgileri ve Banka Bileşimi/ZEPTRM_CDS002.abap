@AbapCatalog.sqlViewName: 'ZEPTRM_DDL002'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Satış Ekranı Kredi Bilgileri ve banka bileşimi'
define view ZEPTRM_CDS002
  as select distinct from zepre_t036 as t036
  association [1..1] to bnka on bnka.bankl = t036.bankl
{
  t036.sozlesme,
  t036.bukrs,
  t036.proje,
  t036.bbolum,
  t036.odenen_katkipayi,
  t036.emlakkonut_kpt,
  t036.yuklenici_kpt,
  t036.kapandi,
  case t036.kapandi
   when 'X' then 'KAPANDI'
   else 'AÇIK ' end      as KREDIDURUMU,
  bnka.banks,
  bnka.bankl,
  bnka.banka,
  bnka.brnch,
  t036.tutar,
  t036.ipotektutar
}
  where t036.sozlesme <> ' '









