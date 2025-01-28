@AbapCatalog.sqlViewName: 'ZEPFI_CDS003'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Kur Farkı Faturası 3'
define view zepfi_ddl003 as select from acdoca as a

        left outer join lfa1 as la on a.lifnr = la.lifnr

        left outer join lfb1 as lb on a.lifnr  = lb.lifnr and
                                      a.rbukrs = lb.bukrs

        left outer join t030h as t on lb.akont = t.hkont
 {
        a.rbukrs,
    a.lifnr,
    a.augdt,
    a.augbl,
    a.rldnr ,
    a.umskz ,
    a.rwcur ,
    a.awref_rev,
    a.blart,
    a.koart,
    la.name1,
    la.name2,
    lb.akont,
    t.lsrea,
    t.lhrea,

     SUBSTRING(augdt, 1 , 4) as lv_gjahr

}
    group by a.rbukrs, a.lifnr, a.augdt, a.augbl, a.rldnr, a.umskz, a.rwcur, a.awref_rev, a.blart, a.koart,
             la.name1, la.name2, lb.akont, t.lsrea, t.lhrea
