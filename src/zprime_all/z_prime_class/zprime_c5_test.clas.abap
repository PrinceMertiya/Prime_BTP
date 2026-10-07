CLASS zprime_c5_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_c5_test IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA(lo_emp) = NEW zprime_c5_child( ).

    lo_emp->mv_name = 'Prime'.
    lo_emp->mv_empid = 101.

    out->write( |Name: { lo_emp->display_name(  ) }| ).

    out->write( |Name: { lo_emp->display_empid(  ) }| ).


    DATA(lo_emp1) = NEW zprime_c5_child( ).

        out->write( lo_emp1->display_name1( ) ).


  ENDMETHOD.

ENDCLASS.
