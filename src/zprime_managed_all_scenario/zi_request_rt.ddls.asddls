
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'request type defintion'
@Search.searchable: true
define view entity ZI_REQUEST_RT as select from zreqtype_vh
{   
    @Search.defaultSearchElement: true
    key req_type as ReqType,
    
    description as Description
}
