# ✉️ MODIF ID ile Dinamik Selection Screen

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-MODIF__ID-2E7D32?style=for-the-badge" alt="Technique" />
  <img src="https://img.shields.io/badge/CATEGORY-SELECTION_SCREEN-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `MODIF ID`, Selection Screen üzerindeki alanları gruplandırarak çalışma anında görünür, gizli, aktif veya pasif hale getirmek için kullanılır. Genellikle Radio Button veya Check Box seçimlerine göre ekranın dinamik olarak değiştirilmesinde tercih edilir.

---

## 🛠️ Kullanılan Yapılar

| Yapı | Açıklama |
|------|----------|
| **MODIF ID** | Selection Screen elemanlarını gruplandırır. |
| **AT SELECTION-SCREEN OUTPUT** | Ekran oluşturulmadan önce dinamik değişiklik yapılmasını sağlar. |
| **SCREEN-GROUP1** | Alanın ait olduğu MODIF ID grubunu belirtir. |
| **SCREEN-ACTIVE** | Alanın görünür/gizli olmasını kontrol eder. |

---

## 💻 Örnek Kullanım

```abap
TABLES: kna1.

SELECTION-SCREEN BEGIN OF BLOCK b1
  WITH FRAME TITLE text-001.

PARAMETERS:
  rb1 RADIOBUTTON GROUP rb
      USER-COMMAND com
      DEFAULT 'X',

  rb2 RADIOBUTTON GROUP rb.

SELECT-OPTIONS:
  s_kunnr FOR kna1-kunnr
  MODIF ID g1.

SELECTION-SCREEN END OF BLOCK b1.

PARAMETERS:
  p_vornr AS CHECKBOX DEFAULT 'X'.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.

    IF rb2 = abap_true
       AND screen-group1 = 'G1'.

      screen-active = '0'.

      MODIFY SCREEN.

    ENDIF.

  ENDLOOP.
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `MODIF ID` en fazla **3 karakter** olabilir ve `SCREEN-GROUP1` üzerinden kontrol edilir.

> [!TIP]
> `SCREEN-ACTIVE = '0'` kullanıldığında ilgili grubun tüm bileşenleri (Label, Low, High, Multiple Selection vb.) birlikte gizlenir.

> [!TIP]
> `USER-COMMAND` tanımlanan Radio Button veya Check Box değiştiğinde `AT SELECTION-SCREEN OUTPUT` olayı tekrar tetiklenir ve ekran dinamik olarak güncellenir.

> [!WARNING]
> Dinamik ekran değişiklikleri yalnızca `AT SELECTION-SCREEN OUTPUT` olayında yapılmalıdır. Başka event'lerde yapılan `SCREEN` değişiklikleri beklenen sonucu vermeyebilir.
