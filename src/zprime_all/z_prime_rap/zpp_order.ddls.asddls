@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order for projection'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZPP_ORDER as projection on ZPI_ORDER
{
    key OrderId,
    CustomerId,
    OrderDate,
    Status,
    
    _Item : redirected to composition child ZPP_ORDER_ITEM
    
    
}
