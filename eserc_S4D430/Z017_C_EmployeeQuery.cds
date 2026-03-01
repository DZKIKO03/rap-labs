@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds path expression'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z017_C_EmployeeQuery
  as select from Z017_R_EMPLOYEE
{
  key EmployeeId,
      FirstName,
      LastName,
      DepartmentId,
      _Department.Description                                                                  as DepartmentDescription,
      //      _Department._Assistant.LastName          as AssistantName,
      concat_with_space( _Department._Assistant.FirstName, _Department._Assistant.LastName, 1) as AssistantName,
      @EndUserText: {
          label: 'Employee Role'
      }
      case
      when EmployeeId = _Department.DepartmentHead
      then 'H'
      when EmployeeId = _Department.DepartmentAssistant
      then 'A'
      else ''
      end                                                                                      as EmployeeRole,
      //      @Semantics.amount: {
      //          currencyCode: 'CurrencyCode'
      //      }
      //      AnnualSalary,
      @EndUserText: {
          label: 'Currency'
      }
      cast( 'USD' as /dmo/currency_code )                                                      as CurrencyCodeUSD,
      @EndUserText.label: 'Annual Salary' @Semantics.amount.currencyCode: 'CurrencyCodeUSD'
      currency_conversion( amount => AnnualSalary,
      source_currency => CurrencyCode ,
       target_currency => $projection.CurrencyCodeUSD,
        exchange_rate_date => $session.system_date )                                           as AnnualSalaryConverted,
      @EndUserText.label: 'Monthly Salary'
      //      @Semantics.amount.currencyCode: 'CurrencyCode'
      cast($projection.AnnualSalaryConverted as abap.fltp  ) / 12.0                            as MonthlySalary,
      //      CurrencyCode,
      division( dats_days_between( EntryDate, $session.system_date ),365,1 )                   as CompanyAffiliation,
      /* Associations */
      _Department
}
