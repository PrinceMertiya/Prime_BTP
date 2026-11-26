CLASS zprime_en_interval_1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_en_interval_1 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA(lt_objects) = VALUE string_table(
          ( `ZPN_HDR_1` )
          ( `ZPN_ITEM_1` )
          ( `ZPN_COND` )
          ( `ZPN_SCHED` )
          ( `ZPN_HU` )
        ).


     LOOP AT lt_objects INTO DATA(lv_obj).
      TRY.
          cl_numberrange_intervals=>create(
            EXPORTING
              interval  = VALUE #( ( nrrangenr  = '01'
                                     fromnumber = '1000001'
                                     tonumber   = '9999999'
                                     procind    = 'I' ) )
              object    = CONV #( lv_obj )
            IMPORTING
              error     = DATA(ld_error)
              error_inf = DATA(ls_error)
              error_iv  = DATA(lt_error_iv)
              warning   = DATA(ld_warning) ).

          out->write( |{ lv_obj }: Created (Error: { ld_error }, Warning: { ld_warning })| ).
        CATCH cx_root INTO DATA(lo_error).
          out->write( |{ lv_obj } Exception: { lo_error->get_text( ) }| ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
