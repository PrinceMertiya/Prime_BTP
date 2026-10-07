CLASS zprime_c2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprime_c2 IMPLEMENTATION.

    METHOD if_oo_adt_classrun~main.

*  DATA(lv_salary) = 25000.
*
*  IF lv_salary >= 50000.
*
*    out->write( 'High Salary' ).
*
*  ELSEIF lv_salary >= 20000.
*
*    out->write( 'Medium Salary' ).
*
*  ELSE.
*
*    out->write( 'Low Salary' ).
*
*  ENDIF.
*
*
*  do 5 times.
*    out->write( |Iteration { sy-index }| ).
*
*  enddo.
*
*
*  data(lv_count) = 1.
*
*  while lv_count <= 5.
*    out->write( lv_count ).
*    lv_count = lv_count + 1.
*
*  ENDWHILE.

*    data(lt_names) = VALUE string_table(
*        ( `John` )
*        ( `David` )
*        ( `Prime` )
*      ).
*
*      LOOP AT lt_names INTO DATA(lv_name).
*
*        out->write( lv_name ).
*
*
*      ENDLOOP.


      data(lt_names) = value string_table(

          ( `prime` )
          ( `prince` )
          ( `prince m` )
      ).


*      delete lt_names index 2.


*      MODIFY lt_names FROM 'AMIT' INDEX 2.

      LOOP at lt_names into data(lv_name).
          out->write( lv_name ).

      ENDLOOP.



      TYPES:
          BEGIN OF ty_emp,
            empid TYPE i,
            name type string,
          end of ty_emp.

*      DATA ls_emp type ty_emp.
*
*      ls_emp-empid = 101.
*      ls_emp-name = 'prime'.
*
*      out->write( ls_emp-empid ).
*      out->write( ls_emp-name ).


       DATA lt_Emp type table of ty_emp.

       append value #( empid = 101 name = 'Prime' ) To lt_emp.
       append value #( empid = 102 name = 'John' ) To lt_emp.


       READ table lt_emp
           into data(ls_emp)
           index 2.

       if sy-subrc = 0.

        out->write( |ID: { ls_emp-empid }| ).
        out->write( |NAME: { ls_emp-name }| ).

        ls_emp-name = 'rajesh'.

        modify lt_emp from ls_emp index 2.


       endif.

       read table lt_emp
            into data(ls_emp1)
            index 2.


       if sy-subrc = 0.

        out->write( |ID: { ls_emp1-empid }| ).
        out->write( |NAME: { ls_emp1-name }| ).



       endif.





ENDMETHOD.


ENDCLASS.
