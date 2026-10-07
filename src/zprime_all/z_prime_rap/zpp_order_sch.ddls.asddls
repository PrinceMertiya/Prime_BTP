@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection for order sch'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZPP_ORDER_SCH as projection on ZPI_ORDER_SCH
{
    key OrderId,
    key ItemNo,
    key ScheduleNo,
    DeliveryDate,
    Quantity,
    
    _Item : redirected to parent ZPP_ORDER_ITEM,
   _Order : redirected to  ZPP_ORDER
   
}
