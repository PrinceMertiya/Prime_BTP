@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View: Sales Order Partner'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SO_PARTNER as projection on ZI_SO_PARTNER
{
    key OrderId,
    key PartnerRole,
    PartnerId,
    PartnerName,
    City,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _Header : redirected to parent ZC_SO_HDR
}
