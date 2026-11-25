CLASS lhc_ZPrime_I_HDR_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR ZPrime_I_HDR_1 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR ZPrime_I_HDR_1 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR ZPrime_I_HDR_1 RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE ZPrime_I_HDR_1.

    METHODS earlynumbering_cba_Item FOR NUMBERING
       entities FOR CREATE ZPrime_I_HDR_1\_Item.

    METHODS Approve FOR MODIFY
       keys FOR ACTION ZPrime_I_HDR_1~Approve RESULT result.

    METHODS CopyRequest FOR MODIFY
       keys FOR ACTION ZPrime_I_HDR_1~CopyRequest RESULT result.

    METHODS Reject FOR MODIFY
       keys FOR ACTION ZPrime_I_HDR_1~Reject RESULT result.

    METHODS Submit FOR MODIFY
       keys FOR ACTION ZPrime_I_HDR_1~Submit RESULT result.

    METHODS CalculateStatus FOR DETERMINE ON MODIFY
       keys FOR ZPrime_I_HDR_1~CalculateStatus.

    METHODS validateItemData FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZPrime_I_ITME_1~validateItemData.

ENDCLASS.

CLASS lhc_ZPrime_I_HDR_1 IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
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


  METHOD get_instance_authorizations.

  READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
    ENTITY zprime_i_hdr_1
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

  METHOD earlynumbering_create.

    DATA(lt_entities) = entities.

    TRY.

        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'
            object      = 'ZPN_HDR'
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
          ) TO failed-zprime_i_hdr_1.

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
      ) TO mapped-zprime_i_hdr_1.

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
            ) TO failed-zprime_i_itme_1.

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
        ) TO mapped-zprime_i_itme_1.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD Approve.

    MODIFY ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
      UPDATE FIELDS ( Status )
      WITH VALUE #(
        FOR key IN keys
        (
          %tky   = key-%tky
          Status = 'APPROVED'
        )
      ).
    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
  ENTITY zprime_i_hdr_1
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

  METHOD CopyRequest.

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    MODIFY ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
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

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
      ALL FIELDS
      WITH VALUE #(
        FOR ls_map IN mapped_hdr-zprime_i_hdr_1
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

  METHOD Reject.

  LOOP AT keys INTO DATA(ls_reject_key).

    IF ls_reject_key-%param-Reason IS INITIAL.

      APPEND VALUE #(
        %tky = ls_reject_key-%tky
      ) TO failed-zprime_i_hdr_1.

      APPEND VALUE #(
        %tky = ls_reject_key-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text = 'Please enter rejection reason'
               )
      ) TO reported-zprime_i_hdr_1.

      RETURN.

    ENDIF.

  ENDLOOP.

  MODIFY ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
    ENTITY zprime_i_hdr_1
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

  METHOD submit.

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    LOOP AT lt_hdr INTO DATA(ls_hdr).

      READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
        ENTITY zprime_i_hdr_1 BY \_Item
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
        ) TO failed-zprime_i_hdr_1.

        APPEND VALUE #(
          %tky = ls_hdr-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Please add at least one item before submit'
                 )
        ) TO reported-zprime_i_hdr_1.

        CONTINUE.

      ENDIF.

      MODIFY ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
        ENTITY zprime_i_hdr_1
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          (
            %tky   = ls_hdr-%tky
            Status = 'SUBMITTED'
          )
        ).

    ENDLOOP.

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
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




  METHOD calculatestatus.

    DATA: lv_status TYPE string.

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
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

      MODIFY ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
        ENTITY zprime_i_hdr_1
        UPDATE FIELDS ( Category )
        WITH VALUE #(
          (
            %tky   = <ls_hdr>-%tky
            Category = lv_status
          )
        ).

    ENDLOOP.

  ENDMETHOD.

   METHOD validateItemData.

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_itme_1
      FIELDS ( ReqId ItemId Material Quantity Price )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      " Clear previous state messages for this item (required for Draft)
      APPEND VALUE #(
        %tky        = ls_item-%tky
        %state_area = 'VALIDATE_ITEM'
      ) TO reported-zprime_i_itme_1.

      IF ls_item-Material IS INITIAL.

        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-zprime_i_itme_1.
        APPEND VALUE #(
          %tky                 = ls_item-%tky
          %state_area          = 'VALIDATE_ITEM'
          %path-zprime_i_hdr_1 = VALUE #( %is_draft = ls_item-%is_draft
                                          ReqId     = ls_item-ReqId )
          %msg                 = new_message(
                                   id       = 'ZPRIME_MSG'
                                   number   = '004'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = ls_item-ItemId )
          %element-Material    = if_abap_behv=>mk-on
        ) TO reported-zprime_i_itme_1.

      ELSEIF ls_item-Quantity <= 0 AND ls_item-Price <= 0.

        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-zprime_i_itme_1.
        APPEND VALUE #(
          %tky                 = ls_item-%tky
          %state_area          = 'VALIDATE_ITEM'
          %path-zprime_i_hdr_1 = VALUE #( %is_draft = ls_item-%is_draft
                                          ReqId     = ls_item-ReqId )
          %msg                 = new_message(
                                   id       = 'ZPRIME_MSG'
                                   number   = '003'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = ls_item-ItemId )
          %element-Quantity    = if_abap_behv=>mk-on
          %element-Price       = if_abap_behv=>mk-on
        ) TO reported-zprime_i_itme_1.

      ELSEIF ls_item-Quantity <= 0.

        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-zprime_i_itme_1.
        APPEND VALUE #(
          %tky                 = ls_item-%tky
          %state_area          = 'VALIDATE_ITEM'
          %path-zprime_i_hdr_1 = VALUE #( %is_draft = ls_item-%is_draft
                                          ReqId     = ls_item-ReqId )
          %msg                 = new_message(
                                   id       = 'ZPRIME_MSG'
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = ls_item-ItemId )
          %element-Quantity    = if_abap_behv=>mk-on
        ) TO reported-zprime_i_itme_1.

      ELSEIF ls_item-Price <= 0.

        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-zprime_i_itme_1.
        APPEND VALUE #(
          %tky                 = ls_item-%tky
          %state_area          = 'VALIDATE_ITEM'
          %path-zprime_i_hdr_1 = VALUE #( %is_draft = ls_item-%is_draft
                                          ReqId     = ls_item-ReqId )
          %msg                 = new_message(
                                   id       = 'ZPRIME_MSG'
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = ls_item-ItemId )
          %element-Price       = if_abap_behv=>mk-on
        ) TO reported-zprime_i_itme_1.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



ENDCLASS.

CLASS lhc_ZPrime_I_ITME_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CalculateTotalAmount FOR DETERMINE ON MODIFY
       keys FOR ZPrime_I_ITME_1~CalculateTotalAmount.

    METHODS CalculatingAmount FOR DETERMINE ON MODIFY
       keys FOR ZPrime_I_ITME_1~CalculatingAmount.



ENDCLASS.

CLASS lhc_ZPrime_I_ITME_1 IMPLEMENTATION.

  METHOD calculatetotalamount.

    DATA lv_total TYPE zi_prime_hdr-TotalAmount.

* Get header

    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_hdr_1
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    LOOP AT lt_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr>).

      CLEAR lv_total.

* Read ALL child items of current header

      READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
        ENTITY zprime_i_hdr_1
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

      MODIFY ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
        ENTITY zprime_i_hdr_1
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

    METHOD CalculatingAmount.

    DATA: lt_items       TYPE TABLE FOR READ RESULT zprime_i_itme_1,
          lt_item_update TYPE TABLE FOR UPDATE zprime_i_itme_1.

    " Read changed items
    READ ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
      ENTITY zprime_i_itme_1
      FIELDS ( Quantity Price )
      WITH CORRESPONDING #( keys )
      RESULT lt_items.

    " Calculate Amount
    LOOP AT lt_items INTO DATA(ls_item).

      APPEND VALUE #(
        %tky   = ls_item-%tky
        Amount = ls_item-Quantity * ls_item-Price
      ) TO lt_item_update.

    ENDLOOP.

    IF lt_item_update IS NOT INITIAL.
      MODIFY ENTITIES OF zprime_i_hdr_1 IN LOCAL MODE
        ENTITY zprime_i_itme_1
        UPDATE FIELDS ( Amount )
        WITH lt_item_update.
    ENDIF.

  ENDMETHOD.




ENDCLASS.
