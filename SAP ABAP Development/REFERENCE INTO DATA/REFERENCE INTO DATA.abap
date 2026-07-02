" ====================================================================
" 🛠️ DATA DEFINITIONS, CONSTANTS & INITIALIZATION
" ====================================================================

" 1. Define semantic constants for type safety and readability
CONSTANTS: BEGIN OF lc_tel_type,
             landline TYPE c LENGTH 1 VALUE '1', " Sabit Hat
             mobile   TYPE c LENGTH 1 VALUE '3', " Cep Telefonu
           END OF lc_tel_type.

" 2. Define business-oriented local types
TYPES: BEGIN OF ty_muhatap,
         tel_type   TYPE c LENGTH 1, " 'r3_user' yerine anlamlı alan adı
         telnr_long TYPE string,
       END OF ty_muhatap,
       tt_muhatap TYPE STANDARD TABLE OF ty_muhatap WITH EMPTY KEY.

TYPES: BEGIN OF ty_data,
         telnr     TYPE string,
         cep_telnr TYPE string,
       END OF ty_data.

DATA: es_data TYPE ty_data.

" 3. Populate internal table with semantic data
DATA(lt_muhatap) = VALUE tt_muhatap( ( tel_type = lc_tel_type-landline telnr_long = '+905551112233' )
                                     ( tel_type = lc_tel_type-mobile   telnr_long = '+905329998877' ) ).

" ====================================================================
" 🚀 PROCESSING WITH REFERENCE INTO
" ====================================================================

IF lt_muhatap IS NOT INITIAL.

  es_data = CORRESPONDING #( lt_muhatap[ 1 ] ).

  LOOP AT lt_muhatap REFERENCE INTO DATA(lr_muhatap).

    " Using constants instead of magic numbers ('1' or '3')
    CASE lr_muhatap->tel_type.
      WHEN lc_tel_type-mobile.
        es_data-cep_telnr = lr_muhatap->telnr_long.
      WHEN lc_tel_type-landline.
        es_data-telnr     = lr_muhatap->telnr_long.
    ENDCASE.

  ENDLOOP.

ENDIF.
