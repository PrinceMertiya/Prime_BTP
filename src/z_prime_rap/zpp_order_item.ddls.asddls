@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection for order item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZPP_ORDER_ITEM as projection on ZPI_ORDER_ITEM
{
    key OrderId,
    key ItemNo,
    Material,
    Quantity,
    
    
    _Order : redirected to parent ZPP_ORDER,
    
     
    _Schedule : redirected to composition child ZPP_ORDER_SCH
}
