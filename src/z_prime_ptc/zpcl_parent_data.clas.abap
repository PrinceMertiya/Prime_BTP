CLASS zpcl_parent_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpcl_parent_data IMPLEMENTATION.
    METHOD if_oo_adt_classrun~main.

        DATA ls_parent TYPE zparent_001.

        ls_parent-client = sy-mandt.

        cl_system_uuid=>create_uuid_x16_static(
          RECEIVING
            uuid = ls_parent-parent_uuid ).

        ls_parent-parent_id   = '00004'.
        ls_parent-parent_name = 'Parent D'.

        INSERT zparent_001 FROM @ls_parent.

        IF sy-subrc = 0.
          COMMIT WORK.
          out->write( 'Parent record inserted successfully' ).
        ELSE.
          out->write( |Insert failed. SY-SUBRC = { sy-subrc }| ).
        ENDIF.


    ENDMETHOD.

ENDCLASS.
