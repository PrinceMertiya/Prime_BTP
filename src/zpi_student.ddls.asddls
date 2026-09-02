@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'student data manipulation'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZPI_Student as select from zpstudent
{
    key student_id,
      name,
      city,
      created_by,
      created_at,
      changed_by,
      changed_at
        
}

