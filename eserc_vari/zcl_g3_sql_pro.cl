CLASS zcl_g3_sql_pro DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_g3_sql_pro IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  select
  from
  /dmo/flight as a
  innER jOIN /dmo/connection as b on a~carrier_id eq b~carrier_id and
                                     a~connection_id eq b~connection_id
  inner join /dmo/airport as c on b~airport_from_id eq c~airport_id
  inneR jOIN /dmo/airport as d on d~airport_id eq b~airport_to_id
  fielDS a~carrier_id,
         b~connection_id,
         a~flight_date,
         c~city as departure_city,
         d~city as arrival_city,
         b~departure_time,
         b~arrival_time,
         b~distance,
         case
         when b~distance > 1000 then 'International Flight'
         else 'Home flight' end as type_of_flight,
         concat_with_space( 'Volo in partenza il', CAST( a~flight_date AS CHAR( 10 ) ), 1 ) AS flight_date_text,
         extract_year( flight_date ) as year,
         extract_month( flight_date ) as month,
         a~currency_code,
         a~price,
         case
         when price < 3000 then 'Economy'
         when price < 6000 then 'Business'
         else 'Premium'
         end as price_category,
         CAST( division( ( price * 22 ), 100 , 2 ) AS CURR( 13,2 ) ) as tax,
         a~price + division( ( price * 22 ), 100 , 2 ) as total,
         a~seats_max,
         a~seats_occupied,
         a~seats_max - a~seats_occupied as seats_remain
  into tABLE @data(lt_table).



  select
  from /dmo/flight
  fields carrier_id,
         connection_id,
         currency_code,
         coalesce( sum( price ), 0 ) as price
  grouP BY carrier_id,connection_id,currency_code
  having avg( price ) > 5000
  into tABLE @data(lt_table2).


  select
  from /dmo/flight
  fields carrier_id,
         connection_id,
         count( * ) as number
   group by carrier_id,connection_id
   into tABLE @data(lt_table3).


   select
   from /dmo/flight
   fields carrier_id,
         connection_id,
         flight_date
   ordER BY flight_date,
            carrier_id,
            connection_id
   into tABLE @data(lt_table4) up to 1 rOWS.


*   select
*   from /dmo/flight
*  fields carrier_id,
*         connection_id,
*         currency_code,
*         price,
*         coalesce(  )
*  Esercizi
*    1. SQL Expressions
*        ◦ Calcoli direttamente in SELECT (es. IVA)
*        ◦ concatenazioni SQL (non ABAP)
*    2. Aggregazioni
*        ◦ COUNT, SUM, AVG
*        ◦ GROUP BY + HAVING
*    3. Null handling
*        ◦ Usa COALESCE per valori nulli
*    4. Determinismo
*        ◦ ORDER BY + UP TO n ROWS
*        ◦ Commenta perché senza ORDER BY è una trappola d’esame
*Criterio esame
*    • nessun SELECT *
*    • tutte le host variables con @
*    • rispetto della Golden Rule:
*      meno dati passano al server applicativo, meglio è
  ENDMETHOD.
ENDCLASS.
