@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View: Sales Order Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SO_ITEM1 as projection on ZI_SO_ITEM1
{
    key OrderId,
    key ItemId,
    Material,
    Uom,
    @Semantics.quantity.unitOfMeasure: 'Uom'
    Quantity,
    CukyField,
    @Semantics.amount.currencyCode: 'CukyField'
    UnitPrice,
    @Semantics.amount.currencyCode: 'CukyField'
    ItemAmount,
    WeightUnit,
    @Semantics.quantity.unitOfMeasure: 'WeightUnit'
    ItemWeight,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _Header : redirected to parent ZC_SO_HDR,
    _Sched  : redirected to composition child ZC_SO_SCHED,
    _Cond   : redirected to composition child ZC_SO_COND
}
