# Determinations

## Equipment

### set_default_isactive (on modify, create)
- Sets IsActive = true when not provided
- Ensures new Equipment is active by default

### cancel_order (on save)
- Trigger: Equipment IsActive changed to inactive
- Effect: cancels related orders still in status Created
- Invariant: inactive Equipment must not have open Created orders

## Maintenance Order

### set_priority (on modify, create)
- Sets Priority = 'M' when not provided

### set_defaults (on modify, create)
- Sets initial lifecycle values:
  - Status = 'Created' (if empty)
  - CreationDate = current timestamp (if empty)

