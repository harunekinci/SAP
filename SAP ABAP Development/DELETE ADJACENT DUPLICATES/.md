# ✉️ DELETE ADJACENT DUPLICATES

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/KEYWORD-DELETE__ADJACENT__DUPLICATES-2E7D32?style=for-the-badge" alt="Keyword" />
  <img src="https://img.shields.io/badge/CATEGORY-INTERNAL_TABLE-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `DELETE ADJACENT DUPLICATES`, internal table içerisinde ardışık tekrar eden kayıtları silmek için kullanılan ABAP deyimidir. Yalnızca yan yana bulunan kayıtları karşılaştırdığı için işlem öncesinde tablo mutlaka uygun alanlara göre `SORT` edilmelidir. Korunacak kayıt ise yapılan sıralama düzenine göre belirlenir.

---

## 🛠️ Parametreler

| Komut | Açıklama |
|-------|----------|
| **FROM** | İşlem yapılacak internal table |
| **COMPARING** | Tekrar kontrolünde kullanılacak alanlar |

---

## 💻 Kullanım

```abap
SORT lt_header BY vbeln   ASCENDING
                  cmdoc   ASCENDING
                  vbelf_b DESCENDING
                  vbelf_a DESCENDING.

DELETE ADJACENT DUPLICATES FROM lt_header COMPARING vbeln cmdoc.
```
