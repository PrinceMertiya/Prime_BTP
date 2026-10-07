CLASS zprime_c3 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mv_name  TYPE string.
    DATA mv_empid TYPE i.

    METHODS set_name
      IMPORTING
        iv_name TYPE string.

    METHODS get_name
      EXPORTING
        ev_name TYPE string.

    METHODS get_name_return
      RETURNING VALUE(rv_name) TYPE string.

    METHODS constructor.

    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS zprime_c3 IMPLEMENTATION.

  METHOD constructor.

    mv_empid = 101.
    mv_name  = 'Prime2'.

  ENDMETHOD.


  METHOD set_name.

    mv_name = iv_name.

  ENDMETHOD.


  METHOD get_name.

    ev_name = mv_name.

  ENDMETHOD.


  METHOD get_name_return.

    rv_name = mv_name.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    DATA(lo_emp) = NEW zprime_c3( ).

    lo_emp->set_name(
      iv_name = 'Prim'
    ).

    DATA lv_name TYPE string.

    lo_emp->get_name(
      IMPORTING
        ev_name = lv_name
    ).

    DATA(lv_name1) = lo_emp->get_name_return( ).

    out->write( |Employee ID: { lo_emp->mv_empid }| ).
    out->write( |Name from Attribute: { lo_emp->mv_name }| ).
    out->write( |Name from Exporting: { lv_name }| ).
    out->write( |Name from Returning: { lv_name1 }| ).

  ENDMETHOD.

ENDCLASS.
