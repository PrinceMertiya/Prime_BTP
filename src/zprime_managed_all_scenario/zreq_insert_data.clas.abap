CLASS zreq_insert_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zreq_insert_data IMPLEMENTATION.

    method if_oo_adt_classrun~main.


        DATA : ls_req type zreqtype_vh.

        ls_req-req_type = 'Req01'.
        ls_req-description = 'Immediate'.

        INSERT zreqtype_vh from @ls_req.
        clear ls_req.

        ls_req-req_type = 'Req02'.
        ls_req-description = 'Approval'.

        INSERT zreqtype_vh from @ls_req.
        clear ls_req.


        ls_req-req_type = 'Req03'.
        ls_req-description = 'Working Request'.

        INSERT zreqtype_vh from @ls_req.
        clear ls_req.
        ls_req-req_type = 'Req04'.
        ls_req-description = 'Access Request'.

        INSERT zreqtype_vh from @ls_req.


        if sy-subrc = 0.
            out->write( 'done' ).


        endif.




    endmethod.
ENDCLASS.
