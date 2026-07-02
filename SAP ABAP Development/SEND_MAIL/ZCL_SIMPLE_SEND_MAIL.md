# ✉️ ZCL_SIMPLE_SEND_MAIL

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/METOT-SEND__MAIL-2E7D32?style=for-the-badge&logo=opsgenie&logoColor=white" alt="Method" />
  <img src="https://img.shields.io/badge/STATUS-READY_FOR_PROD-C62828?style=for-the-badge" alt="Status" />
</div>

<br/>

> **Sistem Mimarı Özeti:** `ZCL_SIMPLE_SEND_MAIL`, SAP Business Communication Services (BCS) mimarisini nesne tabanlı katmanlarla sarmalayan kurumsal bir e-posta framework bileşenidir. Geliştiricileri SMTP konfigürasyon detaylarından kurtararak `zcl_simple_send_mail=>send_mail( )` statik metodu üzerinden temiz, deklaratif ve tek merkezden yönetilebilir bir arayüz sağlar.

---

## 🛠️ SE24: Class Builder — zcl_simple_send_mail=>send_mail( ) İmza Yapısı

Metodun SE24 interface yapısı ve parametre listesi:

### ABAP Metot Deklarasyonu
    
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
      <td><b>I_SENDER</b></td>
      <td><code>TYPE AD_SMTPADR OPTIONAL</code></td>
      <td>Gönderen E-posta adresi</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>I_SENDER_NAME</b></td>
      <td><code>TYPE AD_SMTPADR OPTIONAL</code></td>
      <td>Gönderen mail adresi tanımı</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>I_SUBJECT</b></td>
      <td><code>TYPE SO_OBJ_DES OPTIONAL</code></td>
      <td>Mail konusu (kısa)</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>I_SUBJECT_LONG</b></td>
      <td><code>TYPE STRING OPTIONAL</code></td>
      <td>Mail konusu (uzun)</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>I_TYPE</b></td>
      <td><code>TYPE SO_OBJ_TP DEFAULT 'RAW'</code></td>
      <td>Doküman tipi için kod</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>I_MAIL_GROUP</b></td>
      <td><code>TYPE SOOBJINFI1-OBJ_NAME OPTIONAL</code></td>
      <td>Dokümanın, klasörün ya da dağıtım listesinin adı</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>I_IMPORTANCE</b></td>
      <td><code>TYPE BCS_DOCIMP OPTIONAL</code></td>
      <td>Doküman önceliği</td>
    </tr>
    <tr style="background-color: #f1f5f9;">
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>T_RECEIVER</b></td>
      <td><code>TYPE ZDAGNILAK_MAIL_REC_TAB OPTIONAL</code></td>
      <td>Mail receiver</td>
    </tr>
    <tr style="background-color: #f1f5f9;">
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>T_TEXT</b></td>
      <td><code>TYPE SOLI_TAB OPTIONAL</code></td>
      <td>Tablo tipi olarak OBJCONT ve OBJHEAD</td>
    </tr>
    <tr style="background-color: #f1f5f9;">
      <td><img src="https://img.shields.io/badge/ℹ️-Importing-blue" alt="Imp"/></td>
      <td><b>T_ATTACH</b></td>
      <td><code>TYPE ZDAGNILAK_MAIL_ATTACH_TAB OPTIONAL</code></td>
      <td>Mail ile dosya gönderimi tablo tipi</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/⬆️-Exporting-orange" alt="Exp"/></td>
      <td><b>E_MESSAGE</b></td>
      <td><code>TYPE BAPI_MSG</code></td>
      <td>BAPI Mesaj Metni</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/⬆️-Exporting-orange" alt="Exp"/></td>
      <td><b>E_SUCCESS</b></td>
      <td><code>TYPE FLAG</code></td>
      <td>Genel gösterge</td>
    </tr>
  </tbody>
</table>

---

## 🗂️ SE11: ABAP Dictionary — Bağımlı Yapılar

### 1️⃣ Table Type: `ZDAGNILAK_MAIL_REC_TAB` *(Mail alıcıları tablo tipi)*
* **Line Type:** `ZBRS_MAIL_RECEIVER` *(Mail receiver)*

#### Structure: `ZBRS_MAIL_RECEIVER` (Components)
<table>
  <thead>
    <tr style="background-color: #34495e; color: white;">
      <th>Component</th>
      <th>Ref. Type</th>
      <th>Component Type</th>
      <th>Data Type</th>
      <th>Length</th>
      <th>Deci...</th>
      <th>Short Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>RECEIVER</b></td>
      <td>Types</td>
      <td><code>AD_SMTPADR</code></td>
      <td>CHAR</td>
      <td>241</td>
      <td>0</td>
      <td>E-posta adresi</td>
    </tr>
    <tr>
      <td><b>CC</b></td>
      <td>Types</td>
      <td><code>OS_BOOLEAN</code></td>
      <td>CHAR</td>
      <td>1</td>
      <td>0</td>
      <td>Boolean</td>
    </tr>
    <tr>
      <td><b>BCC</b></td>
      <td>Types</td>
      <td><code>OS_BOOLEAN</code></td>
      <td>CHAR</td>
      <td>1</td>
      <td>0</td>
      <td>Boolean</td>
    </tr>
  </tbody>
</table>

---

### 2️⃣ Table Type: `ZDAGNILAK_MAIL_ATTACH_TAB` *(Mail ile dosya gönderimi tablo tipi)*
* **Line Type:** `ZBRS_ATTACH` *(Mail dosya gönderimi yapısı)*

#### Structure: `ZBRS_ATTACH` (Components)
<table>
  <thead>
    <tr style="background-color: #34495e; color: white;">
      <th>Component</th>
      <th>Ref. Type</th>
      <th>Component Type</th>
      <th>Data Type</th>
      <th>Length</th>
      <th>Deci...</th>
      <th>Short Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>ATT_TYPE</b></td>
      <td>Types</td>
      <td><code>SO_OBJ_TP</code></td>
      <td>CHAR</td>
      <td>3</td>
      <td>0</td>
      <td>Döküman tipi için kod</td>
    </tr>
    <tr>
      <td><b>ATT_TITLE</b></td>
      <td>Types</td>
      <td><code>SO_OBJ_DES</code></td>
      <td>CHAR</td>
      <td>50</td>
      <td>0</td>
      <td>Kısa içerik tanımı</td>
    </tr>
    <tr style="background-color: #fcfcfc;">
      <td><b>ATTACH</b></td>
      <td>Types</td>
      <td><code>SOLI_TAB</code></td>
      <td>TTYP</td>
      <td>0</td>
      <td>0</td>
      <td>Tablo tipi olarak OBJCONT ve OBJHEAD</td>
    </tr>
    <tr style="background-color: #fcfcfc;">
      <td><b>ATTACHX</b></td>
      <td>Types</td>
      <td><code>SOLIX_TAB</code></td>
      <td>TTYP</td>
      <td>0</td>
      <td>0</td>
      <td>GBT: Tablo tipi olarak SOLIX</td>
    </tr>
  </tbody>
</table>

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> **ATTACH vs ATTACHX Ayrımı**  
> Smartforms, Adobe Forms çıktıları veya saf binary `.xlsx` dosyaları gönderilirken ham veri bozulmasını önlemek için kesinlikle **`ATTACHX`** (`SOLIX_TAB`) alanı beslenmelidir[cite: 1]. Düz metin (TXT) veya HTML şablonları için ise **`ATTACH`** yeterlidir[cite: 1].

> [!TIP]
> **50 Karakter Konu Sınırı**  
> SAP yapısı gereği `I_SUBJECT` alanı 50 karakter ile sınırlıdır[cite: 1]. Mail başlığının bütünlüğünü korumak adına uzun başlık senaryolarında doğrudan `I_SUBJECT_LONG` (`STRING`) parametresini sisteme besleyin[cite: 1].

> [!WARNING]
> **Kuyruk ve Performans Optimizasyonu**  
> Döngü içerisinde (Örn: Toplu hakediş veya fatura mailleri) her satırda `COMMIT WORK` yapılması DB kilitlerine sebep olur. Performans için harici entegrasyonlarda commit stratejilerine dikkat edilmeli ve yoğun yüklerde mailler toplu işlenmelidir.

> 
```abap
class-methods send_mail
  importing
    i_sender       type ad_smtpadr                optional
    i_sender_name  type ad_smtpadr                optional
    i_subject      type so_obj_des                optional
    i_subject_long type string                    optional
    i_type         type so_obj_tp                 default 'RAW'
    i_mail_group   type soobjinfi1-obj_name       optional
    i_importance   type bcs_docimp                optional
    t_receiver     type zdagnilak_mail_rec_tab    optional
    t_text         type soli_tab                  optional
    t_attach       type zdagnilak_mail_attach_tab optional
  exporting
    e_message      type bapi_msg
    e_success      type flag.
