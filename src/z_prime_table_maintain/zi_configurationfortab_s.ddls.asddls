@EndUserText.label: 'configuration for table Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Semantics.valueRange.maximum: '1'
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'ConfigurationForAll'
  }
}
define root view entity ZI_ConfigurationForTab_S
  as select from I_Language
    left outer join ZSLS_CONFIG_TAB on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_ConfigurationForTab as _ConfigurationForTab
{
  @UI.facet: [ {
    id: 'ConfigurationForTab', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'configuration for table', 
    position: 1 , 
    targetElement: '_ConfigurationForTab'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _ConfigurationForTab,
  @UI.hidden: true
  max( ZSLS_CONFIG_TAB.LAST_CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
