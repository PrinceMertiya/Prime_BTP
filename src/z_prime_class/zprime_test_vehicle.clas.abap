CLASS zprime_test_vehicle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_test_vehicle IMPLEMENTATION.

    method if_oo_adt_classrun~main.
        data(lo_car) = new zprime_car( ).

        lo_car->mv_name = 'BMW'.

        out->write( |vehicle name: { lo_car->mv_name }| ).
        out->write( |vehicle type: { lo_car->display_type( ) }| ).

    endmethod.
ENDCLASS.
