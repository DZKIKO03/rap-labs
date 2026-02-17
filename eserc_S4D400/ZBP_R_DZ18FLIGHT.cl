class ZBP_R_DZ18FLIGHT definition
  public
  abstract
  final
  for behavior of ZR_DZ18FLIGHT .

public section.
protected section.
private section.
ENDCLASS.



CLASS ZBP_R_DZ18FLIGHT IMPLEMENTATION.
ENDCLASS.

CLASS lhc_zr_dz18flight DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrDz18flight
        RESULT result,
      validatePrice FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrDz18flight~validatePrice,
      validateCurrency FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrDz18flight~validateCurrency.
ENDCLASS.

CLASS lhc_zr_dz18flight IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD validatePrice.
    DATA: failed_record   LIKE LINE OF failed-zrdz18flight.
    DATA: reported_record LIKE LINE OF reported-zrdz18flight.

    READ ENTITIES OF zr_dz18flight IN LOCAL MODE
    ENTITY ZrDz18flight
    FIELDS ( price )
    WITH CORRESPONDING #( keys )
    RESULT DATA(flights).

    LOOP AT flights ASSIGNING FIELD-SYMBOL(<lfs_flight>).
      IF <lfs_flight>-Price <= 0.
        failed_record-%tky = <lfs_flight>-%tky.
        APPEND failed_record TO failed-zrdz18flight.
        reported_record-%tky = <lfs_flight>-%tky.
        reported_record-%element-price = if_abap_behv=>mk-on.
        reported_record-%msg = new_message( id = '/LRN/S4D400'
                                            number = '101'
                                            severity = if_abap_behv_message=>severity-error ).
        APPEND reported_record TO reported-zrdz18flight.
      ENDIF.


    ENDLOOP.


  ENDMETHOD.

  METHOD validateCurrency.
    DATA: failed_record LIKE LINE OF failed-zrdz18flight.
    DATA: reported_record LIKE LINE OF reported-zrdz18flight.
    DATA lt_curr TYPE HASHED TABLE OF i_currency-currency
      WITH UNIQUE KEY TABLE_LINE.

    READ ENTITIES OF zr_dz18flight IN LOCAL MODE
    ENTITY ZrDz18flight
    FIELDS ( CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(flights).

    SELECT DISTINCT currency
    FROM I_Currency
    INNER JOIN @flights AS flight ON flight~CurrencyCode = I_Currency~Currency
    INTO TABLE @lt_curr.


    LOOP AT flights ASSIGNING FIELD-SYMBOL(<lfs_flight>).
      IF NOT line_exists( LT_CURR[ TABLE_LINE = <LFS_FLIGHT>-CurrencyCode ] ).
        failed_record-%tky = <lfs_flight>-%tky.
        APPEND failed_record TO failed-zrdz18flight.

        reported_record-%tky = <lfs_flight>-%tky.
        reported_record-%element-currencycode = if_abap_behv=>mk-on.
        reported_record-%msg = new_message( id = '/LRN/S4D400'
                                            number = '102'
                                            severity = if_abap_behv_message=>severity-error ).
        APPEND reported_record TO reported-zrdz18flight.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
