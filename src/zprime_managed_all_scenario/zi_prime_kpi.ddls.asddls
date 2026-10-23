@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'KPI Source View'

define view entity ZI_PRIME_KPI
  as select from zprime_hdr
{
  key req_id       as ReqId,
      status       as Status,

      cuky_field   as CukyField,

      @Semantics.amount.currencyCode: 'CukyField'
      total_amount as TotalAmount,

      vendor       as Vendor,
      category     as Category,
      created_at   as CreatedAt
}
