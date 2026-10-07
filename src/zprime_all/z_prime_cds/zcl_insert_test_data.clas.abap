CLASS zcl_insert_test_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_insert_test_data IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: gt_parent     TYPE TABLE OF zsls_parent,
          gt_child      TYPE TABLE OF zsls_child,
          gt_parent_txt TYPE TABLE OF zsls_parent_txt.

    DELETE FROM zsls_parent.
    DELETE FROM zsls_child.
    DELETE FROM zsls_parent_txt.

    gt_parent = VALUE #(
                          ( parent_id = 'P001'
                            status    = abap_true )

                          ( parent_id = 'P002'
                            status    = abap_false )

                          ( parent_id = 'P003'
                            status    = abap_true )
                        ).

    INSERT zsls_parent FROM TABLE @gt_parent.
    IF sy-subrc = 0.
      out->write( sy-dbcnt ).
    ENDIF.


    gt_child = VALUE #(
                      ( parent_id  = 'P001'
                        child_id   = 'C01'
                        description = 'Child 1 of Parent P001' )

                      ( parent_id  = 'P001'
                        child_id   = 'C02'
                        description = 'Child 2 of Parent P001' )

                      ( parent_id  = 'P002'
                        child_id   = 'C01'
                        description = 'Child 1 of Parent P002' )

                      ( parent_id  = 'P003'
                        child_id   = 'C01'
                        description = 'Child 1 of Parent P003' )

                      ( parent_id  = 'P003'
                        child_id   = 'C02'
                        description = 'Child 2 of Parent P003' )
                    ).

    INSERT zsls_child FROM TABLE @gt_child.

    IF sy-subrc = 0.
      out->write( sy-dbcnt ).
    ENDIF.

    gt_parent_txt = VALUE #(
                             ( parent_id  = 'P001'
                               language   = 'E'
                               description = 'Parent One' )

                             ( parent_id  = 'P001'
                               language   = 'D'
                               description = 'Eltern Eins' )

                             ( parent_id  = 'P002'
                               language   = 'E'
                               description = 'Parent Two' )

                             ( parent_id  = 'P003'
                               language   = 'E'
                               description = 'Parent Three' )
                           ).


    INSERT zsls_parent_txt FROM TABLE @gt_parent_txt.
    IF sy-subrc = 0.
      out->write( sy-dbcnt ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
