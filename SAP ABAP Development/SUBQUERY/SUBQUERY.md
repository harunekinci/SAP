# ✉️ SELECT İçerisinde Subquery Kullanımı

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-SUBQUERY-2E7D32?style=for-the-badge" alt="Technique" />
  <img src="https://img.shields.io/badge/CATEGORY-OPEN_SQL-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** ABAP Open SQL'de **Subquery**, başka bir `SELECT` ifadesinin sonucunu doğrudan sorgu içerisinde kullanmayı sağlar. Böylece geçici Internal Table oluşturmadan veya birden fazla `SELECT` çalıştırmadan ilişkili veriler tek sorguda okunabilir.

---

## 🛠️ Kullanılan Yapılar

| Yapı | Açıklama |
|------|----------|
| **IN ( SELECT ... )** | Alt sorgudan dönen birden fazla değeri filtrelemek için kullanılır. |
| **= ( SELECT ... )** | Alt sorgudan dönen tek bir değeri kullanır. |
| **SELECT SINGLE** | Tek kayıt okunacak senaryolarda tercih edilir. |

---

## 💻 IN ile Subquery

```abap
SELECT value_old,
       value_new,
       username,
       udate,
       utime
  FROM zchdr_cdpos
  INTO CORRESPONDING FIELDS OF TABLE @gt_out
 WHERE objectid IN (
          SELECT vbeln
            FROM vbap
           WHERE vbeln IN @s_vbeln
             AND abgru = '46' )
   AND objectclas = 'VERKBELEG'
   AND tabname    = 'VBAK'
   AND fname      = 'VDATU'.
```

---

## 💻 Tek Değer Döndüren Subquery

```abap
SELECT SINGLE prsdt
  FROM vbkd
  INTO @gs_sales_header_in-price_date
 WHERE posnr = '000000'
   AND vbeln = (
        SELECT vbeln
          FROM zbrs_ofk_log_b_h
         WHERE panid = @gt_input-panid ).
```

---

## 💻 Başka Bir Tablodan Filtreleme

```abap
SELECT SINGLE city,
              latitude,
              longitude
  FROM sgeocity
 WHERE city IN (
        SELECT cityfrom
          FROM spfli
         WHERE carrid = @carr_id
           AND connid = @conn_id )
 INTO (@city,
       @lati,
       @longi).
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `=` ile kullanılan Subquery yalnızca **tek kayıt** döndürmelidir. Birden fazla kayıt dönmesi durumunda çalışma zamanı hatası oluşabilir.

> [!TIP]
> `IN ( SELECT ... )`, geçici Internal Table oluşturmadan ilişkili kayıtları filtrelemek için oldukça kullanışlıdır.

> [!TIP]
> Subquery sayesinde birden fazla `SELECT` yerine tek SQL ifadesi yazılarak kod okunabilirliği artırılabilir.

> [!WARNING]
> Karmaşık veya büyük veri hacmine sahip Subquery'lerde performans açısından Execution Plan kontrol edilmeli, gerektiğinde `JOIN` kullanımı değerlendirilmelidir.
