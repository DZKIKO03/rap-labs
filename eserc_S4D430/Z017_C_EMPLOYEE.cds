@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds employee'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: { dataClass: #MASTER,
                          serviceQuality: #D,
                          sizeCategory: #M }

define view entity Z017_C_EMPLOYEE
  as select from Z017_R_EMPLOYEE
{
  key EmployeeId,
      FirstName,
      LastName,
      BirthDate,
      EntryDate,
      DepartmentId,
      @Semantics.amount: {
          currencyCode: 'CurrencyCode'
      }
      AnnualSalary,
      CurrencyCode,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
