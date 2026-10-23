@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Request KPI'

define view entity ZI_PRIME_KPI_CNT
  as select from ZI_PRIME_KPI
{
  key cast( '1' as abap.char(1) ) as Id,

      count(*) as TotalRequests
}
