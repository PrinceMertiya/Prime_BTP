CLASS lhc_ZPS_I_ORDER_HRH DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zps_i_order_hrh RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zps_i_order_hrh.

ENDCLASS.

CLASS lhc_ZPS_I_ORDER_HRH IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA:
      entity       TYPE STRUCTURE FOR CREATE zps_i_order_hrh,
      order_id_max TYPE ZSP_NUM.

    " Idempotency guard: carry forward entities that already have an Order ID
    " Required for draft-enabled BOs to avoid re-numbering on re-activation
    LOOP AT entities INTO entity WHERE OrderId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-zps_i_order_hrh.
    ENDLOOP.

    DATA(entities_wo_orderid) = entities.
    DELETE entities_wo_orderid WHERE OrderId IS NOT INITIAL.

    " Nothing left to number — exit cleanly
    CHECK entities_wo_orderid IS NOT INITIAL.

    " *** NUMBER RANGE PATH (always active) ***
    " PREREQUISITE: Buffering MUST be enabled on object ZNU_RANGE in  .
    " Without buffering, cl_numberrange_runtime=>number_get executes
    " UPDATE nriv on the primary DB connection, which violates the RAP
    " interaction phase contract and causes dump BEHAVIOR_ILLEGAL_STATEMENT.
    " With buffering ON, SAP uses a secondary DB connection (CONNECTION 'R/3*NRIV')
    " which is fully permitted in EarlyNumbering.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZNUM_RANGE'
            quantity          = CONV #( lines( entities_wo_orderid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_root INTO DATA(lx_root).

  LOOP AT entities_wo_orderid INTO entity.
    APPEND VALUE #(
      %cid = entity-%cid
      %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = lx_root->get_text( ) )
    ) TO reported-zps_i_order_hrh.

    APPEND VALUE #(
      %cid = entity-%cid )
    TO failed-zps_i_order_hrh.

  ENDLOOP.

  RETURN.
    ENDTRY.

    " Validate return code
    " '1' = last number of interval issued (warning only, still usable)
    " '2' = number range is fully exhausted — must fail
    IF number_range_return_code = '2'.
      LOOP AT entities_wo_orderid INTO entity.
        APPEND VALUE #( %cid = entity-%cid
                        %key = entity-%key
                      ) TO failed-zps_i_order_hrh.
      ENDLOOP.
      RETURN.
    ENDIF.

    " Guard against partial allocation
    " number_get may return fewer numbers than requested if near interval end
    IF number_range_returned_quantity < lines( entities_wo_orderid ).
      DATA(lv_allocated) = CONV i( number_range_returned_quantity ).
      " Fail the entities that did not get a number
      LOOP AT entities_wo_orderid INTO entity FROM lv_allocated + 1.
        APPEND VALUE #( %cid = entity-%cid
                        %key = entity-%key
                      ) TO failed-zps_i_order_hrh.
      ENDLOOP.
      " Only process the ones that were actually allocated
      DELETE entities_wo_orderid FROM lv_allocated + 1.
    ENDIF.

    " number_range_key = LAST number in the allocated block
    " Subtract returned_quantity to get the value just before the block starts
    " then increment by 1 per entity in the loop below
    order_id_max = number_range_key - number_range_returned_quantity.

    " Assign unique Order ID to each new entity
    LOOP AT entities_wo_orderid INTO entity.
      order_id_max += 1.

      entity-OrderId      = order_id_max.
      entity-%key-OrderId = order_id_max.

      APPEND VALUE #( %cid = entity-%cid
                      %key = entity-%key
                    ) TO mapped-zps_i_order_hrh.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
