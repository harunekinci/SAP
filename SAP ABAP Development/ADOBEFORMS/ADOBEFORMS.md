# 📄 Adobe Forms — Subform ve Sayfa Taşma Ayarları

<br/>

<div align="center">

<img src="https://img.shields.io/badge/SAP-Adobe_Forms-008FD3?style=for-the-badge&logo=sap&logoColor=white" />
<img src="https://img.shields.io/badge/FORM-Subform-orange?style=for-the-badge" />
<img src="https://img.shields.io/badge/LAYOUT-Multi_Page-success?style=for-the-badge" />

</div>

<br/>

> **Amaç:** Adobe Forms üzerinde özellikle tablo içerisinde çok sayıda kalem bulunduğunda, kayıtların sayfa sınırını aşarak bir sonraki sayfada devam edebilmesini sağlamak için Subform ve Table nesnelerinin doğru şekilde yapılandırılması gerekir.

---

## 💻 Subform Ayarları

Adobe Forms tasarımında tabloyu veya çoklu kayıt içeren alanları taşıyan **Subform**, **Master Page içerisinde** bulunabilir ancak **Page1 içerisinde olmamalıdır**.

Çok sayıda kalemin birden fazla sayfaya taşınabilmesi için Subform üzerinde aşağıdaki ayarlar yapılmalıdır.

### 📌 Object → Subform

| Property | Değer |
|---|---|
| **Content** | `Flowed` |
| **Flow Direction** | `Top to bottom` |
| **Allow page breaks within content** | ✅ Tikli |
| **Place** | `Following previous` |
| **After** | `Continue filling parent` |
| **Overflow** | `None` |

### 📌 Önemli

> **Allow page breaks within content** seçeneği mutlaka işaretlenmelidir.

Bu seçenek sayesinde kayıtlar mevcut sayfaya sığmadığında Adobe Forms içeriği otomatik olarak **2. sayfadan ve sonraki sayfalardan devam ettirebilir.**

---

## 💻 Table Ayarları

Tablonun kendisinde de sayfa taşmasına izin verilmelidir.

### 📌 Table → Object → Subform

Tablo içerisinde kullanılan Subform için:

| Property | Değer |
|---|---|
| **Content** | `Flowed` |
| **Flow Direction** | `Top to bottom` |
| **Allow page breaks within content** | ✅ Tikli |

> **Allow page breaks within content** ayarı hem ana Subform'da hem de tabloda kullanılan Subform'da ayrı ayrı işaretlenmelidir.

---

## 🔁 Repeat Table Ayarları

Tablonun birden fazla kayıt için tekrar oluşturulabilmesi amacıyla **Repeat Table for Each Data Item** seçeneği kullanılmalıdır.

### 📌 Binding / Repeat Settings

| Property | Değer |
|---|---|
| **Repeat Table for Each Data Item** | ✅ Tikli |
| **Min** | Boş |
| **Max** | Boş |
| **Initial Count** | Boş |

`Min`, `Max` ve `Initial Count` alanları boş bırakılmalıdır.

Bu yapı sayesinde backend'den gelen kayıt sayısına göre tablo satırları dinamik olarak oluşturulur ve kayıtlar sayfa sınırını aştığında sonraki sayfalara aktarılır.

---

## ⚠️ Kritik Noktalar

> [!IMPORTANT]
> Çok sayıda kalem gösterilecekse **Subform → Content = Flowed** olmalıdır.

> [!IMPORTANT]
> **Flow Direction = Top to bottom** seçilmelidir.

> [!IMPORTANT]
> **Allow page breaks within content** hem Subform hem de Table/Subform seviyesinde ayrı ayrı aktif edilmelidir.

> [!TIP]
> Subform'un **Place = Following previous** ve **After = Continue filling parent** olarak ayarlanması, içeriğin parent form akışı içerisinde devam etmesini sağlar.

> [!TIP]
> **Overflow = None** bırakılmalıdır.

> [!WARNING]
> Subform'un `Positioned` olarak bırakılması, çok sayıda kaydın aynı alan içerisinde akış göstermesini ve sonraki sayfaya taşmasını engelleyebilir.

---

## 📋 Kısa Özet

```text
SUBFORM
│
├── Content
│   └── Flowed
│
├── Flow Direction
│   └── Top to bottom
│
├── Allow page breaks within content
│   └── ✅
│
├── Place
│   └── Following previous
│
├── After
│   └── Continue filling parent
│
└── Overflow
    └── None


TABLE / TABLE SUBFORM
│
├── Allow page breaks within content
│   └── ✅
│
├── Repeat Table for Each Data Item
│   └── ✅
│
├── Min
│   └── Boş
│
├── Max
│   └── Boş
│
└── Initial Count
    └── Boş