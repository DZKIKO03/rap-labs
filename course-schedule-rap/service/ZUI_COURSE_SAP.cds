@EndUserText.label: 'Servizio corso rap'
define service ZUI_COURSE_SAP {
  expose ZC_COURSE_SAP_RAP as rap;
  expose ZC_COURSE_SCHED   as sched;
  expose I_Country         as country;
  expose I_Currency        as currency;
}
