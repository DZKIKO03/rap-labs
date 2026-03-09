@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata: {
    allowExtensions: true
}
@Search: {
    searchable: true
}
define root view entity Z017_C_Travel
  provider contract transactional_query
  as projection on Z017_R_Travel
{
  key AgencyId,
  key TravelId,
      @Search: {
          defaultSearchElement: true
      }

      Description,
      @Search: {
      defaultSearchElement: true
      }
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Customer_StdVH', element: 'CustomerID'  } } ]
      CustomerId,
      BeginDate,
      EndDate,
      @EndUserText: {
          label: 'Duration (days)'
      }
      Duration,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt,
      _TravelItem: redirected to composition child Z017_C_TravelItem
}
