@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View: Pricing Condition'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SO_COND as projection on ZI_SO_COND
{
    key OrderId,
    key ItemId,
    key CondId,
    CondType,
    CalcType,
    RatePercent,
    CukyField,
    @Semantics.amount.currencyCode: 'CukyField'
    CondValue,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
     _Item   : redirected to parent ZC_SO_ITEM1,
      _Header : redirected to ZC_SO_HDR
}
