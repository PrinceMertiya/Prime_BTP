CLASS zpcl_student_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS zpcl_student_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA ls_student TYPE zpstudent.

    ls_student-client     = sy-mandt.
    ls_student-student_id = '0000000002'.
    ls_student-name       = 'ved bhai'.
    ls_student-city       = 'Gandhinagar'.

    ls_student-created_by = cl_abap_context_info=>get_user_technical_name( ).

    GET TIME STAMP FIELD ls_student-created_at.

    ls_student-changed_by = ls_student-created_by.
    ls_student-changed_at = ls_student-created_at.

    INSERT zpstudent FROM @ls_student.

    IF sy-subrc = 0.
      out->write( 'Record inserted successfully' ).
    ELSE.
      out->write( |Insert failed. SY-SUBRC = { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
