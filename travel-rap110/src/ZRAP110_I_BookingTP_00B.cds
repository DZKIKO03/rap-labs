@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forBooking'
define view entity ZRAP110_I_BookingTP_00B 
  as projection on ZRAP110_R_BOOKINGTP_00B as Booking
{
  key TravelID,
  key BookingID,
  BookingDate,
  CustomerID,
  CarrierID,
  ConnectionID,
  FlightDate,
  BookingStatus,
  FlightPrice,
  CurrencyCode,
  LocalLastChangedAt,
  _Travel : redirected to parent ZRAP110_I_TravelTP_00B,
  _Customer,
  _Carrier,
  _Connection,
  _Flight,
  _BookingStatus,
  _Currency
}
