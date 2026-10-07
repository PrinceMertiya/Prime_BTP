@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for parent table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSLS_I_Parent_rap as select from ZSLS_PARENT
composition [1..*] of zsls_i_child_rap as _child
{
    key parent_id as ParentId,
    status as Status,
    _child
}
