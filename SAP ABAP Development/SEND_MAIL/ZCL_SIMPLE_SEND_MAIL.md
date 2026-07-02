GitHub deponuzun (Repository) ana sayfasında ya da `docs/` klasöründe profesyonel, temiz ve modern bir teknik dokümantasyon olarak sergileyebileceğiniz, Markdown (`.md`) formatındaki hazır dosya içeriği aşağıdadır.

Projenize doğrudan **`README.md`** veya **`ZCL_SIMPLE_SEND_MAIL.md`** adıyla ekleyebilirsiniz.

---

```markdown
# ZCL_SIMPLE_SEND_MAIL

![SAP](https://img.shields.io/badge/SAP-ABAP_7.40%2B-blue?logo=sap)
![Status](https://img.shields.io/badge/Status-Active-success)
![Object Type](https://img.shields.io/badge/Object_Type-Class-orange)

`ZCL_SIMPLE_SEND_MAIL` sınıfı, SAP Business Communication Services (BCS) mimarisini nesne tabanlı yöntemlerle sarmalayarak, sistem içi ve dışı e-posta gönderim süreçlerini standartlaştırmak, kod karmaşıklığını azaltmak ve mail operasyonlarını tek bir merkezden yönetmek amacıyla geliştirilmiş bir **Core Framework** bileşenidir.

Sınıf; arka planda yürütülen SMTP konfigürasyonlarını, veri türü dönüştürmelerini (MIME, binary, text) ve alıcı gruplama mantıklarını soyutlayarak geliştiriciye deklaratif, esnek ve temiz bir arayüz sunar.

---

## 🛠️ Metot Parametreleri (Signature)

Sınıfın ana gönderim metodunda yer alan parametre yapısı ve türleri aşağıdaki tabloda listelenmiştir:

| Parametre Adı | Türü | Veri Tipi (Type Spec.) | Opsiyonel | Kısa Açıklama |
| :--- | :--- | :--- | :---: | :--- |
| **`I_SENDER`** | Importing | `AD_SMTPADR` | Evet | Gönderen e-posta adresi |
| **`I_SENDER_NAME`** | Importing | `AD_SMTPADR` | Evet | Gönderen mail adresi tanımı (Görünen Ad) |
| **`I_SUBJECT`** | Importing | `SO_OBJ_DES` | Evet | Mail konusu (Kısa - Max 50 Karakter) |
| **`I_SUBJECT_LONG`** | Importing | `STRING` | Evet | Mail konusu (Uzun - Karakter sınırı yok) |
| **`I_TYPE`** | Importing | `SO_OBJ_TP` | Varsayılan: `'RAW'` | Döküman tipi için kod (RAW, HTM, vb.) |
| **`I_MAIL_GROUP`** | Importing | `SOOBJINFI1-OBJ_NAME` | Evet | Dokümanın, klasörün ya da dağıtım listesinin adı |
| **`I_NO_COMMIT`** | Importing | `FLAG` | Evet | `X` ise metot içinde `COMMIT WORK` çalıştırılmaz |
| **`I_IMPORTANCE`** | Importing | `BCS_DOCIMP` | Evet | Doküman önceliği (1: Yüksek, 5: Düşük) |
| **`T_RECEIVER`** | Importing | `ZBRS_MAIL_REC_TAB` | Evet | Alıcı tablosu (TO, CC, BCC yönlendirmeleri) |
| **`T_TEXT`** | Importing | `SOLI_TAB` | Evet | Mail gövdesi metin tablosu (OBJCONT ve OBJHEAD) |
| **`T_ATTACH`** | Importing | `ZBRS_ATTACH_TAB` | Evet | Mail ile dosya gönderimi (Ekler) tablo tipi |
| **`E_MESSAGE`** | Exporting | `TEXT100` | - | İşlem sonucu dönen açıklayıcı mesaj metni |
| **`E_SUCCESS`** | Exporting | `FLAG` | - | İşlem başarı durumu (X: Başarılı, Boş: Hatalı) |

---

## 🗂️ Bağımlı Veri Sözlüğü (DDIC) Yapıları

Sınıfın esnek ve dinamik yapısını besleyen özel `Table Type` ve `Structure` bileşenlerinin detayları aşağıda kırılımlı olarak belirtilmiştir.

### 1. Alıcı Yönetimi Yapısı (`T_RECEIVER`)
* **Table Type:** `ZBRS_MAIL_REC_TAB` *(Mail alıcıları tablo tipi)*
* **Line Type (Structure):** `ZBRS_MAIL_RECEIVER` *(Mail receiver)*

| Bileşen (Component) | Bileşen Tipi (Type) | Veri Tipi | Uzunluk | Kısa Açıklama |
| :--- | :--- | :---: | :---: | :--- |
| **`RECEIVER`** | `AD_SMTPADR` | CHAR | 241 | Alıcı E-posta adresi |
| **`CC`** | `OS_BOOLEAN` | CHAR | 1 | Bilgi (Carbon Copy) - Boolean Flag (`X`/` `) |
| **`BCC`** | `OS_BOOLEAN` | CHAR | 1 | Gizli Bilgi (Blind Carbon Copy) - Boolean Flag (`X`/` `) |

### 2. Ek (Attachment) Yönetimi Yapısı (`T_ATTACH`)
* **Table Type:** `ZBRS_ATTACH_TAB` *(Mail ile dosya gönderimi tablo tipi)*
* **Line Type (Structure):** `ZBRS_ATTACH` *(Mail dosya gönderimi yapısı)*

| Bileşen (Component) | Bileşen Tipi (Type) | Veri Tipi | Uzunluk | Kısa Açıklama |
| :--- | :--- | :---: | :---: | :--- |
| **`ATT_TYPE`** | `SO_OBJ_TP` | CHAR | 3 | Döküman tipi kodu (Örn: PDF, XLS, RAW) |
| **`ATT_TITLE`** | `SO_OBJ_DES` | CHAR | 50 | Ek dosyanın adı/kısa içerik tanımı |
| **`ATTACH`** | `SOLI_TAB` | Table Type | 0 | Metin tabanlı dosya içeriği tablosu |
| **`ATTACHX`** | `SOLIX_TAB` | Table Type | 0 | Binary (ikili) dosya içeriği tablosu (SOLIX) |

---

## 💡 Kritik Geliştirici ve Mimari Notlar

> [!IMPORTANT]
> **Metin (Text) vs Binary Seçimi**
> Eğer Smartforms/Adobe Forms çıktısı (PDF) veya ham bir Excel dosyası (`.xlsx`) ekleyecekseniz, `T_ATTACH` yapısındaki **`ATTACHX`** (SOLIX_TAB) alanını beslemeniz gerekir. Düz metin, log dosyaları veya saf HTML şablonları gönderecekseniz **`ATTACH`** alanını kullanmalısınız.

> [!TIP]
> **Uzun Konu Başlıkları (Subject)**
> SAP standart veri yapısı gereği `I_SUBJECT` parametresi 50 karakter ile sınırlıdır. Gönderilecek e-postanın konusunun sistem tarafından kesilmesini önlemek adına, uzun başlık senaryolarında doğrudan **`I_SUBJECT_LONG`** (`STRING`) parametresi tercih edilmelidir.

> [!WARNING]
> **Performans ve Kuyruk Yönetimi (Commit Stratejisi)**
> Toplu e-posta gönderim döngülerinde (Örn: Batch raporlar) metot içerisinde sürekli `COMMIT WORK` çalışması veritabanı kilitlerine (DB Locks) ve performans kaybına yol açar. Bu senaryolarda `I_NO_COMMIT = 'X'` flag'i set edilmeli ve döngünün en sonunda tek seferlik harici bir `COMMIT WORK` tetiklenmelidir.

```
