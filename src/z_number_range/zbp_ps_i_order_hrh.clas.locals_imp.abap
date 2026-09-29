CLASS lhc_ZPS_I_ORDER_HRH DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zps_i_order_hrh RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zps_i_order_hrh RESULT result.

    METHODS getdata FOR MODIFY
       keys FOR ACTION zps_i_order_hrh~getdata.
    METHODS calculatestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zps_i_order_hrh~calculatestatus.
    METHODS validateamount FOR VALIDATE ON SAVE
      IMPORTING keys FOR zps_i_order_hrh~validateamount.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE zps_i_order_hrh.

ENDCLASS.

CLASS lhc_ZPS_I_ORDER_HRH IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.



  METHOD earlynumbering_create.
*  DATA:
*    lt_entities TYPE TABLE FOR CREATE zps_i_order_hrh,
*    lv_orderid  TYPE zsp_num.
*  lt_entities = entities.
    DATA(lt_entities) = entities.
    DATA lv_orderid TYPE n LENGTH 10.

    " Only generate number when OrderId is empty
*  DELETE lt_entities WHERE OrderId IS NOT INITIAL.
*
*  IF lt_entities IS INITIAL.
*    RETURN.
*  ENDIF.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'
            object      = 'ZNUM_RANGE'
            quantity    = CONV #( lines( lt_entities ) )
          IMPORTING
            number            = DATA(lv_last_number)
            returncode        = DATA(lv_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_number_ranges INTO DATA(lo_error).

        LOOP AT lt_entities INTO DATA(ls_entity).
          APPEND VALUE #(
            %cid = ls_entity-%cid
            %key = ls_entity-%key
            %is_draft = ls_entity-%is_draft
          ) TO failed-zps_i_order_hrh.
          APPEND VALUE #(
            %cid = ls_entity-%cid
            %key = ls_entity-%key
            %msg = lo_error
            %is_draft = ls_entity-%is_draft
          ) TO reported-zps_i_order_hrh.
        ENDLOOP.
        EXIT.

    ENDTRY.

    ASSERT lv_qty = lines( lt_entities ).
    lv_orderid = lv_last_number - lv_qty.

    LOOP AT lt_entities INTO ls_entity.
      lv_orderid = lv_orderid + 1.
      APPEND VALUE #(
        %cid         = ls_entity-%cid
        %is_draft    = ls_entity-%is_draft
        OrderId      = lv_orderid
      ) TO mapped-zps_i_order_hrh.
    ENDLOOP.
  ENDMETHOD.

*METHOD getData.
*
*
*    DATA(lo_gen) = NEW zcl_order_generator( ).
*    lo_gen->gen_and_get_data(
*    IMPORTING
*    ct_table = DATA(lt_data)
*
*    ).
*
*  MODIFY ENTITIES OF zps_i_order_hrh IN LOCAL MODE
*    ENTITY zps_i_order_hrh
*    CREATE FROM VALUE #(
*      (
*        %cid      = 'CID12'
**        OrderId   = 10002032
*        OrderName = 'chaman Order'
*        OrderType = 'IT'
*        OrderDate = cl_abap_context_info=>get_system_date( )
*        Status    = 'Opene'
*        CukyField = 'INR'
*        Amount    = '1000'
*
*        %control  =
*                   VALUE #(
**                        OrderId = if_abap_behv=>mk-on
*                        OrderName = if_abap_behv=>mk-on
*                        OrderType = if_abap_behv=>mk-on
*                        OrderDate = if_abap_behv=>mk-on
*                        Status = if_abap_behv=>mk-on
*                        CukyField = if_abap_behv=>mk-on
*                        Amount = if_abap_behv=>mk-on
*                     )
*      )
*    )
*    MAPPED mapped
*    FAILED failed.
*
*
*ENDMETHOD.


  METHOD getData.

    DATA(lo_gen) = NEW zcl_order_generator( ).

    lo_gen->gen_and_get_data(
      IMPORTING
        ct_table = DATA(lt_data)
    ).

    LOOP AT lt_data INTO DATA(ls_data).

      MODIFY ENTITIES OF zps_i_order_hrh IN LOCAL MODE
        ENTITY zps_i_order_hrh
        CREATE FROM VALUE #(
          FOR <instance> IN keys
          (
            %cid      = <instance>-%cid
            OrderName = ls_data-order_name
            OrderType = ls_data-order_type
            OrderDate = ls_data-order_date
            Status    = ls_data-status
            CukyField = ls_data-cuky_field
            Amount    = ls_data-amount

            %control = VALUE #(
              OrderName = if_abap_behv=>mk-on
              OrderType = if_abap_behv=>mk-on
              OrderDate = if_abap_behv=>mk-on
              Status    = if_abap_behv=>mk-on
              CukyField = if_abap_behv=>mk-on
              Amount    = if_abap_behv=>mk-on
            )
          )
        )
        MAPPED mapped
        FAILED failed.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculatestatus.

    READ ENTITIES OF zps_i_order_hrh IN LOCAL MODE
      ENTITY zps_i_order_hrh
      FIELDS ( Amount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_order).

    LOOP AT lt_order ASSIGNING FIELD-SYMBOL(<ls_order>).

      DATA lv_status TYPE zps_order_hrh-status.

      IF <ls_order>-Amount <= 0.
        lv_status = 'Invalid'.

      ELSEIF <ls_order>-Amount < 10000.
        lv_status = 'NORMAL'.
      ELSEIF <ls_order>-Amount < 50000.
        lv_status = 'PREMIUM'.
      ELSE.
        lv_status = 'VIP'.
      ENDIF.

      MODIFY ENTITIES OF zps_i_order_hrh IN LOCAL MODE
        ENTITY zps_i_order_hrh
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          (
            %tky = <ls_order>-%tky
            Status = lv_status
          )
        ).

    ENDLOOP.

  ENDMETHOD.

  METHOD validateamount.

    READ ENTITIES OF zps_i_order_hrh IN LOCAL MODE
      ENTITY zps_i_order_hrh
      FIELDS ( Amount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      IF <ls_data>-Amount <= 0.

        APPEND VALUE #(
          %tky = <ls_data>-%tky
        ) TO failed-zps_i_order_hrh.

        APPEND VALUE #(
          %tky = <ls_data>-%tky
          %msg = new_message(
                   id       = 'SY'
                   number   = '002'
                   severity = if_abap_behv_message=>severity-error
                   v1       = 'Amount must be greater than zero'
                 )
        ) TO reported-zps_i_order_hrh.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
