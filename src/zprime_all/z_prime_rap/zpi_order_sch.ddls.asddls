@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'order sch'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZPI_ORDER_SCH as select from zporder_sch

association to ZPI_ORDER as _Order
  on $projection.OrderId = _Order.OrderId

association to parent ZPI_ORDER_ITEM as _Item
  on $projection.OrderId = _Item.OrderId
 and $projection.ItemNo  = _Item.ItemNo

{
    key order_id    as OrderId,
    key item_no     as ItemNo,
    key schedule_no as ScheduleNo,

    delivery_date   as DeliveryDate,
    quantity        as Quantity,

    created_by,
    created_at,
    last_changed_by,
    last_changed_at,

    _Item,
    _Order
}
