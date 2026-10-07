@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection for employee table'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPS_C_EMPLOYEE as projection on ZPS_I_EMPLOYEE
{
    key EmployeeId,
    FirstName,
    LastName,
    Email,
    MobileNumber,
    Department,
    Designation,
    JoiningDate,
    DateOfBirth,
    Status,
    CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Salary,
    Address,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt
}
