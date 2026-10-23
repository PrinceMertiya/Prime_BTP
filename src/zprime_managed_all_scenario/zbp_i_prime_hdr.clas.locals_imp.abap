CLASS lhc_ZI_PRIME_HDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zi_prime_hdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zi_prime_hdr RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE zi_prime_hdr.

    METHODS earlynumbering_cba_Item FOR NUMBERING
       entities FOR CREATE zi_prime_hdr\_Item.

    METHODS get_instance_features
      FOR INSTANCE FEATURES
      IMPORTING keys   REQUEST requested_features
                  FOR zi_prime_hdr
      RESULT    result.


    METHODS CalculatingAmount FOR DETERMINE ON MODIFY
       keys FOR zi_prime_item~CalculatingAmount.
    METHODS CalculateTotalAmount FOR DETERMINE ON MODIFY
       keys FOR zi_prime_item~CalculateTotalAmount.
    METHODS CalculateStatus FOR DETERMINE ON MODIFY
       keys FOR zi_prime_hdr~CalculateStatus.
    METHODS Submit FOR MODIFY
       keys FOR ACTION zi_prime_hdr~Submit RESULT result.
    METHODS CopyRequest FOR MODIFY
       keys FOR ACTION zi_prime_hdr~CopyRequest RESULT result.
    METHODS Approve FOR MODIFY
       keys FOR ACTION zi_prime_hdr~Approve RESULT result.
    METHODS Reject FOR MODIFY
      keys FOR ACTION ZI_PRIME_HDR~Reject RESULT result.




ENDCLASS.

CLASS lhc_ZI_PRIME_HDR IMPLEMENTATION.

  METHOD get_instance_authorizations.

  READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
    ENTITY zi_prime_hdr
    FIELDS ( CreatedBy )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_hdr).

  DATA(lv_user) = sy-uname.

  result = VALUE #(
    FOR ls_hdr IN lt_hdr
    (
      %tky = ls_hdr-%tky

      %update =
        COND #(
          WHEN ls_hdr-CreatedBy = lv_user
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized
        )

      %delete =
        COND #(
          WHEN ls_hdr-CreatedBy = lv_user
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized
        )
    )
  ).

ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    result = VALUE #(
      FOR ls_hdr IN lt_hdr
      (
        %tky = ls_hdr-%tky



        " Custom actions
        %action-Submit =
          COND #(
            WHEN ls_hdr-status IS INITIAL
              OR ls_hdr-status = 'DRAFT'
            THEN if_abap_behv=>fc-o-enabled
            ELSE if_abap_behv=>fc-o-disabled )

        %action-Approve =
          COND #(
            WHEN ls_hdr-status = 'SUBMITTED'
            THEN if_abap_behv=>fc-o-enabled
            ELSE if_abap_behv=>fc-o-disabled )

        %action-Reject =
          COND #(
            WHEN ls_hdr-status = 'SUBMITTED'
            THEN if_abap_behv=>fc-o-enabled
            ELSE if_abap_behv=>fc-o-disabled )
      )
    ).

  ENDMETHOD.



  METHOD calculatingamount.

    DATA: lt_items       TYPE TABLE FOR READ RESULT zi_prime_item,
          lt_item_update TYPE TABLE FOR UPDATE zi_prime_item,
          lv_total       TYPE zi_prime_hdr-TotalAmount.

*--------------------------------------------------------------------
* Read changed items
*--------------------------------------------------------------------
    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_item
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT lt_items.

*--------------------------------------------------------------------
* Calculate Amount
*--------------------------------------------------------------------
    LOOP AT lt_items INTO DATA(ls_item).

      APPEND VALUE #(
        %tky            = ls_item-%tky
        Amount          = ls_item-Quantity * ls_item-Price
        %control-Amount = if_abap_behv=>mk-on
      ) TO lt_item_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_item
      UPDATE FIELDS ( Amount )
      WITH lt_item_update.


  ENDMETHOD.


  METHOD earlynumbering_create.

    DATA(lt_entities) = entities.

    TRY.

        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'
            object      = 'ZPN_PRIME'
            quantity    = CONV #( lines( lt_entities ) )
          IMPORTING
            number            = DATA(lv_last_number)
            returned_quantity = DATA(lv_qty)
        ).

      CATCH cx_number_ranges INTO DATA(lo_error).

        LOOP AT lt_entities INTO DATA(ls_entity).

          APPEND VALUE #(
            %cid      = ls_entity-%cid
            %is_draft = ls_entity-%is_draft
          ) TO failed-zi_prime_hdr.

        ENDLOOP.

        RETURN.

    ENDTRY.

    DATA(lv_reqid) = lv_last_number - lv_qty.

    LOOP AT lt_entities INTO DATA(ls_entity1).

      lv_reqid += 1.

      APPEND VALUE #(
        %cid       = ls_entity1-%cid
        %is_draft  = ls_entity1-%is_draft
        ReqId      = |REF{ lv_reqid }|
      ) TO mapped-zi_prime_hdr.

    ENDLOOP.

  ENDMETHOD.


  METHOD earlynumbering_cba_Item.

    LOOP AT entities INTO DATA(ls_parent).

      DATA(lt_target) = ls_parent-%target.

      TRY.

          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = 'ZPN_ITEM'
              quantity    = CONV #( lines( lt_target ) )
            IMPORTING
              number            = DATA(lv_last_number)
              returned_quantity = DATA(lv_qty)
          ).

        CATCH cx_number_ranges INTO DATA(lo_error).

          LOOP AT lt_target INTO DATA(ls_item_fail).

            APPEND VALUE #(
              %cid      = ls_item_fail-%cid
              %is_draft = ls_item_fail-%is_draft
            ) TO failed-zi_prime_item.

          ENDLOOP.

          CONTINUE.

      ENDTRY.

      DATA(lv_itemid) = lv_last_number - lv_qty.

      LOOP AT lt_target INTO DATA(ls_item).

        lv_itemid += 1.

        APPEND VALUE #(
          %cid      = ls_item-%cid
          %is_draft = ls_item-%is_draft
          ReqId     = ls_parent-ReqId
          ItemId    = |ITEM{ lv_itemid }|
        ) TO mapped-zi_prime_item.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.



  METHOD calculatetotalamount.

    DATA lv_total TYPE zi_prime_hdr-TotalAmount.

* Get header

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    LOOP AT lt_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr>).

      CLEAR lv_total.

* Read ALL child items of current header

      READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
        ENTITY zi_prime_hdr
        BY \_Item
        ALL FIELDS
        WITH VALUE #(
          (
            %tky = <ls_hdr>-%tky
          )
        )
        RESULT DATA(lt_all_items).

* Sum all items

      LOOP AT lt_all_items INTO DATA(ls_item).

        lv_total += ls_item-Amount.

      ENDLOOP.

* Update header

      MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
        ENTITY zi_prime_hdr
        UPDATE FIELDS ( TotalAmount )
        WITH VALUE #(
          (
            %tky = <ls_hdr>-%tky
            TotalAmount = lv_total
            %control-TotalAmount = if_abap_behv=>mk-on
          )
        ).

    ENDLOOP.

  ENDMETHOD.

  METHOD calculatestatus.

    DATA: lv_status TYPE string.

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      FIELDS ( TotalAmount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    LOOP AT lt_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr>).

      IF <ls_hdr>-TotalAmount < 100000.
        lv_status = '⚪ NORMAL'.
      ELSEIF <ls_hdr>-TotalAmount < 500000.
        lv_status = '🔵 PREMIUM'.
      ELSE.
        lv_status = '🟢 VIP'.
      ENDIF.

      MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
        ENTITY zi_prime_hdr
        UPDATE FIELDS ( Category )
        WITH VALUE #(
          (
            %tky   = <ls_hdr>-%tky
            Category = lv_status
          )
        ).

    ENDLOOP.

  ENDMETHOD.
  METHOD submit.

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    LOOP AT lt_hdr INTO DATA(ls_hdr).

      READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
        ENTITY zi_prime_hdr BY \_Item
        ALL FIELDS
        WITH VALUE #(
          (
            %tky = ls_hdr-%tky
          )
        )
        RESULT DATA(lt_items).

      IF lt_items IS INITIAL.

        APPEND VALUE #(
          %tky = ls_hdr-%tky
        ) TO failed-zi_prime_hdr.

        APPEND VALUE #(
          %tky = ls_hdr-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Please add at least one item before submit'
                 )
        ) TO reported-zi_prime_hdr.

        CONTINUE.

      ENDIF.

      MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
        ENTITY zi_prime_hdr
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          (
            %tky   = ls_hdr-%tky
            Status = 'SUBMITTED'
          )
        ).

    ENDLOOP.

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls IN lt_result
      (
        %tky   = ls-%tky
        %param = ls
      )
    ).

  ENDMETHOD.

*  METHOD CopyRequest.
*
*  READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
*    ENTITY zi_prime_hdr
*    ALL FIELDS
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_hdr).
*
*  LOOP AT lt_hdr INTO DATA(ls_hdr).
*
*    MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
*      ENTITY zi_prime_hdr
*      CREATE
*      FROM VALUE #(
*        (
*          %cid = |COPY_{ sy-tabix }|
*
*          ReqType   = ls_hdr-ReqType
*          Vendor    = ls_hdr-Vendor
*          Status    = 'DRAFT'
*          Category  = ls_hdr-Category
*          CukyField = ls_hdr-CukyField
*        )
*      )
*      MAPPED DATA(mapped_hdr).
*
*      APPEND VALUE #(
*  %msg = new_message_with_text(
*            severity = if_abap_behv_message=>severity-success
*            text = 'CopyRequest Method Executed'
*         )
*) TO reported-zi_prime_hdr.
*
*
*  ENDLOOP.
*
*ENDMETHOD.
  METHOD CopyRequest.

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      CREATE
      FIELDS ( ReqType Vendor Status Category CukyField )
      WITH VALUE #(
        FOR ls_hdr IN lt_hdr
        (
          %cid      = |COPY_{ sy-tabix }|
          ReqType   = ls_hdr-ReqType
          Vendor    = ls_hdr-Vendor
          Status    = 'DRAFT'
          Category  = ls_hdr-Category
          CukyField = ls_hdr-CukyField
        )
      )
      MAPPED DATA(mapped_hdr)
      FAILED DATA(failed_hdr)
      REPORTED DATA(reported_hdr).

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      ALL FIELDS
      WITH VALUE #(
        FOR ls_map IN mapped_hdr-zi_prime_hdr
        (
          %tky = ls_map-%tky
        )
      )
      RESULT DATA(lt_new_hdr).

    result = VALUE #(
      FOR ls_new IN lt_new_hdr
      (
        %tky   = ls_new-%tky
        %param = ls_new
      )
    ).

  ENDMETHOD.

  METHOD Approve.

    MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_hdr
      UPDATE FIELDS ( Status )
      WITH VALUE #(
        FOR key IN keys
        (
          %tky   = key-%tky
          Status = 'APPROVED'
        )
      ).
    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
  ENTITY zi_prime_hdr
  ALL FIELDS
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls IN lt_result
      (
        %tky = ls-%tky
        %param = ls
      )
    ).

  ENDMETHOD.

*  METHOD Reject.
*
*    MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
*      ENTITY zi_prime_hdr
*      UPDATE FIELDS ( Status )
*      WITH VALUE #(
*        FOR key IN keys
*        (
*          %tky   = key-%tky
*          Status = 'REJECTED'
*        )
*      ).
*    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
*  ENTITY zi_prime_hdr
*  ALL FIELDS
*  WITH CORRESPONDING #( keys )
*  RESULT DATA(lt_result).
*
*    result = VALUE #(
*      FOR ls IN lt_result
*      (
*        %tky = ls-%tky
*        %param = ls
*      )
*    ).
*
*  ENDMETHOD.
*
  METHOD Reject.

  LOOP AT keys INTO DATA(ls_reject_key).

    IF ls_reject_key-%param-Reason IS INITIAL.

      APPEND VALUE #(
        %tky = ls_reject_key-%tky
      ) TO failed-zi_prime_hdr.

      APPEND VALUE #(
        %tky = ls_reject_key-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text = 'Please enter rejection reason'
               )
      ) TO reported-zi_prime_hdr.

      RETURN.

    ENDIF.

  ENDLOOP.

  MODIFY ENTITIES OF zi_prime_hdr IN LOCAL MODE
    ENTITY zi_prime_hdr
    UPDATE FIELDS ( Status RejectReason )
    WITH VALUE #(
      FOR ls_key IN keys
      (
        %tky         = ls_key-%tky
        Status       = 'REJECTED'
        RejectReason = ls_key-%param-Reason
      )
    ).

ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_PRIME_ITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*    METHODS CalculatingAmount FOR DETERMINE ON MODIFY
*       keys FOR zi_prime_item~CalculatingAmount.

    METHODS validateItemData FOR VALIDATE ON SAVE
       keys FOR zi_prime_item~validateItemData.
*    METHODS CalculateTotalAmount FOR DETERMINE ON MODIFY
*      keys FOR ZI_PRIME_ITEM~CalculateTotalAmount.


ENDCLASS.

CLASS lhc_ZI_PRIME_ITEM IMPLEMENTATION.



  METHOD validateItemData.

    READ ENTITIES OF zi_prime_hdr IN LOCAL MODE
      ENTITY zi_prime_item
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-Material IS NOT INITIAL.

        " Both Quantity and Price invalid
        IF ls_item-Quantity <= 0
           AND ls_item-Price <= 0.

          APPEND VALUE #(
            %tky = ls_item-%tky
          ) TO failed-zi_prime_item.

          APPEND VALUE #(
            %tky = ls_item-%tky
            %msg = new_message(
                     id       = 'ZPRIME_MSG'
                     number   = '003'
                     severity = if_abap_behv_message=>severity-error
                     v1       = ls_item-ItemId
                   )
          ) TO reported-zi_prime_item.

          " Quantity only invalid
        ELSEIF ls_item-Quantity <= 0
           AND ls_item-Price > 0.

          APPEND VALUE #(
            %tky = ls_item-%tky
          ) TO failed-zi_prime_item.

          APPEND VALUE #(
            %tky = ls_item-%tky
            %msg = new_message(
                     id       = 'ZPRIME_MSG'
                     number   = '001'
                     severity = if_abap_behv_message=>severity-error
                     v1       = ls_item-ItemId
                   )
          ) TO reported-zi_prime_item.

          " Price only invalid
        ELSEIF ls_item-Price <= 0
           AND ls_item-Quantity > 0.

          APPEND VALUE #(
            %tky = ls_item-%tky
          ) TO failed-zi_prime_item.

          APPEND VALUE #(
            %tky = ls_item-%tky
            %msg = new_message(
                     id       = 'ZPRIME_MSG'
                     number   = '002'
                     severity = if_abap_behv_message=>severity-error
                     v1       = ls_item-ItemId
                   )
          ) TO reported-zi_prime_item.

        ENDIF.

      ELSE.

        APPEND VALUE #(
          %tky = ls_item-%tky
        ) TO failed-zi_prime_item.

        APPEND VALUE #(
          %tky = ls_item-%tky
          %msg = new_message(
                   id       = 'ZPRIME_MSG'
                   number   = '004'
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_item-ItemId
                 )
        ) TO reported-zi_prime_item.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


ENDCLASS.
