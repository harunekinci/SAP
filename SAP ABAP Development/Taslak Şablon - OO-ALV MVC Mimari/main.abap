*&---------------------------------------------------------------------*
*& Report ZDEVELOPMENT_01
*&---------------------------------------------------------------------*
*& Title     : Taslak Şablon - OO-ALV MVC Mimari Uygulaması
*&
*&----------------------------------------------------------------------*
*& Developer: Harun Ekinci 29.06.2026
*&----------------------------------------------------------------------*
************************************************************************
*             H I S T O R Y   O F   R E V I S I O N S
************************************************************************
*       Date             Developer           Description
*  ---------------  -------------------  -------------------*
*     29.06.2026        Harun Ekinci        New Development
*----------------------------------------------------------------------*
report zdevelopment_01.

" -----------------------------------------------------------------------
" INCLUDES
" -----------------------------------------------------------------------
include zdevelopment_01_ooalv_mvc_cls. " Class Definitions & Implementations
include zdevelopment_01_ooalv_mvc_mod. " PBO & PAI Modules

" -----------------------------------------------------------------------
" INITIALIZATION
" -----------------------------------------------------------------------

INITIALIZATION.
  go_controller = NEW lcl_controller( ).
  go_controller->initialization( ).

  " -----------------------------------------------------------------------
  " AT SELECTION-SCREEN
  " -----------------------------------------------------------------------

at selection-screen.
  go_controller->at_selection_screen( changing cv_ucomm = sscrfields-ucomm ).

  " -----------------------------------------------------------------------
  " START-OF-SELECTION
  " -----------------------------------------------------------------------

start-of-selection.
  go_controller->run( iv_bukrs = p_bukrs
                      it_kunnr = s_kunnr[] ).

  " -----------------------------------------------------------------------
  " END-OF-SELECTION
  " -----------------------------------------------------------------------

end-of-selection.
  if go_controller->has_data( ) = abap_true.
    call screen '9000'.
  else.
    message 'Seçim kriterlerine uygun veri bulunamadı!' type 'S' display like 'E'.
  endif.