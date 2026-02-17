CLASS zcl_g4_clean_oop_v2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  mETHODS:
  flight_value
  importing
  carrier_id type /dmo/flight-carrier_id
  expoRTING
  price type /dmo/flight-price
  tax type /dmo/flight-price
  total type /dmo/flight-price.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_g4_clean_oop_v2 IMPLEMENTATION.


  METHOD flight_value.

    SELECT CARRIER_ID, SUM( PRICE ) AS PRICE
    FROM /DMO/FLIGHT
    WHERE CARRIER_ID = @carrier_id
    GROUP BY CARRIER_ID
    INTO TABLE @DATA(LT_PRICE).
    IF LT_PRICE IS NOT INITIAL.
    DATA(LO_LOCAL) = NEW lcl_local(  ).

    READ TABLE LT_PRICE ASSIGNING FIELD-SYMBOL(<FS_PRICE>) INDEX 1.
    IF <FS_PRICE> IS ASSIGNED.
    PRICE = <FS_PRICE>-price.
    try.
    LO_LOCAL->calc_tax_price(
      EXPORTING
        price          = <FS_PRICE>-price
      RECEIVING
        lv_total_price = DATA(LV_TOTAL)
    ).
    catCH lcx_exception into data(lo_mess).
    RAISE EXCEPTION lo_mess.
    endTRY.


    TAX = LV_TOTAL - PRICE.
    TOTAL = LV_TOTAL.
    ENDIF.
    ENDIF.



  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

class lcx_exception dEFINITION INHERITING FROM cx_static_check.

public SECTION.
interfaces if_t100_message.
METHODS constructor
IMPORTING
        textid      LIKE if_t100_message=>t100key OPTIONAL
        previous    LIKE previous OPTIONAL
        price       TYPE /dmo/flight-price OPTIONAL.
CONSTANTS:
    BEGIN OF lcx_price_invalid,
        msgid TYPE symsgid VALUE 'ZS4D400_G4_EXC',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
        END OF lcx_price_invalid,
        BEGIN OF lcx_price_much,
        msgid TYPE symsgid VALUE 'ZS4D400_G4_EXC',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'PRICE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF lcx_price_much.

      DATA GV_PRICE TYPE /DMO/FLIGHT-PRICE.
proTECTED SECTION.
privATE SECTION.


endclass.

CLASS lcx_exception IMPLEMENTATION.


  METHOD constructor.
   super->constructor( previous = previous ).
    me->if_t100_message~t100key = textid.
    me->gv_price = price.
  ENDMETHOD.



ENDCLASS.


class lcl_local definition.

  public section.
  METHODS:
  CALC_TAX_PRICE
  IMPORTING
  PRICE TYPE /dmo/flight-price
  RETURNING
  VALUE(LV_TOTAL_PRICE) TYPE /dmo/flight-price
  RAISING
  lcx_exception.
  protected section.
  private section.

endclass.

class lcl_local implementation.

  method calc_tax_price.
    if price <= 0.
RAISE EXCEPTION TYPE lcx_exception
      EXPORTING
        textid = lcx_exception=>lcx_price_invalid
        price  = price.
    endif.

    lv_total_price = price + ( ( price * 22 ) / 100 ).

    if lv_total_price > 20000.
    RAISE EXCEPTION TYPE lcx_exception
      EXPORTING
        textid = lcx_exception=>lcx_price_much
        price  = lv_total_price.
    endif.

     endmethod.

endclass.
