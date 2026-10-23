@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'KPI Consumption view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PRIME_KPI
  as select from ZI_PRIME_KPI
{
  key ReqId,
      Status,
      CukyField,

      @Semantics.amount.currencyCode: 'CukyField'
      TotalAmount,

      Vendor,
      Category,
      CreatedAt
}
