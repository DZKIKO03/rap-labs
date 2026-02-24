CLASS zcl_017_solution DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_017_solution IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    CONSTANTS c_carrier_id TYPE /dmo/carrier_id VALUE 'UA'.

    TRY.
*        DATA(carrier) = NEW lcl_carrier(  i_carrier_id = c_carrier_id ).
        DATA(carrier) = lcl_carrier=>get_instance(
                          i_carrier_id   = c_carrier_id
                        ).

        out->write(  name = `Carrier Overview`
                     data = carrier->get_output(  ) ).

*      CATCH cx_abap_invalid_value INTO DATA(exc_inv).
*        out->write( exc_inv->get_text( ) ).
*      CATCH cx_abap_auth_check_exception INTO DATA(exc_auth).
*        out->write( exc_auth->get_text( ) ).
      CATCH zcx_017_failed INTO DATA(exc).
        out->write( exc->get_text( ) ).
    ENDTRY.

    IF carrier IS BOUND.

      out->write(  `--------------------------------------------------` ).

* Find a passenger flight from Frankfurt to New York
* starting as soon as possible after tomorrow
* with at least 5 free seats

      DATA(today) = cl_abap_context_info=>get_system_date(  ).

      carrier->find_passenger_flight(
         EXPORTING
           i_airport_from_id = 'FRA'
           i_airport_to_id   = 'JFK'
           i_from_date       = today
           i_seats           = 5
         IMPORTING
           e_flight =     DATA(pass_flight)
           e_days_later = DATA(days_later)
                         ).

      IF pass_flight IS BOUND.
        out->write( name = |Found a suitable passenger flight in { days_later } days:|
                    data = pass_flight->get_description( ) ).
      ELSE.
        out->write( data = `No Passenger Flight found` ).
      ENDIF.

      out->write(  `--------------------------------------------------` ).

** Find a cargo flight from Frankfurt to New York
** starting as soon as possible but earliest in 7 days
** with at least 1200 KG free capacity
*
      carrier->find_cargo_flight(
         EXPORTING
           i_airport_from_id = 'FRA'
           i_airport_to_id   = 'JFK'
           i_from_date       = today
           i_cargo           = 1200
         IMPORTING
           e_flight =     DATA(cargo_flight)
           e_days_later = DATA(days_later2)
                         ).

      IF cargo_flight IS BOUND.
        out->write( name = |Found a suitable cargo flight in { days_later2 } days:|
                    data = cargo_flight->get_description( ) ).
      ELSE.
        out->write( data = `No cargo flight found` ).
      ENDIF.



    ENDIF.
  ENDMETHOD.
ENDCLASS.


*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations


INTERFACE lif_output.
  TYPES t_output TYPE c LENGTH 43.
  TYPES tt_output TYPE STANDARD TABLE OF t_output
                  WITH NON-UNIQUE DEFAULT KEY.
  METHODS get_output RETURNING VALUE(r_result) TYPE tt_output.
ENDINTERFACE.

CLASS lcl_flight DEFINITION ABSTRACT.

  PUBLIC SECTION.
    INTERFACES lif_output.
    TYPES: tab TYPE STANDARD TABLE OF REF TO lcl_flight WITH DEFAULT KEY,
           BEGIN OF st_connection_details,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             departure_time  TYPE /dmo/flight_departure_time,
             arrival_time    TYPE /dmo/flight_departure_time,
             duration        TYPE i,
           END OF st_connection_details.
    DATA carrier_id    TYPE /dmo/carrier_id       READ-ONLY.
    DATA connection_id TYPE /dmo/connection_id    READ-ONLY.
    DATA flight_date   TYPE /dmo/flight_date      READ-ONLY.


    METHODS
      get_description RETURNING VALUE(r_result) TYPE string_table.

    METHODS
      constructor
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
          i_connection_id TYPE /dmo/connection_id
          i_flight_date   TYPE /dmo/flight_date.
    METHODS: get_connection_details
      RETURNING
        VALUE(r_result) TYPE st_connection_details.

  PROTECTED SECTION.
    DATA connection_details TYPE st_connection_details.
    DATA planetype TYPE /dmo/plane_type_id.



  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_flight IMPLEMENTATION.
  METHOD lif_output~get_output.

    r_result = get_description( ).

  ENDMETHOD.
  METHOD get_connection_details.
    r_result = me->connection_details.
  ENDMETHOD.

  METHOD get_description.
    DATA txt TYPE string.
    txt = 'Flight &carrid& &connid& on &date& from &from& to &to&'(005).
    txt = replace( val = txt sub = '&carrid&' with = carrier_id ).
    txt = replace( val = txt sub = '&connid&' with = connection_id ).
    txt = replace( val = txt sub = '&date&' with = |{ flight_date DATE = USER }| ).
    txt = replace( val = txt sub = '&from&' with = connection_details-airport_from_id ).
    txt = replace( val = txt sub = '&to&' with = connection_details-airport_to_id ).
    APPEND txt TO r_result.
    APPEND |{ 'Planetype:'(006) } { planetype } | TO r_result.
  ENDMETHOD.

  METHOD constructor.
    me->carrier_id    = i_carrier_id.
    me->connection_id = i_connection_id.
    me->flight_date   = i_flight_date.
  ENDMETHOD.


ENDCLASS.

CLASS lcl_passenger_flight DEFINITION INHERITING FROM lcl_flight.

  PUBLIC SECTION.


    METHODS constructor
      IMPORTING
        i_carrier_id    TYPE /dmo/carrier_id
        i_connection_id TYPE /dmo/connection_id
        i_flight_date   TYPE /dmo/flight_date.


    TYPES
      tt_flights TYPE STANDARD TABLE OF REF TO lcl_passenger_flight WITH DEFAULT KEY.


    METHODS
      get_free_seats
        RETURNING
          VALUE(r_result) TYPE i.

    METHODS
      get_description REDEFINITION.

    CLASS-METHODS class_constructor.
    CLASS-METHODS
      get_flights_by_carrier
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
        RETURNING
          VALUE(r_result) TYPE tt_flights.



  PROTECTED SECTION.

  PRIVATE SECTION.


    DATA seats_max  TYPE /dmo/plane_seats_max.
    DATA seats_occ  TYPE /dmo/plane_seats_occupied.
    DATA seats_free TYPE i.

    DATA price TYPE /dmo/flight_price.
    CONSTANTS currency TYPE /dmo/currency_code VALUE 'EUR'.
    TYPES: BEGIN OF st_flights_buffer,
             carrier_id     TYPE /lrn/passflight-carrier_id,
             connection_id  TYPE /lrn/passflight-connection_id,
             flight_date    TYPE /lrn/passflight-flight_date,
             plane_type_id  TYPE /lrn/passflight-plane_type_id,
             seats_max      TYPE /lrn/passflight-seats_max,
             seats_occupied TYPE /lrn/passflight-seats_occupied,
             seats_free     TYPE i,
             price          TYPE /lrn/passflight-price,
             currency_code  TYPE /lrn/passflight-currency_code,
           END OF st_flights_buffer,
           BEGIN OF st_connections_buffer,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             departure_time  TYPE /dmo/flight_departure_time,
             arrival_time    TYPE /dmo/flight_departure_time,
             timzone_from    TYPE /lrn/airport-timzone,
             timzone_to      TYPE /lrn/airport-timzone,
             duration        TYPE i,
           END OF st_connections_buffer.
    CLASS-DATA: flights_buffer TYPE HASHED TABLE OF st_flights_buffer WITH UNIQUE KEY carrier_id connection_id flight_date
                                                                      WITH NON-UNIQUE SORTED KEY sk_carrier COMPONENTS carrier_id.

    CLASS-DATA: connections_buffer TYPE HASHED TABLE OF st_connections_buffer WITH UNIQUE KEY carrier_id connection_id.

    TYPES: BEGIN OF st_airoport,
             airport_id TYPE /lrn/airport-airport_id,
             timzone    TYPE /lrn/airport-timzone,
           END OF st_airoport.
    CLASS-DATA: airoport TYPE TABLE OF st_airoport.

ENDCLASS.

CLASS lcl_passenger_flight IMPLEMENTATION.

  METHOD class_constructor.
    DATA(today) = cl_abap_context_info=>get_system_date( ).
    SELECT
           FROM /dmo/connection AS conn
           LEFT OUTER JOIN /lrn/airport AS airoport ON conn~airport_from_id = airoport~airport_id
           LEFT OUTER JOIN  /lrn/airport AS airoport2 ON conn~airport_to_id = airoport2~airport_id
         FIELDS carrier_id, connection_id, airport_from_id, airport_to_id, departure_time, arrival_time,
                airoport~timzone AS timzone_from,airoport2~timzone AS timzone_to,
                div( tstmp_seconds_between(
                tstmp1 = dats_tims_to_tstmp(
                date = @today,
                time = departure_time,
                tzone = airoport~timzone ),
                tstmp2 = dats_tims_to_tstmp(
                date = @today,
                time = arrival_time,
                tzone = airoport2~timzone )
                                          )
                , 60 ) AS duration
           INTO TABLE @connections_buffer.
*    IF sy-subrc IS INITIAL.
*
*      LOOP AT connections_buffer ASSIGNING FIELD-SYMBOL(<fs_conn>).
*        CONVERT DATE today TIME <fs_conn>-departure_time
*         TIME ZONE <fs_conn>-timzone_from
*         INTO UTCLONG DATA(departure_utclong).
*
*        CONVERT DATE today TIME <fs_conn>-arrival_time
*        TIME ZONE <fs_conn>-timzone_to
*        INTO UTCLONG DATA(arrival_utclong).
*
*        <fs_conn>-duration = utclong_diff( high = arrival_utclong low = departure_utclong ) / 60.
*      ENDLOOP.
*    ENDIF.

  ENDMETHOD.

  METHOD get_flights_by_carrier.


    IF NOT line_exists( flights_buffer[ KEY sk_carrier COMPONENTS carrier_id = i_carrier_id ] ).
      SELECT
           FROM /lrn/passflight
         FIELDS carrier_id, connection_id, flight_date,plane_type_id,
                seats_max, seats_occupied, seats_max - seats_occupied AS seats_free, price, currency_code
          WHERE carrier_id    = @i_carrier_id
*        ORDER BY flight_date
           APPENDING TABLE @flights_buffer.
*      SORT flights_buffer BY carrier_id connection_id flight_date.

      DELETE ADJACENT DUPLICATES FROM flights_buffer COMPARING carrier_id connection_id flight_date.
    ENDIF.

    r_result = VALUE #( FOR <flight> IN flights_buffer
                        USING KEY sk_carrier
                        WHERE ( carrier_id = i_carrier_id )
                        ( NEW lcl_passenger_flight(
                        i_carrier_id    = <flight>-carrier_id
                        i_connection_id = <flight>-connection_id
                        i_flight_date   = <flight>-flight_date )
                         ) ) .

*    LOOP AT flights_buffer INTO DATA(flight) where carrier_id = i_carrier_id.
*      APPEND NEW lcl_passenger_flight( i_carrier_id    = flight-carrier_id
*                                       i_connection_id = flight-connection_id
*                                       i_flight_date   = flight-flight_date )
*              TO r_result.
*    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.
    super->constructor( i_carrier_id = i_carrier_id i_connection_id = i_connection_id i_flight_date = i_flight_date ).
    TRY.
        DATA(flight_raw) = flights_buffer[ carrier_id = i_carrier_id
                                           connection_id = i_connection_id
                                           flight_date = i_flight_date ].

      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE
          FROM /lrn/passflight
        FIELDS plane_type_id, seats_max, seats_occupied,seats_max - seats_occupied AS seats_free,
        currency_conversion( amount = price,
                             source_currency = currency_code,
                             target_currency = @currency,
                             exchange_rate_date = flight_date,
                             on_error = @sql_currency_conversion=>c_on_error-set_to_null ) AS price,
          currency_code
      WHERE carrier_id    = @i_carrier_id
      AND connection_id = @i_connection_id
      AND flight_date   = @i_flight_date
      INTO CORRESPONDING FIELDS OF @flight_raw.
    ENDTRY.

    IF flight_raw IS NOT INITIAL.
*      me->carrier_id    = i_carrier_id.
*      me->connection_id = i_connection_id.
*      me->flight_date   = i_flight_date.

      planetype = flight_raw-plane_type_id.
      seats_max = flight_raw-seats_max.
      seats_occ = flight_raw-seats_occupied.
      seats_free = flight_raw-seats_free.
      price = flight_raw-price.

* convert currencies
*      TRY.
*          cl_exchange_rates=>convert_to_local_currency(
*            EXPORTING
*              date              = me->flight_date
*              foreign_amount    = flight_raw-price
*              foreign_currency  = flight_raw-currency_code
*              local_currency    = me->currency
*            IMPORTING
*              local_amount      = me->price
*          ).
*        CATCH cx_exchange_rates.
*          price = flight_raw-price.
*      ENDTRY.

* Set connection details
*      SELECT SINGLE
*        FROM /dmo/connection
*      FIELDS airport_from_id, airport_to_id, departure_time, arrival_time
*       WHERE carrier_id    = @carrier_id
*         AND connection_id = @connection_id
*        INTO @connection_details .
*


      TRY.

          connection_details = CORRESPONDING #( connections_buffer[ carrier_id = carrier_id
                                                   connection_id = connection_id ] ).
          connection_details-duration = connection_details-arrival_time
                                      - connection_details-departure_time.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

    ENDIF.
  ENDMETHOD.




  METHOD get_free_seats.
    r_result = me->seats_free.
  ENDMETHOD.

  METHOD get_description.

    r_result = super->get_description( ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_cargo_flight DEFINITION INHERITING FROM lcl_flight.

  PUBLIC SECTION.


    TYPES
       tt_flights TYPE STANDARD TABLE OF REF TO lcl_cargo_flight WITH DEFAULT KEY.


    METHODS constructor
      IMPORTING
        i_carrier_id    TYPE /dmo/carrier_id
        i_connection_id TYPE /dmo/connection_id
        i_flight_date   TYPE /dmo/flight_date.


    METHODS
      get_free_capacity
        RETURNING
          VALUE(r_result) TYPE /lrn/plane_actual_load.

    METHODS get_description REDEFINITION.

    CLASS-METHODS
      get_flights_by_carrier
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
        RETURNING
          VALUE(r_result) TYPE tt_flights.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF st_flights_buffer,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             flight_date     TYPE /dmo/flight_date,
             plane_type_id   TYPE /dmo/plane_type_id,
             maximum_load    TYPE /lrn/plane_maximum_load,
             actual_load     TYPE /lrn/plane_actual_load,
             load_unit       TYPE /lrn/plane_weight_unit,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             departure_time  TYPE /dmo/flight_departure_time,
             arrival_time    TYPE /dmo/flight_arrival_time,
             duration        TYPE i,
           END OF st_flights_buffer.

    TYPES tt_flights_buffer TYPE HASHED TABLE OF st_flights_buffer
                            WITH UNIQUE KEY carrier_id connection_id flight_date.


    DATA maximum_load TYPE /lrn/plane_maximum_load.
    DATA actual_load TYPE /lrn/plane_actual_load.
    DATA load_unit    TYPE /lrn/plane_weight_unit.

    CLASS-DATA flights_buffer TYPE tt_flights_buffer.

ENDCLASS.

CLASS lcl_cargo_flight IMPLEMENTATION.

  METHOD get_flights_by_carrier.

    SELECT
      FROM /lrn/cargoflight
    FIELDS carrier_id, connection_id, flight_date,
           plane_type_id, maximum_load, actual_load, load_unit,
           airport_from_id, airport_to_id, departure_time, arrival_time
     WHERE carrier_id    = @i_carrier_id
     ORDER BY flight_date
      INTO CORRESPONDING FIELDS OF TABLE @flights_buffer.

    LOOP AT flights_buffer INTO DATA(flight).
      APPEND NEW lcl_cargo_flight( i_carrier_id    = flight-carrier_id
                                   i_connection_id = flight-connection_id
                                   i_flight_date   = flight-flight_date )
              TO r_result.

    ENDLOOP.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( i_carrier_id = i_carrier_id i_connection_id = i_connection_id i_flight_date = i_flight_date ).
    " Read buffer
    TRY.
        DATA(flight_raw) = flights_buffer[ carrier_id    = i_carrier_id
                                           connection_id = i_connection_id
                                           flight_date   = i_flight_date ].

      CATCH cx_sy_itab_line_not_found.
        " Read from database if data not found in buffer
        SELECT SINGLE
          FROM /lrn/cargoflight
        FIELDS plane_type_id, maximum_load, actual_load, load_unit,
               airport_from_id, airport_to_id, departure_time, arrival_time
         WHERE carrier_id    = @i_carrier_id
           AND connection_id = @i_connection_id
           AND flight_date   = @i_flight_date
          INTO CORRESPONDING FIELDS OF @flight_raw.
    ENDTRY.

    carrier_id    = i_carrier_id.
    connection_id = i_connection_id.
    flight_date   = i_flight_date.

    planetype = flight_raw-plane_type_id.
    maximum_load = flight_raw-maximum_load.
    actual_load = flight_raw-actual_load.
    load_unit = flight_raw-load_unit.

    connection_details = CORRESPONDING #( flight_raw ).

    connection_details-duration = me->connection_details-arrival_time
                                    - me->connection_details-departure_time.

  ENDMETHOD.



  METHOD get_free_capacity.
    r_result = maximum_load - actual_load.
  ENDMETHOD.

  METHOD get_description.
    r_result = super->get_description( ).
  ENDMETHOD.

ENDCLASS.
"! Flight Carrier -
"! A factory logic ensures that there is only one instance for the same carrier ID.
CLASS lcl_carrier DEFINITION  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES lif_output.

    TYPES: tt_carriers TYPE STANDARD TABLE OF REF TO lcl_carrier WITH DEFAULT KEY.

    DATA carrier_id TYPE /dmo/carrier_id READ-ONLY.


    ALIASES: get_output FOR lif_output~get_output,
             tt_output FOR lif_output~tt_output,
             t_output FOR lif_output~t_output.
    "! Factory method - returns an instance of this class.
    "! @parameter i_carrier_id | Three-character identification of the carrier.
    "! @parameter r_result | Reference to the instance - initial if instantiation failed.
    "! @raising zcx_017_failed| Instantiation failed - evaluate the exception text for details.
    CLASS-METHODS get_instance
      IMPORTING
        i_carrier_id    TYPE /dmo/carrier_id
      RETURNING
        VALUE(r_result) TYPE REF TO lcl_carrier
      RAISING   "cx_abap_invalid_value
        "cx_abap_auth_check_exception
        zcx_017_failed.

    "! Search for a <strong>passenger flight</strong> between two airports that
    "! <ul>
    "! <li>lies on or after a given date and</li>
    "! <li>has a minimum number of available seats left</li>
    "!</ul>
    "! @parameter i_airport_from_id | <em>Departure</em> airport
    "! @parameter i_airport_to_id | <em>Arrival</em> airport
    "! @parameter i_from_date | First possible flight date
    "! @parameter i_seats | Minimum number of available seats
    "! @parameter e_flight | Found flight (object reference)
    "! @parameter e_days_later | Number of days after the requested date
    METHODS find_passenger_flight
      IMPORTING
        i_airport_from_id TYPE /dmo/airport_from_id
        i_airport_to_id   TYPE /dmo/airport_to_id
        i_from_date       TYPE /dmo/flight_date
        i_seats           TYPE i
      EXPORTING
        e_flight          TYPE REF TO lcl_flight
        e_days_later      TYPE i.

    "! Search for a <strong>cargo flight</strong> between two airports that
    "! <ul>
    "! <li>lies on or after a given date and</li>
    "! <li>has a minimum number of available capacity left</li>
    "!</ul>
    "! @parameter i_airport_from_id | <em>Departure</em> airport
    "! @parameter i_airport_to_id | <em>Arrival</em> airport
    "! @parameter i_from_date | First possible flight date
    "! @parameter i_cargo | Minimum number of available capacity
    "! @parameter e_flight | Found flight (object reference)
    "! @parameter e_days_later | Number of days after the requested date
    METHODS find_cargo_flight
      IMPORTING
        i_airport_from_id TYPE /dmo/airport_from_id
        i_airport_to_id   TYPE /dmo/airport_to_id
        i_from_date       TYPE /dmo/flight_date
        i_cargo           TYPE /lrn/plane_actual_load
      EXPORTING
        e_flight          TYPE REF TO lcl_flight
        e_days_later      TYPE i.


  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA instances TYPE tt_carriers.
    METHODS constructor
      IMPORTING
        i_carrier_id TYPE /dmo/carrier_id.
*      RAISING   cx_abap_invalid_value
*                cx_abap_auth_check_exception.

    DATA flights TYPE lcl_flight=>tab.
    CLASS-DATA name          TYPE c LENGTH 43.
    CLASS-DATA currency_code TYPE /dmo/currency_code ##NEEDED.

*    DATA passenger_flights TYPE lcl_passenger_flight=>tt_flights.
*
*    DATA cargo_flights TYPE lcl_cargo_flight=>tt_flights.

    METHODS get_average_free_seats
      RETURNING VALUE(r_result) TYPE i.

    DATA pf_count TYPE i.

    DATA cf_count TYPE i.

ENDCLASS.


CLASS lcl_carrier IMPLEMENTATION.

  METHOD get_instance.
* me->carrier_id = i_carrier_id.

    SELECT SINGLE
      FROM /dmo/carrier "/LRN/I_Carrier
    FIELDS concat_with_space( carrier_id, name, 1 ) AS name, currency_code "concat_with_space( airlineid, name, 1 ), CurrencyCode
     WHERE carrier_id = @i_carrier_id "AirlineID = @i_carrier_id
     INTO @DATA(details).

    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE cx_abap_invalid_value
*        EXPORTING
**         textid   =
**         previous =
*          value = CONV #( i_carrier_id ).
      RAISE EXCEPTION TYPE zcx_017_failed
        EXPORTING
          textid     = zcx_017_failed=>carrier_not_found
*         previous   =
          carrier_id = i_carrier_id.
    ELSE.
      AUTHORITY-CHECK OBJECT '/LRN/CARR' ID '/LRN/CARR' FIELD i_carrier_id.
      IF sy-subrc <> 0.
*        RAISE EXCEPTION TYPE cx_abap_auth_check_exception
*          EXPORTING
*            textid = cx_abap_auth_check_exception=>missing_authorization.
**            previous       =
**            text           =
**            message_prefix =

        RAISE EXCEPTION TYPE zcx_017_failed
          EXPORTING
            textid     = zcx_017_failed=>carrier_not_auth
*           previous   =
            carrier_id = i_carrier_id.
      ENDIF.

      .
    ENDIF.

    TRY.
        r_result = instances[ table_line->carrier_id = i_carrier_id ].


      CATCH cx_sy_itab_line_not_found.
        r_result = NEW #( i_carrier_id = i_carrier_id
                         ).
*

        r_result->name = details-name.
        r_result->currency_code = details-currency_code.
        APPEND r_result TO instances.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    me->carrier_id = i_carrier_id.
*
*    SELECT SINGLE
*      FROM /dmo/carrier "/LRN/I_Carrier
*    FIELDS concat_with_space( carrier_id, name, 1 ), currency_code "concat_with_space( airlineid, name, 1 ), CurrencyCode
*     WHERE carrier_id = @i_carrier_id "AirlineID = @i_carrier_id
*     INTO ( @me->name, @me->currency_code ).
*
*    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE cx_abap_invalid_value.
*    ELSE.
*      AUTHORITY-CHECK OBJECT '/LRN/CARR' ID '/LRN/CARR' FIELD i_carrier_id.
*      IF sy-subrc <> 0.
*        RAISE EXCEPTION TYPE cx_abap_auth_check_exception.
*
*      ENDIF.
*    ENDIF.

*    name = carrier_id && ` ` && name.

    DATA(passenger_flights) =
        lcl_passenger_flight=>get_flights_by_carrier(
              i_carrier_id    = i_carrier_id ).


    DATA(cargo_flights) =
        lcl_cargo_flight=>get_flights_by_carrier(
              i_carrier_id    = i_carrier_id ).

    flights = VALUE #( BASE flights FOR pflight IN passenger_flights ( pflight ) ).
    flights = VALUE #( BASE flights FOR pcargo IN cargo_flights ( pcargo ) ).

    pf_count = lines( passenger_flights ).
    Cf_count = lines( cargo_flights ).

  ENDMETHOD.

  METHOD get_output.

    APPEND |{ 'Carriers:'(t01) }   { me->name } | TO r_result.
    APPEND |{ 'Passenger Flights:'(t02) }  { pf_count } | TO r_result.
    APPEND |{ 'Average free seats:'(t03) }  { get_average_free_seats(  ) } | TO r_result.
    APPEND |{ 'Cargo Flights:'(t04) }  { cf_count } | TO r_result.

  ENDMETHOD.

  METHOD find_cargo_flight.

    e_days_later = 99999999.

    LOOP AT flights INTO DATA(flight)
        WHERE table_line->flight_date >= i_from_date
        AND table_line IS INSTANCE OF lcl_cargo_flight.

      DATA(connection_details) = flight->get_connection_details(  ).

      IF connection_details-airport_from_id = i_airport_from_id
       AND connection_details-airport_to_id = i_airport_to_id
       AND CAST lcl_cargo_flight( flight )->get_free_capacity(  )  >= i_cargo.

        DATA(days_later) =  flight->flight_date - i_from_date.

        IF days_later < e_days_later. "earlier than previous one?
          e_flight = flight.
          e_days_later = days_later.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD find_passenger_flight.

    e_days_later = 99999999.

    LOOP AT flights INTO DATA(flight)
         WHERE table_line->flight_date >= i_from_date
         AND table_line IS INSTANCE OF lcl_passenger_flight.

      DATA(connection_details) = flight->get_connection_details(  ).

      IF connection_details-airport_from_id = i_airport_from_id
       AND connection_details-airport_to_id = i_airport_to_id
       AND CAST lcl_passenger_flight( flight )->get_free_seats( ) >= i_seats.
        DATA(days_later) = flight->flight_date - i_from_date.

        IF days_later < e_days_later. "earlier than previous one?
          e_flight = flight.
          e_days_later = days_later.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_average_free_seats.

*    DATA total TYPE i.
*
*    LOOP AT passenger_flights INTO DATA(flight).
*
*      total = total + flight->get_free_seats( ).
*
*    ENDLOOP.
*
*    r_result = total / lines( passenger_flights ).

*    SELECT
*    FROM /lrn/passflight
*    FIELDS SUM( seats_max - seats_occupied ) AS sum, COUNT( * ) AS count
*    WHERE carrier_id = @carrier_id
*    INTO @DATA(aggregates).
*    IF sy-subrc IS INITIAL.
*      r_result = aggregates-sum / aggregates-count.
*    ENDIF.

*    r_result = REDUCE #( INIT total = 0 FOR flight IN  passenger_flights
*                         NEXT total = total +  flight->get_free_seats( )
*                            )
*                            / lines( passenger_flights ).

    r_result = REDUCE #( INIT i = 0 FOR <flight> IN flights
               WHERE ( table_line IS INSTANCE OF lcl_passenger_flight )
               NEXT i += CAST lcl_passenger_flight( <flight> )->get_free_seats( ) )
                / pf_count .

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-DATA the_carrier TYPE REF TO lcl_carrier.

    CLASS-DATA some_flight_data TYPE /lrn/cargoflight.

    CLASS-METHODS class_setup.

    METHODS:
      test_find_cargo_flight FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.
  METHOD test_find_cargo_flight.
*    SELECT SINGLE
*      FROM /lrn/cargoflight
*    FIELDS carrier_id, connection_id, flight_date,
*           airport_from_id, airport_to_id
*      INTO @DATA(some_flight_data).
*
*    IF sy-subrc <> 0.
*      cl_abap_unit_assert=>fail( `No data in table /lrn/CARGOFLIGHT` ).
*    ENDIF.
*
*    TRY.
*
*        DATA(the_carrier) = NEW lcl_carrier( i_carrier_id = some_flight_data-carrier_id ).
*
*      CATCH cx_abap_invalid_value.
*
*        cl_abap_unit_assert=>fail( `Unable to instantiate lcl_carrier` ).
*
*    ENDTRY.

    the_carrier->find_cargo_flight(
      EXPORTING
        i_airport_from_id = some_flight_data-airport_from_id
        i_airport_to_id   = some_flight_data-airport_to_id
        i_from_date       = some_flight_data-flight_date
        i_cargo           = 1
      IMPORTING
        e_flight          = DATA(flight)
        e_days_later      = DATA(days_later)
    ).

    cl_abap_unit_assert=>assert_bound(
        act = flight
        msg = `Method find_cargo_flight does not return a result` ).

    cl_abap_unit_assert=>assert_equals(
        act = days_later
        exp = 0
        msg = `Method find_cargo_flight returns wrong result` ).


  ENDMETHOD.

  METHOD class_setup.


    SELECT SINGLE
      FROM /lrn/cargoflight
    FIELDS carrier_id, connection_id, flight_date,
           airport_from_id, airport_to_id
      INTO CORRESPONDING FIELDS OF @some_flight_data.

    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( `No data in table /lrn/CARGOFLIGHT` ).
    ENDIF.

    TRY.

*        the_carrier = NEW lcl_carrier( i_carrier_id = some_flight_data-carrier_id ).
        the_carrier = lcl_carrier=>get_instance(
                         i_carrier_id   = some_flight_data-carrier_id
                       ).

*      CATCH cx_abap_invalid_value.
*
*        cl_abap_unit_assert=>fail( `Unable to instantiate lcl_carrier` ).
*
*      CATCH cx_abap_auth_check_exception.
*        cl_abap_unit_assert=>fail( `Unable to instantiate lcl_carrier` ).
      CATCH cx_root INTO DATA(exc_root).
        cl_abap_unit_assert=>fail( exc_root->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
