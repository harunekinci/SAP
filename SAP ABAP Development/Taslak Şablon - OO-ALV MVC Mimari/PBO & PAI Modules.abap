*&---------------------------------------------------------------------*
*&  Include           ZDEVELOPMENT_01_OOALV_MVC_MOD
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* OUTPUT MODULE (PBO - Screen 9000)
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR '9000'.
  IF go_controller IS BOUND.
    go_controller->render_screen( ).
  ENDIF.
ENDMODULE.

*----------------------------------------------------------------------*
* INPUT MODULE (PAI - Screen 9000)
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE sy-ucomm.
    WHEN '&BACK' OR '&EXIT' OR '&CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.