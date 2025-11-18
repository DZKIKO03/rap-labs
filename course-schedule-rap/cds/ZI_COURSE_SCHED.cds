@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS ZCOURSE_SCHED'

define view entity ZI_COURSE_SCHED 
  as select from zcourse_sched as SCHEDULE
  association to parent ZI_COURSE_SAP_RAP as _COURSE 
    on $projection.courseuuid = _COURSE.COURSEUUID
{
  key SCHEDULE.schedule_uuid      as scheduleuuid,
      SCHEDULE.course_begin       as coursebegin,
      SCHEDULE.course_uuid        as courseuuid,
      SCHEDULE.location           as location,
      SCHEDULE.trainer            as trainer,
      SCHEDULE.is_online          as isonline,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      SCHEDULE.last_changed_at    as lastchangedat,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      SCHEDULE.local_last_changed_at as LOCALLASTCHANGEDAT,

      _COURSE
}
