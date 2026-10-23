@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Amount KPI'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PRIME_KPI_AMOUNT
  as select from ZI_PRIME_KPI_AMOUNT
{
  key CukyField,

  @Semantics.amount.currencyCode: 'CukyField'
  TotalAmount
}
