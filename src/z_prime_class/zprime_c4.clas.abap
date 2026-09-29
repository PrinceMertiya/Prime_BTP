CLASS zprime_c4 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mv_name TYPE string.

    METHODS set_name
      IMPORTING
        iv_name TYPE string.

    CLASS-METHODS get_company
      RETURNING VALUE(rv_company) TYPE string.

    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS zprime_c4 IMPLEMENTATION.

  METHOD set_name.

    mv_name = iv_name.

  ENDMETHOD.


  METHOD get_company.

    rv_company = 'Microsoft'.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    DATA(lo_emp) = NEW zprime_c4( ).

    lo_emp->set_name(
      iv_name = 'Prime'
    ).

    out->write(
      |Employee Name: { lo_emp->mv_name }|
    ).

    DATA(lv_company) = zprime_c4=>get_company( ).

    out->write(
      |Company: { lv_company }|
    ).

  ENDMETHOD.

ENDCLASS.
