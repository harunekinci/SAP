# ✉️ ZCL_SIMPLE_SEND_MAIL

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/MODULE-BCS_%2F_SMTP-2E7D32?style=for-the-badge&logo=opsgenie&logoColor=white" alt="Module" />
  <img src="https://img.shields.io/badge/STATUS-READY_FOR_PROD-C62828?style=for-the-badge" alt="Status" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `ZCL_SIMPLE_SEND_MAIL`, SAP Business Communication Services (BCS) mimarisini nesne tabanlı katmanlarla sarmalayan kurumsal bir e-posta framework bileşenidir. Geliştiricileri SMTP konfigürasyon detaylarından kurtararak temiz, deklaratif ve tek merkezden yönetilebilir bir arayüz sağlar.

---

## 🛠️ Metot İmza Yapısı (Signature)

Sıradan tablolar yerine, parametre türlerine göre renklendirilmiş kurumsal arayüz tablosu:

<table>
  <thead>
    <tr style="background-color: #1F4E79; color: white;">
      <th>Parametre Adı</th>
      <th>Yön (Type)</th>
      <th>Veri Tipi (Type Spec.)</th>
      <th>Durum</th>
      <th>Fonksiyonel Açıklama</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>I_SENDER</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>AD_SMTPADR</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Gönderen e-posta adresi.</td>
    </tr>
    <tr>
      <td><b>I_SENDER_NAME</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>AD_SMTPADR</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Gönderen mail adresi tanımı (Görünen Ad).</td>
    </tr>
    <tr>
      <td><b>I_SUBJECT</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>SO_OBJ_DES</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Mail konusu (Kısa - Max 50 Karakter).</td>
    </tr>
    <tr>
      <td><b>I_SUBJECT_LONG</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>STRING</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Mail konusu (Uzun - Karakter sınırı yoktur).</td>
    </tr>
    <tr>
      <td><b>I_TYPE</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>SO_OBJ_TP</code></td>
      <td><code>Default 'RAW'</code></td>
      <td>Döküman tipi kodu (RAW, HTM vb.).</td>
    </tr>
    <tr>
      <td><b>I_MAIL_GROUP</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>SOOBJINFI1-OBJ_NAME</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Dağıtım listesi veya klasör adı.</td>
    </tr>
    <tr>
      <td><b>I_NO_COMMIT</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>FLAG</code></td>
      <td><code>Opsiyonel</code></td>
      <td><code>X</code> ise metot içinde <code>COMMIT WORK</code> çalıştırılmaz.</td>
    </tr>
    <tr>
      <td><b>I_IMPORTANCE</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>BCS_DOCIMP</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Doküman önceliği (1: Yüksek, 5: Düşük).</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td><b>T_RECEIVER</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>ZBRS_MAIL_REC_TAB</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Alıcı tablosu (TO, CC, BCC dinamik yönetimi).</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td><b>T_TEXT</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>SOLI_TAB</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Mail gövdesi metin tablosu (OBJCONT / OBJHEAD).</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td><b>T_ATTACH</b></td>
      <td><kbd>Importing</kbd></td>
      <td><code>ZBRS_ATTACH_TAB</code></td>
      <td><code>Opsiyonel</code></td>
      <td>Mail ile gönderilecek eklerin (Attachment) tablosu.</td>
    </tr>
    <tr>
      <td><b>E_MESSAGE</b></td>
      <td><kbd>Exporting</kbd></td>
      <td><code>TEXT100</code></td>
      <td><code>-</code></td>
      <td>İşlem sonucu dönen açıklayıcı mesaj metni.</td>
    </tr>
    <tr>
      <td><b>E_SUCCESS</b></td>
      <td><kbd>Exporting</kbd></td>
      <td><code>FLAG</code></td>
      <td><code>-</code></td>
      <td>İşlem başarı durumu (<code>X</code>: Başarılı, <code>Space</code>: Hatalı).</td>
    </tr>
  </tbody>
</table>

---

## 🗂️ Bağımlı Veri Sözlüğü (DDIC) Yapıları

### 1️⃣ Alıcı Yönetimi Tablosu (`T_RECEIVER`)
* **Table Type:** `ZBRS_MAIL_REC_TAB` 
* **Structure (Line Type):** `ZBRS_MAIL_RECEIVER`

```sql
/* Structure Yapısı Görünümü */
TYPES: BEGIN OF zbrs_mail_receiver,
         receiver TYPE ad_smtpadr,   " Alıcı E-posta adresi (CHAR 241)
         cc       TYPE os_boolean,   " Bilgi (Carbon Copy) -> X/Boş
         bcc      TYPE os_boolean,   " Gizli Bilgi (Blind Carbon Copy) -> X/Boş
       END OF zbrs_mail_receiver.
