# Business Rules

## Equipment Rules

### Defaulting
- On Equipment create, IsActive is defaulted to true.
  - Determination: set_default_isactive (on modify, create)

### Mandatory Fields
- Description is mandatory
- Category is mandatory

### Category Validation
- Category must exist in the custom reference table z_categ_search_help.
  - Validation: validate_category (on save)
  - Invalid category blocks save with an error message and field marking.

### Deactivation Warning
- If Equipment is set to inactive and related orders exist (excluding already cancelled orders), a warning message is raised.
  - Validation: warn_isactive (on save)
  - Warning does not block save.

### Deactivation Cancels Open Orders
- If Equipment becomes inactive, all related orders still in status Created are cancelled.
  - Determination: cancel_order (on save)
  - Only orders in status Created are cancelled (Released/Complete are not changed).

## Maintenance Order Rules

### Mandatory Fields
- Description is mandatory
- ReportedBy is mandatory

### Defaulting on Create
- Status defaults to Created
- CreationDate defaults to current timestamp
  - Determination: set_defaults (on modify, create)

### Default Priority
- If Priority is not provided during creation, it defaults to 'M' (Medium).
  - Determination: set_priority (on modify, create)

## Order Lifecycle and Status Transitions

### Status Values
- Created
- Release
- Complete
- Cancel

### Actions
- releaseOrder:
  - Sets Status to Release
  - Allowed only when current status is Created
- completedOrder:
  - Sets Status to Complete
  - Sets CompletionDate if empty
  - Allowed only when current status is not Complete and not Cancel
- cancelledOrder:
  - Sets Status to Cancel
  - Allowed only when current status is not Complete and not Cancel

### Update/Delete Rules
- Update and Delete are disabled when Status is Complete or Cancel.
- Update/Delete are enabled in Created and Release.

## Cross-Entity Rule: Order Creation
- Order creation is disabled when Equipment is inactive.
- Order creation is enabled when Equipment is active.
This is enforced via feature control on the composition association _ORDER.

