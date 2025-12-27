//" Authorization enforced at CDS level, aligned with root BO security
@AccessControl.authorizationCheck: #MANDATORY

//" Allows controlled extensibility following Clean Core principles
@Metadata.allowExtensions: true

//" Business object node identifier for Order entity
@ObjectModel.sapObjectNodeType.name: 'ZORDORDER_MAN000'

@EndUserText.label: 'Order'

//" Order entity representing Maintenance Orders
define view entity ZORDR_ORDER_MAN000
  as select from zorder_man

//" Association to parent Equipment (dependent entity)
association to parent ZEQUR_EQUIPMENT as _equi
  on $projection.EquipmentID = _equi.EquiID
{
  key order_id              as OrderID,
      equipment_id          as EquipmentID,

      @Search.defaultSearchElement: true
      priority              as Priority,

      status                as Status,
      reported_by           as ReportedBy,
      description           as Description,
      creation_date         as CreationDate,
      completion_date       as CompletionDate,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _equi
}
