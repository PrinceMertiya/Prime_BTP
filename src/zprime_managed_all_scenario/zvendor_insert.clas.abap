CLASS zvendor_insert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zvendor_insert IMPLEMENTATION.

    method if_oo_adt_classrun~main.

        DATA ls_vendor type zvendor_vh.

        ls_vendor-vendor_id = 'V004'.
        ls_vendor-vendor_name = 'Capgemini'.

        INSERT zvendor_vh from @ls_vendor.

        clear ls_vendor.

        ls_vendor-vendor_id = 'V005'.
        ls_vendor-vendor_name = 'Astragenica'.

        INSERT zvendor_vh from @ls_vendor.

        clear ls_vendor.

        ls_vendor-vendor_id = 'V006'.
        ls_vendor-vendor_name = 'Rolex'.

        INSERT zvendor_vh from @ls_vendor.

        if sy-subrc = 0.
            COMMIT WORK.
            out->write( 'done' ).

        else.
            out->write( 'not done' ).

        endif.



    ENDMETHOD.
ENDCLASS.
