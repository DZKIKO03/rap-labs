@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection Course'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_COURSE_SAP_RAP
  as projection on ZI_COURSE_SAP_RAP
{
    key COURSEUUID,

    @Search.defaultSearchElement: true
    courseid,

    @Search.defaultSearchElement: true
    COURSENAME,

    COURSELENGHT,

    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_COUNTRY', element: 'Country'} }]
    COUNTRY,

    @Semantics.amount.currencyCode: 'CurrencyCode'
    PRICE,

    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency'} }]
    CURRENCYCODE,

    LASTCHANGEDAT,
    LOCALLASTCHANGEDAT,

    /* Associations */
    _COUNTRY,
    _CURRENCY,
    _SCHEDULE : redirected to composition child ZC_COURSE_SCHED
}
