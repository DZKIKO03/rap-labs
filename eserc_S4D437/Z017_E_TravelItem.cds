@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.extensibility: {
        extensible: true,
        allowNewDatasources: false,
        dataSources: [ 'item' ],
        elementSuffix: 'Z99'
 }
define view entity Z017_E_TravelItem
  as select from z017_tritem as item
{
  key item_uuid as ItemUuid
}
