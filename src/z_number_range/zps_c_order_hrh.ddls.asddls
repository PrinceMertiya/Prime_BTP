@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection for order table'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPS_C_ORDER_HRH provider contract transactional_query as projection on ZPS_I_ORDER_HRH
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
