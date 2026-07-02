# ✉️ OO-ALV MVC Template

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/ARCHITECTURE-MVC-2E7D32?style=for-the-badge" alt="MVC" />
  <img src="https://img.shields.io/badge/CATEGORY-OO__ALV_TEMPLATE-C62828?style=for-the-badge" alt="Template" />
</div>

<br/>

> **Sistem Mimarı Özeti:** Bu şablon, SAP GUI üzerinde geliştirilecek OO-ALV uygulamaları için **Model-View-Controller (MVC)** mimarisini temel alan örnek bir proje iskeletidir. Controller uygulama akışını yönetirken, Model veri erişimini ve iş kurallarını, View ise ALV ekranı ile kullanıcı etkileşimini üstlenir. Toolbar, Hotspot, Double Click, Editable ALV, Selection Screen ve Log yönetimi gibi yaygın ihtiyaçlar başlangıç seviyesinde hazır olarak sunulmaktadır.

---

## 🛠️ Mimari Bileşenler

| Bileşen | Sorumluluk |
|---------|------------|
| **Main Report** | Program event'lerini yönetir. |
| **Controller** | Uygulama akışını yönetir ve Model ile View arasında köprü görevi görür. |
| **Model** | Veri okuma, iş kuralları ve BAPI/FM işlemlerini yürütür. |
| **View** | OO-ALV oluşturur ve tüm GUI Event'lerini yönetir. |
| **PBO / PAI** | Screen 9000 yaşam döngüsünü yönetir. |

---

## 🛠️ Hazır Özellikler

| Özellik | Durum |
|---------|-------|
| MVC Mimarisi | ✅ |
| OO-ALV Grid | ✅ |
| Toolbar Event | ✅ |
| User Command | ✅ |
| Double Click | ✅ |
| Hotspot | ✅ |
| Editable ALV | ✅ |
| DATA_CHANGED Event | ✅ |
| Selection Screen | ✅ |
| Custom Function Key | ✅ |
| Popup Screen (9000) | ✅ |
| Log Yönetimi (`CL_PTU_MESSAGE`) | ✅ |

---

## 💻 Program Akışı

```text
INITIALIZATION
        │
        ▼
Controller Oluşturulur
        │
        ▼
Selection Screen
        │
        ▼
Controller->run( )
        │
        ▼
Model->retrieve_data( )
        │
        ▼
Veri Var mı?
   │             │
   │             └──────► Bilgilendirme Mesajı
   ▼
CALL SCREEN 9000
        │
        ▼
PBO
        │
        ▼
View->display_alvdat( )
        │
        ▼
OO-ALV Eventleri
        │
        ▼
Controller
        │
        ▼
Model
        │
        ▼
ALV Refresh
```

---

## 💻 Include Yapısı

```text
ZDEVELOPMENT_01

│
├── ZDEVELOPMENT_01_OOALV_MVC_CLS
│      │
│      ├── LCL_MODEL
│      ├── LCL_VIEW
│      └── LCL_CONTROLLER
│
└── ZDEVELOPMENT_01_OOALV_MVC_MOD
       │
       ├── PBO
       └── PAI
```

---

## 💻 Event Akışı

```text
Toolbar Button
        │
        ▼
handle_user_command
        │
        ▼
Controller->on_user_command()
        │
        ▼
Model->post_documents()
        │
        ▼
CL_PTU_MESSAGE
        │
        ▼
ALV Refresh
```

---

## 💻 Kullanılan SAP Teknolojileri

| Teknoloji | Amaç |
|-----------|------|
| `CL_GUI_ALV_GRID` | OO-ALV |
| `LVC_FIELDCATALOG_MERGE` | Field Catalog |
| `VIEW_MAINTENANCE_CALL` | SM30 Bakım Ekranı |
| `CL_PTU_MESSAGE` | Log Yönetimi |
| `SET HANDLER` | Event Yönetimi |
| `CALL SCREEN` | Dynpro Yönetimi |

---

## 💻 Kaynak Kod

### Main Report

```abap
REPORT zdevelopment_01.

INCLUDE zdevelopment_01_ooalv_mvc_cls.
INCLUDE zdevelopment_01_ooalv_mvc_mod.

INITIALIZATION.

AT SELECTION-SCREEN.

START-OF-SELECTION.

END-OF-SELECTION.
```

---

### Include : ZDEVELOPMENT_01_OOALV_MVC_CLS

```abap
" LCL_MODEL
" LCL_VIEW
" LCL_CONTROLLER

" (Tam kaynak kod)
```

---

### Include : ZDEVELOPMENT_01_OOALV_MVC_MOD

```abap
MODULE status_9000 OUTPUT.

...

MODULE user_command_9000 INPUT.

...
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> Main Report yalnızca event'leri yönetmeli; tüm iş kuralları Controller ve Model katmanında yer almalıdır.

> [!TIP]
> Controller katmanı, View ve Model arasında tek iletişim noktası olarak kullanılmalıdır.

> [!TIP]
> View katmanı yalnızca ekran ve ALV yönetiminden sorumlu olmalı; iş kuralları içermemelidir.

> [!TIP]
> İş süreçleri (`BAPI`, `CALL TRANSACTION`, `UPDATE`, `COMMIT WORK` vb.) Model sınıfında toplanmalıdır.

> [!WARNING]
> Controller içerisinde SQL yazılması veya View içerisinde Business Logic bulunması MVC prensiplerini bozar ve bakım maliyetini artırır.
