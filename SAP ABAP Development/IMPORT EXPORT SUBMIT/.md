# ✉️ CL_SALV_BS_RUNTIME_INFO & EXPORT TO MEMORY ID

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/CLASS-CL__SALV__BS__RUNTIME__INFO-2E7D32?style=for-the-badge" alt="Class" />
  <img src="https://img.shields.io/badge/CATEGORY-MEMORY_%26_ALV-C62828?style=for-the-badge" alt="Category" />
</div>

<br/>

> **Sistem Mimarı Özeti:** SAP'te başka bir programın ürettiği ALV verisine erişmek için iki yaygın yöntem bulunur. İlk yöntem olan `CL_SALV_BS_RUNTIME_INFO`, hedef programa hiçbir müdahalede bulunmadan ALV ekranına gönderilecek veriyi bellekten yakalamaya imkan sağlar. İkinci yöntem ise `EXPORT TO MEMORY ID` kullanılarak hedef programa küçük bir geliştirme yapılıp verinin Shared Memory üzerinden çağıran programa aktarılmasıdır.

---

## 🛠️ Kullanılan Yapılar

| Yapı | Açıklama |
|------|----------|
| **CL_SALV_BS_RUNTIME_INFO=>SET** | ALV ekranını göstermeden veriyi Runtime Memory'e yönlendirir. |
| **CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF** | Yakalanan ALV verisinin referansını döndürür. |
| **CL_SALV_BS_RUNTIME_INFO=>CLEAR** | Runtime mekanizmasını temizler. Mutlaka çağrılmalıdır. |
| **EXPORT TO MEMORY ID** | Veriyi ABAP Memory'e aktarır. |
| **IMPORT FROM MEMORY ID** | Aktarılan veriyi başka programda okur. |
| **SUBMIT ... AND RETURN** | Hedef programı çağırıp kontrolü geri döndürür. |

---

## 📌 Yöntem Karşılaştırması

| Yöntem | Ne Zaman Kullanılır |
|---------|---------------------|
| **CL_SALV_BS_RUNTIME_INFO** | Hedef programa müdahale edilemiyorsa |
| **EXPORT TO MEMORY ID** | Hedef program geliştirilebiliyorsa |
| **IMPORT FROM MEMORY ID** | EXPORT edilen veriyi okumak için |

---

## 💻 EXPORT TO MEMORY ID

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

---

## 💻 CL_SALV_BS_RUNTIME_INFO

```abap
DATA lr_data TYPE REF TO data.

cl_salv_bs_runtime_info=>set(
  EXPORTING
    display  = abap_false
    metadata = abap_false
    data     = abap_true ).

SUBMIT rm07mm60
       WITH matnr = '123'
       AND RETURN.

TRY.

    cl_salv_bs_runtime_info=>get_data_ref(
      IMPORTING
        r_data = lr_data ).

  CATCH cx_salv_bs_sc_runtime_info.

ENDTRY.

cl_salv_bs_runtime_info=>clear( ).
```

---

> [!IMPORTANT]
> `CL_SALV_BS_RUNTIME_INFO=>CLEAR( )` çağrısı mutlaka yapılmalıdır. Aksi halde sonraki ALV ekranları da Runtime Mode'da çalışmaya devam edebilir.

> [!TIP]
> Hedef program sizin geliştirdiğiniz bir Z Programı ise `EXPORT TO MEMORY ID` yöntemi daha hızlı ve daha güvenilirdir. Standart SAP programlarında ise çoğunlukla `CL_SALV_BS_RUNTIME_INFO` tercih edilir.
