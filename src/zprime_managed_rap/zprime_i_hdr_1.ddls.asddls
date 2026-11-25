@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for Header Table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZPrime_I_HDR_1 as select from zprime_hdr_1
composition [0..*] of ZPrime_I_ITME_1 as _Item

{
    key req_id as ReqId,
    req_type as ReqType,
    vendor as Vendor,
    status as Status,
    category as Category,
    cuky_field as CukyField,
    @Semantics.amount.currencyCode: 'CukyField'
    total_amount as TotalAmount,
    reject_reason as RejectReason,
    
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt : true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Item
}
