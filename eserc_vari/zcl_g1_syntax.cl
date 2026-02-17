CLASS zcl_g1_syntax DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
     types: BEGIN OF ENUM ty_class STRUCTURE gs_class,
            premium,
            business,
            economy,
      END OF ENUM ty_class STRUCTURE gs_class.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_g1_syntax IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  types: BEGIN OF ty_flights_v2,
         source type c length 5,
         carrier_description type string,
         connection_id type /DMO/FLIGHT-connection_id,
         flight_date type /DMO/FLIGHT-flight_date,
         price type /DMO/FLIGHT-price,
         currency_code type /DMO/FLIGHT-currency_code,
         seats_max type /DMO/FLIGHT-seats_max,
         seats_occupied type /DMO/FLIGHT-seats_occupied ,
         status type c length 11,
         type_fly type ty_class,
         end OF ty_flights_v2,
         tty_flight type stANDARD TABLE OF ty_flights_v2 with eMPTY KEY.

  data(lv_carrier_id) = 'LH'.

* 1 parte move corresponding
  select
  from /DMO/FLIGHT
  fields carrier_id, connection_id, flight_date, price, currency_code, seats_max, seats_occupied
  where carrier_id = @lv_carrier_id
  into table @data(lt_flights).

DATA(LT_FLIGHTS_V2) = VALUE tty_flight( FOR WA IN LT_FLIGHTS
                                        LET LV_CARRIER = SWITCH #( WA-carrier_id WHEN 'LH' THEn 'LUFTHANSA' else 'NULL' )
                                            LV_STATUS = COND #( WHEN ( WA-SEATS_MAX - WA-seats_occupied ) <= 30 THEN 'Almost Full'
                                                                else 'Ok' )
                                            lv_type_fly = cond #( when  WA-price <= 3000 then gs_class-economy
                                                                  when WA-price <= 5000 then gs_class-business
                                                                  else gs_class-premium )
                                        in
                                        ( source = 'CLOUD'
                                          carrier_description = lv_carrier
                                          connection_id = WA-connection_id
                                          flight_date = WA-flight_date
                                          price = WA-price
                                          currency_code = WA-currency_code
                                          seats_max = WA-seats_max
                                          seats_occupied = WA-seats_occupied
                                          status = lv_status
                                          type_fly = lv_type_fly ) ) .

  data(lv_price_tot) = reduce /dmo/flight-price( init tot =  0
                                 for wa2 in LT_FLIGHTS_V2
                                 next tot += wa2-price
                                  ).

                                  out->write( lt_flights_v2 ).
                                  out->write( |Prezzo totale: { lv_price_tot } | ) .

*  Esercizi
*    1. Strict ABAP SQL
*        ◦ SELECT da /DMO/FLIGHT
*        ◦ FIELDS carrid, connid, fldate, price
*        ◦ filtro con host variables @
*        ◦ INTO TABLE @DATA(lt_flights)
*    2. Constructor Operators
*        ◦ Crea lt_flights_v2 usando
*CORRESPONDING #( lt_flights )
*        ◦ aggiungi campo fisso (es. source = 'CLOUD')
*    3. Conditional Logic (leggibile)
*        ◦ Calcola lv_status con COND
*        ◦ Usa SWITCH per convertire il carrier ('LH' → 'Lufthansa')
*        ◦ Status e mapping calcolati prima, poi usati nel costruttore
*(no COND annidati dentro VALUE)
*    4. Enumerations
*        ◦ Definisci un BEGIN OF ENUM per il tipo volo
*(economy / premium)
*        ◦ niente CONSTANTS legacy
*    5. Aggregazione controllata
*        ◦ Usa REDUCE una sola volta, ben commentata,
*per calcolare il totale prezzi
*Criterio esame
*    • zero DATA: legacy
*    • niente concatenazioni manuali
*    • REDUCE usato come dimostrazione, non abuso
  ENDMETHOD.
ENDCLASS.
