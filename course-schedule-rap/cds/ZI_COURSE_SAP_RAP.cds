@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cds zcourse_sap_rap'
define root view entity ZI_COURSE_SAP_RAP
  as select from zcourse_sap_rap as COURSE
  composition [0..*] of ZI_COURSE_SCHED as _SCHEDULE
  association [0..1] to I_Currency      as _CURRENCY on $projection.CURRENCYCODE = _CURRENCY.Currency
  association [0..1] to I_Country       as _COUNTRY  on $projection.COUNTRY = _COUNTRY.Country
{
  key COURSE.course_uuid           as COURSEUUID,
      COURSE.course_id             as courseid,
      COURSE.course_name           as COURSENAME,
      COURSE.course_lenght         as COURSELENGHT,
      COURSE.country               as COUNTRY,
      COURSE.price                 as PRICE,
      COURSE.currency_code         as CURRENCYCODE,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      COURSE.last_changed_at       as LASTCHANGEDAT,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      COURSE.local_last_changed_at as LOCALLASTCHANGEDAT,

      _SCHEDULE,
      _CURRENCY,
      _COUNTRY
}
