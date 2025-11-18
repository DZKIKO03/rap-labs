@EndUserText.label : 'Test tabella course 2'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED

define table zcourse_sched {

  key client            : abap.clnt not null;
  key schedule_uuid     : abap.raw(16) not null;
  course_begin          : abap.dats;
  course_uuid           : abap.raw(16);
  location              : abap.sstring(60);
  trainer               : abap.sstring(60);
  is_online             : abap_boolean;
  last_changed_at       : timestampl;
  local_last_changed_at : timestampl;

}
