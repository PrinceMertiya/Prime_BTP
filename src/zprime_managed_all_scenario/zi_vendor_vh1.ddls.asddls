@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Value Help'
@Search.searchable: true

define view entity ZI_VENDOR_VH1
  as select from zvendor_vh
{
  key vendor_id as Vendor,

  @Search.defaultSearchElement: true
  vendor_name as VendorName
}
