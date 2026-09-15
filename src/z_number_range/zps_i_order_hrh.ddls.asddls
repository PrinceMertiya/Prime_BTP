@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface for order table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZPS_I_ORDER_HRH as select from zps_order_hrh

{
    key order_id as OrderId,
    order_name as OrderName,
    order_type as OrderType,
    order_date as OrderDate,
    status as Status,
    
    cuky_field as CukyField,
    @Semantics.amount.currencyCode : 'CukyField'
    amount as Amount,
    @Semantics.user.createdBy:true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt
    
}
