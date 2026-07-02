# 🔍 ZCL_SQL_SUBQUERY_TEMPLATES

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/SQL-SUBQUERY-2E7D32?style=for-the-badge&logo=quicklook&logoColor=white" alt="Query" />
  <img src="https://img.shields.io/badge/STATUS-PRODUCTION_READY-C62828?style=for-the-badge" alt="Status" />
</div>

<br/>

> **Sistem Mimarı Özeti:** Bu doküman, SAP ABAP Open SQL mimarisinde sıkça kullanılan alt sorgu (*Subquery*) desenlerini ve bu sorguların veri sözlüğü (SE11) bağımlılıklarını kurumsal standartlara uygun olarak modeller. Alt sorgular, veri kümesini DB katmanında filtreleyerek uygulama sunucusuna taşınan veri trafiğini (Network I/O) optimize etmek için deklaratif bir yapı sunar.

---

## 🛠️ SQL Deyimleri ve Sözdizimi (Syntax) Yapıları

Sistemde kullanılan 3 temel kurumsal alt sorgu senaryosunun teknik kod blokları:

### 1️⃣ Senaryo 1: Değişiklik Belgeleri Filtreleme (ZCHDR_CDPOS & VBAP)
Bu sorgu, belirli bir ret gerekçesine (`ABGRU = '46'`) sahip satış belgelerinin termin tarihi (`VDATU`) üzerindeki kullanıcı değişiklik geçmişini yakalar.


```abap
---
SELECT value_old, value_new, username, udate, utime
  FROM zchdr_cdpos INTO CORRESPONDING FIELDS OF TABLE @gt_out
  WHERE objectid IN ( SELECT vbeln FROM vbap WHERE vbeln IN @s_vbeln AND abgru EQ '46' ) 
   AND  objectclas EQ 'VERKBELEG'
   AND  tabname    EQ 'VBAK'
   AND  fname      EQ 'VDATU'.
---
select single prsdt
  from vbkd
  into @gs_sales_header_in-price_date
  where posnr eq '000000' 
   and  vbeln eq ( select  vbeln from zbrs_ofk_log_b_h where panid eq @gt_input-panid ).
---
SELECT SINGLE city, latitude, longitude 
         FROM sgeocity 
         WHERE city IN ( SELECT cityfrom 
                                FROM spfli 
                                WHERE carrid = @carr_id AND 
                                      connid = @conn_id ) 
         INTO (@city, @lati, @longi).  
   
