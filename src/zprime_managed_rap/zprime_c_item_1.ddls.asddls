@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'item table projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPRIME_C_ITEM_1 as projection on ZPrime_I_ITME_1
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
    _Header : redirected to parent ZPRIME_C_HDR_1
}
