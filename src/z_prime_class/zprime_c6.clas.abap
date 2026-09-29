CLASS zprime_c6 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES zif_employee.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.





CLASS zprime_c6 IMPLEMENTATION.

  METHOD zif_employee~display_details.

    rv_details = 'Employee Details'.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

    DATA(lv_text) = me->zif_employee~display_details( ).

    out->write( lv_text ).

  ENDMETHOD.

ENDCLASS.
