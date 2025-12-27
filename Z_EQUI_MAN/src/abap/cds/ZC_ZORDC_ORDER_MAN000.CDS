//" Allows controlled extensibility for UI-specific annotations
@Metadata.allowExtensions: true

//" Prevent propagation of annotations from interface view
@Metadata.ignorePropagatedAnnotations: true

@EndUserText: {
  label: 'Order'
}

//" Business object node identifier aligned with interface view
@ObjectModel: {
  sapObjectNodeType.name: 'ZORDORDER_MAN001'
}

//" Authorization enforced at projection level
@AccessControl.authorizationCheck: #MANDATORY

//" Projection view exposing Order entity for consumption layer
define view entity ZORDC_ORDER_MAN000
  as projection on ZORDR_ORDER_MAN000

//" Association to base interface entity
  association [1..1] to ZORDR_ORDER_MAN000     as _BaseEntity
    on $projection.OrderID = _BaseEntity.OrderID

//" Association to Priority value help
  association [0..1] to Z_PRIORITY_SEARCH_HELP as _PRIORITY
    on $projection.Priority = _PRIORITY.value
{
  key OrderID,
      EquipmentID,

      @Consumption.valueHelpDefinition:
      [ { entity: { name: 'Z_PRIORITY_SEARCH_HELP', element: 'value' } } ]
      @Consumption.filter.mandatory: true
      @Consumption.filter.selectionType: #SINGLE
      @ObjectModel.text.association: '_PRIORITY'
      Priority,

      Status,
      ReportedBy,
      Description,
      CreationDate,
      CompletionDate,

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

//" Redirect association to parent Equipment projection
      _equi : redirected to parent ZEQUC_EQUIPMENT,

      _PRIORITY,
      _BaseEntity
}
