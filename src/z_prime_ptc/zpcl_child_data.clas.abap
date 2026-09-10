CLASS zpcl_child_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS zpcl_child_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA ls_child TYPE zchild_tab.

    ls_child-client = sy-mandt.

    "Generate Child UUID
    ls_child-child_uuid = cl_system_uuid=>create_uuid_x16_static( ).

    "Parent UUID must exist in ZPARENT_001
    ls_child-parent_uuid = 'F2A1AFB65F9C1FD1AAE745499B1EB7A3'.

    ls_child-child_id   = 'CH003'.
    ls_child-child_name = 'Child C'.

    ls_child-created_by = cl_abap_context_info=>get_user_technical_name( ).

    GET TIME STAMP FIELD ls_child-created_at.

    ls_child-last_changed_by = ls_child-created_by.
    ls_child-last_changed_at = ls_child-created_at.

    INSERT zchild_tab FROM @ls_child.

    IF sy-subrc = 0.

      COMMIT WORK.

      out->write( 'Child record inserted successfully' ).

    ELSE.

      out->write(
        |Insert failed. SY-SUBRC = { sy-subrc }|
      ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
