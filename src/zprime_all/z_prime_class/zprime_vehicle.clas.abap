CLASS zprime_vehicle DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mv_name TYPE string.

    methods display_type
        ABSTRACT
        RETURNING VALUE(rv_type) type string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_vehicle IMPLEMENTATION.
ENDCLASS.
