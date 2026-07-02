# ✉️ HTML Mail Gönderimi (BCS + MIME Repository)

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP_7.40%2B-0089D0?style=for-the-badge&logo=sap&logoColor=white" alt="SAP ABAP" />
  <img src="https://img.shields.io/badge/TECHNIQUE-BCS_MAIL-2E7D32?style=for-the-badge" alt="BCS" />
  <img src="https://img.shields.io/badge/CATEGORY-HTML_EMAIL-C62828?style=for-the-badge" alt="Mail" />
</div>

<br/>

> **Sistem Mimarı Özeti:** SAP BCS (Business Communication Services) kullanılarak HTML formatında e-posta gönderilebilir. Mail içerisine MIME Repository'de bulunan görseller CID (Content-ID) yöntemiyle gömülerek Outlook ve diğer mail istemcilerinde harici bağlantıya ihtiyaç duymadan görüntülenebilir.

---

## 🛠️ İşlem Adımları

| Adım | Açıklama |
|------|----------|
| **Mime Repository** | Görsel `GET` metodu ile okunur. |
| **SCMS_XSTRING_TO_BINARY** | XSTRING veri SOLIX formatına dönüştürülür. |
| **CL_GBT_MULTIRELATED_SERVICE** | HTML ve görseller aynı mail içerisine eklenir. |
| **HTML Body** | Mail içeriği HTML olarak hazırlanır. |
| **CL_BCS** | Mail oluşturulur ve gönderilir. |

---

## 💻 Mail Akışı

```text
Mime Repository
        │
        ▼
GET()
        │
        ▼
XSTRING
        │
        ▼
SCMS_XSTRING_TO_BINARY
        │
        ▼
SOLIX
        │
        ▼
CL_GBT_MULTIRELATED_SERVICE
        │
        ├── HTML
        └── Image (CID)
        │
        ▼
CL_DOCUMENT_BCS
        │
        ▼
CL_BCS
        │
        ▼
SEND()
```

---

## 💡 Mimari Tasarım Notları

> [!IMPORTANT]
> HTML içerisinde kullanılan `cid:` değeri ile `content_id` parametresi birebir aynı olmalıdır. Aksi halde görsel mail içerisinde görüntülenmez.

> [!TIP]
> Görselleri internet adresi yerine **MIME Repository** üzerinden göndermek, mail istemcilerinin dış bağlantıları engellemesinden etkilenmez.

> [!TIP]
> `SCMS_XSTRING_TO_BINARY` fonksiyonu, manuel byte dönüşümlerine göre daha güvenilir ve performanslıdır.

> [!WARNING]
> `SEND()` işlemi başarılı olsa bile mailin gerçekten gönderilebilmesi için `COMMIT WORK` çalıştırılmalıdır.

---

## 💻 Kod

```abap
REPORT zdemo_birthday_mail.

CLASS lcl_birthday_mail DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS send_mail.
ENDCLASS.

CLASS lcl_birthday_mail IMPLEMENTATION.

  METHOD send_mail.

    "----------------------------------------------------------
    " 1. Mime Repository'den Görseli Oku
    "----------------------------------------------------------

    DATA(lv_url) = '/sap/bc/bsp/sap/zhr_dogumgun/dogumgunu.jpg'.

    DATA(lo_mr_api) =
      cl_mime_repository_api=>if_mr_api~get_api( ).

    DATA lv_content TYPE xstring.

    lo_mr_api->get(
      EXPORTING
        i_url              = lv_url
      IMPORTING
        e_content          = lv_content
      EXCEPTIONS
        parameter_missing  = 1
        error_occured      = 2
        not_found          = 3
        permission_failure = 4
        OTHERS             = 5 ).

    IF sy-subrc <> 0.
      MESSAGE 'Görsel Mime Repository''de bulunamadı!'
        TYPE 'E'.
      RETURN.
    ENDIF.

    "----------------------------------------------------------
    " 2. XSTRING -> SOLIX
    "----------------------------------------------------------

    DATA:
      lt_solix TYPE solix_tab,
      lv_len   TYPE i.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_content
      IMPORTING
        output_length = lv_len
      TABLES
        binary_tab    = lt_solix.

    "----------------------------------------------------------
    " 3. HTML + Image
    "----------------------------------------------------------

    DATA(lo_mime_helper) =
      NEW cl_gbt_multirelated_service( ).

    DATA(lv_content_id) = 'img_happy.jpg'.

    lo_mime_helper->add_binary_part(
      content      = lt_solix
      filename     = 'img_happy.jpg'
      extension    = 'JPG'
      description  = 'Doğum Günü Görseli'
      content_type = 'image/jpeg'
      length       = lv_len
      content_id   = lv_content_id ).

    "----------------------------------------------------------
    " 4. HTML Body
    "----------------------------------------------------------

    DATA(lt_soli) =
      VALUE soli_tab(

      ( line = '<html><body>' )

      ( line = '<p style="font-family:Roboto,Comic Sans MS;font-size:14px;color:#333333;font-style:italic;">' )

      ( line = '<b>Dear Celebrity,</b><br><br>' )

      ( line = |<img alt="Dogum Gunu" src="cid:{ lv_content_id }" /><br><br>| )

      ( line = 'Regards,<br><b>Harun EKINCI</b></p>' )

      ( line = '</body></html>' )

      ).

    lo_mime_helper->set_main_html(
      content     = lt_soli
      filename    = 'sapwebform.htm'
      description = 'Doğum Gününüz Kutlu Olsun!' ).

    "----------------------------------------------------------
    " 5. Mail Gönderimi
    "----------------------------------------------------------

    TRY.

        DATA(lo_bcs) =
          cl_bcs=>create_persistent( ).

        DATA(lo_doc_bcs) =
          cl_document_bcs=>create_from_multirelated(
            i_subject          = 'Doğum Gününüz Kutlu Olsun'
            i_multirel_service = lo_mime_helper ).

        lo_bcs->set_document( lo_doc_bcs ).

        DATA(lo_sender) =
          cl_cam_address_bcs=>create_internet_address(
            'hekinci@emlakinsaat.com.tr' ).

        lo_bcs->set_sender( lo_sender ).

        DATA(lo_recipient) =
          cl_cam_address_bcs=>create_internet_address(
            'hekinci@emlakinsaat.com.tr' ).

        lo_bcs->add_recipient( lo_recipient ).

        IF lo_bcs->send( ) = abap_true.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_bcs INTO DATA(lx_bcs).

        ROLLBACK WORK.

        MESSAGE lx_bcs->get_text( )
          TYPE 'E'.

    ENDTRY.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  lcl_birthday_mail=>send_mail( ).
```
