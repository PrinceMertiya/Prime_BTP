@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection for item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PRIME_ITEM as projection on ZI_PRIME_ITEM
{
    key ReqId,
    key ItemId,
    Material,
    Quantity,
    CukyField,
    @Semantics.amount.currencyCode: 'CukyField'
    Price,
    @Semantics.amount.currencyCode: 'CukyField'
    Amount,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _Header : redirected to parent ZC_PRIME_HDR
}
