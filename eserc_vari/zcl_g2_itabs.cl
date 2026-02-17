CLASS zcl_g2_itabs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ENUM TY_STATUS STRUCTURE GS_STATUS,
           AVAILABLE,
           FULL,
           END OF ENUM TY_STATUS STRUCTURE GS_STATUS.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_g2_itabs IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  types: beGIN OF ty_table,
         flight type /dmo/flight,
         status type TY_STATUS,
         enD OF ty_table,
         tty_table type sorted tABLE OF ty_table with noN-UNIQUE key flight-carrier_id flight-connection_id.

         data(lt_table) = value tty_table( ( flight-carrier_id = 'LH'
                                            FLIGHT-connection_id = '0400'
                                            flight-flight_date = '20210101'
                                            flight-price = 4200
                                            flight-currency_code = 'EUR'
                                            status = GS_STATUS-available )
                                          ( flight-carrier_id = 'AA'
                                            flight-connection_id = '001'
                                            flight-flight_date = '20210101'
                                            flight-currency_code = 'USD'
                                            flight-price = 52
                                            STATUS = GS_STATUS-FULL )
                                            ( flight-carrier_id = 'AA'
                                            flight-connection_id = '002'
                                            flight-flight_date = '20210101'
                                            flight-currency_code = 'USD'
                                            flight-price = 52
                                            STATUS = GS_STATUS-FULL ) ).

        if line_exists( lt_table[ flight-carrier_id = 'LH' FLIGHT-connection_id = '0400' ] ).
       data(lv_price)  = conv ty_table-flight-price(
        lt_table[ flight-carrier_id = 'LH' flight-connection_id = '0400' ]-flight-price   ).
        else.
        out->write( 'line not found' ).
        endif.
        try.
       data(lv_price2) = value  /dmo/flight_price(
       lt_table[ flight-carrier_id = 'AA' flight-connection_id = '001' ]-flight-price ).
       catch cx_sy_itab_line_not_found into data(lx_err).
       out->write( lx_err->get_longtext( ) ).
       endtry.

       data(lt_table2) = value tty_table( for wa in lt_table where ( status = GS_STATUS-full )
                                          ( flight-carrier_id = wa-flight-carrier_id
                                            FLIGHT-connection_id = wa-flight-connection_id
                                            flight-flight_date = wa-flight-flight_date
                                            flight-price = wa-flight-price
                                            flight-currency_code = wa-flight-currency_code
                                            status = GS_STATUS-available ) ).


      loop at lt_table assIGNING fIELD-SYMBOL(<lfs_table>)
      group by ( carrier_id = <lfs_table>-flight-carrier_id )
      into data(ls_group).
      data(lv_price3) = 0.

      loop at grOUP ls_group assIGNING fIELD-SYMBOL(<lfs_group>).
      lv_price3 += <lfs_group>-flight-price.
      endLOOP.
      endLOOP.



*  Esercizi
*    1. VALUE operatorS
*        ◦ Popola una ITAB complessa in un’unica istruzione
*        ◦ anche con struttura annidata
*    2. Table Expressions – doppia strategia
*        ◦ Accesso protetto con line_exists( )
*        ◦ Accesso con:
*            ▪ VALUE #( itab[ ... ] OPTIONAL )
*            ▪ oppure TRY / CATCH cx_sy_itab_line_not_found
*        ◦ Commenta quando usare ciascun approccio
*    3. Iteration Expressions
*        ◦ Trasforma una ITAB in un’altra con:
*          VALUE #( FOR ... IN ... WHERE ( ... ) ( ... ) )
*        ◦ Nessun LOOP + CHECK + APPEND
*    4. Grouping
*        ◦ Usa LOOP AT ... GROUP BY per raggruppare voli
*        ◦ spiega perché è preferibile al raggruppamento manuale
*Criterio esame
*    • nessun dump possibile
*    • sai spiegare STANDARD vs SORTED vs HASHED
*    • le espressioni semplificano, non oscurano
  ENDMETHOD.
ENDCLASS.
