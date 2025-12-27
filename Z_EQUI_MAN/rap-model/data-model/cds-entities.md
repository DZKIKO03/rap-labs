# CDS Entities

## Root Entity: Equipment
- Persistent table: ZEQUIPMENT
- Business key: EquiID (NUMC 8)
- Key fields:
  - EquiID
- Main fields:
  - Description
  - Category (ZCATEG_DE)
  - SerialNumb
  - Location
  - IsActive
- Administrative fields:
  - CreatedBy, CreatedAt
  - LocalLastChangedBy, LocalLastChangedAt (ETag source)

## Child Entity: Maintenance Order
- Persistent table: ZORDER_MAN
- Business key: OrderID (NUMC 8)
- Foreign key:
  - EquipmentID references Equipment EquiID
- Main fields:
  - Priority (ZPRIOR_DE)
  - Status (CHAR 10)
  - ReportedBy
  - Description
  - CreationDate
  - CompletionDate
- Administrative fields:
  - CreatedBy, CreatedAt
  - LocalLastChangedBy, LocalLastChangedAt (ETag source)

