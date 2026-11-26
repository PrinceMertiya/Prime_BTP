@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View: Handling Unit'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SO_HU as select from zso_hu
association        to parent ZI_SO_SCHED as _Sched  on  $projection.OrderId = _Sched.OrderId
                                                      and $projection.ItemId  = _Sched.ItemId
                                                      and $projection.SchedId = _Sched.SchedId
  association [1..1] to ZI_SO_HDR          as _Header on  $projection.OrderId = _Header.OrderId
{
    key order_id              as OrderId,
  key item_id               as ItemId,
  key sched_id              as SchedId,
  key hu_id                 as HuId,
      serial_no             as SerialNo,
      packaging_type        as PackagingType,
      weight_unit           as WeightUnit,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      gross_weight          as GrossWeight,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      _Sched,
      _Header
}
