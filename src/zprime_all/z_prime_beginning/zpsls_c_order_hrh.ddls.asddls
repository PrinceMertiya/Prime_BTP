@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Table ordere hrh projection for cds'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPSLS_C_ORDER_HRH
  provider contract transactional_query as projection on zpsls_i_order_hrh
{
    key OrderId,
    OrderName,
    OrderType,
    OrderDate,
    Status,
    CukyField,
    @Semantics.amount.currencyCode : 'CukyField'
    Amount,
    CreatedBy,
    CreatedAt,
    LastChangedAt
}

