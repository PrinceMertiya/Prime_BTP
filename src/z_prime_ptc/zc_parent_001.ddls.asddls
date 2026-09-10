@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection for parent_001'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_PARENT_001 as projection on ZI_PARENT_001
{
    key ParentUuid,
    ParentId,
    ParentName,
    created_by,
    created_at,
    last_changed_by,
    last_changed_at,
    /* Associations */
    _Child: redirected to composition child ZC_CHILD_001
}
