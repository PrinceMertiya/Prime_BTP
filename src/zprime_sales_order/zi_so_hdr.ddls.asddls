@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View: Sales Order Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SO_HDR as select from zso_hdr

composition [0..*] of ZI_SO_ITEM1  as _Item
composition [0..*] of ZI_SO_PARTNER  as _Partner


{
    key order_id              as OrderId,
      customer_id           as CustomerId,
      sales_org             as SalesOrg,
      status                as Status,
      priority              as Priority,
      cuky_field            as CukyField,
      @Semantics.amount.currencyCode: 'CukyField'
      net_value             as NetValue,
      uzeit_weight_unit     as WeightUnit,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      total_weight          as TotalWeight,
      reject_reason         as RejectReason,
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
      _Partner
   
}
