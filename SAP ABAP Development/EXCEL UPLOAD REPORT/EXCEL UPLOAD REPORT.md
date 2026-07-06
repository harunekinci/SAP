# 📂 Excel Dosyası Okuma (CL_FDT_XL_SPREADSHEET)

Excel (.xlsx) dosyalarını ABAP içerisinde kullanıcıdan seçerek okumak için kullanılan modern yöntemdir. `CL_GUI_FRONTEND_SERVICES` ile dosya seçilir ve yüklenir, ardından `CL_FDT_XL_SPREADSHEET` sınıfı ile worksheet verileri doğrudan internal table formatında elde edilir.

---

## 🛠️ Kullanılan Sınıflar

| Sınıf | Amaç |
|-------|------|
| `CL_GUI_FRONTEND_SERVICES` | Dosya seçim ekranını açar ve dosyayı yükler. |
| `CL_BCS_CONVERT` | SOLIX verisini XSTRING formatına dönüştürür. |
| `CL_FDT_XL_SPREADSHEET` | Excel dosyasını okur ve worksheet verilerini döndürür. |
| `CL_DEMO_OUTPUT` | Okunan veriyi HTML formatında görüntüler. |
| `CL_ABAP_BROWSER` | HTML çıktısını SAP GUI içerisinde gösterir. |

---

## 💻 ABAP Kodu

```abap
DATA: lv_rc     TYPE i,
      it_files  TYPE filetable,
      lv_action TYPE i.

TRY.
    " Step 1: Open file dialog to select the target Excel file from frontend
    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        file_filter = |xlsx (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|
      CHANGING
        file_table  = it_files
        rc          = lv_rc
        user_action = lv_action ).

    IF lv_action = cl_gui_frontend_services=>action_ok
       AND lines( it_files ) > 0.

      DATA: lv_filesize TYPE w3param-cont_len,
            it_bin_data TYPE w3mimetabtype.

      " Step 2: Upload the frontend file into SAP application memory as binary data
      cl_gui_frontend_services=>gui_upload(
        EXPORTING
          filename   = CONV string( it_files[ 1 ]-filename )
          filetype   = 'BIN'
        IMPORTING
          filelength = lv_filesize
        CHANGING
          data_tab   = it_bin_data ).

      " Step 3: Convert binary SOLIX table to a single XSTRING container
      DATA(lv_bin_data) = cl_bcs_convert=>solix_to_xstring(
                            it_solix = it_bin_data ).

      " Step 4: Parse the spreadsheet binary data via FDT core engine class
      DATA(lo_excel) = NEW cl_fdt_xl_spreadsheet(
                        document_name = CONV #( it_files[ 1 ]-filename )
                        xdocument     = lv_bin_data ).

      DATA lt_worksheet_names TYPE if_fdt_doc_spreadsheet=>t_worksheet_names.

      " Step 5: Extract worksheet identifiers contained inside the spreadsheet
      lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
        IMPORTING
          worksheet_names = lt_worksheet_names ).

      IF lines( lt_worksheet_names ) > 0.

        " Step 6: Convert the target active sheet into a dynamic internal table
        DATA(lo_worksheet) =
          lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
            lt_worksheet_names[ 1 ] ).

        ASSIGN lo_worksheet->* TO FIELD-SYMBOL(<worksheet>).

        " Step 7: Stream parsed dynamic structural data into browser component
        cl_demo_output=>write_data( <worksheet> ).
        DATA(lv_html) = cl_demo_output=>get( ).

        cl_abap_browser=>show_html(
          EXPORTING
            title       = 'Excel Worksheet Output'
            html_string = lv_html
            container   = cl_gui_container=>default_screen ).

        WRITE space.
      ENDIF.
    ENDIF.

  CATCH cx_root INTO DATA(lx_error).
    MESSAGE lx_error->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
ENDTRY.
```

---

## 💡 Notlar

> [!TIP]
> `FILE_OPEN_DIALOG` kullanıcıya standart dosya seçim penceresi açar.

> [!TIP]
> `GUI_UPLOAD` dosyayı binary (BIN) olarak okuyarak SOLIX formatına aktarır.

> [!TIP]
> `CL_BCS_CONVERT=>SOLIX_TO_XSTRING` metodu Excel dosyasını `XSTRING` formatına dönüştürür. `CL_FDT_XL_SPREADSHEET` yalnızca `XSTRING` ile çalışır.

> [!TIP]
> `GET_WORKSHEET_NAMES` ile çalışma sayfaları alınır. İstenirse belirli bir worksheet seçilerek okunabilir.

> [!TIP]
> `GET_ITAB_FROM_WORKSHEET` worksheet'i generic internal table olarak döndürür.

> [!TIP]
> Generic referans aşağıdaki şekilde Field Symbol'e bağlanır:

```abap
ASSIGN lo_worksheet->* TO FIELD-SYMBOL(<worksheet>).
```

> [!TIP]
> `CL_DEMO_OUTPUT` ve `CL_ABAP_BROWSER` sadece örnek görüntüleme amacıyla kullanılmıştır. Gerçek projelerde okunan veri genellikle kendi internal table yapınıza aktarılır.

> [!IMPORTANT]
> Bu yöntem yalnızca **.xlsx** formatındaki Excel dosyalarını destekler. Eski **.xls** dosyaları için farklı yöntemler kullanılmalıdır.
