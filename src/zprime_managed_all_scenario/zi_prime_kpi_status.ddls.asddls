@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Stat*s KPI'

define view entity ZI_PRIME_KPI_STATUS
  as select from ZI_PRIME_KPI
{
  key Status,
      count(*) as RequestCount
}
group by Status
