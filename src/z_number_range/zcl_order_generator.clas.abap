CLASS zcl_order_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_order,
        order_name TYPE zps_order_hrh-order_name,
        order_type TYPE zps_order_hrh-order_type,
        order_date TYPE zps_order_hrh-order_date,
        status     TYPE zps_order_hrh-status,
        cuky_field TYPE zps_order_hrh-cuky_field,
        amount     TYPE zps_order_hrh-amount,
      END OF ty_order.

    TYPES tt_order TYPE STANDARD TABLE OF ty_order.

    METHODS gen_and_get_data
      EXPORTING
        ct_table TYPE tt_order.

ENDCLASS.



CLASS zcl_order_generator IMPLEMENTATION.

  METHOD gen_and_get_data.

    DATA:
      lt_ordername TYPE STANDARD TABLE OF zps_order_hrh-order_name,
      lt_ordertype TYPE STANDARD TABLE OF zps_order_hrh-order_type,
      lt_status    TYPE STANDARD TABLE OF zps_order_hrh-status,
      ranidx1      TYPE i,
      ranidx2      TYPE i,
      ranidx3      TYPE i.

    lt_ordername = VALUE #(
      ( 'Laptop Order' )
      ( 'Desktop Order' )
      ( 'Mobile Order' )
      ( 'Printer Order' )
      ( 'Network Order' )
      ( 'Software Order' )
    ).

    lt_ordertype = VALUE #(
      ( 'IT' )
      ( 'HR' )
      ( 'FINANCE' )
      ( 'ADMIN' )
      ( 'SALES' )
    ).

    lt_status = VALUE #(
      ( 'Open' )
      ( 'Pending' )
      ( 'Closed' )
      ( 'Approved' )
    ).

    DO 10 TIMES.

      ranidx1 = cl_abap_random_int=>create(
                  seed = cl_abap_random=>seed( )
                  min  = 1
                  max  = lines( lt_ordername ) )->get_next( ).

      ranidx2 = cl_abap_random_int=>create(
                  seed = cl_abap_random=>seed( )
                  min  = 1
                  max  = lines( lt_ordertype ) )->get_next( ).

      ranidx3 = cl_abap_random_int=>create(
                  seed = cl_abap_random=>seed( )
                  min  = 1
                  max  = lines( lt_status ) )->get_next( ).

      APPEND VALUE #(
        order_name = lt_ordername[ ranidx1 ]
        order_type = lt_ordertype[ ranidx2 ]
        order_date = cl_abap_context_info=>get_system_date( )
        status     = lt_status[ ranidx3 ]
        cuky_field = 'INR'
        amount     = cl_abap_random_int=>create(
                       seed = cl_abap_random=>seed( )
                       min  = 1000
                       max  = 50000 )->get_next( )
      ) TO ct_table.

    ENDDO.

  ENDMETHOD.

ENDCLASS.
