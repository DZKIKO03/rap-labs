# Behavior Definition

## Scenario
- Managed RAP
- Strict mode 2
- Draft enabled (optimized activation)
- Extensible behavior

## Equipment (Root)
- Persistent: ZEQUIPMENT
- Draft: ZEQUEQUIPMENT_D
- ETag: LocalLastChangedAt
- Lock: master total (root controls transaction)
- Authorization: master (global placeholder)
- Numbering: late numbering
- Additional save with full data enabled

Operations:
- create enabled
- update/delete controlled by instance features
- IsActive field controlled by instance features

## Maintenance Order (Child)
- Persistent: ZORDER_MAN
- Draft: ZORDORDER_MAN_D
- ETag: LocalLastChangedAt
- Lock: dependent by _equi
- Authorization: dependent by _equi
- Numbering: late numbering
- Additional save with full data enabled

Operations:
- update/delete controlled by instance features
- actions controlled by instance features

