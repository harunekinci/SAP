@AbapCatalog.sqlViewName: 'ZEPFI_CDS002'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Kur Farkı Faturası 2'
define view ZEPFI_DDL002 as select from acdoca {
    rldnr,
    rbukrs,
    belnr,
    gjahr,
    kunnr,
    rwcur,
    augdt,
    augbl,
    racct,
    hsl

}

    where koart = 'S' and
        ( racct like '646%' or racct like '656%' ) and
          hsl <> 0

    group by rldnr, rbukrs, belnr, gjahr, kunnr, rwcur, augdt, augbl, racct, hsl
