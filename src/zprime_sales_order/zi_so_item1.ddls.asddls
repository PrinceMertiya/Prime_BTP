@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View: Sales Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SO_ITEM1 as select from zso_item
association to parent ZI_SO_HDR as _Header
on $projection.OrderId = _Header.OrderId
composition [0..*] of ZI_SO_SCHED as _Sched
composition [0..*] of ZI_SO_COND as _Cond

{
    key order_id              as OrderId,
    key item_id               as ItemId,
      material              as Material,
      uom                   as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      quantity              as Quantity,
      cuky_field            as CukyField,
      @Semantics.amount.currencyCode: 'CukyField'
      unit_price            as UnitPrice,
      @Semantics.amount.currencyCode: 'CukyField'
      item_amount           as ItemAmount,
      weight_unit           as WeightUnit,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      item_weight           as ItemWeight,
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
      
      _Header,
      _Sched,
      _Cond
}
