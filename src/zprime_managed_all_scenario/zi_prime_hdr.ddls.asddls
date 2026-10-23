@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'data definition for prime hdr'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PRIME_HDR
  as select from zprime_hdr
  composition [0..*] of ZI_PRIME_ITEM as _Item

{
      @EndUserText.label: 'Request ID'
      key req_id                as ReqId,
      @EndUserText.label: 'Request Type'
      req_type              as ReqType,


      vendor                as Vendor,
      status                as Status,
      category              as category,
      reject_reason  as RejectReason,
      cuky_field            as CukyField,
      @Semantics.amount.currencyCode : 'CukyField'
      total_amount          as TotalAmount,

      case
      when category = 'NORMAL' then 1
      when category = 'PREMIUM' then 2
      when category = 'VIP' then 3
      else 0
      end                   as Criticality,
      
      

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
      //    _association_name // Make association public
}
