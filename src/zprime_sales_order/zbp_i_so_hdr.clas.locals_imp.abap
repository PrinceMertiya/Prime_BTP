CLASS lhc_SalesOrderHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR SalesOrderHeader RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR SalesOrderHeader RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR SalesOrderHeader RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE SalesOrderHeader.

    METHODS earlynumbering_cba_Item FOR NUMBERING
       entities FOR CREATE SalesOrderHeader\_Item.

    METHODS DeepCopyOrder FOR MODIFY
       keys FOR ACTION SalesOrderHeader~DeepCopyOrder RESULT result.

    METHODS RejectOrder FOR MODIFY
       keys FOR ACTION SalesOrderHeader~RejectOrder RESULT result.

    METHODS ReleaseOrder FOR MODIFY
       keys FOR ACTION SalesOrderHeader~ReleaseOrder RESULT result.

    METHODS SubmitOrder FOR MODIFY
       keys FOR ACTION SalesOrderHeader~SubmitOrder RESULT result.

    METHODS determinePriority FOR DETERMINE ON MODIFY
       keys FOR SalesOrderHeader~determinePriority.

    METHODS setDefaultsOnCreate FOR DETERMINE ON MODIFY
       keys FOR SalesOrderHeader~setDefaultsOnCreate.

    METHODS validateOrderBeforeSave FOR VALIDATE ON SAVE
       keys FOR SalesOrderHeader~validateOrderBeforeSave.

ENDCLASS.

CLASS lhc_SalesOrderHeader IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    result = VALUE #( FOR ls_order IN lt_orders (
      %tky = ls_order-%tky
      %action-SubmitOrder  = COND #( WHEN ls_order-Status = 'OPEN'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-ReleaseOrder = COND #( WHEN ls_order-Status = 'SUBMITTED'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-RejectOrder  = COND #( WHEN ls_order-Status <> 'REJECTED'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
    ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

    METHOD earlynumbering_create.
    DATA(lt_entities) = entities.
    DELETE lt_entities WHERE OrderId IS NOT INITIAL.

    LOOP AT entities INTO DATA(ls_existing) WHERE OrderId IS NOT INITIAL.
      APPEND VALUE #( %cid      = ls_existing-%cid
                      %is_draft = ls_existing-%is_draft
                      OrderId   = ls_existing-OrderId ) TO mapped-salesorderheader.
    ENDLOOP.

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZPN_HDR_1'
            quantity          = CONV #( lines( lt_entities ) )
          IMPORTING
            number            = DATA(lv_last_number)
            returned_quantity = DATA(lv_qty) ).

      CATCH cx_number_ranges INTO DATA(lo_error).
        LOOP AT lt_entities INTO DATA(ls_err).
          APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft ) TO failed-salesorderheader.
          APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = lo_error->get_text( ) ) ) TO reported-salesorderheader.
        ENDLOOP.
        RETURN.
    ENDTRY.

    DATA(lv_num) = lv_last_number - lv_qty.
    LOOP AT lt_entities INTO DATA(ls_entity).
      lv_num += 1.
      APPEND VALUE #( %cid      = ls_entity-%cid
                      %is_draft = ls_entity-%is_draft
                      OrderId   = |ORD{ lv_num }| ) TO mapped-salesorderheader.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Item.
    LOOP AT entities INTO DATA(ls_entity).
      DATA(lv_count) = lines( ls_entity-%target ).
      IF lv_count = 0.
        CONTINUE.
      ENDIF.

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'ZPN_ITEM_1'
              quantity          = CONV #( lv_count )
            IMPORTING
              number            = DATA(lv_last_number)
              returned_quantity = DATA(lv_qty) ).

        CATCH cx_number_ranges INTO DATA(lo_error).
          LOOP AT ls_entity-%target INTO DATA(ls_err).
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft ) TO failed-salesorderitem.
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = lo_error->get_text( ) ) ) TO reported-salesorderitem.
          ENDLOOP.
          RETURN.
      ENDTRY.

      DATA(lv_num) = lv_last_number - lv_qty.
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        lv_num += 1.
        APPEND VALUE #( %cid      = ls_target-%cid
                        %is_draft = ls_target-%is_draft
                        OrderId   = ls_entity-OrderId
                        ItemId    = |ITM{ lv_num }| ) TO mapped-salesorderitem.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


    METHOD DeepCopyOrder.
    DATA lt_hdr_create     TYPE TABLE FOR CREATE zi_so_hdr\\SalesOrderHeader.
    DATA lt_partner_create TYPE TABLE FOR CREATE zi_so_hdr\\SalesOrderHeader\_Partner.
    DATA lt_item_create    TYPE TABLE FOR CREATE zi_so_hdr\\SalesOrderHeader\_Item.
    DATA lt_cond_create    TYPE TABLE FOR CREATE zi_so_hdr\\SalesOrderItem\_Cond.
    DATA lt_sched_create   TYPE TABLE FOR CREATE zi_so_hdr\\SalesOrderItem\_Sched.
    DATA lt_hu_create      TYPE TABLE FOR CREATE zi_so_hdr\\DeliverySchedule\_Hu.

    " 1. Read Source Header, Partners, and Line Items
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers)
      ENTITY SalesOrderHeader BY \_Partner ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partners)
      ENTITY SalesOrderHeader BY \_Item ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    " 2. Read Conditions, Schedules, and Handling Units for those Line Items
    IF lt_items IS NOT INITIAL.
      READ ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY SalesOrderItem BY \_Cond ALL FIELDS WITH CORRESPONDING #( lt_items )
        RESULT DATA(lt_conds)
        ENTITY SalesOrderItem BY \_Sched ALL FIELDS WITH CORRESPONDING #( lt_items )
        RESULT DATA(lt_scheds).

      IF lt_scheds IS NOT INITIAL.
        READ ENTITIES OF zi_so_hdr IN LOCAL MODE
          ENTITY DeliverySchedule BY \_Hu ALL FIELDS WITH CORRESPONDING #( lt_scheds )
          RESULT DATA(lt_hus).
      ENDIF.
    ENDIF.

    " 3. Assemble 4-Level Deep Create Payload using %cid References
    LOOP AT keys INTO DATA(ls_key).
      READ TABLE lt_headers INTO DATA(ls_hdr) WITH KEY %tky = ls_key-%tky.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_hdr_cid) = |HDR_{ sy-tabix }|.

      APPEND VALUE #(
        %cid        = lv_hdr_cid
        %is_draft   = ls_key-%is_draft
        CustomerId  = ls_hdr-CustomerId
        SalesOrg    = ls_hdr-SalesOrg
        Status      = 'OPEN'
        Priority    = ls_hdr-Priority
        CukyField   = ls_hdr-CukyField
        NetValue    = ls_hdr-NetValue
        WeightUnit  = ls_hdr-WeightUnit
        TotalWeight = ls_hdr-TotalWeight
        %control    = VALUE #(
          CustomerId  = if_abap_behv=>mk-on
          SalesOrg    = if_abap_behv=>mk-on
          Status      = if_abap_behv=>mk-on
          Priority    = if_abap_behv=>mk-on
          CukyField   = if_abap_behv=>mk-on
          NetValue    = if_abap_behv=>mk-on
          WeightUnit  = if_abap_behv=>mk-on
          TotalWeight = if_abap_behv=>mk-on )
      ) TO lt_hdr_create.

      " Level 2A: Business Partners
      DATA ls_p_line   LIKE LINE OF lt_partner_create.
      DATA lt_p_target LIKE ls_p_line-%target.
      CLEAR lt_p_target.
      LOOP AT lt_partners INTO DATA(ls_p) WHERE OrderId = ls_hdr-OrderId.
        APPEND VALUE #(
          %cid        = |PRT_{ lv_hdr_cid }_{ sy-tabix }|
          %is_draft   = ls_key-%is_draft
          PartnerRole = ls_p-PartnerRole
          PartnerId   = ls_p-PartnerId
          PartnerName = ls_p-PartnerName
          City        = ls_p-City
          %control    = VALUE #(
            PartnerRole = if_abap_behv=>mk-on
            PartnerId   = if_abap_behv=>mk-on
            PartnerName = if_abap_behv=>mk-on
            City        = if_abap_behv=>mk-on )
        ) TO lt_p_target.
      ENDLOOP.
      IF lt_p_target IS NOT INITIAL.
        APPEND VALUE #( %cid_ref  = lv_hdr_cid
                        %is_draft = ls_key-%is_draft
                        %target   = lt_p_target ) TO lt_partner_create.
      ENDIF.

      " Level 2B: Line Items
      DATA ls_i_line   LIKE LINE OF lt_item_create.
      DATA lt_i_target LIKE ls_i_line-%target.
      CLEAR lt_i_target.
      LOOP AT lt_items INTO DATA(ls_item) WHERE OrderId = ls_hdr-OrderId.
        DATA(lv_itm_cid) = |ITM_{ lv_hdr_cid }_{ sy-tabix }|.

        APPEND VALUE #(
          %cid       = lv_itm_cid
          %is_draft  = ls_key-%is_draft
          Material   = ls_item-Material
          Uom        = ls_item-Uom
          Quantity   = ls_item-Quantity
          CukyField  = ls_item-CukyField
          UnitPrice  = ls_item-UnitPrice
          ItemAmount = ls_item-ItemAmount
          WeightUnit = ls_item-WeightUnit
          ItemWeight = ls_item-ItemWeight
          %control   = VALUE #(
            Material   = if_abap_behv=>mk-on
            Uom        = if_abap_behv=>mk-on
            Quantity   = if_abap_behv=>mk-on
            CukyField  = if_abap_behv=>mk-on
            UnitPrice  = if_abap_behv=>mk-on
            ItemAmount = if_abap_behv=>mk-on
            WeightUnit = if_abap_behv=>mk-on
            ItemWeight = if_abap_behv=>mk-on )
        ) TO lt_i_target.

        " Level 3A: Pricing Conditions
        DATA ls_c_line   LIKE LINE OF lt_cond_create.
      DATA lt_c_target LIKE ls_c_line-%target.
        CLEAR lt_c_target.
        LOOP AT lt_conds INTO DATA(ls_c) WHERE OrderId = ls_item-OrderId AND ItemId = ls_item-ItemId.
          APPEND VALUE #(
            %cid        = |CND_{ lv_itm_cid }_{ sy-tabix }|
            %is_draft   = ls_key-%is_draft
            CondType    = ls_c-CondType
            CalcType    = ls_c-CalcType
            RatePercent = ls_c-RatePercent
            CukyField   = ls_c-CukyField
            CondValue   = ls_c-CondValue
            %control    = VALUE #(
              CondType    = if_abap_behv=>mk-on
              CalcType    = if_abap_behv=>mk-on
              RatePercent = if_abap_behv=>mk-on
              CukyField   = if_abap_behv=>mk-on
              CondValue   = if_abap_behv=>mk-on )
          ) TO lt_c_target.
        ENDLOOP.
        IF lt_c_target IS NOT INITIAL.
          APPEND VALUE #( %cid_ref  = lv_itm_cid
                          %is_draft = ls_key-%is_draft
                          %target   = lt_c_target ) TO lt_cond_create.
        ENDIF.

        " Level 3B: Delivery Schedules
       DATA ls_s_line   LIKE LINE OF lt_sched_create.
      DATA lt_s_target LIKE ls_s_line-%target.
        CLEAR lt_s_target.
        LOOP AT lt_scheds INTO DATA(ls_sched) WHERE OrderId = ls_item-OrderId AND ItemId = ls_item-ItemId.
          DATA(lv_sch_cid) = |SCH_{ lv_itm_cid }_{ sy-tabix }|.

          APPEND VALUE #(
            %cid         = lv_sch_cid
            %is_draft    = ls_key-%is_draft
            DeliveryDate = ls_sched-DeliveryDate
            Plant        = ls_sched-Plant
            Uom          = ls_sched-Uom
            ConfirmedQty = ls_sched-ConfirmedQty
            WeightUnit   = ls_sched-WeightUnit
            SchedWeight  = ls_sched-SchedWeight
            %control     = VALUE #(
              DeliveryDate = if_abap_behv=>mk-on
              Plant        = if_abap_behv=>mk-on
              Uom          = if_abap_behv=>mk-on
              ConfirmedQty = if_abap_behv=>mk-on
              WeightUnit   = if_abap_behv=>mk-on
              SchedWeight  = if_abap_behv=>mk-on
)
          ) TO lt_s_target.

          " Level 4: Handling Units
           DATA ls_h_line   LIKE LINE OF lt_hu_create.
           DATA lt_h_target LIKE ls_h_line-%target.
          CLEAR lt_h_target.
          LOOP AT lt_hus INTO DATA(ls_h) WHERE OrderId = ls_sched-OrderId
                                           AND ItemId  = ls_sched-ItemId
                                           AND SchedId = ls_sched-SchedId.
            APPEND VALUE #(
              %cid          = |HU_{ lv_sch_cid }_{ sy-tabix }|
              %is_draft     = ls_key-%is_draft
              SerialNo      = ls_h-SerialNo
              PackagingType = ls_h-PackagingType
              WeightUnit    = ls_h-WeightUnit
              GrossWeight   = ls_h-GrossWeight
              %control      = VALUE #(
                SerialNo      = if_abap_behv=>mk-on
                PackagingType = if_abap_behv=>mk-on
                WeightUnit    = if_abap_behv=>mk-on
                GrossWeight   = if_abap_behv=>mk-on )
            ) TO lt_h_target.
          ENDLOOP.
          IF lt_h_target IS NOT INITIAL.
            APPEND VALUE #( %cid_ref  = lv_sch_cid
                            %is_draft = ls_key-%is_draft
                            %target   = lt_h_target ) TO lt_hu_create.
          ENDIF.
        ENDLOOP.

        IF lt_s_target IS NOT INITIAL.
          APPEND VALUE #( %cid_ref  = lv_itm_cid
                          %is_draft = ls_key-%is_draft
                          %target   = lt_s_target ) TO lt_sched_create.
        ENDIF.
      ENDLOOP.

      IF lt_i_target IS NOT INITIAL.
        APPEND VALUE #( %cid_ref  = lv_hdr_cid
                        %is_draft = ls_key-%is_draft
                        %target   = lt_i_target ) TO lt_item_create.
      ENDIF.
    ENDLOOP.

    " 4. Execute Deep Create (Early Numbering assigns all new IDs automatically)
    MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader CREATE FROM lt_hdr_create
      ENTITY SalesOrderHeader CREATE BY \_Partner FROM lt_partner_create
      ENTITY SalesOrderHeader CREATE BY \_Item    FROM lt_item_create
      ENTITY SalesOrderItem   CREATE BY \_Cond    FROM lt_cond_create
      ENTITY SalesOrderItem   CREATE BY \_Sched   FROM lt_sched_create
      ENTITY DeliverySchedule CREATE BY \_Hu      FROM lt_hu_create
      MAPPED DATA(lt_mapped).

    " 5. Return Newly Copied Header Instance to UI
    IF lt_mapped-salesorderheader IS NOT INITIAL.
      READ ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY SalesOrderHeader ALL FIELDS WITH CORRESPONDING #( lt_mapped-salesorderheader )
        RESULT DATA(lt_new_orders).

      LOOP AT keys INTO DATA(ls_in_key).
        READ TABLE lt_new_orders INTO DATA(ls_new_o) INDEX sy-tabix.
        IF sy-subrc = 0.
          APPEND VALUE #( %tky   = ls_in_key-%tky
                          %param = ls_new_o ) TO result.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.




  METHOD RejectOrder.
    MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader UPDATE FIELDS ( Status RejectReason )
      WITH VALUE #( FOR key IN keys (
        %tky         = key-%tky
        Status       = 'REJECTED'
        RejectReason = key-%param-reason
      ) ).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    result = VALUE #( FOR ls_o IN lt_orders ( %tky = ls_o-%tky %param = ls_o ) ).
  ENDMETHOD.

  METHOD SubmitOrder.
    MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'SUBMITTED' ) ).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    result = VALUE #( FOR ls_o IN lt_orders ( %tky = ls_o-%tky %param = ls_o ) ).
  ENDMETHOD.

  METHOD ReleaseOrder.
    MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'RELEASED' ) ).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    result = VALUE #( FOR ls_o IN lt_orders ( %tky = ls_o-%tky %param = ls_o ) ).
  ENDMETHOD.

    METHOD setDefaultsOnCreate.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader FIELDS ( Status Priority WeightUnit ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DELETE lt_orders WHERE Status IS NOT INITIAL.
    IF lt_orders IS INITIAL. RETURN. ENDIF.

    MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader UPDATE FIELDS ( Status Priority WeightUnit )
      WITH VALUE #( FOR ls_o IN lt_orders (
        %tky       = ls_o-%tky
        Status     = 'OPEN'
        Priority   = 'LOW'
        WeightUnit = 'KG'
      ) ).
  ENDMETHOD.

  METHOD determinePriority.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader FIELDS ( NetValue ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader UPDATE FIELDS ( Priority )
      WITH VALUE #( FOR ls_o IN lt_orders (
        %tky     = ls_o-%tky
        Priority = COND #( WHEN ls_o-NetValue >= 10000 THEN 'HIGH'
                           WHEN ls_o-NetValue >= 2500  THEN 'MEDIUM'
                           ELSE 'LOW' )
      ) ).
  ENDMETHOD.


    METHOD validateOrderBeforeSave.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader FIELDS ( CustomerId SalesOrg CukyField ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader BY \_Item FIELDS ( ItemId ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_orders INTO DATA(ls_order).
      " Clear old state messages for draft UI
      APPEND VALUE #( %tky        = ls_order-%tky
                      %state_area = 'VALIDATE_HDR' ) TO reported-salesorderheader.

      IF ls_order-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = ls_order-%tky ) TO failed-salesorderheader.
        APPEND VALUE #( %tky                = ls_order-%tky
                        %state_area         = 'VALIDATE_HDR'
                        %element-CustomerId = if_abap_behv=>mk-on
                        %msg                = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = 'Customer ID is required.' ) ) TO reported-salesorderheader.
      ENDIF.

      IF ls_order-SalesOrg IS INITIAL.
        APPEND VALUE #( %tky = ls_order-%tky ) TO failed-salesorderheader.
        APPEND VALUE #( %tky              = ls_order-%tky
                        %state_area       = 'VALIDATE_HDR'
                        %element-SalesOrg = if_abap_behv=>mk-on
                        %msg              = new_message_with_text(
                                              severity = if_abap_behv_message=>severity-error
                                              text     = 'Sales Organization is required.' ) ) TO reported-salesorderheader.
      ENDIF.

      IF ls_order-CukyField IS INITIAL.
        APPEND VALUE #( %tky = ls_order-%tky ) TO failed-salesorderheader.
        APPEND VALUE #( %tky               = ls_order-%tky
                        %state_area        = 'VALIDATE_HDR'
                        %element-CukyField = if_abap_behv=>mk-on
                        %msg               = new_message_with_text(
                                               severity = if_abap_behv_message=>severity-error
                                               text     = 'Currency Code is required.' ) ) TO reported-salesorderheader.
      ENDIF.

      IF NOT line_exists( lt_items[ OrderId = ls_order-OrderId ] ).
        APPEND VALUE #( %tky = ls_order-%tky ) TO failed-salesorderheader.
        APPEND VALUE #( %tky        = ls_order-%tky
                        %state_area = 'VALIDATE_HDR'
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = 'Sales Order must contain at least one Line Item.' ) ) TO reported-salesorderheader.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_SalesOrderItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_Cond FOR NUMBERING
       entities FOR CREATE SalesOrderItem\_Cond.

    METHODS earlynumbering_cba_Sched FOR NUMBERING
       entities FOR CREATE SalesOrderItem\_Sched.

    METHODS calcItemAmount FOR DETERMINE ON MODIFY
       keys FOR SalesOrderItem~calcItemAmount.

    METHODS updateHeaderTotals FOR DETERMINE ON MODIFY
       keys FOR SalesOrderItem~updateHeaderTotals.

    METHODS validateItemData FOR VALIDATE ON SAVE
       keys FOR SalesOrderItem~validateItemData.

ENDCLASS.

CLASS lhc_SalesOrderItem IMPLEMENTATION.

    METHOD earlynumbering_cba_Cond.
    LOOP AT entities INTO DATA(ls_entity).
      DATA(lv_count) = lines( ls_entity-%target ).
      IF lv_count = 0.
        CONTINUE.
      ENDIF.

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'ZPN_COND'
              quantity          = CONV #( lv_count )
            IMPORTING
              number            = DATA(lv_last_number)
              returned_quantity = DATA(lv_qty) ).

        CATCH cx_number_ranges INTO DATA(lo_error).
          LOOP AT ls_entity-%target INTO DATA(ls_err).
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft ) TO failed-pricingcondition.
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = lo_error->get_text( ) ) ) TO reported-pricingcondition.
          ENDLOOP.
          RETURN.
      ENDTRY.

      DATA(lv_num) = lv_last_number - lv_qty.
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        lv_num += 1.
        APPEND VALUE #( %cid      = ls_target-%cid
                        %is_draft = ls_target-%is_draft
                        OrderId   = ls_entity-OrderId
                        ItemId    = ls_entity-ItemId
                        CondId    = |CND{ lv_num }| ) TO mapped-pricingcondition.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Sched.
    LOOP AT entities INTO DATA(ls_entity).
      DATA(lv_count) = lines( ls_entity-%target ).
      IF lv_count = 0.
        CONTINUE.
      ENDIF.

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'ZPN_SCHED'
              quantity          = CONV #( lv_count )
            IMPORTING
              number            = DATA(lv_last_number)
              returned_quantity = DATA(lv_qty) ).

        CATCH cx_number_ranges INTO DATA(lo_error).
          LOOP AT ls_entity-%target INTO DATA(ls_err).
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft ) TO failed-deliveryschedule.
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = lo_error->get_text( ) ) ) TO reported-deliveryschedule.
          ENDLOOP.
          RETURN.
      ENDTRY.

      DATA(lv_num) = lv_last_number - lv_qty.
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        lv_num += 1.
        APPEND VALUE #( %cid      = ls_target-%cid
                        %is_draft = ls_target-%is_draft
                        OrderId   = ls_entity-OrderId
                        ItemId    = ls_entity-ItemId
                        SchedId   = |SCH{ lv_num }| ) TO mapped-deliveryschedule.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


    METHOD calcItemAmount.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderItem FIELDS ( Quantity UnitPrice CukyField WeightUnit ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderItem BY \_Header FIELDS ( CukyField WeightUnit ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderItem BY \_Cond FIELDS ( CondValue ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_conds).

    DATA lt_update TYPE TABLE FOR UPDATE zi_so_hdr\\SalesOrderItem.

    LOOP AT lt_items INTO DATA(ls_item).
      DATA(lv_base_amt) = ls_item-Quantity * ls_item-UnitPrice.
      DATA(lv_cond_sum) = REDUCE decfloat34( INIT sum = CONV decfloat34( 0 )
                                             FOR ls_c IN lt_conds
                                             WHERE ( OrderId = ls_item-OrderId AND ItemId = ls_item-ItemId )
                                             NEXT sum = sum + ls_c-CondValue ).

      READ TABLE lt_headers INTO DATA(ls_hdr) WITH KEY OrderId = ls_item-OrderId.

      APPEND VALUE #(
        %tky       = ls_item-%tky
        ItemAmount = lv_base_amt + lv_cond_sum
        CukyField  = COND #( WHEN ls_item-CukyField IS INITIAL THEN ls_hdr-CukyField ELSE ls_item-CukyField )
        WeightUnit = COND #( WHEN ls_item-WeightUnit IS INITIAL THEN ls_hdr-WeightUnit ELSE ls_item-WeightUnit )
      ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY SalesOrderItem UPDATE FIELDS ( ItemAmount CukyField WeightUnit ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

      METHOD updateHeaderTotals.
    " Collect unique parent Header keys typed for the \_Item association
    DATA lt_read_hdr TYPE TABLE FOR READ IMPORT zi_so_hdr\_Item.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %is_draft = ls_key-%is_draft OrderId = ls_key-OrderId ) TO lt_read_hdr.
    ENDLOOP.
    SORT lt_read_hdr BY %is_draft OrderId.
    DELETE ADJACENT DUPLICATES FROM lt_read_hdr COMPARING %is_draft OrderId.

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderHeader BY \_Item FIELDS ( ItemAmount ItemWeight ) WITH lt_read_hdr
      RESULT DATA(lt_all_items).

    DATA lt_hdr_update TYPE TABLE FOR UPDATE zi_so_hdr\\SalesOrderHeader.

    LOOP AT lt_read_hdr INTO DATA(ls_hdr_key).
      DATA(lv_net_val) = REDUCE decfloat34( INIT amt = CONV decfloat34( 0 )
                                            FOR ls_i IN lt_all_items
                                            WHERE ( OrderId = ls_hdr_key-OrderId )
                                            NEXT amt = amt + ls_i-ItemAmount ).

      DATA(lv_tot_wgt) = REDUCE decfloat34( INIT wgt = CONV decfloat34( 0 )
                                            FOR ls_i IN lt_all_items
                                            WHERE ( OrderId = ls_hdr_key-OrderId )
                                            NEXT wgt = wgt + ls_i-ItemWeight ).

      APPEND VALUE #( %tky        = ls_hdr_key-%tky
                      NetValue    = lv_net_val
                      TotalWeight = lv_tot_wgt ) TO lt_hdr_update.
    ENDLOOP.

    IF lt_hdr_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY SalesOrderHeader UPDATE FIELDS ( NetValue TotalWeight ) WITH lt_hdr_update.
    ENDIF.
  ENDMETHOD.



    METHOD validateItemData.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderItem FIELDS ( OrderId ItemId Material Quantity Uom UnitPrice ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).
      APPEND VALUE #( %tky        = ls_item-%tky
                      %state_area = 'VALIDATE_ITEM' ) TO reported-salesorderitem.

      IF ls_item-Material IS INITIAL.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-salesorderitem.
        APPEND VALUE #( %tky              = ls_item-%tky
                        %state_area       = 'VALIDATE_ITEM'
                        %path             = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_item-%is_draft OrderId = ls_item-OrderId ) )
                        %element-Material = if_abap_behv=>mk-on
                        %msg              = new_message_with_text(
                                              severity = if_abap_behv_message=>severity-error
                                              text     = 'Material is required on line item.' ) ) TO reported-salesorderitem.
      ENDIF.

      IF ls_item-Quantity <= 0 OR ls_item-Uom IS INITIAL.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-salesorderitem.
        APPEND VALUE #( %tky              = ls_item-%tky
                        %state_area       = 'VALIDATE_ITEM'
                        %path             = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_item-%is_draft OrderId = ls_item-OrderId ) )
                        %element-Quantity = if_abap_behv=>mk-on
                        %msg              = new_message_with_text(
                                              severity = if_abap_behv_message=>severity-error
                                              text     = 'Quantity must be greater than zero with a valid UoM.' ) ) TO reported-salesorderitem.
      ENDIF.

      IF ls_item-UnitPrice <= 0.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-salesorderitem.
        APPEND VALUE #( %tky               = ls_item-%tky
                        %state_area        = 'VALIDATE_ITEM'
                        %path              = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_item-%is_draft OrderId = ls_item-OrderId ) )
                        %element-UnitPrice = if_abap_behv=>mk-on
                        %msg               = new_message_with_text(
                                               severity = if_abap_behv_message=>severity-error
                                               text     = 'Unit Price must be greater than zero.' ) ) TO reported-salesorderitem.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_PricingCondition DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calcConditionValue FOR DETERMINE ON MODIFY
       keys FOR PricingCondition~calcConditionValue.

    METHODS updateItemPricing FOR DETERMINE ON MODIFY
       keys FOR PricingCondition~updateItemPricing.

    METHODS validateConditionRate FOR VALIDATE ON SAVE
       keys FOR PricingCondition~validateConditionRate.

ENDCLASS.

CLASS lhc_PricingCondition IMPLEMENTATION.

    METHOD calcConditionValue.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY PricingCondition FIELDS ( CalcType RatePercent CondValue ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_conds).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY PricingCondition BY \_Item FIELDS ( Quantity UnitPrice CukyField ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE zi_so_hdr\\PricingCondition.

    LOOP AT lt_conds INTO DATA(ls_cond).
      READ TABLE lt_items INTO DATA(ls_item) WITH KEY OrderId = ls_cond-OrderId ItemId = ls_cond-ItemId.
      DATA(lv_base) = ls_item-Quantity * ls_item-UnitPrice.

      " CalcType 'P' = Percentage (e.g. -10.00 = 10% discount), 'F' = Fixed Rate
      DATA(lv_val) = COND decfloat34(
        WHEN ls_cond-CalcType = 'P' THEN ( lv_base * ls_cond-RatePercent ) / 100
        ELSE ls_cond-RatePercent ).

      APPEND VALUE #( %tky      = ls_cond-%tky
                      CondValue = lv_val
                      CukyField = ls_item-CukyField ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY PricingCondition UPDATE FIELDS ( CondValue CukyField ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

    METHOD updateItemPricing.
    DATA lt_item_keys TYPE TABLE FOR READ IMPORT zi_so_item1\_Cond.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %is_draft = ls_key-%is_draft OrderId = ls_key-OrderId ItemId = ls_key-ItemId ) TO lt_item_keys.
    ENDLOOP.
    SORT lt_item_keys BY %is_draft OrderId ItemId.
    DELETE ADJACENT DUPLICATES FROM lt_item_keys COMPARING %is_draft OrderId ItemId.

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderItem FIELDS ( Quantity UnitPrice ) WITH CORRESPONDING #( lt_item_keys )
      RESULT DATA(lt_items).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderItem BY \_Cond FIELDS ( CondValue ) WITH lt_item_keys
      RESULT DATA(lt_conds).

    DATA lt_item_upd TYPE TABLE FOR UPDATE zi_so_hdr\\SalesOrderItem.
    LOOP AT lt_items INTO DATA(ls_item).
      DATA(lv_cond_sum) = REDUCE decfloat34( INIT sum = CONV decfloat34( 0 )
                                             FOR ls_c IN lt_conds
                                             WHERE ( OrderId = ls_item-OrderId AND ItemId = ls_item-ItemId )
                                             NEXT sum = sum + ls_c-CondValue ).
      APPEND VALUE #( %tky       = ls_item-%tky
                      ItemAmount = ( ls_item-Quantity * ls_item-UnitPrice ) + lv_cond_sum ) TO lt_item_upd.
    ENDLOOP.

    IF lt_item_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY SalesOrderItem UPDATE FIELDS ( ItemAmount ) WITH lt_item_upd.
    ENDIF.
  ENDMETHOD.



    METHOD validateConditionRate.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY PricingCondition FIELDS ( OrderId ItemId CondType CalcType RatePercent ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_conds).

    LOOP AT lt_conds INTO DATA(ls_cond).
      APPEND VALUE #( %tky        = ls_cond-%tky
                      %state_area = 'VALIDATE_COND' ) TO reported-pricingcondition.

      IF ls_cond-CondType IS INITIAL.
        APPEND VALUE #( %tky = ls_cond-%tky ) TO failed-pricingcondition.
        APPEND VALUE #( %tky              = ls_cond-%tky
                        %state_area       = 'VALIDATE_COND'
                        %path             = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_cond-%is_draft OrderId = ls_cond-OrderId )
                                                     salesorderitem-%tky   = VALUE #( %is_draft = ls_cond-%is_draft OrderId = ls_cond-OrderId ItemId = ls_cond-ItemId ) )
                        %element-CondType = if_abap_behv=>mk-on
                        %msg              = new_message_with_text(
                                              severity = if_abap_behv_message=>severity-error
                                              text     = 'Condition Type is mandatory.' ) ) TO reported-pricingcondition.
      ENDIF.

      IF ls_cond-CalcType <> 'P' AND ls_cond-CalcType <> 'F'.
        APPEND VALUE #( %tky = ls_cond-%tky ) TO failed-pricingcondition.
        APPEND VALUE #( %tky              = ls_cond-%tky
                        %state_area       = 'VALIDATE_COND'
                        %path             = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_cond-%is_draft OrderId = ls_cond-OrderId )
                                                     salesorderitem-%tky   = VALUE #( %is_draft = ls_cond-%is_draft OrderId = ls_cond-OrderId ItemId = ls_cond-ItemId ) )
                        %element-CalcType = if_abap_behv=>mk-on
                        %msg              = new_message_with_text(
                                              severity = if_abap_behv_message=>severity-error
                                              text     = 'Calculation Type must be P (Percentage) or F (Fixed).' ) ) TO reported-pricingcondition.
      ENDIF.

      IF ls_cond-CalcType = 'P' AND ls_cond-RatePercent < -100.
        APPEND VALUE #( %tky = ls_cond-%tky ) TO failed-pricingcondition.
        APPEND VALUE #( %tky                 = ls_cond-%tky
                        %state_area          = 'VALIDATE_COND'
                        %path                = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_cond-%is_draft OrderId = ls_cond-OrderId )
                                                        salesorderitem-%tky   = VALUE #( %is_draft = ls_cond-%is_draft OrderId = ls_cond-OrderId ItemId = ls_cond-ItemId ) )
                        %element-RatePercent = if_abap_behv=>mk-on
                        %msg                 = new_message_with_text(
                                                 severity = if_abap_behv_message=>severity-error
                                                 text     = 'Percentage discount cannot exceed -100%.' ) ) TO reported-pricingcondition.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_DeliverySchedule DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_Hu FOR NUMBERING
       entities FOR CREATE DeliverySchedule\_Hu.

    METHODS updateItemWeight FOR DETERMINE ON MODIFY
       keys FOR DeliverySchedule~updateItemWeight.

    METHODS validateScheduleQty FOR VALIDATE ON SAVE
       keys FOR DeliverySchedule~validateScheduleQty.

ENDCLASS.

CLASS lhc_DeliverySchedule IMPLEMENTATION.

    METHOD earlynumbering_cba_Hu.
    LOOP AT entities INTO DATA(ls_entity).
      DATA(lv_count) = lines( ls_entity-%target ).
      IF lv_count = 0.
        CONTINUE.
      ENDIF.

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'ZPN_HU'
              quantity          = CONV #( lv_count )
            IMPORTING
              number            = DATA(lv_last_number)
              returned_quantity = DATA(lv_qty) ).

        CATCH cx_number_ranges INTO DATA(lo_error).
          LOOP AT ls_entity-%target INTO DATA(ls_err).
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft ) TO failed-handlingunit.
            APPEND VALUE #( %cid = ls_err-%cid %is_draft = ls_err-%is_draft
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = lo_error->get_text( ) ) ) TO reported-handlingunit.
          ENDLOOP.
          RETURN.
      ENDTRY.

      DATA(lv_num) = lv_last_number - lv_qty.
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        lv_num += 1.
        APPEND VALUE #( %cid      = ls_target-%cid
                        %is_draft = ls_target-%is_draft
                        OrderId   = ls_entity-OrderId
                        ItemId    = ls_entity-ItemId
                        SchedId   = ls_entity-SchedId
                        HuId      = |HNU{ lv_num }| ) TO mapped-handlingunit.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


   METHOD updateItemWeight.
    DATA lt_item_keys TYPE TABLE FOR READ IMPORT zi_so_item1\_Sched.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %is_draft = ls_key-%is_draft OrderId = ls_key-OrderId ItemId = ls_key-ItemId ) TO lt_item_keys.
    ENDLOOP.
    SORT lt_item_keys BY %is_draft OrderId ItemId.
    DELETE ADJACENT DUPLICATES FROM lt_item_keys COMPARING %is_draft OrderId ItemId.

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderItem BY \_Sched FIELDS ( SchedWeight ) WITH lt_item_keys
      RESULT DATA(lt_scheds).

    DATA lt_item_upd TYPE TABLE FOR UPDATE zi_so_hdr\\SalesOrderItem.
    LOOP AT lt_item_keys INTO DATA(ls_ik).
      DATA(lv_wgt) = REDUCE decfloat34( INIT sum = CONV decfloat34( 0 )
                                        FOR ls_s IN lt_scheds
                                        WHERE ( OrderId = ls_ik-OrderId AND ItemId = ls_ik-ItemId )
                                        NEXT sum = sum + ls_s-SchedWeight ).
      APPEND VALUE #( %tky       = ls_ik-%tky
                      ItemWeight = lv_wgt ) TO lt_item_upd.
    ENDLOOP.

    IF lt_item_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY SalesOrderItem UPDATE FIELDS ( ItemWeight ) WITH lt_item_upd.
    ENDIF.
  ENDMETHOD.



    METHOD validateScheduleQty.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY DeliverySchedule FIELDS ( OrderId ItemId DeliveryDate Plant ConfirmedQty ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_scheds).

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY DeliverySchedule BY \_Item FIELDS ( OrderId ItemId Quantity ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_scheds INTO DATA(ls_sched).
      APPEND VALUE #( %tky        = ls_sched-%tky
                      %state_area = 'VALIDATE_SCHED' ) TO reported-deliveryschedule.

      IF ls_sched-DeliveryDate IS INITIAL OR ls_sched-DeliveryDate < lv_today.
        APPEND VALUE #( %tky = ls_sched-%tky ) TO failed-deliveryschedule.
        APPEND VALUE #( %tky                  = ls_sched-%tky
                        %state_area           = 'VALIDATE_SCHED'
                        %path                 = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_sched-%is_draft OrderId = ls_sched-OrderId )
                                                         salesorderitem-%tky   = VALUE #( %is_draft = ls_sched-%is_draft OrderId = ls_sched-OrderId ItemId = ls_sched-ItemId ) )
                        %element-DeliveryDate = if_abap_behv=>mk-on
                        %msg                  = new_message_with_text(
                                                  severity = if_abap_behv_message=>severity-error
                                                  text     = 'Delivery Date cannot be empty or in the past.' ) ) TO reported-deliveryschedule.
      ENDIF.

      IF ls_sched-ConfirmedQty <= 0.
        APPEND VALUE #( %tky = ls_sched-%tky ) TO failed-deliveryschedule.
        APPEND VALUE #( %tky                  = ls_sched-%tky
                        %state_area           = 'VALIDATE_SCHED'
                        %path                 = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_sched-%is_draft OrderId = ls_sched-OrderId )
                                                         salesorderitem-%tky   = VALUE #( %is_draft = ls_sched-%is_draft OrderId = ls_sched-OrderId ItemId = ls_sched-ItemId ) )
                        %element-ConfirmedQty = if_abap_behv=>mk-on
                        %msg                  = new_message_with_text(
                                                  severity = if_abap_behv_message=>severity-error
                                                  text     = 'Confirmed Quantity must be greater than zero.' ) ) TO reported-deliveryschedule.
      ENDIF.

      READ TABLE lt_items INTO DATA(ls_item) WITH KEY OrderId = ls_sched-OrderId ItemId = ls_sched-ItemId.
      IF sy-subrc = 0 AND ls_sched-ConfirmedQty > ls_item-Quantity.
        APPEND VALUE #( %tky = ls_sched-%tky ) TO failed-deliveryschedule.
        APPEND VALUE #( %tky                  = ls_sched-%tky
                        %state_area           = 'VALIDATE_SCHED'
                        %path                 = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_sched-%is_draft OrderId = ls_sched-OrderId )
                                                         salesorderitem-%tky   = VALUE #( %is_draft = ls_sched-%is_draft OrderId = ls_sched-OrderId ItemId = ls_sched-ItemId ) )
                        %element-ConfirmedQty = if_abap_behv=>mk-on
                        %msg                  = new_message_with_text(
                                                  severity = if_abap_behv_message=>severity-error
                                                  text     = 'Confirmed Quantity cannot exceed Item Quantity.' ) ) TO reported-deliveryschedule.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_HandlingUnit DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS updateSchedWeight FOR DETERMINE ON MODIFY
       keys FOR HandlingUnit~updateSchedWeight.

    METHODS validateGrossWeight FOR VALIDATE ON SAVE
       keys FOR HandlingUnit~validateGrossWeight.

ENDCLASS.

CLASS lhc_HandlingUnit IMPLEMENTATION.

    METHOD updateSchedWeight.
    DATA lt_sched_keys TYPE TABLE FOR READ IMPORT zi_so_sched\_Hu.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %is_draft = ls_key-%is_draft OrderId = ls_key-OrderId ItemId = ls_key-ItemId SchedId = ls_key-SchedId ) TO lt_sched_keys.
    ENDLOOP.
    SORT lt_sched_keys BY %is_draft OrderId ItemId SchedId.
    DELETE ADJACENT DUPLICATES FROM lt_sched_keys COMPARING %is_draft OrderId ItemId SchedId.

    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY DeliverySchedule BY \_Hu FIELDS ( GrossWeight WeightUnit ) WITH lt_sched_keys
      RESULT DATA(lt_hus).

    DATA lt_sched_upd TYPE TABLE FOR UPDATE zi_so_hdr\\DeliverySchedule.
    LOOP AT lt_sched_keys INTO DATA(ls_sk).
      DATA(lv_wgt) = REDUCE decfloat34( INIT sum = CONV decfloat34( 0 )
                                        FOR ls_h IN lt_hus
                                        WHERE ( OrderId = ls_sk-OrderId AND ItemId = ls_sk-ItemId AND SchedId = ls_sk-SchedId )
                                        NEXT sum = sum + ls_h-GrossWeight ).
      APPEND VALUE #( %tky        = ls_sk-%tky
                      SchedWeight = lv_wgt
                      WeightUnit  = 'KG' ) TO lt_sched_upd.
    ENDLOOP.

    IF lt_sched_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY DeliverySchedule UPDATE FIELDS ( SchedWeight WeightUnit ) WITH lt_sched_upd.
    ENDIF.
  ENDMETHOD.

  " --- Inside lhc_DeliverySchedule ---

    METHOD validateGrossWeight.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY HandlingUnit FIELDS ( OrderId ItemId SchedId PackagingType GrossWeight WeightUnit ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hus).

    LOOP AT lt_hus INTO DATA(ls_hu).
      APPEND VALUE #( %tky        = ls_hu-%tky
                      %state_area = 'VALIDATE_HU' ) TO reported-handlingunit.

      IF ls_hu-PackagingType IS INITIAL.
        APPEND VALUE #( %tky = ls_hu-%tky ) TO failed-handlingunit.
        APPEND VALUE #( %tky                   = ls_hu-%tky
                        %state_area            = 'VALIDATE_HU'
                        %path                  = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_hu-%is_draft OrderId = ls_hu-OrderId )
                                                          salesorderitem-%tky   = VALUE #( %is_draft = ls_hu-%is_draft OrderId = ls_hu-OrderId ItemId = ls_hu-ItemId )
                                                          deliveryschedule-%tky = VALUE #( %is_draft = ls_hu-%is_draft OrderId = ls_hu-OrderId ItemId = ls_hu-ItemId SchedId = ls_hu-SchedId ) )
                        %element-PackagingType = if_abap_behv=>mk-on
                        %msg                   = new_message_with_text(
                                                   severity = if_abap_behv_message=>severity-error
                                                   text     = 'Packaging Type is mandatory.' ) ) TO reported-handlingunit.
      ENDIF.

      IF ls_hu-GrossWeight <= 0 OR ls_hu-WeightUnit IS INITIAL.
        APPEND VALUE #( %tky = ls_hu-%tky ) TO failed-handlingunit.
        APPEND VALUE #( %tky                 = ls_hu-%tky
                        %state_area          = 'VALIDATE_HU'
                        %path                = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_hu-%is_draft OrderId = ls_hu-OrderId )
                                                        salesorderitem-%tky   = VALUE #( %is_draft = ls_hu-%is_draft OrderId = ls_hu-OrderId ItemId = ls_hu-ItemId )
                                                        deliveryschedule-%tky = VALUE #( %is_draft = ls_hu-%is_draft OrderId = ls_hu-OrderId ItemId = ls_hu-ItemId SchedId = ls_hu-SchedId ) )
                        %element-GrossWeight = if_abap_behv=>mk-on
                        %msg                 = new_message_with_text(
                                                 severity = if_abap_behv_message=>severity-error
                                                 text     = 'Gross Weight must be greater than zero with a valid Weight Unit.' ) ) TO reported-handlingunit.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_SalesOrderPartner DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS fetchPartnerDetails FOR DETERMINE ON MODIFY
       keys FOR SalesOrderPartner~fetchPartnerDetails.

    METHODS validatePartnerRole FOR VALIDATE ON SAVE
       keys FOR SalesOrderPartner~validatePartnerRole.

ENDCLASS.

CLASS lhc_SalesOrderPartner IMPLEMENTATION.

    METHOD fetchPartnerDetails.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderPartner FIELDS ( PartnerId PartnerName City ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partners).

    DATA lt_upd TYPE TABLE FOR UPDATE zi_so_hdr\\SalesOrderPartner.
    LOOP AT lt_partners INTO DATA(ls_p) WHERE PartnerId IS NOT INITIAL.
      APPEND VALUE #( %tky        = ls_p-%tky
                      PartnerName = |Partner { ls_p-PartnerId }|
                      City        = 'Ahmedabad' ) TO lt_upd.
    ENDLOOP.

    IF lt_upd IS NOT INITIAL.
      MODIFY ENTITIES OF zi_so_hdr IN LOCAL MODE
        ENTITY SalesOrderPartner UPDATE FIELDS ( PartnerName City ) WITH lt_upd.
    ENDIF.
  ENDMETHOD.


    METHOD validatePartnerRole.
    READ ENTITIES OF zi_so_hdr IN LOCAL MODE
      ENTITY SalesOrderPartner FIELDS ( OrderId PartnerRole PartnerId ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partners).

    LOOP AT lt_partners INTO DATA(ls_partner).
      APPEND VALUE #( %tky        = ls_partner-%tky
                      %state_area = 'VALIDATE_PARTNER' ) TO reported-salesorderpartner.

      IF ls_partner-PartnerRole IS INITIAL.
        APPEND VALUE #( %tky = ls_partner-%tky ) TO failed-salesorderpartner.
        APPEND VALUE #( %tky                 = ls_partner-%tky
                        %state_area          = 'VALIDATE_PARTNER'
                        %path                = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_partner-%is_draft OrderId = ls_partner-OrderId ) )
                        %element-PartnerRole = if_abap_behv=>mk-on
                        %msg                 = new_message_with_text(
                                                 severity = if_abap_behv_message=>severity-error
                                                 text     = 'Partner Role (e.g. AG, WE, RE, RG) is mandatory.' ) ) TO reported-salesorderpartner.
      ENDIF.

      IF ls_partner-PartnerId IS INITIAL.
        APPEND VALUE #( %tky = ls_partner-%tky ) TO failed-salesorderpartner.
        APPEND VALUE #( %tky               = ls_partner-%tky
                        %state_area        = 'VALIDATE_PARTNER'
                        %path              = VALUE #( salesorderheader-%tky = VALUE #( %is_draft = ls_partner-%is_draft OrderId = ls_partner-OrderId ) )
                        %element-PartnerId = if_abap_behv=>mk-on
                        %msg               = new_message_with_text(
                                               severity = if_abap_behv_message=>severity-error
                                               text     = 'Partner ID is mandatory.' ) ) TO reported-salesorderpartner.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
