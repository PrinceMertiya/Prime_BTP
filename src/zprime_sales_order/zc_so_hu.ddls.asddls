@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View: Handling Unit'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SO_HU as projection on ZI_SO_HU
{
    key OrderId,
    key ItemId,
    key SchedId,
    key HuId,
    SerialNo,
    PackagingType,
    WeightUnit,
    @Semantics.quantity.unitOfMeasure: 'WeightUnit'
    GrossWeight,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _Sched : redirected to parent ZC_SO_SCHED,
    _Header : redirected to ZC_SO_HDR
}
