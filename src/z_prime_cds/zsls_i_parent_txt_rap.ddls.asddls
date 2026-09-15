@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Text RAP CDS View'
@Metadata.ignorePropagatedAnnotations: true

define view entity zsls_i_parent_txt_rap
  as select from ZSLS_PARENT_TXT

  association to parent ZSLS_I_Parent_rap as _Parent
    on $projection.ParentId = _Parent.ParentId

{
    key parent_id   as ParentId,
    key language    as Language,
        description as Description,

    _Parent
}
