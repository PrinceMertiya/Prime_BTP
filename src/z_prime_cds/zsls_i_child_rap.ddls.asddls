@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'child table cds'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsls_i_child_rap as select from ZSLS_CHILD

association to parent ZSLS_I_Parent_rap as _parent
  on $projection.ParentId = _parent.ParentId
association [0..*] to zsls_i_parent_txt_rap as _txt
    on $projection.parentId = _txt.ParentId 
 
{
    key parent_id as ParentId,
    key child_id as ChildId,
    description as Description,
    _parent,
    _txt
}
