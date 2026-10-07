CLASS lhc_ZPS_I_EMPLOYEE DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    class-DATA gt_employee TYPE TABLE OF zps_employee.

    CLASS-DATA gt_delete TYPE TABLE OF zps_employee.


  PRIVATE SECTION.




    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zps_i_employee RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zps_i_employee RESULT result.

    METHODS create FOR MODIFY
       entities FOR CREATE zps_i_employee.

    METHODS update FOR MODIFY
       entities FOR UPDATE zps_i_employee.

    METHODS delete FOR MODIFY
       keys FOR DELETE zps_i_employee.

    METHODS read FOR READ
       keys FOR READ zps_i_employee RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK zps_i_employee.

ENDCLASS.

CLASS lhc_ZPS_I_EMPLOYEE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

*  gt_employee = VALUE #(
*    FOR ls_entity IN entities
*    (
*      client        = sy-mandt
*      employee_id   = ls_entity-EmployeeId
*      first_name    = ls_entity-FirstName
*      last_name     = ls_entity-LastName
*      email         = ls_entity-Email
*      mobile_number = ls_entity-MobileNumber
*      department    = ls_entity-Department
*      designation   = ls_entity-Designation
*      joining_date  = ls_entity-JoiningDate
*      date_of_birth = ls_entity-DateOfBirth
*      status        = ls_entity-Status
*      currency_code = ls_entity-CurrencyCode
*      salary        = ls_entity-Salary
*      address       = ls_entity-Address
*    )
*  ).

zbp_ps_i_employee=>lt_insert = CORRESPONDING #( entities MAPPING
  employee_id   = EmployeeId
  first_name    = FirstName
  last_name     = LastName
  email         = Email
  mobile_number = MobileNumber
  department    = Department
  designation   = Designation
  joining_date  = JoiningDate
  date_of_birth = DateOfBirth
  status        = Status
  currency_code = CurrencyCode
  salary        = Salary
  address       = Address
  created_by    = CreatedBy
  created_at    = CreatedAt

).
*  if i used entities mapping from enitity is used the mapping from behaviour


ENDMETHOD.

  METHOD update.

*  lhc_zps_i_employee=>gt_employee = VALUE #(
*    FOR ls_entity IN entities
*    (
*      client        = sy-mandt
*      employee_id   = ls_entity-EmployeeId
*      first_name    = ls_entity-FirstName
*      last_name     = ls_entity-LastName
*      email         = ls_entity-Email
*      mobile_number = ls_entity-MobileNumber
*      department    = ls_entity-Department
*      designation   = ls_entity-Designation
*      joining_date  = ls_entity-JoiningDate
*      date_of_birth = ls_entity-DateOfBirth
*      status        = ls_entity-Status
*      currency_code = ls_entity-CurrencyCode
*      salary        = ls_entity-Salary
*      address       = ls_entity-Address
*    )
*  ).



  SELECT *
    FROM zps_employee
    FOR ALL ENTRIES IN @entities
    WHERE employee_id = @entities-EmployeeId
    INTO TABLE @DATA(lt_employee).

  LOOP AT entities INTO DATA(ls_entity).

    DATA(ls_employee) = VALUE #(
        lt_employee[
            employee_id = ls_entity-EmployeeId
        ] OPTIONAL ).

    IF ls_employee IS INITIAL.
      CONTINUE.
    ENDIF.

    ls_employee-first_name =
      COND #(
        WHEN ls_entity-%control-FirstName = if_abap_behv=>mk-on
        THEN ls_entity-FirstName
        ELSE ls_employee-first_name ).

    ls_employee-last_name =
      COND #(
        WHEN ls_entity-%control-LastName = if_abap_behv=>mk-on
        THEN ls_entity-LastName
        ELSE ls_employee-last_name ).

    ls_employee-email =
      COND #(
        WHEN ls_entity-%control-Email = if_abap_behv=>mk-on
        THEN ls_entity-Email
        ELSE ls_employee-email ).

    ls_employee-mobile_number =
      COND #(
        WHEN ls_entity-%control-MobileNumber = if_abap_behv=>mk-on
        THEN ls_entity-MobileNumber
        ELSE ls_employee-mobile_number ).

    ls_employee-department =
      COND #(
        WHEN ls_entity-%control-Department = if_abap_behv=>mk-on
        THEN ls_entity-Department
        ELSE ls_employee-department ).

    ls_employee-designation =
      COND #(
        WHEN ls_entity-%control-Designation = if_abap_behv=>mk-on
        THEN ls_entity-Designation
        ELSE ls_employee-designation ).

    ls_employee-joining_date =
      COND #(
        WHEN ls_entity-%control-JoiningDate = if_abap_behv=>mk-on
        THEN ls_entity-JoiningDate
        ELSE ls_employee-joining_date ).

    ls_employee-date_of_birth =
      COND #(
        WHEN ls_entity-%control-DateOfBirth = if_abap_behv=>mk-on
        THEN ls_entity-DateOfBirth
        ELSE ls_employee-date_of_birth ).

    ls_employee-status =
      COND #(
        WHEN ls_entity-%control-Status = if_abap_behv=>mk-on
        THEN ls_entity-Status
        ELSE ls_employee-status ).

    ls_employee-currency_code =
      COND #(
        WHEN ls_entity-%control-CurrencyCode = if_abap_behv=>mk-on
        THEN ls_entity-CurrencyCode
        ELSE ls_employee-currency_code ).

    ls_employee-salary =
      COND #(
        WHEN ls_entity-%control-Salary = if_abap_behv=>mk-on
        THEN ls_entity-Salary
        ELSE ls_employee-salary ).

    ls_employee-address =
      COND #(
        WHEN ls_entity-%control-Address = if_abap_behv=>mk-on
        THEN ls_entity-Address
        ELSE ls_employee-address ).

    APPEND ls_employee TO gt_employee.

  ENDLOOP.

ENDMETHOD.

  METHOD delete.

  gt_delete = VALUE #(
    FOR ls_key IN keys
    (
      client      = sy-mandt
      employee_id = ls_key-EmployeeId
    )
  ).

ENDMETHOD.

  METHOD read.

  SELECT *
  FROM zps_employee
  for all ENTRIES IN @keys
  where employee_id = @keys-EmployeeId
  INTO TABLE @DATA(lt_employee).


  result = VALUE #( FOR ls_employee IN lt_employee
                    (
                      EmployeeId    = ls_employee-employee_id
                      FirstName     = ls_employee-first_name
                      LastName      = ls_employee-last_name
                      Email         = ls_employee-email
                      MobileNumber  = ls_employee-mobile_number
                      Department    = ls_employee-department
                      Designation   = ls_employee-designation
                      JoiningDate   = ls_employee-joining_date
                      DateOfBirth   = ls_employee-date_of_birth
                      Status        = ls_employee-status
                      CurrencyCode  = ls_employee-currency_code
                      Salary        = ls_employee-salary
                      Address       = ls_employee-address
                    ) ).



  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZPS_I_EMPLOYEE DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZPS_I_EMPLOYEE IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.


  if zbp_ps_i_employee=>lt_insert is not initial.
    insert zps_employee from table @zbp_ps_i_employee=>lt_insert.
  endif.

  if zbp_ps_i_employee=>lt_update is not initial.
    MODIFY zps_employee FROM TABLE @lhc_zps_i_employee=>gt_employee.

  endif.

  MODIFY zps_employee
    FROM TABLE @lhc_zps_i_employee=>gt_employee.

  LOOP AT lhc_zps_i_employee=>gt_delete INTO DATA(ls_delete).

    DELETE FROM zps_employee
      WHERE employee_id = @ls_delete-employee_id.

  ENDLOOP.

  CLEAR lhc_zps_i_employee=>gt_employee.
  CLEAR lhc_zps_i_employee=>gt_delete.


ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
