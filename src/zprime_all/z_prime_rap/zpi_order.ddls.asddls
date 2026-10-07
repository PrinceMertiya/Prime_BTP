@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order cds'

define root view entity ZPI_ORDER as select from zporder_hdr
composition [0..*] of ZPI_ORDER_ITEM as _Item
{
    key order_id as OrderId,
    
    customer_id as CustomerId,
    order_date as OrderDate,
    status as Status,
    
    created_by,
    created_at,
    last_changed_by ,
    last_changed_at,
    
    _Item
    
}
