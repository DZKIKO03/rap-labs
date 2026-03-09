CLASS zcl_017_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070000'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00009808'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_017_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    READ ENTITIES OF z017_r_travel
    ENTITY travel
    ALL FIELDS WITH  VALUE #( (   AgencyId = c_agency_id
                                  TravelId = c_travel_id ) )
    RESULT DATA(travels)
    FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      out->write( 'Error' ).
    ELSE.

      MODIFY ENTITIES OF z017_r_travel
      ENTITY travel
      UPDATE FIELDS ( description )
      WITH VALUE #( ( AgencyId = c_agency_id
                      TravelId = c_travel_id
                      description = 'Travel in past' ) )
      FAILED failed.

      IF failed IS NOT INITIAL.
        out->write( 'Error' ).
        ROLLBACK ENTITIES.
      ELSE.
        out->write( 'Success' ).
        COMMIT ENTITIES.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
