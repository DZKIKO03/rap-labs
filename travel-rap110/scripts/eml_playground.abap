" Script: eml_playground.abap
" Purpose: Standalone EML test script for Travel & Booking

REPORT z_eml_playground_00b.

DATA travel_keys TYPE TABLE FOR READ IMPORT ZRAP110_R_TravelTP_00B.

" Read travel 0003 (adjust if needed)
travel_keys = VALUE #( ( TravelID = '0003' ) ).

out->write( |*** EML Playground ***| ).

" Read Travel
READ ENTITIES OF ZRAP110_R_TravelTP_00B
  ENTITY Travel
    FIELDS ( TravelID AgencyID CustomerID BeginDate EndDate )
    WITH travel_keys
  RESULT DATA(lt_travels)
  FAILED DATA(failed)
  REPORTED DATA(reported).

IF failed IS NOT INITIAL.
  out->write( |Travel read failed: { failed-travel[ 1 ]-%fail-cause }| ).
ENDIF.

" Read Bookings of Travel
READ ENTITIES OF ZRAP110_R_TravelTP_00B
  ENTITY Travel BY \_Booking
    FROM CORRESPONDING #( lt_travels )
    RESULT DATA(lt_bookings)
  LINK DATA(trav_to_book).

" Execute getDaysToFlight
READ ENTITIES OF ZRAP110_R_TravelTP_00B
  ENTITY Booking
    EXECUTE getDaysToFlight
      FROM VALUE #( FOR link IN trav_to_book ( %tky = link-target-%tky ) )
  RESULT DATA(days).

LOOP AT days ASSIGNING FIELD-SYMBOL(<d>).
  out->write( |Travel={ <d>-%tky-TravelID }, Booking={ <d>-%tky-BookingID }| ).
  out->write( |Remaining={ <d>-%param-Remaining_Days_To_Flight }| ).
  out->write( |Initial={ <d>-%param-Initial_Days_To_Flight }| ).
  out->write( '---' ).
ENDLOOP.
