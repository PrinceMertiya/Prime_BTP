INTERFACE zif_employee
  PUBLIC .

  METHODS display_details
    RETURNING VALUE(rv_details) TYPE string.

ENDINTERFACE.

