# Feature Control

## Equipment Instance Features

### Association _ORDER create
- Disabled when Equipment IsActive is false/initial
- Enabled when Equipment IsActive is true

### Field IsActive
- Read-only when blocking orders exist:
  - If related orders have Status = 'Release' or 'Complete'
- Unrestricted otherwise

### Update/Delete on Equipment
- Disabled when completed orders exist
- Enabled otherwise

## Maintenance Order Instance Features

### Actions
- releaseOrder / completedOrder / cancelledOrder are enabled/disabled based on current Status:
  - Disabled for Complete and Cancel where applicable
  - Enabled for valid transitions

### Update/Delete
- Disabled when Status is Complete or Cancel
- Enabled in Created and Release

