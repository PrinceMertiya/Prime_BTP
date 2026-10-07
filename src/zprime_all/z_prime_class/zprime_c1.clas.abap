CLASS zprime_c1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    METHODS say_hello
      IMPORTING
         prime TYPE REF TO if_oo_adt_classrun_out.

    METHODS say_num
        IMPORTING
            out TYPE ref to if_oo_adt_classrun_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_c1 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

*    data(lv_name) = 'Prime'.
*
*    out->write( lv_name ).

    say_hello(
     prime = out
     ).

     CONSTANTS gc_company TYPE string VALUE 'Microsoft'.
     CONSTANTS gc_name TYPE string VALUE 'PRIME'.
     constants gc_role type string value 'software engineer'.

     out->write( gc_company ).
     out->write( gc_name ).
     out->write( gc_role ).


     say_hello(
     prime = out
      ).

      say_num( out = out ).



  ENDMETHOD.

  METHOD say_hello.

    DATA lv_name  TYPE string VALUE 'PRIME'.
    DATA lv_role TYPE string VALUE 'SOFTWARE ENGINEER'.

    prime->write( |Name: { lv_name } | ).
    prime->write( |Role: { lv_role } | ).



    DATA(lv_names) = 'Prime'.
DATA(lv_roles) = 'Software Engineer'.

prime->write(
  |My name is { lv_names } and I am a { lv_role }|
).

  ENDMETHOD.

  METHOD say_num.

    DATA lv_n type i value 12.
    DATA lv_n2 type i value 20.
*    data lv_sum type i.

    DATA(lv_sum)  = lv_n + lv_n2.

    DATA(lv_minus) = lv_n - lv_n2.

    DATA(lv_multiply) = lv_n * lv_n2.



    out->write( lv_sum ).

    out->write( | A - B is { lv_minus }| ).
    out->write( | A * B is { lv_multiply }| ).




  ENDMETHOD.

ENDCLASS..

