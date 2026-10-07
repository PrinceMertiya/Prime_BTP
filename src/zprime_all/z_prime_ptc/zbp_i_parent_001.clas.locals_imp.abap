CLASS lhc_ZI_PARENT_001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zi_parent_001 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zi_parent_001 RESULT result.

    METHODS GenerateUUID FOR DETERMINE ON MODIFY
       keys FOR zi_parent_001~GenerateUUID.

ENDCLASS.

CLASS lhc_ZI_PARENT_001 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GenerateUUID.

  READ ENTITIES OF zi_parent_001 IN LOCAL MODE
    ENTITY zi_parent_001
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_parent).

  MODIFY ENTITIES OF zi_parent_001 IN LOCAL MODE
    ENTITY zi_parent_001
    UPDATE FIELDS ( ParentUuid )
    WITH VALUE #(
      FOR ls_parent IN lt_parent (
        %tky       = ls_parent-%tky
        ParentUuid = cl_system_uuid=>create_uuid_x16_static( )
      )
    ).

ENDMETHOD.
ENDCLASS.
