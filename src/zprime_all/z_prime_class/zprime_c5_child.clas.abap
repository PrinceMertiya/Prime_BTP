CLASS zprime_c5_child DEFINITION
  PUBLIC

  INHERITING FROM zprime_c5

  CREATE PUBLIC .

  PUBLIC SECTION.

    data mv_empid TYPE i.

    methods display_empid
        returning value(rv_empid) type i.

    METHODS display_name1 REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_c5_child IMPLEMENTATION.
    METHOD display_empid.
        rv_empid = mv_empid.

    ENDMETHOD.
  METHOD display_name1.

    rv_name1 = 'prince'.

  ENDMETHOD.

ENDCLASS.
