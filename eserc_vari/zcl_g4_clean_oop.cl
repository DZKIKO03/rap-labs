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
