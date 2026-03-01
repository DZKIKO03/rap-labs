@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds path expression'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z017_C_DepartmentQuery
  with parameters
    p_target_curr : /dmo/currency_code,
    @EndUserText.label: 'Date of evaluation'
    @Environment.systemField: #SYSTEM_DATE
    p_date        : abap.dats
  as select from     Z017_C_EmployeeQueryP(
                     p_target_curr: $parameters.p_target_curr,
                     p_date: $parameters.p_date ) as query
    right outer join Z017_R_DEPARTMENT            as department on department.Id = query.DepartmentId
{
  department.Id,
  department.Description,
  avg( query.CompanyAffiliation as abap.dec(11,1) ) as CompanyAffiliation,
  @Semantics.amount: {
      currencyCode: 'CurrencyCode'
  }
  sum( query.AnnualSalaryConverted )                as AnnualSalaryConverted,
  query.CurrencyCode
}
group by
  department.Id,
  department.Description,
  query.CurrencyCode
