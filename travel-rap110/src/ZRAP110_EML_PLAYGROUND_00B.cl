class ZRAP110_EML_PLAYGROUND_00B definition
  public
  final
  create public .

  public section.
    interfaces IF_OO_ADT_CLASSRUN .
  protected section.
  private section.
endclass.



class ZRAP110_EML_PLAYGROUND_00B implementation.
  method IF_OO_ADT_CLASSRUN~MAIN.
    "declare internal table using derived type
    data TRAVEL_KEYS type table for read import ZRAP110_R_TravelTP_00B .

    "fill in relevant travel keys for READ request
    TRAVEL_KEYS = value #( ( TravelID = '0003' )
                          "( TravelID = '...' )
                         ).

    "insert your coding here
    "read _travel_ instances for specified key
    read entities of ZRAP110_R_TravelTP_00B
      entity Travel
*        ALL FIELDS
       fields ( TravelID AgencyID CustomerID BeginDate EndDate )
       with TRAVEL_KEYS
   result data(LT_TRAVELS_READ)
   failed data(FAILED)
   reported data(REPORTED).

    "console output
    OUT->WRITE( | ***Exercise 10: Implement the Base BO Behavior - Functions*** | ).
*    out->write( lt_travels_read ).
    if FAILED is not initial.
      OUT->WRITE( |- [ERROR] Cause for failed read: { FAILED-TRAVEL[ 1 ]-%FAIL-CAUSE } | ).
    endif.

    "read relevant booking instances
    read entities of ZRAP110_R_TravelTP_00B
      entity Travel by \_Booking
        from corresponding #( LT_TRAVELS_READ )
        result data(LT_BOOKINGS_READ)
    link data(TRAVELS_TO_BOOKINGS).

    "execute function getDaysToFlight
    read entities of ZRAP110_R_TravelTP_00B
      entity Booking
        execute getDaysToFlight
          from value #( for LINK in TRAVELS_TO_BOOKINGS ( %TKY = LINK-TARGET-%TKY ) )
    result data(DAYS_TO_FLIGHT).

    "output result structure
    loop at DAYS_TO_FLIGHT assigning field-symbol(<DAYS_TO_FLIGHT>).
      OUT->WRITE( | TravelID = { <DAYS_TO_FLIGHT>-%TKY-TravelID } |  ).
      OUT->WRITE( | BookingID = { <DAYS_TO_FLIGHT>-%TKY-BookingID } | ).
      OUT->WRITE( | RemainingDaysToFlight  = { <DAYS_TO_FLIGHT>-%PARAM-REMAINING_DAYS_TO_FLIGHT } | ).
      OUT->WRITE( | InitialDaysToFlight = { <DAYS_TO_FLIGHT>-%PARAM-INITIAL_DAYS_TO_FLIGHT } | ).
      OUT->WRITE( | ---------------           | ).
    endloop.
  endmethod.
endclass.
