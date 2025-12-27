//" Allows controlled extensibility for UI-specific annotations
@Metadata.allowExtensions: true

//" Prevent propagation of annotations from interface view
@Metadata.ignorePropagatedAnnotations: true

@EndUserText: {
  label: 'Equipment'
}

//" Business object node identifier aligned with interface view
@ObjectModel: {
  sapObjectNodeType.name: 'ZEQUEQUIPMENT'
}

//" Authorization enforced at projection level
@AccessControl.authorizationCheck: #MANDATORY

//" Root projection exposing Equipment for transactional consumption
define root view entity ZEQUC_EQUIPMENT
  provider contract transactional_query
  as projection on ZEQUR_EQUIPMENT

//" Association to base interface entity
  association [1..1] to ZEQUR_EQUIPMENT     as _BaseEntity
    on $projection.EquiID = _BaseEntity.EquiID

//" Association to Category value help
  association [0..1] to Z_CATEG_SEARCH_HELP as _Category
    on $projection.Category = _Category.value
{
  key EquiID,
      Description,

      @Consumption.valueHelpDefinition:
      [ { entity: { name: 'Z_CATEG_SEARCH_HELP', element: 'value' } } ]
      @Consumption.filter.selectionType: #SINGLE
      @ObjectModel.text.association: '_Category'
      Category,

      SerialNumb,
      Location,

      @Consumption.filter.defaultValue: 'X'
      IsActive,

      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,

      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,

      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LocalLastChangedBy,

      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,

//" Redirect composition to Order projection
      _ORDER : redirected to composition child ZORDC_ORDER_MAN000,

      _BaseEntity,
      _Category
}
