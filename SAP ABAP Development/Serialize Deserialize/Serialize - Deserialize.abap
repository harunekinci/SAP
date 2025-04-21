CLASS demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
ENDCLASS.

CLASS demo IMPLEMENTATION.
  METHOD main.

    DATA: lt_flight TYPE STANDARD TABLE OF sflight,
          lrf_descr TYPE REF TO cl_abap_typedescr,
          lv_json   TYPE /ui2/cl_json=>json.


    SELECT * FROM sflight INTO TABLE lt_flight.

    " serialize table lt_flight into JSON, skipping initial fields and converting ABAP field names into camelCase
    lv_json = /ui2/cl_json=>serialize( data          = lt_flight
                                       pretty_name   = /ui2/cl_json=>pretty_mode-camel_case
                                       compress      = abap_true
                                       assoc_arrays = abap_true
                                      ).


    cl_demo_output=>write_json( lv_json ).

    CLEAR lt_flight.

    " deserialize JSON string json into internal table lt_flight doing camelCase to ABAP like field name mapping
    /ui2/cl_json=>deserialize( EXPORTING json = lv_json pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING data  = lt_flight ).

    " serialize ABAP object into JSON string
    lrf_descr = cl_abap_typedescr=>describe_by_data( lt_flight ).
    lv_json = /ui2/cl_json=>serialize( data = lrf_descr format_output = abap_true ).

    cl_demo_output=>write_json( lv_json ).

    cl_demo_output=>display( ).

  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  demo=>main( ).