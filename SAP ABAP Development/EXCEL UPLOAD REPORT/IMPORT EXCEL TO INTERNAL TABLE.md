# 📂 Excel Dosyası Okuma (XLSX Upload)

<br/>

<div align="center">

<img src="https://img.shields.io/badge/SAP-ABAP_7.40+-008FD3?style=for-the-badge&logo=sap&logoColor=white" />
<img src="https://img.shields.io/badge/FILE-XLSX-success?style=for-the-badge" />
<img src="https://img.shields.io/badge/CLASS-CL_FDT_XL_SPREADSHEET-blue?style=for-the-badge" />

</div>

<br/>

> **Amaç:** Kullanıcının bilgisayarından Excel (.xlsx) dosyası seçilerek SAP içerisine yüklenmesi, dosyanın `XSTRING` formatına çevrilmesi ve `CL_FDT_XL_SPREADSHEET` sınıfı kullanılarak worksheet verilerinin Internal Table olarak okunması.

---

# 📋 Kullanılan Yapılar

| Yapı | Açıklama |
|------|----------|
| `F4_FILENAME` | Dosya seçim yardımı |
| `CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG` | Windows dosya seçme ekranı |
| `GUI_UPLOAD` | Excel dosyasını Binary olarak SAP'a alma |
| `CL_BCS_CONVERT=>SOLIX_TO_XSTRING` | Binary → XSTRING dönüşümü |
| `CL_FDT_XL_SPREADSHEET` | XLSX dosyasını okuma |
| `GET_WORKSHEET_NAMES` | Sayfa isimlerini alma |
| `GET_ITAB_FROM_WORKSHEET` | Worksheet'i Internal Table olarak alma |
| `CL_DEMO_OUTPUT` | Okunan veriyi HTML olarak gösterme |
| `CL_ABAP_BROWSER` | HTML çıktısını görüntüleme |

---

# 🔄 Program Akışı

```text
Selection Screen
      │
      ▼
Excel Dosyası Seçilir
      │
      ▼
FILE_OPEN_DIALOG
      │
      ▼
GUI_UPLOAD (Binary)
      │
      ▼
SOLIX → XSTRING
      │
      ▼
CL_FDT_XL_SPREADSHEET
      │
      ▼
Worksheet Listesi
      │
      ▼
İlk Worksheet Okunur
      │
      ▼
Internal Table
      │
      ▼
HTML Olarak Gösterilir
```

---

# 💡 Kullanım Notları

> [!TIP]
> `CL_FDT_XL_SPREADSHEET`, Office kurulu olmasına ihtiyaç duymadan doğrudan `.xlsx` dosyalarını okuyabilir.

> [!TIP]
> `GET_WORKSHEET_NAMES` metodu ile çalışma kitabındaki tüm sayfalar alınabilir.

> [!TIP]
> `GET_ITAB_FROM_WORKSHEET` generic bir internal table döndürür. `ASSIGN` ile field-symbol'a bağlanarak kullanılabilir.

> [!IMPORTANT]
> Excel dosyası önce Binary (`SOLIX`) olarak yüklenmeli, ardından `XSTRING` formatına çevrilmelidir.

> [!IMPORTANT]
> Kullanıcı dosya seçimini iptal ederse (`ACTION_OK` kontrolü), yükleme işlemi yapılmamalıdır.

> [!WARNING]
> Bu yöntem yalnızca **.xlsx** formatı içindir. Eski **.xls** dosyaları desteklenmez.

---

# 💻 ABAP Kodu

```abap
REPORT zbrs_sd_ikame_upload.

*&---------------------------------------------------------------------*
*& Report ZBRS_SD_VKM_ONAY_LOG
*&---------------------------------------------------------------------*
*& harun.ekinci@alfayazilim.com  29.04.22
*&
*& Ikame upload raporu
*&
*&---------------------------------------------------------------------*

DATA : BEGIN OF gt_data,
         vkorg TYPE komgd-vkorg,
         vtweg TYPE komgd-vtweg,
         matnr TYPE komgd-matnr,
         kdgrp TYPE komgd-kdgrp,
         datam TYPE rv130-datam,
         datbi TYPE rv130-datbi,
       END OF gt_data.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-tt1.

PARAMETERS : p_file TYPE rlgrap-filename
             OBLIGATORY
             DEFAULT 'C:\Users\ALFA\Desktop\ikame.xlsx'.

SELECTION-SCREEN ULINE /1(77).

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_1 RADIOBUTTON GROUP grp DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(70) text-001 FOR FIELD p_1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_2 RADIOBUTTON GROUP grp.
SELECTION-SCREEN COMMENT 3(70) text-002 FOR FIELD p_2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.

START-OF-SELECTION.

  TRY.

      DATA : lv_rc     TYPE i,
             it_files  TYPE filetable,
             lv_action TYPE i.

      cl_gui_frontend_services=>file_open_dialog(

        EXPORTING
          file_filter = |XLSX (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|

        CHANGING
          file_table  = it_files
          rc          = lv_rc
          user_action = lv_action ).

      IF lv_action = cl_gui_frontend_services=>action_ok.

        IF lines( it_files ) > 0.

          DATA : lv_filesize TYPE w3param-cont_len,
                 lv_filetype TYPE w3param-cont_type,
                 it_bin_data TYPE w3mimetabtype.

          cl_gui_frontend_services=>gui_upload(

            EXPORTING
              filename   = |{ it_files[ 1 ]-filename }|
              filetype   = 'BIN'

            IMPORTING
              filelength = lv_filesize

            CHANGING
              data_tab   = it_bin_data ).

          DATA(lv_bin_data) = cl_bcs_convert=>solix_to_xstring(
                                it_solix = it_bin_data ).

          DATA(o_excel) =
            NEW cl_fdt_xl_spreadsheet(
                document_name = CONV #( it_files[ 1 ]-filename )
                xdocument     = lv_bin_data ).

          DATA it_worksheet_names TYPE if_fdt_doc_spreadsheet=>t_worksheet_names.

          o_excel->if_fdt_doc_spreadsheet~get_worksheet_names(

            IMPORTING
              worksheet_names = it_worksheet_names ).

          IF lines( it_worksheet_names ) > 0.

            DATA(o_worksheet_itab) =
              o_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                it_worksheet_names[ 1 ] ).

            ASSIGN o_worksheet_itab->* TO FIELD-SYMBOL(<worksheet>).

            cl_demo_output=>write_data( <worksheet> ).

            DATA(lv_html) = cl_demo_output=>get( ).

            cl_abap_browser=>show_html(

              EXPORTING
                title       = 'Excel Worksheet'
                html_string = lv_html
                container   = cl_gui_container=>default_screen ).

            WRITE space.

          ENDIF.

        ENDIF.

      ENDIF.

    CATCH cx_root INTO DATA(e_text).

      MESSAGE e_text->get_text( )
      TYPE 'S'
      DISPLAY LIKE 'E'.

  ENDTRY.
```

---

# ✅ Kazanımlar

- ✔ Windows dosya seçim ekranı açma
- ✔ Excel dosyasını Binary olarak yükleme
- ✔ Binary veriyi XSTRING formatına dönüştürme
- ✔ XLSX dosyasındaki worksheet isimlerini okuma
- ✔ Worksheet verisini Internal Table olarak alma
- ✔ Generic tabloyu Field-Symbol ile kullanma
- ✔ HTML çıktısı oluşturarak SAP içerisinde görüntüleme
