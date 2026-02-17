CLASS zcl_g4_clean_oop DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_g4_clean_oop IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  data: lo_class type ref to lcl_local,
        lo_exc type ref to lcx_business_error.

     TRY.
      lo_class = new #( i_airlineid = 'JL' ).
       CATCH lcx_business_error INTO lo_exc.
        out->write( lo_exc->get_text( ) ).
        eNDTRY.

        IF LO_CLASS IS BOUND.
        lo_class->check_first_class(
          EXPORTING
            price       =  lcl_local=>PRICE_WT
          RECEIVING
            price_total = DATA(LV_PRICE_TOTAL)
        ).

        out->write( LV_PRICE_TOTAL ).
        ENDIF.
*  Esercizi
*    1. Functional Methods
*        ◦ metodi di calcolo con solo RETURNING
*    2. Exception Design
*        ◦ eccezione custom locale LCX_BUSINESS_ERROR
*(ereditata da CX_STATIC_CHECK)
*        ◦ RAISE EXCEPTION su violazione business
*    3. Istanziazione
*        ◦ solo NEW, mai CREATE OBJECT
*    4. ABAP Unit (base ma reale)
*        ◦ Classe di test locale FOR TESTING
*        ◦ Test che fallisce se prezzo < 0
*        ◦ Uso di cl_abap_unit_assert=>assert_equals
*Criterio esame
*    • logica separata dall’output
*    • codice testabile, non solo funzionante




  ENDMETHOD.
ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

class lcx_business_error definition inheriting from cx_static_check.

  public section.
INTERFACES if_t100_message.
 METHODS constructor
      IMPORTING
        textid      LIKE if_t100_message=>t100key OPTIONAL
        previous    LIKE previous OPTIONAL
        price        TYPE /dmo/flight-price OPTIONAL.
      constANTS:  BEGIN OF lcx_price_invalid,
        msgid TYPE symsgid VALUE 'ZS4D400_G4_EXC',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF lcx_price_invalid.

       constANTS:  BEGIN OF lcx_price_much,
        msgid TYPE symsgid VALUE 'ZS4D400_G4_EXC',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'PRICE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF lcx_price_much.

      DATA price TYPE /dmo/flight-price READ-ONLY.
  protected section.

  private section.

endclass.

CLASS lcx_business_error IMPLEMENTATION.

  METHOD constructor.


super->constructor( previous = previous ).

    me->price = price.

    CLEAR me->textid.

    if price = 0.
      if_t100_message~t100key = lcx_price_invalid.
    elseif price > 1000.
      if_t100_message~t100key = lcx_price_much.
    endif.


  ENDMETHOD.

ENDCLASS.

class lcl_local definition.

  public section.

CLASS-DATA PRICE_WT TYPE /dmo/flight-price.

  methODS:
  constructor
  imporTING
   i_airlineid        TYPE /dmo/carrier_id
    raising
  lcx_business_error,

  check_first_class
  importing
  price type /dmo/flight-price
  retURNING VALUE(price_total) type /dmo/flight-price.




  protected section.
  private section.

endclass.

class lcl_local implementation.

  method check_first_class.

    price_total =  price + ( price * 22 ) / 100  .
  endmethod.



  method constructor.

  select single
  from /dmo/flight
  fields carrier_id, sum( price ) as total
  WHERE CARRIER_ID EQ @i_airlineid
  group by carrier_id
  into @data(ls_flight).
  if ls_flight-total <= 0.
      raise exception type lcx_business_error.
    elseif ls_flight-total > 30000.
     raise exCEPTION type lcx_business_error
    expoRTING
    price = ls_flight-total.
    ELSE.
    PRICE_WT = ls_flight-total.
    endif.
  endmethod.

endclass.
