@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View: Sales Order Partner'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SO_PARTNER as select from zso_partner
association to parent ZI_SO_HDR as _Header 
on $projection.OrderId = _Header.OrderId
{
     key order_id              as OrderId,
     key partner_role          as PartnerRole,
      partner_id            as PartnerId,
      partner_name          as PartnerName,
      city                  as City,
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
      _Header
}
