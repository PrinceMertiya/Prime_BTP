@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'table for order item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZPI_ORDER_ITEM as select from zporder_item

association to parent ZPI_ORDER as _Order
on $projection.OrderId = _Order.OrderId

composition [0..*] of ZPI_ORDER_SCH as _Schedule
{
    
    key order_id as OrderId,
    key item_no as ItemNo,
    material as Material,
    quantity as Quantity,
    
    
    created_by,
    created_at,
    last_changed_by,
    last_changed_at,
    
    _Order,
    _Schedule
}
