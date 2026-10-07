CLASS zps_insert_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zps_insert_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_data TYPE TABLE OF zps_employee.

    lt_data = VALUE #(

      ( employee_id    = 'EMP001'
        first_name     = 'Prince'
        last_name      = 'Mertiya'
        email          = 'prince@test.com'
        mobile_number  = '9876543210'
        department     = 'IT'
        designation    = 'Developer'
        joining_date   = '20250101'
        date_of_birth  = '20000115'
        status         = 'ACTIVE'
        currency_code  = 'INR'
        salary         = '50000.00'
        address        = 'Gandhinagar, Gujarat' )

      ( employee_id    = 'EMP002'
        first_name     = 'Amit'
        last_name      = 'Sharma'
        email          = 'amit@test.com'
        mobile_number  = '9876543211'
        department     = 'HR'
        designation    = 'Manager'
        joining_date   = '20240115'
        date_of_birth  = '19950520'
        status         = 'ACTIVE'
        currency_code  = 'INR'
        salary         = '75000.00'
        address        = 'Ahmedabad, Gujarat' )

      ( employee_id    = 'EMP003'
        first_name     = 'John'
        last_name      = 'David'
        email          = 'john@test.com'
        mobile_number  = '9876543212'
        department     = 'Finance'
        designation    = 'Analyst'
        joining_date   = '20240301'
        date_of_birth  = '19980710'
        status         = 'ACTIVE'
        currency_code  = 'USD'
        salary         = '65000.00'
        address        = 'New York, USA' )

    ).

    INSERT zps_employee FROM TABLE @lt_data.

    IF sy-subrc = 0.
      out->write( 'Data inserted successfully' ).
    ELSE.
      out->write( 'Insertion failed or records already exist' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
