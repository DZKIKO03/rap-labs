CLASS zexercise8 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zexercise8 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lo_connection TYPE REF TO lcl_connection.
    DATA: lo_connections TYPE TABLE OF REF TO lcl_connection.

*  lo_connection = new #( ).
*  try.
*  lo_connection->set_attributes(
*    i_carrier_id    = ''
*    i_connection_id = '0400'
*  ).
*    APPEND LO_CONNECTION TO LO_CONNECTIONS.
*  CATCH cx_abap_invalid_value.
*out->write( `Method call failed` ).
*  endtry.
*
*  lo_connection = new #( ).
*    try.
*  lo_connection->set_attributes(
*    i_carrier_id    = 'AA'
*    i_connection_id = '0017'
*  ).
*    APPEND LO_CONNECTION TO LO_CONNECTIONS.
*  CATCH cx_abap_invalid_value.
*out->write( `Method call failed` ).
*  endtry.
*
*  lo_connection = new #( ).
*      try.
*  lo_connection->set_attributes(
*    i_carrier_id    = 'SQ'
*    i_connection_id = '0001'
*  ).
*    APPEND LO_CONNECTION TO LO_CONNECTIONS.
*  CATCH cx_abap_invalid_value.
*  out->write( `Method call failed` ).
*  endtry.

    TRY.
        lo_connection = NEW #( i_carrier_id = 'LH' i_connection_id = '0400' ).
        APPEND lo_connection TO lo_connections.
      CATCH cx_abap_invalid_value.
        out->write( `Method call failed` ).
    ENDTRY.

    TRY.
        lo_connection = NEW #( i_carrier_id = 'AA' i_connection_id = '0017' ).
        APPEND lo_connection TO lo_connections.
      CATCH cx_abap_invalid_value.
        out->write( `Method call failed` ).
    ENDTRY.

    TRY.
        lo_connection = NEW #( i_carrier_id = 'SQ' i_connection_id = '0001' ).
        APPEND lo_connection TO lo_connections.
      CATCH cx_abap_invalid_value.
        out->write( `Method call failed` ).
    ENDTRY.

    LOOP AT lo_connections INTO lo_connection.
      out->write( lo_connection->get_output(  ) ).

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_connection DEFINITION.

  PUBLIC SECTION.
    CLASS-DATA: conn_counter TYPE i READ-ONLY.


    METHODS:
      constructor
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
          i_connection_id TYPE /dmo/connection_id
        RAISING
          cx_abap_invalid_value,
      get_output
        RETURNING VALUE(r_output) TYPE string_table.
*  set_attributes
*   importing
*    i_carrier_id type /DMO/CARRIER_ID
*  i_connection_id type /DMO/CONNECTION_ID
*    raISING
*  CX_ABAP_INVALID_VALUE.


  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF st_details,
             DepartureAirport   TYPE /dmo/airport_from_id,
             DestinationAirport TYPE /dmo/airport_to_id,
             AirlineName        TYPE /dmo/carrier_name,
           END OF st_detAILS.
    DATA: carrier_id    TYPE /dmo/carrier_id,
          connection_id TYPE /dmo/connection_id,
          details       TYPE st_details.
*          airoport_from_id TYPE /dmo/airport_from_id,
*          airoport_to_id   TYPE /dmo/airport_to_id,
*          carrier_name     TYPE /dmo/carrier_name.

ENDCLASS.

CLASS lcl_connection IMPLEMENTATION.

  METHOD get_output.
    APPEND |----------------| TO r_output.
    APPEND  |valore carrier id: { carrier_id }|  TO r_output.
    APPEND  |valore conncetion id: { connection_id } | TO r_output.
    APPEND  |valore airport from id: { details-departureairport } | TO r_output.
    APPEND  |valore airport to id: { details-destinationairport } | TO r_output.
    APPEND  |valore carrier name: { details-airlinename } | TO r_output.
  ENDMETHOD.

*  method set_attributes.
*  if i_carrier_id is initial or i_connection_id is initial.
*  raISE exCEPTION type CX_ABAP_INVALID_VALUE.
*  endif.
*  carrier_id = i_carrier_id.
*  connection_id = i_connection_id.
*  endmethod.

  METHOD constructor.
    IF i_carrier_id IS INITIAL OR i_connection_id IS INITIAL.
      RAISE EXCEPTION TYPE cx_abap_invalid_value.
    ENDIF.
*    SELECT SINGLE
*    FROM /dmo/connection
*    FIELDS airport_from_id,airport_to_id
*    WHERE carrier_id = @i_carrier_id AND
*          connection_id = @i_connection_id
*          INTO ( @me->airoport_from_id, @me->airoport_to_id ).
    SELECT SINGLE
    FROM /dmo/i_connection
    FIELDS DepartureAirport,DestinationAirport, \_airline-Name AS AirlineName
    WHERE AirlineID = @i_carrier_id AND
          ConnectionID = @i_connection_id
          INTO CORRESPONDING FIELDS OF @details.
    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE cx_abap_invalid_value.
    ENDIF.
    me->carrier_id = i_carrier_id.
    me->connection_id = i_connection_id.
    conn_counter = conn_counter + 1.
  ENDMETHOD.

ENDCLASS.
