# 📊 SAP ABAP CDS View (Core Data Services)

<br/>

<div align="center">

<img src="https://img.shields.io/badge/SAP-ABAP_7.50+-008FD3?style=for-the-badge&logo=sap&logoColor=white" />
<img src="https://img.shields.io/badge/HANA-CDS-success?style=for-the-badge" />
<img src="https://img.shields.io/badge/DATABASE-Code_Pushdown-blue?style=for-the-badge" />

</div>

<br/>

> **Amaç:** CDS (Core Data Services), veriyi mümkün olduğunca veritabanında işleyerek (Code Pushdown) performanslı veri erişimi sağlayan modern SAP geliştirme teknolojisidir. CDS View'lar; okunabilir, yeniden kullanılabilir ve yüksek performanslı veri modelleri oluşturmak için kullanılır.

---

# 📚 İçindekiler

1. Basit CDS View
2. WHERE Kullanımı
3. INNER JOIN
4. LEFT OUTER JOIN
5. Association
6. CASE
7. CAST
8. COALESCE
9. GROUP BY
10. COUNT
11. SUM
12. AVG
13. MAX - MIN
14. DISTINCT
15. Parameter CDS
16. UNION
17. String Fonksiyonları
18. Tarih Fonksiyonları
19. Session Variables
20. Authorization Check
21. UI Annotation
22. Open SQL'den CDS Kullanımı
23. Parametreli CDS Çağırma
24. Association Path Expression
25. CDS Extension

---

# 💻 1. Basit CDS View

CDS View Entity oluşturmanın en temel örneğidir. Veritabanındaki alanları performanslı şekilde uygulamaya sunar.

```abap
@EndUserText.label: 'Customer List'

define view entity ZI_CUSTOMER
  as select from kna1
{
      key kunnr,
          land1,
          name1,
          ort01,
          regio
}
```

---

# 💻 2. WHERE Kullanımı

Belirli koşullara göre kayıtları filtrelemek için kullanılır. Filtreleme veritabanında yapıldığı için gereksiz veri transferi engellenir.

```abap
define view entity ZI_CUSTOMER_TR

  as select from kna1

{
      key kunnr,
          name1,
          land1
}

where land1 = 'TR'
```

---

# 💻 3. INNER JOIN

İki tablo arasında eşleşen kayıtları getirir. İlişkisel veri okumalarında en sık kullanılan JOIN türüdür.

```abap
define view entity ZI_SALES

  as select from vbak

  inner join vbap
     on vbak.vbeln = vbap.vbeln

{
    key vbak.vbeln,
        vbap.posnr,
        vbak.erdat,
        vbap.matnr,
        vbap.kwmeng
}
```

---

# 💻 4. LEFT OUTER JOIN

Sol tablodaki tüm kayıtları getirir. Sağ tabloda eşleşme yoksa ilgili alanlar NULL olarak döner.

```abap
define view entity ZI_CUSTOMER_ORDER

  as select from kna1

  left outer join vbak
    on kna1.kunnr = vbak.kunnr

{
    key kna1.kunnr,
        kna1.name1,
        vbak.vbeln
}
```

---

# 💻 5. Association

Association, CDS içerisindeki ilişkileri tanımlar. Gerektiğinde JOIN oluşturduğu için okunabilirliği artırır.

```abap
define view entity ZI_SALES

  as select from vbak

association [0..*] to vbap as _Items
    on $projection.vbeln = _Items.vbeln

{
    key vbeln,
        erdat,
        _Items
}
```

---

# 💻 6. CASE

Koşullara göre hesaplanan yeni alanlar oluşturmak için kullanılır.

```abap
case land1
    when 'TR' then 'Turkey'
    when 'DE' then 'Germany'
    else 'Other'
end as country_name
```

---

# 💻 7. CAST

Bir alanın veri tipini CDS içerisinde dönüştürmek için kullanılır.

```abap
cast( netwr as abap.curr(15,2) ) as amount
```

---

# 💻 8. COALESCE

NULL değerleri belirtilen varsayılan değerle değiştirir.

```abap
coalesce( name2, name1 ) as customer_name
```

---

# 💻 9. GROUP BY

Aggregate fonksiyonlarla birlikte kayıtları gruplamak için kullanılır.

```abap
define view entity ZI_TOTAL

as select from vbap

{
      matnr,
      sum( kwmeng ) as quantity
}

group by matnr
```

---

# 💻 10. COUNT

Kayıt sayısını hesaplamak için kullanılır.

```abap
count( * ) as total_count
```

---

# 💻 11. SUM

Sayısal alanların toplamını hesaplar.

```abap
sum( netwr ) as total_amount
```

---

# 💻 12. AVG

Ortalama değer hesaplamak için kullanılır.

```abap
avg( netwr ) as average_amount
```

---

# 💻 13. MAX - MIN

En büyük ve en küçük değeri döndürür.

```abap
max( erdat ) as last_date,
min( erdat ) as first_date
```

---

# 💻 14. DISTINCT

Tekrarlayan kayıtları kaldırır.

```abap
select distinct land1
```

---

# 💻 15. Parameter CDS

Dinamik parametre alabilen CDS View tanımıdır.

```abap
define view entity ZI_CUSTOMER

with parameters

    p_land : land1_gp

as select from kna1

{
      kunnr,
      name1
}

where land1 = $parameters.p_land
```

---

# 💻 16. UNION

Aynı yapıya sahip iki sorgunun sonucunu birleştirir.

```abap
select from table1
{
    field1
}

union

select from table2
{
    field1
}
```

---

# 💻 17. String Fonksiyonları

Metin alanları üzerinde işlem yapmak için kullanılır.

```abap
concat( name1, name2 ) as fullname

upper( name1 )

lower( name1 )

substring( name1,1,5 )
```

---

# 💻 18. Tarih Fonksiyonları

Tarih hesaplamalarını veritabanı seviyesinde gerçekleştirir.

```abap
dats_add_days(
    erdat,
    30,
    'FAIL'
)
```

---

# 💻 19. Session Variables

SAP oturum bilgilerine erişmek için kullanılır.

```abap
$session.user

$session.client

$session.system_language
```

---

# 💻 20. Authorization Check

DCL yetkilendirmesini CDS seviyesinde aktif eder.

```abap
@AccessControl.authorizationCheck: #CHECK
```

---

# 💻 21. UI Annotation

Fiori uygulamalarının görünümünü metadata üzerinden belirler.

```abap
@UI.lineItem: [
{
    position: 10
}
]
```

---

# 💻 22. Open SQL'den CDS Kullanımı

CDS View'lar ABAP Open SQL'de normal tablo gibi kullanılabilir.

```abap
SELECT *

FROM zi_customer

INTO TABLE @DATA(gt_customer).
```

---

# 💻 23. Parametreli CDS Çağırma

ABAP tarafından parametre gönderilerek CDS çağrılır.

```abap
SELECT *

FROM zi_customer(
      p_land = 'TR'
)

INTO TABLE @DATA(gt_customer).
```

---

# 💻 24. Association Path Expression

Association üzerinden ilişkili verilere erişmek için kullanılır.

```abap
_Items.matnr

_Items.kwmeng
```

---

# 💻 25. CDS Extension

Standart CDS View'ları değiştirmeden yeni alan eklemek için kullanılır.

```abap
extend view entity I_BusinessPartner

with ZI_BP_EXT

{
    zzfield
}
```

---

# 💡 Özet

> [!TIP]
> CDS View'lar klasik Open SQL'e göre daha yüksek performans sağlar çünkü işlemler veritabanında gerçekleştirilir (**Code Pushdown**).

> [!TIP]
> Association kullanımı gereksiz JOIN'leri azaltarak daha okunabilir veri modelleri oluşturur.

> [!TIP]
> Annotation'lar sayesinde aynı CDS View; RAP, Fiori ve OData servislerinde tekrar kullanılabilir.

> [!IMPORTANT]
> Yeni SAP geliştirmelerinde mümkün olduğunca klasik Database View yerine **CDS View Entity** kullanılması önerilir.

> [!WARNING]
> Büyük veri kümelerinde performans için filtreleme (`WHERE`), gruplama (`GROUP BY`) ve hesaplamaların mümkün olduğunca CDS seviyesinde yapılması tavsiye edilir.
