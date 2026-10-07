@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'order interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zpsls_i_order_hrh as select from zpsls_order_hrh

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
