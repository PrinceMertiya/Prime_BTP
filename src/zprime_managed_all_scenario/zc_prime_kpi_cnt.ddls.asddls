@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total Requests KPI'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PRIME_KPI_CNT
  as select from ZI_PRIME_KPI_CNT
{
   key Id,
       TotalRequests
}
