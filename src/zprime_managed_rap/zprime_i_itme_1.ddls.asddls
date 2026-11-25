@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for Item Table'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZPrime_I_ITME_1 as select from zprime_item_1
association to parent ZPrime_I_HDR_1 as _Header
on $projection.ReqId = _Header.ReqId
{
     key req_id as ReqId,
     key item_id as ItemId,
     material as Material,
     quantity as Quantity,
     cuky_field as CukyField,
     @Semantics.amount.currencyCode: 'CukyField'
     price as Price,
     @Semantics.amount.currencyCode: 'CukyField'
     amount as Amount,
     created_by as CreatedBy,
     created_at as CreatedAt,
     last_changed_by as LastChangedBy,
     last_changed_at as LastChangedAt,
     local_last_changed_at as LocalLastChangedAt,
     _Header
}
