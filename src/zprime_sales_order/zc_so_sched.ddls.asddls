@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View: Delivery Schedule Line'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SO_SCHED as projection on ZI_SO_SCHED
{
    key OrderId,
    key ItemId,
    key SchedId,
    DeliveryDate,
    Plant,
    Uom,
    @Semantics.quantity.unitOfMeasure: 'Uom'
    ConfirmedQty,
    WeightUnit,
    @Semantics.quantity.unitOfMeasure: 'WeightUnit'
    SchedWeight,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
     _Item   : redirected to parent ZC_SO_ITEM1,
      _Header : redirected to ZC_SO_HDR,
      _Hu     : redirected to composition child ZC_SO_HU
}
