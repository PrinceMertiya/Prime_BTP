@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Amount KPI'

define view entity ZI_PRIME_KPI_AMOUNT
  as select from ZI_PRIME_KPI
{
  key CukyField,
      @Semantics.amount.currencyCode: 'CukyField'
      sum( TotalAmount ) as TotalAmount
}
group by CukyField
