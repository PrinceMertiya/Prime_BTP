@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'child interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CHILD_001 as select from zchild_tab

association to parent ZI_PARENT_001 as _Parent

on $projection.ParentUuid = _Parent.ParentUuid
{
    key child_uuid as ChildUuid,
    parent_uuid as ParentUuid,
    child_id as ChildId,
    child_name,
    created_by,
    created_at,
    last_changed_by,
    last_changed_at,
    
    _Parent
}
