*CLASS zprime_test DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC.
*
*  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
*ENDCLASS.
*
*CLASS zprime_test IMPLEMENTATION.
*
*  METHOD if_oo_adt_classrun~main.
*
*    out->write( '===== DRAFT HEADERS =====' ).
*
*    SELECT *
*      FROM zprime_dt_hdr
*      INTO TABLE @DATA(lt_hdr).
*
*    LOOP AT lt_hdr INTO DATA(ls_hdr).
*
*      out->write(
*        |REQID = { ls_hdr-reqid }|
*      ).
*
*    ENDLOOP.
*
*    out->write( '===== ACTIVE HEADERS =====' ).
*
*    SELECT *
*      FROM zprime_hdr
*      INTO TABLE @DATA(lt_active).
*
*    LOOP AT lt_active INTO DATA(ls_active).
*
*      out->write(
*        |REQID = { ls_active-req_id }|
*      ).
*
*    ENDLOOP.
*
*  ENDMETHOD.
*
*ENDCLASS.

CLASS zprime_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zprime_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( '===== ACTIVE ITEMS =====' ).

    SELECT *
      FROM zprime_item
      INTO TABLE @DATA(lt_item).

    LOOP AT lt_item INTO DATA(ls_item).

      out->write(
        |REQID={ ls_item-req_id } ITEMID={ ls_item-item_id }|
      ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
