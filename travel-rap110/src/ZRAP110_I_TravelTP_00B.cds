@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forTravel'
define root view entity ZRAP110_I_TravelTP_00B
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZRAP110_R_TRAVELTP_00B as Travel
{
  key TravelID, 
  AgencyID,
  CustomerID,
  BeginDate,
  EndDate,
  BookingFee,
  TotalPrice,
  CurrencyCode,
  Description,
  OverallStatus,
  Attachment,
  MimeType,
  FileName,
  LastChangedAt,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  _Booking : redirected to composition child ZRAP110_I_BookingTP_00B,
  _Agency,
  _Customer,
  _OverallStatus,
  _Currency
}
