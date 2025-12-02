class ZRAP110_BP_TRAVELTP_00B definition
  public
  abstract
  final
  for behavior of ZRAP110_R_TRAVELTP_00B .

public section.
protected section.
private section.
ENDCLASS.



CLASS ZRAP110_BP_TRAVELTP_00B IMPLEMENTATION.
ENDCLASS.

**********************************************************************
**  Local Saver Class of Travel BO entity                           **
**********************************************************************
CLASS lsc_zrap110_r_traveltp_00B DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.

  PROTECTED SECTION.
    CONSTANTS:
      BEGIN OF TRAVEL_STATUS,
        OPEN     TYPE C LENGTH 1 VALUE 'O', "Open
        ACCEPTED TYPE C LENGTH 1 VALUE 'A', "Accepted
        REJECTED TYPE C LENGTH 1 VALUE 'X', "Rejected
      END OF TRAVEL_STATUS.

    METHODS SAVE_MODIFIED REDEFINITION.

    METHODS ADJUST_NUMBERS REDEFINITION.

ENDCLASS.

CLASS lsc_zrap110_r_traveltp_00B IMPLEMENTATION.

  METHOD ADJUST_NUMBERS.

    DATA: TRAVEL_ID_MAX TYPE /DMO/TRAVEL_ID.

    "Root BO entity: Travel
    IF MAPPED-TRAVEL IS NOT INITIAL.
      TRY.
          "get numbers
          CL_NUMBERRANGE_RUNTIME=>NUMBER_GET(
            EXPORTING
              NR_RANGE_NR       = '01'
              OBJECT            = 'ZRAP11000B'   "'ZRAP110###'
              QUANTITY          = CONV #( LINES( MAPPED-TRAVEL ) )
            IMPORTING
              NUMBER            = DATA(NUMBER_RANGE_KEY)
              RETURNCODE        = DATA(NUMBER_RANGE_RETURN_CODE)
              RETURNED_QUANTITY = DATA(NUMBER_RANGE_RETURNED_QUANTITY)
          ).
        CATCH CX_NUMBER_RANGES INTO DATA(LX_NUMBER_RANGES).
          RAISE SHORTDUMP TYPE CX_NUMBER_RANGES
            EXPORTING
              PREVIOUS = LX_NUMBER_RANGES.
      ENDTRY.

      ASSERT NUMBER_RANGE_RETURNED_QUANTITY = LINES( MAPPED-TRAVEL ).
      TRAVEL_ID_MAX = NUMBER_RANGE_KEY - NUMBER_RANGE_RETURNED_QUANTITY.
      LOOP AT MAPPED-TRAVEL ASSIGNING FIELD-SYMBOL(<TRAVEL>).
        TRAVEL_ID_MAX += 1.
        <TRAVEL>-TravelID = TRAVEL_ID_MAX.
      ENDLOOP.
    ENDIF.
    "--------------insert the code for the booking entity below ---------

    "Child BO entity: Booking
    IF MAPPED-BOOKING IS NOT INITIAL.
      READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
        ENTITY Booking BY \_Travel
          FROM VALUE #( FOR BOOKING IN MAPPED-BOOKING WHERE ( %TMP-TravelID IS INITIAL )
                                                            ( %PID = BOOKING-%PID
                                                              %KEY = BOOKING-%TMP ) )
        LINK DATA(BOOKING_TO_TRAVEL_LINKS).

      LOOP AT MAPPED-BOOKING ASSIGNING FIELD-SYMBOL(<BOOKING>).
        <BOOKING>-TravelID =
          COND #( WHEN <BOOKING>-%TMP-TravelID IS INITIAL
                  THEN MAPPED-TRAVEL[ %PID = BOOKING_TO_TRAVEL_LINKS[ SOURCE-%PID = <BOOKING>-%PID ]-TARGET-%PID ]-TravelID
                  ELSE <BOOKING>-%TMP-TravelID ).
      ENDLOOP.

      LOOP AT MAPPED-BOOKING INTO DATA(MAPPED_BOOKING) GROUP BY MAPPED_BOOKING-TravelID.
        SELECT MAX( BOOKING_ID ) FROM zrap110_abook00B WHERE TRAVEL_ID = @MAPPED_BOOKING-TravelID INTO @DATA(MAX_BOOKING_ID) .
        LOOP AT GROUP MAPPED_BOOKING ASSIGNING <BOOKING>.
          MAX_BOOKING_ID += 10.
          <BOOKING>-BookingID = MAX_BOOKING_ID.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD SAVE_MODIFIED.
    "send notification for all accepted and rejected travel instances
    IF UPDATE IS NOT INITIAL.

      "raise event
      RAISE ENTITY EVENT ZRAP110_R_TravelTP_00B~TRAVEL_ACCEPTED
       FROM VALUE #(
         FOR TRAVEL IN UPDATE-TRAVEL
         WHERE ( %CONTROL-OverallStatus EQ IF_ABAP_BEHV=>MK-ON AND
                 OverallStatus          EQ TRAVEL_STATUS-ACCEPTED )
           "transferred information
           ( %KEY           = TRAVEL-%KEY
             TRAVEL_ID      = TRAVEL-TravelID
             AGENCY_ID      = TRAVEL-AgencyID
             CUSTOMER_ID    = TRAVEL-CustomerID
             OVERALL_STATUS = TRAVEL-OverallStatus
             DESCRIPTION    = TRAVEL-Description
             TOTAL_PRICE    = TRAVEL-TotalPrice
             CURRENCY_CODE  = TRAVEL-CurrencyCode
             BEGIN_DATE     = TRAVEL-BeginDate
             END_DATE       = TRAVEL-EndDate
           )
         ).

      "raise event
      RAISE ENTITY EVENT ZRAP110_R_TravelTP_00B~TRAVEL_REJECTED
       FROM VALUE #(
         FOR TRAVEL IN UPDATE-TRAVEL
         WHERE ( %CONTROL-OverallStatus EQ IF_ABAP_BEHV=>MK-ON AND
                 OverallStatus          EQ TRAVEL_STATUS-REJECTED )
           "transferred information
            ( %KEY = TRAVEL-%KEY )
         ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.


**********************************************************************
**  Local Handler Class of Travel BO entity                         **
**********************************************************************
CLASS LHC_TRAVEL DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.

    CONSTANTS:
      "travel status
      BEGIN OF TRAVEL_STATUS,
        OPEN     TYPE C LENGTH 1 VALUE 'O', "Open
        ACCEPTED TYPE C LENGTH 1 VALUE 'A', "Accepted
        REJECTED TYPE C LENGTH 1 VALUE 'X', "Rejected
      END OF TRAVEL_STATUS.

    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST REQUESTED_AUTHORIZATIONS FOR Travel
        RESULT RESULT,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING KEYS REQUEST REQUESTED_FEATURES FOR Travel RESULT RESULT.

    METHODS acceptTravel FOR MODIFY
      IMPORTING KEYS FOR ACTION Travel~acceptTravel RESULT RESULT.

    METHODS createTravel FOR MODIFY
      IMPORTING KEYS FOR ACTION Travel~createTravel.

    METHODS recalcTotalPrice FOR MODIFY
      IMPORTING KEYS FOR ACTION Travel~recalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING KEYS FOR ACTION Travel~rejectTravel RESULT RESULT.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING KEYS FOR Travel~calculateTotalPrice.

    METHODS setInitialTravelValues FOR DETERMINE ON MODIFY
      IMPORTING KEYS FOR Travel~setInitialTravelValues.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING KEYS FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING KEYS FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING KEYS FOR Travel~validateDates.
ENDCLASS.

CLASS LHC_TRAVEL IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
**************************************************************************
* Instance-bound dynamic feature control
**************************************************************************
  METHOD GET_INSTANCE_FEATURES.
    " read relevant travel instance data
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
      ENTITY TRAVEL
         FIELDS ( TravelID OverallStatus )
         WITH CORRESPONDING #( KEYS )
       RESULT DATA(TRAVELS)
       FAILED FAILED.

    " evaluate the conditions, set the operation state, and set result parameter
    RESULT = VALUE #( FOR TRAVEL IN TRAVELS
                       ( %TKY                   = TRAVEL-%TKY

                         %FEATURES-%UPDATE      = COND #( WHEN TRAVEL-OverallStatus = TRAVEL_STATUS-ACCEPTED
                                                          THEN IF_ABAP_BEHV=>FC-O-DISABLED ELSE IF_ABAP_BEHV=>FC-O-ENABLED   )

                         %FEATURES-%DELETE      = COND #( WHEN TRAVEL-OverallStatus = TRAVEL_STATUS-OPEN
                                                          THEN IF_ABAP_BEHV=>FC-O-ENABLED ELSE IF_ABAP_BEHV=>FC-O-DISABLED   )

                         %ACTION-Edit           = COND #( WHEN TRAVEL-OverallStatus = TRAVEL_STATUS-ACCEPTED
                                                            THEN IF_ABAP_BEHV=>FC-O-DISABLED ELSE IF_ABAP_BEHV=>FC-O-ENABLED   )

                         %ACTION-acceptTravel   = COND #( WHEN TRAVEL-OverallStatus = TRAVEL_STATUS-ACCEPTED
                                                              THEN IF_ABAP_BEHV=>FC-O-DISABLED ELSE IF_ABAP_BEHV=>FC-O-ENABLED   )

                         %ACTION-rejectTravel   = COND #( WHEN TRAVEL-OverallStatus = TRAVEL_STATUS-REJECTED
                                                            THEN IF_ABAP_BEHV=>FC-O-DISABLED ELSE IF_ABAP_BEHV=>FC-O-ENABLED   )
                      ) ).
  ENDMETHOD.




**************************************************************************
* Instance-bound action acceptTravel
**************************************************************************
  METHOD acceptTravel.
    MODIFY ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
         ENTITY TRAVEL
            UPDATE FIELDS ( OverallStatus )
               WITH VALUE #( FOR KEY IN KEYS ( %TKY         = KEY-%TKY
                                               OverallStatus = TRAVEL_STATUS-ACCEPTED ) ). " 'A' Accepted

    " read changed data for result
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
      ENTITY TRAVEL
         ALL FIELDS WITH
         CORRESPONDING #( KEYS )
       RESULT DATA(TRAVELS).

    RESULT = VALUE #( FOR TRAVEL IN TRAVELS ( %TKY = TRAVEL-%TKY  %PARAM = TRAVEL ) ).
  ENDMETHOD.

**************************************************************************
* static default factory action createTravel
**************************************************************************
  METHOD createTravel.

    IF KEYS IS NOT INITIAL.
      SELECT * FROM /DMO/FLIGHT FOR ALL ENTRIES IN @KEYS WHERE CARRIER_ID    = @KEYS-%PARAM-CARRIER_ID
                                                         AND   CONNECTION_ID = @KEYS-%PARAM-CONNECTION_ID
                                                         AND   FLIGHT_DATE   = @KEYS-%PARAM-FLIGHT_DATE
                                                         INTO TABLE @DATA(FLIGHTS).

      "create travel instances with default bookings
      MODIFY ENTITIES OF ZRAP110_R_TRAVELTP_00B IN LOCAL MODE
        ENTITY Travel
          CREATE
            FIELDS ( CustomerID Description )
              WITH VALUE #( FOR KEY IN KEYS ( %CID = KEY-%CID
                                              %IS_DRAFT = KEY-%PARAM-%IS_DRAFT
                                              CustomerID = KEY-%PARAM-CUSTOMER_ID
                                              Description = 'Own Create Implementation' ) )
          CREATE BY \_Booking
            FIELDS ( CustomerID CarrierID ConnectionID FlightDate FlightPrice CurrencyCode )
              WITH VALUE #( FOR KEY IN KEYS INDEX INTO I
                          ( %CID_REF  = KEY-%CID
                            %IS_DRAFT = KEY-%PARAM-%IS_DRAFT
                            %TARGET   = VALUE #( ( %CID         = I
                                                   %IS_DRAFT    = KEY-%PARAM-%IS_DRAFT
                                                   CustomerID   = KEY-%PARAM-CUSTOMER_ID
                                                   CarrierID    = KEY-%PARAM-CARRIER_ID
                                                   ConnectionID = KEY-%PARAM-CONNECTION_ID
                                                   FlightDate   = KEY-%PARAM-FLIGHT_DATE
                                                   FlightPrice  = VALUE #( FLIGHTS[ CARRIER_ID    = KEY-%PARAM-CARRIER_ID
                                                                                    CONNECTION_ID = KEY-%PARAM-CONNECTION_ID
                                                                                    FLIGHT_DATE   = KEY-%PARAM-FLIGHT_DATE ]-PRICE OPTIONAL )
                                                   CurrencyCode = VALUE #( FLIGHTS[ CARRIER_ID    = KEY-%PARAM-CARRIER_ID
                                                                                    CONNECTION_ID = KEY-%PARAM-CONNECTION_ID
                                                                                    FLIGHT_DATE   = KEY-%PARAM-FLIGHT_DATE ]-CURRENCY_CODE OPTIONAL )
                          ) ) ) )
      MAPPED MAPPED.
    ENDIF.

  ENDMETHOD.

**************************************************************************
* Internal instance-bound action calculateTotalPrice
**************************************************************************
  METHOD reCalctotalprice.
    TYPES: BEGIN OF TY_AMOUNT_PER_CURRENCYCODE,
             AMOUNT        TYPE /DMO/TOTAL_PRICE,
             CURRENCY_CODE TYPE /DMO/CURRENCY_CODE,
           END OF TY_AMOUNT_PER_CURRENCYCODE.

    DATA: AMOUNTS_PER_CURRENCYCODE TYPE STANDARD TABLE OF TY_AMOUNT_PER_CURRENCYCODE.

    " Read all relevant travel instances.
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
         ENTITY Travel
            FIELDS ( BookingFee CurrencyCode )
            WITH CORRESPONDING #( KEYS )
         RESULT DATA(TRAVELS).

    DELETE TRAVELS WHERE CurrencyCode IS INITIAL.

    " Read all associated bookings and add them to the total price.
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
      ENTITY Travel BY \_Booking
        FIELDS ( FlightPrice CurrencyCode )
      WITH CORRESPONDING #( TRAVELS )
      LINK DATA(BOOKING_LINKS)
      RESULT DATA(BOOKINGS).

    LOOP AT TRAVELS ASSIGNING FIELD-SYMBOL(<TRAVEL>).
      " Set the start for the calculation by adding the booking fee.
      AMOUNTS_PER_CURRENCYCODE = VALUE #( ( AMOUNT        = <TRAVEL>-BOOKINGFEE
                                            CURRENCY_CODE = <TRAVEL>-CURRENCYCODE ) ).

      LOOP AT BOOKING_LINKS INTO DATA(BOOKING_LINK) USING KEY ID WHERE SOURCE-%TKY = <TRAVEL>-%TKY.
        " Short dump occurs if link table does not match read table, which must never happen
        DATA(BOOKING) = BOOKINGS[ KEY ID  %TKY = BOOKING_LINK-TARGET-%TKY ].
        COLLECT VALUE TY_AMOUNT_PER_CURRENCYCODE( AMOUNT        = BOOKING-FLIGHTPRICE
                                                  CURRENCY_CODE = BOOKING-CURRENCYCODE ) INTO AMOUNTS_PER_CURRENCYCODE.
      ENDLOOP.

      DELETE AMOUNTS_PER_CURRENCYCODE WHERE CURRENCY_CODE IS INITIAL.

      CLEAR <TRAVEL>-TotalPrice.
      LOOP AT AMOUNTS_PER_CURRENCYCODE INTO DATA(AMOUNT_PER_CURRENCYCODE).
        " If needed do a Currency Conversion
        IF AMOUNT_PER_CURRENCYCODE-CURRENCY_CODE = <TRAVEL>-CurrencyCode.
          <TRAVEL>-TotalPrice += AMOUNT_PER_CURRENCYCODE-AMOUNT.
        ELSE.
          /DMO/CL_FLIGHT_AMDP=>CONVERT_CURRENCY(
             EXPORTING
               IV_AMOUNT                   =  AMOUNT_PER_CURRENCYCODE-AMOUNT
               IV_CURRENCY_CODE_SOURCE     =  AMOUNT_PER_CURRENCYCODE-CURRENCY_CODE
               IV_CURRENCY_CODE_TARGET     =  <TRAVEL>-CurrencyCode
               IV_EXCHANGE_RATE_DATE       =  CL_ABAP_CONTEXT_INFO=>GET_SYSTEM_DATE( )
             IMPORTING
               EV_AMOUNT                   = DATA(TOTAL_BOOKING_PRICE_PER_CURR)
            ).
          <TRAVEL>-TotalPrice += TOTAL_BOOKING_PRICE_PER_CURR.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " write back the modified total_price of travels
    MODIFY ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
      ENTITY TRAVEL
        UPDATE FIELDS ( TotalPrice )
        WITH CORRESPONDING #( TRAVELS ).

  ENDMETHOD.

**************************************************************************
* Instance-bound action rejectTravel
**************************************************************************
  METHOD rejectTravel.
    MODIFY ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
         ENTITY TRAVEL
            UPDATE FIELDS ( OverallStatus )
               WITH VALUE #( FOR KEY IN KEYS ( %TKY         = KEY-%TKY
                                               OverallStatus = TRAVEL_STATUS-REJECTED ) ). " 'X' Rejected

    " read changed data for result
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
      ENTITY TRAVEL
         ALL FIELDS WITH
         CORRESPONDING #( KEYS )
       RESULT DATA(TRAVELS).

    RESULT = VALUE #( FOR TRAVEL IN TRAVELS ( %TKY = TRAVEL-%TKY  %PARAM = TRAVEL ) ).
  ENDMETHOD.

**************************************************************************
* determination calculateTotalPrice
**************************************************************************
  METHOD calculateTotalPrice.
    MODIFY ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
      ENTITY Travel
        EXECUTE reCalcTotalPrice
        FROM CORRESPONDING #( KEYS ).

  ENDMETHOD.

**************************************************************************
* determination setInitialTravelValues: BeginDate, EndDate
**************************************************************************
  METHOD setInitialTravelValues.

    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
    ENTITY Travel
      FIELDS ( BeginDate EndDate CurrencyCode OverallStatus )
      WITH CORRESPONDING #( KEYS )
    RESULT DATA(TRAVELS).

    DATA: UPDATE TYPE TABLE FOR UPDATE zrap110_r_traveltp_00B\\Travel.
    UPDATE = CORRESPONDING #( TRAVELS ).
    DELETE UPDATE WHERE BeginDate IS NOT INITIAL AND EndDate IS NOT INITIAL
                    AND CurrencyCode IS NOT INITIAL AND OverallStatus IS NOT INITIAL.

    LOOP AT UPDATE ASSIGNING FIELD-SYMBOL(<UPDATE>).
      IF <UPDATE>-BeginDate IS INITIAL.
        <UPDATE>-BeginDate     = CL_ABAP_CONTEXT_INFO=>GET_SYSTEM_DATE( ) + 1.
        <UPDATE>-%CONTROL-BeginDate = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
      IF <UPDATE>-EndDate  IS INITIAL.
        <UPDATE>-EndDate       = CL_ABAP_CONTEXT_INFO=>GET_SYSTEM_DATE( ) + 15.
        <UPDATE>-%CONTROL-EndDate = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
      IF <UPDATE>-CurrencyCode IS INITIAL.
        <UPDATE>-CurrencyCode  = 'EUR'.
        <UPDATE>-%CONTROL-CurrencyCode = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
      IF <UPDATE>-OverallStatus IS INITIAL.
        <UPDATE>-OverallStatus = TRAVEL_STATUS-OPEN.
        <UPDATE>-%CONTROL-OverallStatus = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
    ENDLOOP.

    IF UPDATE IS NOT INITIAL.
      MODIFY ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
      ENTITY Travel
        UPDATE FROM UPDATE.
    ENDIF.

  ENDMETHOD.

**************************************************************************
* Validation for AgencyID
**************************************************************************
  METHOD validateAgency.
    " Read relevant travel instance data
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
    ENTITY TRAVEL
     FIELDS ( AgencyID )
     WITH CORRESPONDING #(  KEYS )
    RESULT DATA(TRAVELS).

    DATA AGENCIES TYPE SORTED TABLE OF /DMO/AGENCY WITH UNIQUE KEY AGENCY_ID.

    " Optimization of DB select: extract distinct non-initial agency IDs
    AGENCIES = CORRESPONDING #( TRAVELS DISCARDING DUPLICATES MAPPING AGENCY_ID = AgencyID EXCEPT * ).
    DELETE AGENCIES WHERE AGENCY_ID IS INITIAL.

    IF  AGENCIES IS NOT INITIAL.
      " check if agency ID exist
      SELECT FROM /DMO/AGENCY FIELDS AGENCY_ID
        FOR ALL ENTRIES IN @AGENCIES
        WHERE AGENCY_ID = @AGENCIES-AGENCY_ID
        INTO TABLE @DATA(AGENCIES_DB).
    ENDIF.

    " Raise msg for non existing and initial agency id
    LOOP AT TRAVELS INTO DATA(TRAVEL).
      APPEND VALUE #(  %TKY        = TRAVEL-%TKY
                       %STATE_AREA = 'VALIDATE_AGENCY'
                     ) TO REPORTED-TRAVEL.

      IF TRAVEL-AgencyID IS INITIAL OR NOT LINE_EXISTS( AGENCIES_DB[ AGENCY_ID = TRAVEL-AgencyID ] ).
        APPEND VALUE #(  %TKY = TRAVEL-%TKY ) TO FAILED-TRAVEL.
        APPEND VALUE #(  %TKY = TRAVEL-%TKY
                         %STATE_AREA = 'VALIDATE_AGENCY'
                         %MSG = NEW /DMO/CM_FLIGHT_MESSAGES(
                                          TEXTID    = /DMO/CM_FLIGHT_MESSAGES=>AGENCY_UNKOWN
                                          AGENCY_ID = TRAVEL-AgencyID
                                          SEVERITY  = IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR )
                         %ELEMENT-AgencyID = IF_ABAP_BEHV=>MK-ON
                      ) TO REPORTED-TRAVEL.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

**************************************************************************
* Validation for CustomerID
**************************************************************************
  METHOD validateCustomer.
    "read relevant travel instance data
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
    ENTITY Travel
     FIELDS ( CustomerID )
     WITH CORRESPONDING #( KEYS )
    RESULT DATA(TRAVELS).

    DATA CUSTOMERS TYPE SORTED TABLE OF /DMO/CUSTOMER WITH UNIQUE KEY CUSTOMER_ID.

    "optimization of DB select: extract distinct non-initial customer IDs
    CUSTOMERS = CORRESPONDING #( TRAVELS DISCARDING DUPLICATES MAPPING CUSTOMER_ID = customerID EXCEPT * ).
    DELETE CUSTOMERS WHERE CUSTOMER_ID IS INITIAL.

    IF CUSTOMERS IS NOT INITIAL.
      "check if customer ID exists
      SELECT FROM /DMO/CUSTOMER FIELDS CUSTOMER_ID
                                FOR ALL ENTRIES IN @CUSTOMERS
                                WHERE CUSTOMER_ID = @CUSTOMERS-CUSTOMER_ID
        INTO TABLE @DATA(VALID_CUSTOMERS).
    ENDIF.

    "raise msg for non existing and initial customer id
    LOOP AT TRAVELS INTO DATA(TRAVEL).
      APPEND VALUE #(  %TKY        = TRAVEL-%TKY
                       %STATE_AREA = 'VALIDATE_CUSTOMER'
                     ) TO REPORTED-TRAVEL.

      IF TRAVEL-CustomerID IS  INITIAL.
        APPEND VALUE #( %TKY = TRAVEL-%TKY ) TO FAILED-TRAVEL.

        APPEND VALUE #( %TKY        = TRAVEL-%TKY
                        %STATE_AREA = 'VALIDATE_CUSTOMER'
                        %MSG        = NEW /DMO/CM_FLIGHT_MESSAGES(
                                        TEXTID   = /DMO/CM_FLIGHT_MESSAGES=>ENTER_CUSTOMER_ID
                                        SEVERITY = IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR )
                        %ELEMENT-CustomerID = IF_ABAP_BEHV=>MK-ON
                      ) TO REPORTED-TRAVEL.

      ELSEIF TRAVEL-CustomerID IS NOT INITIAL AND NOT LINE_EXISTS( VALID_CUSTOMERS[ CUSTOMER_ID = TRAVEL-CustomerID ] ).
        APPEND VALUE #(  %TKY = TRAVEL-%TKY ) TO FAILED-TRAVEL.

        APPEND VALUE #(  %TKY        = TRAVEL-%TKY
                         %STATE_AREA = 'VALIDATE_CUSTOMER'
                         %MSG        = NEW /DMO/CM_FLIGHT_MESSAGES(
                                         CUSTOMER_ID = TRAVEL-CUSTOMERID
                                         TEXTID      = /DMO/CM_FLIGHT_MESSAGES=>CUSTOMER_UNKOWN
                                         SEVERITY    = IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR )
                         %ELEMENT-CustomerID = IF_ABAP_BEHV=>MK-ON
                      ) TO REPORTED-TRAVEL.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

**************************************************************************
* Validation for BeginDate and EndDate
**************************************************************************
  METHOD validateDates.
    READ ENTITIES OF ZRAP110_R_TravelTP_00B IN LOCAL MODE
       ENTITY TRAVEL
         FIELDS ( BeginDate EndDate )
         WITH CORRESPONDING #( KEYS )
       RESULT DATA(TRAVELS).

    LOOP AT TRAVELS INTO DATA(TRAVEL).
      APPEND VALUE #(  %TKY        = TRAVEL-%TKY
                       %STATE_AREA = 'VALIDATE_DATES' ) TO REPORTED-TRAVEL.

      IF TRAVEL-EndDate < TRAVEL-BeginDate.                                 "end_date before begin_date
        APPEND VALUE #( %TKY = TRAVEL-%TKY ) TO FAILED-TRAVEL.
        APPEND VALUE #( %TKY = TRAVEL-%TKY
                        %STATE_AREA = 'VALIDATE_DATES'
                        %MSG = NEW /DMO/CM_FLIGHT_MESSAGES(
                                   TEXTID     = /DMO/CM_FLIGHT_MESSAGES=>BEGIN_DATE_BEF_END_DATE
                                   SEVERITY   = IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR
                                   BEGIN_DATE = TRAVEL-BeginDate
                                   END_DATE   = TRAVEL-EndDate
                                   TRAVEL_ID  = TRAVEL-TravelID )
                        %ELEMENT-BeginDate    = IF_ABAP_BEHV=>MK-ON
                        %ELEMENT-EndDate      = IF_ABAP_BEHV=>MK-ON
                     ) TO REPORTED-TRAVEL.

      ELSEIF TRAVEL-BeginDate < CL_ABAP_CONTEXT_INFO=>GET_SYSTEM_DATE( ).  "begin_date must be in the future
        APPEND VALUE #( %TKY        = TRAVEL-%TKY ) TO FAILED-TRAVEL.
        APPEND VALUE #( %TKY = TRAVEL-%TKY
                        %STATE_AREA = 'VALIDATE_DATES'
                        %MSG = NEW /DMO/CM_FLIGHT_MESSAGES(
                                    TEXTID   = /DMO/CM_FLIGHT_MESSAGES=>BEGIN_DATE_ON_OR_BEF_SYSDATE
                                    SEVERITY = IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR )
                        %ELEMENT-BeginDate  = IF_ABAP_BEHV=>MK-ON
                        %ELEMENT-EndDate    = IF_ABAP_BEHV=>MK-ON
                      ) TO REPORTED-TRAVEL.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
