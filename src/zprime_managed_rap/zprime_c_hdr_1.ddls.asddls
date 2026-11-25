@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection for Zprime header table'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPRIME_C_HDR_1 as projection on ZPrime_I_HDR_1
{
    key ReqId,
    ReqType,
    Vendor,
    Status,
    Category,
    CukyField,
    @Semantics.amount.currencyCode: 'CukyField'
    TotalAmount,
    RejectReason,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _Item : redirected to composition child ZPRIME_C_ITEM_1
}
