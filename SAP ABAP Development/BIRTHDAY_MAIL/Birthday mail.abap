*&---------------------------------------------------------------------*
*& Report ZDEMO_BIRTHDAY_MAIL
*&---------------------------------------------------------------------*
*& Source : https://abap4help.blogspot.com/2017/01/image-in-mail-body-steps-enter.html
*&---------------------------------------------------------------------*

REPORT zdemo_birthday_mail.

"For Mime Repository
DATA : gv_mr_api  TYPE REF TO if_mr_api, "mime repository object
       gv_content TYPE xstring,          "image in XSTRING
       is_folder  TYPE boole_d,
       l_loio     TYPE skwf_io.

*Image to Xstring Table form
DATA : l_obj_len         TYPE so_obj_len,
       lv_graphic_length TYPE tdlength,
       gr_xstr           TYPE xstring,
       l_offset          TYPE i,
       l_length          TYPE i,
       l_diff            TYPE i,
       ls_solix          TYPE solix,
       lt_solix          TYPE solix_tab.

"Attach image to HTML body
DATA: l_filename   TYPE string,
      l_content_id TYPE string.

"for HTML content
DATA : lt_soli TYPE soli_tab,
       ls_soli TYPE soli.

"Class for cobining HMTL & Image
DATA : lo_mime_helper    TYPE REF TO cl_gbt_multirelated_service.

"BCS class for sending mail
DATA: lo_bcs       TYPE REF TO cl_bcs,
      lo_doc_bcs   TYPE REF TO cl_document_bcs,
      lo_sender    TYPE REF TO if_sender_bcs,
      lo_recipient TYPE REF TO if_recipient_bcs,
      l_subject    TYPE so_obj_des.

"Create image in xstring form
IF gv_mr_api IS INITIAL.

  gv_mr_api = cl_mime_repository_api=>if_mr_api~get_api( ).

ENDIF.

CALL METHOD gv_mr_api->get
  EXPORTING
    i_url              = '/sap/bc/bsp/sap/zhr_dogumgun/dogumgunu.jpg'  "Image path
  IMPORTING
    e_is_folder        = is_folder
    e_content          = gv_content
    e_loio             = l_loio
  EXCEPTIONS
    parameter_missing  = 1
    error_occured      = 2
    not_found          = 3
    permission_failure = 4
    OTHERS             = 5.
"Convert Image to Xstring table form

l_obj_len = xstrlen( gv_content ).
lv_graphic_length = xstrlen( gv_content ).

"Get whole image
CLEAR gr_xstr.
gr_xstr = gv_content(l_obj_len).

l_offset = 0.
l_length = 255.

CLEAR lt_solix[].
WHILE l_offset < lv_graphic_length.
  l_diff = lv_graphic_length - l_offset.
  IF l_diff > l_length.
    ls_solix-line = gr_xstr+l_offset(l_length).
  ELSE.
    ls_solix-line = gr_xstr+l_offset(l_diff).
  ENDIF.
  APPEND ls_solix TO lt_solix.
  ADD l_length TO l_offset.
ENDWHILE.

*&-------------------------------
*Attach image to HTML body
*&-------------------------------
l_filename   = 'img_happy.jpg'.
l_content_id = 'img_happy.jpg'.

CREATE OBJECT lo_mime_helper.
CALL METHOD lo_mime_helper->add_binary_part
  EXPORTING
    content      = lt_solix                   "Xstring in table form
    filename     = l_filename                 "file name to be given to image
    extension    = 'JPG'                      "type of file
    description  = 'Graphic in JPG format'    "description
    content_type = 'IMAGE/jpg'                "content type / Mime type. If mime                   type not present in system then need to add through tcode : SMW0
    length       = l_obj_len                  "length of image
    content_id   = l_content_id.          "content id would be used in html part

*&===============================================================================
*& Create HTML mail body Content
*&===============================================================================
REFRESH lt_soli[].

CLEAR ls_soli.
ls_soli = '<body>'.
APPEND ls_soli TO lt_soli.

"to apply font to HTML body content
CLEAR ls_soli.
concatenate '<p><font size="3" face="Roboto,Lucida Calligraphy,Comic Sans MS" color="#CCD9FF" fontStyle="italic"><i><b>Dear'
 'Celebrity' ', <br>' INTO ls_soli SEPARATED BY space.
APPEND ls_soli TO lt_soli.

"For displaying Image
CLEAR ls_soli.
ls_soli = '<br><img alt="[image]" src="cid:img_happy.jpg" /><br>'.
APPEND ls_soli TO lt_soli.

CLEAR ls_soli.
CONCATENATE '<br>Regards,<br>' 'Developer Name' '<br>Harun EKINCI</b></i></font></p></body></html>'
            INTO ls_soli SEPARATED BY space.
APPEND ls_soli TO lt_soli.

*&=======================================================================================================
"Create main HTML body
*CREATE OBJECT lo_mime_helper.
CALL METHOD lo_mime_helper->set_main_html
  EXPORTING
    content     = lt_soli
    filename    = 'sapwebform.htm'      "filename for HMTL form
    description = 'Doğum Gününüz Kutlu Olsun !'.  "Title

"Create HTML using BCS class and attach html and image part to it.
l_subject  = 'Doğum Gününüz Kutlu Olsun'(t01).  "subject
lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
i_subject  = l_subject
i_multirel_service = lo_mime_helper ).

lo_bcs = cl_bcs=>create_persistent( ).

"Create Document
lo_bcs->set_document( i_document = lo_doc_bcs ).

"create Sender
lo_sender = cl_cam_address_bcs=>create_internet_address( 'hekinci@emlakinsaat.com.tr' ).

" Set sender
lo_bcs->set_sender(
EXPORTING
i_sender = lo_sender ).

"Create Recipient
lo_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string ='hekinci@emlakinsaat.com.tr' ).
lo_bcs->add_recipient( i_recipient = lo_recipient ).

lo_bcs->send( ).
COMMIT WORK AND WAIT.
