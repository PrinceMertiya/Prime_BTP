@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PROJECTION VIEW FOR STUDENT'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZPC_STUDENT  provider contract transactional_query as  projection on ZPI_Student
{
    
    key student_id,
          name,
          city,
          created_by,
          created_at,
          changed_by,
          changed_at
}
    
    
    
