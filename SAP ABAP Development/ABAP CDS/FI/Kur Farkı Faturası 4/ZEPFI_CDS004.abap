@AbapCatalog.sqlViewName: 'ZEPFI_CDS004'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Kur Farkı Faturası 4'
define view zepfi_ddl004 as select from acdoca {

    rldnr,
    rbukrs,
    belnr,
    gjahr,
    lifnr,
    rwcur,
    augdt,
    augbl,
    racct,
    hsl
}
    where koart = 'S' and
        ( racct like '646%' or racct like '656%' ) and
          hsl <> 0

    group by rldnr, rbukrs, belnr, gjahr, lifnr, rwcur, augdt, augbl, racct, hsl
