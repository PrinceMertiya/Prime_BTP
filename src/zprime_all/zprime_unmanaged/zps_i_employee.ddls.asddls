@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface for employee table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZPS_I_EMPLOYEE as select from zps_employee

{
    key employee_id as EmployeeId,
    first_name as FirstName,
    last_name as LastName,
    email as Email,
    mobile_number as MobileNumber,
    department as Department,
    designation as Designation,
    joining_date as JoiningDate,
    date_of_birth as DateOfBirth,
    status as Status,
    currency_code as CurrencyCode,
    @Semantics.amount.currencyCode : 'Currencycode'
    salary as Salary,
    address as Address,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
   
}
