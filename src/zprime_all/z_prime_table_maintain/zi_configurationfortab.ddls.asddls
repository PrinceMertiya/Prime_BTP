@EndUserText.label: 'configuration for table'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_ConfigurationForTab
  as select from ZSLS_CONFIG_TAB
  association to parent ZI_ConfigurationForTab_S as _ConfigurationForAll on $projection.SingletonID = _ConfigurationForAll.SingletonID
{
  key CONFIG_ID as ConfigId,
  DESCRIPTION as Description,
  CONFIG_ACTIVE as ConfigActive,
  @Semantics.user.createdBy: true
  LOCAL_CREATED_BY as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  LOCAL_CREATED_AT as LocalCreatedAt,
  @Semantics.user.lastChangedBy: true
  LOCAL_LAST_CHANGED_BY as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  LOCAL_LAST_LASTCHANGED as LocalLastLastchanged,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _ConfigurationForAll
}
