@AbapCatalog.sqlViewName: 'ZEPFI_CDS001'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Kur farkı faturası'
define view zepfi_ddl001 as select from acdoca as a

        left outer join kna1 as ka on a.kunnr = ka.kunnr

        left outer join knb1 as kb on a.kunnr  = kb.kunnr and
                                      a.rbukrs = kb.bukrs

        left outer join t030h as t on kb.akont = t.hkont
 {
    a.rbukrs,
    a.kunnr,
    a.augdt,
    a.augbl,
    a.rldnr ,
    a.umskz ,
    a.rwcur ,
    a.awref_rev,
    a.blart,
    a.koart,
    ka.name1,
    ka.name2,
    kb.akont,
    t.lsrea,
    t.lhrea,

     SUBSTRING(augdt, 1 , 4) as lv_gjahr
}
    group by a.rbukrs, a.kunnr, a.augdt, a.augbl, a.rldnr, a.umskz, a.rwcur, a.awref_rev, a.blart, a.koart,
             ka.name1, ka.name2, kb.akont, t.lsrea, t.lhrea
