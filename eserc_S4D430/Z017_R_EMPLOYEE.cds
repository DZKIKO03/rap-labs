@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds employee'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog: { dataMaintenance: #RESTRICTED,
                viewEnhancementCategory: [#PROJECTION_LIST],
                extensibility: { dataSources: [ 'Employee' ],
                                 elementSuffix: 'ZEM' } }
@ObjectModel.usageType: { dataClass: #MASTER,
                          serviceQuality: #D,
                          sizeCategory: #M }

define view entity Z017_R_EMPLOYEE 
  as select from z017employ as Employee
  association [1..1] to Z017_R_DEPARTMENT as _Department on $projection.DepartmentId = _Department.Id
{
  key employee_id           as EmployeeId,
      first_name            as FirstName,
      last_name             as LastName,
      birth_date            as BirthDate,
      entry_date            as EntryDate,
      department_id         as DepartmentId,
      @Semantics.amount: {
          currencyCode: 'CurrencyCode'
      }
      annual_salary         as AnnualSalary,
      @EndUserText: {
          label: 'Currency key'
      }
      currency_code         as CurrencyCode,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _Department
}
