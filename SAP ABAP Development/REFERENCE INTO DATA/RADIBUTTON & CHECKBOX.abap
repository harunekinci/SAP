-------------------------------------------------------
parameters : rb1 radiobutton group rb user-command com,
             rb2 radiobutton group rb.
-------------------------------------------------------

AT SELECTION-SCREEN OUTPUT.

 LOOP AT SCREEN.

 if rb2 eq 'X'.

  if screen-name cp '*S_KUNNR*'.
  screen-active = 0.
 endif.

else.

 if screen-name cp '*S_KUNWE*'.
  screen-active = 0.
endif.

modify screen.

ENDLOOP.


-----------------------------------------------

PARAMETERS : p_vornr AS CHECKBOX default 'X' .

-----------------------------------------------


