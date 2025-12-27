# Actions

## Maintenance Order Actions

### releaseOrder
- Purpose: move order to Release state
- Backend effect: sets Status = 'Release'
- Availability:
  - Enabled when Status is not Release, not Complete, not Cancel
  - Intended transition: Created -> Release

### completedOrder
- Purpose: finalize an order
- Backend effect:
  - sets Status = 'Complete'
  - sets CompletionDate if empty
- Availability:
  - Disabled when Status is Complete or Cancel

### cancelledOrder
- Purpose: terminate an order
- Backend effect: sets Status = 'Cancel'
- Availability:
  - Disabled when Status is Complete or Cancel

