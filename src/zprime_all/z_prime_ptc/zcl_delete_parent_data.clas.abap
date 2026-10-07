CLASS zcl_delete_parent_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_delete_parent_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DELETE FROM zchild_tab
      WHERE parent_uuid IS INITIAL
         OR child_uuid  IS INITIAL.

    DELETE FROM zparent_001
      WHERE parent_uuid IS INITIAL.

    COMMIT WORK.

    out->write( |Deleted records: { sy-dbcnt }| ).

  ENDMETHOD.

ENDCLASS.
