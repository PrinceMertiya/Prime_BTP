@EndUserText.label: 'Reject Sales Order Parameter'
define abstract entity ZPS_SO_REJECT
 
{
    @EndUserText.label: 'Rejection Reason'
    reason : abap.char(100);
    
}
