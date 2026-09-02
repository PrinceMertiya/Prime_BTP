CLASS zp_program_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zp_program_class IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( 'chup' ).

  ENDMETHOD.

ENDCLASS.
