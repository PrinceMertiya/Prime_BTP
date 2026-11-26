@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View: Sales Order Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_SO_HDR 
    
    provider contract transactional_query
    as projection on ZI_SO_HDR
    
{
    key OrderId,
    CustomerId,
    SalesOrg,
    Status,
    Priority,
    CukyField,
    @Semantics.amount.currencyCode: 'CukyField'
    NetValue,
    WeightUnit,
    @Semantics.quantity.unitOfMeasure: 'WeightUnit'
    TotalWeight,
    RejectReason,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
     _Item    : redirected to composition child ZC_SO_ITEM1,
     _Partner : redirected to composition child ZC_SO_PARTNER
}
