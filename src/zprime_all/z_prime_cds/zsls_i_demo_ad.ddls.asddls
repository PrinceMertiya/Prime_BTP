@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds view for rap'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSLS_i_demo_Ad as select from zsls_parent_txt
{
    key parent_id as ParentId,
    key language as Language,
    description as Description
}
