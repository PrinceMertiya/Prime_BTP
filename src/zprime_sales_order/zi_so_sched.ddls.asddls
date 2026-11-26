@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View: Delivery Schedule Line'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SO_SCHED as select from zso_sched
association to parent ZI_SO_ITEM1 as _Item
on $projection.OrderId = _Item.OrderId and $projection.ItemId = _Item.ItemId
association [1..1] to ZI_SO_HDR as _Header on $projection.OrderId = _Header.OrderId

composition [0..*] of ZI_SO_HU          as _Hu

{
    key order_id              as OrderId,
  key item_id               as ItemId,
  key sched_id              as SchedId,
      delivery_date         as DeliveryDate,
      plant                 as Plant,
      uom                   as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      confirmed_qty         as ConfirmedQty,
      weight_unit           as WeightUnit,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      sched_weight          as SchedWeight,
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
      _Item,
      _Header,
      _Hu
}
