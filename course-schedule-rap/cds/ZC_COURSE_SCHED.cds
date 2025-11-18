@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection Course Schedule'
@Metadata.allowExtensions: true
define view entity ZC_COURSE_SCHED
  as projection on ZI_COURSE_SCHED
{
  key scheduleuuid,
      coursebegin,
      courseuuid,

      @Search.defaultSearchElement: true
      location,

      @Search.defaultSearchElement: true
      trainer,

      isonline,
      lastchangedat,
      LOCALLASTCHANGEDAT,

      /* associations */
      _COURSE : redirected to parent ZC_COURSE_SAP_RAP
}
