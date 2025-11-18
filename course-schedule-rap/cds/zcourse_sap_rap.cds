@EndUserText.label : 'Test tabella course 1'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zcourse_sap_rap {

  key client            : abap.clnt not null;
  key course_uuid       : abap.raw(16) not null;
  course_id             : abap.char(10);
  course_name           : abap.sstring(60);
  course_lenght         : abap.int1;
  country               : land1;

  @Semantics.amount.currencyCode : 'zcourse_sap_rap.currency_code'
  price                 : abap.curr(6,2);

  currency_code         : abap.cuky;
  last_changed_at       : timestampl;
  local_last_changed_at : timestampl;

}
