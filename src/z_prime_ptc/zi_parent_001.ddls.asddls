@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parent Data'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_PARENT_001
  as select from zparent_001

  composition [0..*] of ZI_CHILD_001 as _Child
{
    key parent_uuid as ParentUuid,
    parent_id as ParentId,
    parent_name as ParentName,
    created_by,
    created_at,
    last_changed_by,
    last_changed_at,

    _Child
}
