TABLES: kna1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: rb1 RADIOBUTTON GROUP rb USER-COMMAND com DEFAULT 'X',
              rb2 RADIOBUTTON GROUP rb.

  " MODIF ID ile elementleri grupluyoruz (Maksimum 3 karakter)
  SELECT-OPTIONS: s_kunnr FOR kna1-kunnr MODIF ID g1.
SELECTION-SCREEN END OF BLOCK b1.

PARAMETERS: p_vornr AS CHECKBOX DEFAULT 'X'.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    " RB2 seçiliyse g1 grubuna ait tüm bileşenleri (low, high, text vb.) komple gizle
    IF rb2 = abap_true AND screen-group1 = 'G1'.
      screen-active = '0'.
      MODIFY screen.
    ENDIF.
  ENDLOOP.
