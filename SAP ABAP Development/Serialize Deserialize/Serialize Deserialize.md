# ✉️ /UI2/CL_JSON — Kurumsal Hızlı Kullanım Kılavuzu

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.00%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/FORMAT-JSON-2E7D32?style=for-the-badge" alt="JSON" />
  <img src="https://img.shields.io/badge/STATUS-READY_FOR_PROD-C62828?style=for-the-badge" alt="Status" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `/UI2/CL_JSON`, ABAP veri yapıları (Strucutre, Internal Table vb.) ile JSON formatı arasında çift yönlü dönüşüm sağlayan, kernel bağımsız çalışan optimize bir kütüphanedir. Bu doküman, kütüphanenin en sık kullanılan metotlarını ve kritik parametrelerini sadeleştirilmiş olarak sunar.

---

## 🛠️ Temel Metotlar ve API İmza Yapısı

En sık kullanılan iki statik metodun yalın parametre yapıları:

### 1️⃣ SERIALIZE (ABAP -> JSON)
ABAP verilerini JSON string yapısına dönüştürür.

* `DATA` (Importing): Dönüştürülecek her türlü ABAP nesnesi (Table, Structure, Element)
* `COMPRESS` (Boolean, Default: `false`): `abap_true` verilirse `IS INITIAL` olan (boş) alanları JSON'a eklemez.
* `PRETTY_NAME` (Enum): Küçük harf veya camelCase isim dönüşüm modu.
* `FORMAT_OUTPUT` (Boolean, Default: `false`): `abap_true` verilirse JSON çıktısını okunabilir şekilde (Indent/Space) formatlar.
* `R_JSON` (Returning): Oluşan JSON string çıktısı.

### 2️⃣ DESERIALIZE (JSON -> ABAP)
JSON string yapısını mevcut ABAP nesnelerine eşler.

* `JSON` (Importing): Çözümlenecek JSON formatındaki string veri.
* `PRETTY_NAME` (Enum): JSON alanlarının ABAP bileşenlerine nasıl eşleneceğini belirleyen mod.
* `DATA` (Changing): Verinin basılacağı hedef ABAP nesnesi. Eşleşmeyen alanların mevcut değerleri korunur.

---

## ⚙️ PRETTY_NAME Parametre Modları

ABAP alan adları (`Büyük Harf` ve `Alt Çizgi`) ile JSON standartları (`camelCase`) arasındaki dönüşüm stratejileri:

| Mod (Enum Sabiti) | ABAP Alan Adı | JSON Alan Adı | Açıklama |
| :--- | :--- | :--- | :--- |
| `pretty_mode-none` | `MANDT_CARRID` | `MANDT_CARRID` | Olduğu gibi (Büyük harf) bırakır. |
| `pretty_mode-low_case` | `MANDT_CARRID` | `mandt_carrid` | Sadece küçük harfe çevirir. |
| `pretty_mode-camel_case` | `MANDT_CARRID` | `mandtCarrid` | Alt çizgileri kaldırır ve camelCase yapar. |

---

## 💻 Pratik Kod Örneği (Hızlı Başlangıç)

Aşağıdaki yapı, standart bir tablonun camelCase formatında JSON'a dönüştürülmesini ve ardından tekrar ABAP tablosuna geri yüklenmesini gösterir:

```abap
CLASS lcl_demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS execute.
ENDCLASS.

CLASS lcl_demo IMPLEMENTATION.
  METHOD execute.
    DATA: lt_flight TYPE STANDARD TABLE OF sflight,
          lv_json   TYPE string.

    " 1. Veriyi Çek
    SELECT * FROM sflight INTO TABLE lt_flight UP TO 10 ROWS.

    " 2. ABAP -> JSON (Boş alanları gizle ve camelCase yap)
    lv_json = /ui2/cl_json=>serialize(
      data        = lt_flight
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      compress    = abap_true
    ).

    CLEAR lt_flight.

    " 3. JSON -> ABAP (Gelen camelCase veriyi ABAP tablosuna geri doldur)
    /ui2/cl_json=>deserialize(
      EXPORTING 
        json        = lv_json 
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case 
      CHANGING 
        data        = lt_flight 
    ).
  ENDMETHOD.
ENDCLASS.
