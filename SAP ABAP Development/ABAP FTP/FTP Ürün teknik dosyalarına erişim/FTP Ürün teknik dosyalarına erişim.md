# ✉️ FTP Doküman Erişimi (Teknik Resimler)

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-FTP-2E7D32?style=for-the-badge" alt="FTP" />
  <img src="https://img.shields.io/badge/CATEGORY-DOCUMENT_MANAGEMENT-C62828?style=for-the-badge" alt="Document" />
</div>

<br/>

> **Sistem Mimarı Özeti:** Ürünlere ait 2D, 3D ve diğer teknik dokümanlar FTP sunucusunda saklanmaktadır. SAP yalnızca dokümanın yol bilgisini tutar. Dosyanın FTP üzerinde bulunmaması veya tarayıcının FTP desteğini kaldırması durumunda kullanıcı dokümana erişemez.

---

## 🛠️ Problem Senaryoları

| Durum | Açıklama |
|-------|----------|
| **Montaj Resmi dosyası FTP sunucusunda bulunamadı!** | SAP'ta doküman kaydı mevcut olmasına rağmen ilgili dosya FTP sunucusunda bulunmamaktadır. |
| **Paketleme Dokümanı mevcut değil!** | SAP içerisinde doküman kaydı bulunmamaktadır. |

---

## 🛠️ Olası Sebepler

- FTP üzerindeki dosya silinmiş olabilir.
- SAP kaydı güncellenmemiş olabilir.
- Test sistemi eski kayıtları gösteriyor olabilir.
- Modern tarayıcılar FTP protokolünü artık desteklememektedir.

---

## 🛠️ Çözüm

| Çözüm | Açıklama |
|-------|----------|
| **Geçici Çözüm** | FTP desteği bulunan Internet Explorer ile dosyaya erişilebilir. |
| **Kalıcı Çözüm** | FTP adresini kullanıcıya göndermek yerine dosya arka planda okunup WebDynpro üzerinden kullanıcıya stream edilmelidir. |

---

## 💻 FTP Path İşlemleri

Örnek FTP yolu

```text
\\172.16.2.230\Kolacad\Aydinlatma\Kor_Alav_S0\2D\ALAV_S0_2D.dwg
```

UNC (Network) yolu

```text
\Kolacad\Aydinlatma\Kor_Alav_S0\2D\ALAV_S0_2D.dwg
```

Dosya Adı

```text
ALAV_S0_2D.dwg
```

Klasör

```text
\Kolacad\Aydinlatma\Kor_Alav_S0\2D
```

---

## 💻 Yol Ayrıştırma

```abap
DATA(path) = '\\172.16.2.230\Kolacad\Aydinlatma\Kor_Alav_S0\2D\ALAV_S0_2D.dwg'.

IF path(2) EQ '\\'.

  path = shift_left(
           val    = path
           places = 14 ).

ENDIF.

DATA(lv_position) =
  find(
    val = path
    occ = -1
    sub = '\' ).

DATA(lv_filename) =
  substring(
    val = path
    off = lv_position + 1 ).

path =
  substring(
    val = path
    len = lv_position ).

lv_position =
  find(
    val = path
    occ = -1
    sub = '\' ).
```

---

## 💡 Yol Ayrıştırma Sonucu

| Değişken | Değer |
|----------|-------|
| **PATH (İlk Değer)** | `\\172.16.2.230\Kolacad\Aydinlatma\Kor_Alav_S0\2D\ALAV_S0_2D.dwg` |
| **SHIFT Sonrası** | `\Kolacad\Aydinlatma\Kor_Alav_S0\2D\ALAV_S0_2D.dwg` |
| **LV_FILENAME** | `ALAV_S0_2D.dwg` |
| **PATH (Son Değer)** | `\Kolacad\Aydinlatma\Kor_Alav_S0\2D` |

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> SAP yalnızca dokümanın yol bilgisini tutabilir. Dosyanın gerçekten FTP sunucusunda bulunup bulunmadığı ayrıca kontrol edilmelidir.

> [!TIP]
> Modern tarayıcılar (Chrome, Edge, Firefox vb.) güvenlik nedeniyle FTP desteğini kaldırmıştır.

> [!TIP]
> WebDynpro uygulamalarında önerilen yöntem, FTP adresini istemciye göndermek yerine dosyayı ABAP tarafında okuyup HTTP Response olarak kullanıcıya göndermektir.

> [!WARNING]
> FTP üzerinde dosya silinmiş olmasına rağmen SAP kayıtları güncellenmemişse kullanıcı "dosya bulunamadı" hatası alacaktır.
