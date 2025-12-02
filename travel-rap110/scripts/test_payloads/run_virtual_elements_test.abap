" Script: run_virtual_elements_test.abap
" Purpose: Test virtual element logic for Travel & Booking

REPORT z_run_virtual_elements_00b.

DATA booking_keys TYPE TABLE FOR READ IMPORT ZRAP110_R_BookingTP_00B.

" Select a sample Booking
SELECT BookingID, TravelID
  FROM ZRAP110_ABOOK00B
  UP TO 1 ROWS
  INTO @DATA(sample).

IF sy-subrc <> 0.
  out->write( |No booking found in DB.| ).
  RETURN.
ENDIF.

booking_keys = VALUE #( ( TravelID = sample-TravelID
                          BookingID = sample-BookingID ) ).

" Execute getDaysToFlight
READ ENTITIES OF ZRAP110_R_TravelTP_00B
  ENTITY Booking
    EXECUTE getDaysToFlight
      FROM VALUE #( FOR k IN booking_keys ( %tky = VALUE #( TravelID = k-TravelID BookingID = k-BookingID ) ) )
  RESULT DATA(res).

LOOP AT res INTO DATA(r).
  out->write( |Booking={ r-%tky-BookingID }| ).
  out->write( |RemainingDays={ r-%param-Remaining_Days_To_Flight }| ).
  out->write( |InitialDays={ r-%param-Initial_Days_To_Flight }| ).
  out->write( |StatusIndicator={ r-%param-BookingStatusIndicator }| ).
ENDLOOP.
