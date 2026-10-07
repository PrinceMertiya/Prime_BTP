@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'child projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_CHILD_001 as projection on ZI_CHILD_001
{
    key ChildUuid,
    ParentUuid,
    ChildId,
    child_name,
    created_by,
    created_at,
    last_changed_by,
    last_changed_at,
    /* Associations */
    _Parent: redirected to parent ZC_PARENT_001
}
