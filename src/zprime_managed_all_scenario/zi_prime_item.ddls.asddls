@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition for prime item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PRIME_ITEM as select from zprime_item
association to parent ZI_PRIME_HDR AS _Header
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
