@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View: Pricing Condition'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SO_COND as select from zso_cond
association        to parent ZI_SO_ITEM1 as _Item   on  $projection.OrderId = _Item.OrderId
                                                     and $projection.ItemId  = _Item.ItemId
  association [1..1] to ZI_SO_HDR         as _Header on  $projection.OrderId = _Header.OrderId
{
    key order_id              as OrderId,
    key item_id               as ItemId,
    key cond_id               as CondId,
      cond_type             as CondType,
      calc_type             as CalcType,
      rate_percent          as RatePercent,
      cuky_field            as CukyField,
      @Semantics.amount.currencyCode: 'CukyField'
      cond_value            as CondValue,
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
      _Header
}
