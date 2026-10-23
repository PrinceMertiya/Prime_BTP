@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection for hdr'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_PRIME_HDR as projection on ZI_PRIME_HDR
{
    key ReqId,
    ReqType,
    Vendor,
    Status,
    category,
    CukyField,
    @Semantics.amount.currencyCode: 'CukyField'
    TotalAmount,
    RejectReason,
    Criticality,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _Item : redirected to composition child ZC_PRIME_ITEM
}
 