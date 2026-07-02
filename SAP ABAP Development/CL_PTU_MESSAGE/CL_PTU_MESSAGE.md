# ✉️ CL_PTU_MESSAGE

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/CLASS-CL__PTU__MESSAGE-2E7D32?style=for-the-badge&logo=opsgenie&logoColor=white" alt="Class" />
  <img src="https://img.shields.io/badge/STATUS-READY_FOR_PROD-C62828?style=for-the-badge" alt="Status" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `cl_ptu_message`, SAP uygulamalarında süreç esnasında oluşan mesajları (Hata, Uyarı, Bilgi) merkezi bir yapıda toplayan, biriktiren ve kullanıcıya esnek arayüzlerle (ALV Grid veya Popup) sunan nesne tabanlı bir loglama framework bileşenidir. Geliştiricileri karmaşık log tablosu yönetimlerinden kurtararak temiz bir mesaj toplama ve gösterme arayüzü sağlar.

---

## 🛠️ SE24: Class Builder — cl_ptu_message Metot Yapıları

Sınıfın öne çıkan metotları ve parametre listesi:

### 1️⃣ ADD_TEXT Metodu Parametreleri
    
<table>
  <thead>
    <tr style="background-color: #1F4E79; color: white;">
      <th>Ty.</th>
      <th>Parameter</th>
      <th>Type Spec.</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>IV_TYPE</b></td>
      <td><code>TYPE BAPI_MTYPE</code></td>
      <td>Mesaj tipi (E: Error, W: Warning, I: Info, S: Success)</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>IV_TEXT</b></td>
      <td><code>TYPE STRING</code></td>
      <td>Eklenecek mesajın metni</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>IV_CUMULATE</b></td>
      <td><code>TYPE ABAP_BOOL OPTIONAL</code></td>
      <td>Aynı mesajların tek bir defa gösterilmesini tetikler</td>
    </tr>
  </tbody>
</table>

### 2️⃣ DISPLAY_LOG Metodu Parametreleri

<table>
  <thead>
    <tr style="background-color: #2e7d32; color: white;">
      <th>Ty.</th>
      <th>Parameter</th>
      <th>Type Spec.</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>IV_AS_POPUP</b></td>
      <td><code>TYPE CHAR01 OPTIONAL</code></td>
      <td>Log ekranını Popup (Diyalog Kutusu) olarak açar ('X')</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>IV_USE_GRID</b></td>
      <td><code>TYPE CHAR01 OPTIONAL</code></td>
      <td>Log listesini ALV Grid formatında gösterir ('X')</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>IV_FORCE_DISPLAY</b></td>
      <td><code>TYPE CHAR01 OPTIONAL</code></td>
      <td>Koşulsuz olarak log ekranının ekrana basılmasını zorlar ('X')</td>
    </tr>
  </tbody>
</table>

---

## 🗂️ İşlevsel Kontrol Metotları

### `HAS_MESSAGES( )` *(Mesaj Varlık Kontrolü)*
* **Dönüş Tipi (Returning):** `ABAP_BOOL` (`abap_true` / `abap_false`)
* **Açıklama:** Nesne içerisinde o ana kadar birikmiş herhangi bir log mesajı olup olmadığını kontrol eder. Özellikle boş log ekranlarının açılmasını engellemek için `DISPLAY_LOG` öncesinde kontrol olarak kararlı bir şekilde kullanılmalıdır.

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> **Boş Log Ekranı Engelleme (Defensive Programming)**  
> Kullanıcı deneyimini korumak adına, `display_log` metodunu çağırmadan önce mutlaka **`has_messages( )`** kontrolü yapılmalıdır. İçerisinde mesaj olmayan bir log nesnesi ekrana basılmaya çalışıldığında boş bir ALV ekranı açılmasını önler.

> [!TIP]
> **Mesaj Biriktirme ve Performans (IV_CUMULATE)**  
> Döngüsel işlemler (Örn: Çoklu kalem içeren fatura onayları) sırasında aynı hata mesajının defalarca loga eklenmesini engellemek için `iv_cumulate = abap_true` parametresi aktif edilmelidir. Bu, log ekranındaki kirliliği önler ve bellek tüketimini optimize eder.

> [!WARNING]
> **Kullanıcı Etkileşimi Kontrolü (Popup & Grid Seçimi)**  
> Arka planda çalışan (Background Job / Batch) programlarda `iv_as_popup = 'X'` kullanılması `DUMP` riski oluşturabilir. Bu metotları tetiklemeden önce programın `sy-batch` modunda olup olmadığı kontrol edilmeli, kullanıcı etkileşimli ekranlar sadece `sy-batch cp abap_false` durumunda çağrılmalıdır.

```abap
DATA: lo_log TYPE REF TO cl_ptu_message.

CREATE OBJECT lo_log.

lo_log->add_text(
  EXPORTING
    iv_type     = 'E'
    iv_text     = lv_text
*   iv_cumulate = abap_true " Aynı mesajları 1 defa gösterir
).

IF lo_log->has_messages( ) EQ abap_true.
  lo_log->display_log(
    EXPORTING
      iv_as_popup      = 'X'
      iv_use_grid      = 'X'
      iv_force_display = 'X'
  ).
ENDIF.
