# ✉️ AT NEW / AT END OF ile Grup Bazlı Veri Toplama

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-CONTROL_BREAK-2E7D32?style=for-the-badge" alt="Control Break" />
  <img src="https://img.shields.io/badge/CATEGORY-INTERNAL_TABLE-C62828?style=for-the-badge" alt="Internal Table" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `AT NEW` ve `AT END OF` ifadeleri, sıralanmış internal table üzerinde aynı anahtar alanına ait kayıtları tek grup halinde işlemek için kullanılır. Bu sayede grup başlangıcında hesaplamalar yapılabilir, grup içerisindeki kayıtlar işlenebilir ve grup sonunda tek bir çıktı satırı oluşturulabilir.

---

## 🛠️ Kullanılan Yapılar

| Yapı | Amaç |
|------|------|
| **SORT** | Control Break ifadelerinin doğru çalışabilmesi için tabloyu sıralar. |
| **AT NEW** | Yeni grubun ilk kaydında çalışır. |
| **AT END OF** | Grubun son kaydında çalışır. |
| **MOVE-CORRESPONDING** | İlk kaydı çıktı yapısına aktarır. |
| **READ TABLE** | Partner bilgilerini okur. |
| **LOOP WHERE** | Aynı projeye ait finansal toplamları hesaplar. |
| **RANGE Table** | Grup içerisindeki kayıt sayısını belirlemek amacıyla kullanılır. |

---

## 💻 İşleyiş

```text
SORT lt_data BY SMENR
        │
        ▼
LOOP lt_data
        │
        ▼
AT NEW SMENR
        │
        ├── Çıktı yapısını doldur
        ├── Hesaplamaları yap
        └── Finansal toplamları hesapla
        │
        ▼
Her kayıt için
        │
        ├── Partner bilgisini oku
        └── Alıcı adını oluştur
        │
        ▼
AT END OF SMENR
        │
        ├── Sonucu GT_OUT'a ekle
        └── Geçici değişkenleri temizle
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> `AT NEW` ve `AT END OF` ifadelerinin doğru çalışabilmesi için internal table mutlaka ilgili alanlara göre **SORT** edilmelidir.

> [!TIP]
> Grup bazlı hesaplamalar (`MOVE-CORRESPONDING`, finansal toplamlar, oran hesapları vb.) `AT NEW` içerisinde yapılmalıdır.

> [!TIP]
> Aynı gruba ait kayıtlar işlenirken string birleştirme, partner toplama veya liste oluşturma işlemleri normal `LOOP` içerisinde gerçekleştirilebilir.

> [!WARNING]
> `CLEAR` işlemleri mutlaka `AT END OF` bloğunda yapılmalıdır. Aksi durumda önceki grubun verileri sonraki gruba taşınabilir.

---

## 💻 Kod

```abap
SORT lt_data BY smenr ASCENDING.

DATA lr_smenr TYPE RANGE OF smenr.

LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

  APPEND VALUE #(
    sign   = 'I'
    option = 'EQ'
    low    = <fs_data>-smenr ) TO lr_smenr.

  AT NEW smenr.

    MOVE-CORRESPONDING <fs_data> TO ls_out.

    ls_out-zeksm2oran =
      COND #( WHEN ls_out-zm1_14 <> 0
              THEN ls_out-exp_value / ls_out-zm1_14
              ELSE 0 ).

    ls_out-zindstsfiyat =
      ls_out-bb_fiyat_s - ls_out-indtutar.

    ls_out-zindstsfiyatzm =
      COND #( WHEN ls_out-zm1_14 <> 0
              THEN ls_out-zindstsfiyat / ls_out-zm1_14
              ELSE 0 ).

    ls_out-zeksstsoran =
      COND #( WHEN ls_out-zindstsfiyat <> 0
              THEN ( ls_out-exp_value / ls_out-zindstsfiyat ) * 100
              ELSE 0 ).

    LOOP AT gt_acdoca ASSIGNING FIELD-SYMBOL(<fs_acdoca>)
         WHERE zuonr = ls_out-swenr.

      ls_out-tsl += <fs_acdoca>-tsl.

    ENDLOOP.

  ENDAT.

  READ TABLE gt_but000 ASSIGNING FIELD-SYMBOL(<fs_but00>)
       WITH KEY partner = <fs_data>-partner.

  IF sy-subrc = 0.

    lv_aliciad =
      <fs_but00>-name_org1 &&
      <fs_but00>-name_org2 &&
      <fs_but00>-name_org3.

    IF lv_aliciad IS INITIAL.
      lv_aliciad =
        <fs_but00>-name_first &&
        <fs_but00>-name_last.
    ENDIF.

    IF lv_aliciad IS NOT INITIAL.

      IF lines( lr_smenr ) > 1.

        CONCATENATE
          lv_aliciad
          ls_out-zaliciad
          INTO ls_out-zaliciad
          SEPARATED BY ' / '.

      ELSE.

        CONCATENATE
          lv_aliciad
          ls_out-zaliciad
          INTO ls_out-zaliciad.

      ENDIF.

    ENDIF.

  ENDIF.

  AT END OF smenr.

    APPEND ls_out TO gt_out.

    CLEAR:
      ls_out,
      lr_smenr.

  ENDAT.

ENDLOOP.
```
