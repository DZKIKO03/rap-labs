//" Authorization enforced at CDS level, aligned with root BO security
@AccessControl.authorizationCheck: #MANDATORY
//" Allows controlled extensibility following Clean Core principles
@Metadata.allowExtensions: true
//" Business object node identifier for integration and tooling
@ObjectModel.sapObjectNodeType.name: 'ZEQUEQUIPMENT'
@EndUserText.label: 'Equipment'
//  " Root entity representing Equipment master data
define root view entity ZEQUR_EQUIPMENT
  as select from zequipment
  composition [0..*] of ZORDR_ORDER_MAN000 as _ORDER
{
  key equi_id               as EquiID,
      description           as Description,
      category              as Category,
      serial_numb           as SerialNumb,
      location              as Location,
      is_active             as IsActive,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _ORDER
}
