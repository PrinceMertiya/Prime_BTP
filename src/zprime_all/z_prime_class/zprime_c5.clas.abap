CLASS zprime_c5 DEFINITION
  PUBLIC

  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mv_name TYPE string.

    METHODS display_name
        RETURNing VALUE(rv_name) TYPE STRING.
    METHODS display_name1
        RETURNing VALUE(rv_name1) TYPE STRING.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_c5 IMPLEMENTATION.


  METHOD display_name.

    rv_name = mv_name.

  ENDMETHOD.

  METHOD display_name1.

    rv_name1 = 'prime'.

  ENDMETHOD.

ENDCLASS.
