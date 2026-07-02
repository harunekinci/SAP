# ✉️ EXPORT TO MEMORY ID & CL_SALV_BS_RUNTIME_INFO

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-MEMORY__TRANSFER-2E7D32?style=for-the-badge" alt="Technique" />
  <img src="https://img.shields.io/badge/CATEGORY-DATA_EXTRACTION-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** Bir raporun ürettiği veriyi yeniden kullanmanın iki yaygın yöntemi vardır. Eğer kaynak programa müdahale edilebiliyorsa **EXPORT / IMPORT TO MEMORY ID** ile veri doğrudan paylaşılabilir. Kaynak programa müdahale edilemiyorsa **CL_SALV_BS_RUNTIME_INFO** kullanılarak ALV ekrana basılmadan oluşturulan veri bellekten okunabilir.

---

## 🛠️ Yöntemler

| Yöntem | Kullanım Senaryosu |
|--------|--------------------|
| **EXPORT / IMPORT TO MEMORY ID** | Kaynak programa müdahale edilebiliyorsa |
| **CL_SALV_BS_RUNTIME_INFO** | Standart veya değiştirilemeyen ALV raporlarının verisini okumak için |

---

## 📌 EXPORT / IMPORT TO MEMORY ID

Program, `P_MEMID` parametresi dolu geldiğinde ALV'yi göstermeden veriyi Memory ID'ye aktarır.

```abap
IF p_memid IS NOT INITIAL.

  DATA lt_data TYPE TABLE OF zbrssd0640.

  lt_data = CORRESPONDING #( gt_data ).

  EXPORT itab FROM lt_data
         TO MEMORY ID p_memid.

ELSE.

  PERFORM display_data.

ENDIF.
```

### Memory'den Okunması

```abap
DATA lv_memid TYPE text60 VALUE 'ZSD_ENVANTER'.

FREE MEMORY ID lv_memid.

EXPORT lt_data[]
       TO MEMORY ID lv_memid.

SUBMIT zbrs_sd_lastik_envanter
       AND RETURN
       WITH p_memid = lv_memid.

IMPORT itab
       TO lt_data
       FROM MEMORY ID lv_memid.
```

---

## 📌 CL_SALV_BS_RUNTIME_INFO

Kaynak programa hiçbir müdahale yapılmadan ALV verisi okunabilir.

```abap
cl_salv_bs_runtime_info=>set(
  EXPORTING
    display  = abap_false
    metadata = abap_false
    data     = abap_true ).

SUBMIT rm07mm60
       AND RETURN.

cl_salv_bs_runtime_info=>get_data_ref(
  IMPORTING
    r_data = lr_data ).

cl_salv_bs_runtime_info=>clear( ).
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `EXPORT / IMPORT TO MEMORY ID` yöntemi kullanılacaksa kaynak programın Memory ID desteği vermesi gerekir.

> [!TIP]
> Standart SAP raporları veya müdahale edilemeyen Z raporlarında `CL_SALV_BS_RUNTIME_INFO` en pratik veri alma yöntemidir.

> [!WARNING]
> `CL_SALV_BS_RUNTIME_INFO=>CLEAR( )` çağrısı mutlaka yapılmalıdır. Aksi halde sonraki ALV ekranları beklenmeyen şekilde etkilenebilir.

---

## 💻 Örnek Function Module

```abap
FUNCTION zbrs_sd_lastik_envanter.

  DATA:
    lv_memid TYPE text60 VALUE 'ZSD_ENVANTER',
    lt_data  TYPE TABLE OF zbrssd0640.

  FREE MEMORY ID lv_memid.

  EXPORT lt_data
         TO MEMORY ID lv_memid.

  SUBMIT zbrs_sd_lastik_envanter
         AND RETURN
         WITH p_memid = lv_memid.

  IMPORT itab
         TO lt_data
         FROM MEMORY ID lv_memid.

  et_data = CORRESPONDING #( lt_data ).

ENDFUNCTION.
```
