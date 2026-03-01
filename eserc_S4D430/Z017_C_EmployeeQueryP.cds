@AbapCatalog: { dataMaintenance: #RESTRICTED,
                viewEnhancementCategory: [#PROJECTION_LIST],
                extensibility: { dataSources: [ 'Employee' ],
                                 elementSuffix: 'ZEM' } }
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds path expression'
@Metadata.ignorePropagatedAnnotations: true
@Metadata: {
    allowExtensions: true
}
define view entity Z017_C_EmployeeQueryP
  with parameters
//  solo per esposizione fiori odata recupera da default
  @Consumption: {
      defaultValue: 'USD'
  }
    p_target_curr : /dmo/currency_code,
    @Environment: {
        systemField: #SYSTEM_DATE
    }
    p_date        : abap.dats 
  as select from Z017_R_EMPLOYEE as Employee
  
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
      $parameters.p_target_curr                                                                as CurrencyCode,
      //      @EndUserText.label: 'Annual Salary'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      currency_conversion( amount => AnnualSalary,
      source_currency => CurrencyCode ,
       target_currency => CurrencyCode,
        exchange_rate_date => $parameters.p_date )                                             as AnnualSalaryConverted,
      
      //      @Semantics.amount.currencyCode: 'CurrencyCode'
      cast($projection.AnnualSalaryConverted as abap.fltp  ) / 12.0                            as MonthlySalary,
      //      CurrencyCode,
      division( dats_days_between( EntryDate, $session.system_date ),365,1 )                   as CompanyAffiliation,
      /* Associations */
      _Department
}
