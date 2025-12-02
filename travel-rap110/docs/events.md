# Events – Travel RAP Business Object

This document explains the event mechanism implemented in the Travel BO, including event raising, event handler logic, and database persistence.

---

# 1. Business Events Overview

The Travel BO raises events when a Travel instance changes its business status.

### Events:
1. **travel_accepted**
2. **travel_rejected**

These events are declared in the behavior definition of:
ZRAP110_R_TRAVELTP_00B

yaml
Copia codice

---

# 2. When Are Events Raised?

Events are triggered in the **saver class**:

LSC_ZRAP110_R_TRAVELTP_00B

markdown
Copia codice

### Raised when:
- acceptTravel action changes OverallStatus → 'A'
- rejectTravel action changes OverallStatus → 'X'

Events include:
- TravelID
- CustomerID
- AgencyID
- OverallStatus
- Description
- TotalPrice
- CurrencyCode
- Begin/EndDate

---

# 3. Event Handler Class

LHE_TRAVEL

markdown
Copia codice

Implements:

### on_travel_accepted  
### on_travel_rejected  

Both methods:
- Close modify phase (`cl_abap_tx=>save`)
- Generate UUID (via cl_system_uuid)
- Write event information into table:

ZRAP110_ETRAV00B

yaml
Copia codice

---

# 4. Event Table Structure

### `ZRAP110_ETRAV00B`

| Field           | Description |
|----------------|-------------|
| UUID           | Unique event ID |
| TravelID       | Travel affected |
| AgencyID       | Agency |
| CustomerID     | Customer |
| Event_Name     | ‘travel_accepted’ / ‘travel_rejected’ |
| OverallStatus  | Status after change |
| Created_At     | UTC timestamp |

---

# 5. Why This Implementation Is Valuable

This pattern demonstrates:

- **Event-based extension** in RAP  
- **Decoupling** BO logic from external processes  
- **Compliant with clean event-driven architecture**  
- Can be extended to:
  - Workflow triggers  
  - Notification APIs  
  - Custom side effects  
  - External integration via event mesh  

---

# 6. Testing Events

### 1. Accept a Travel in UI  
→ New entry appears in `ZRAP110_ETRAV00B`

### 2. Reject a Travel  
→ Another entry appears

### 3. Repeated updates without status change  
→ No event raised

---

The event mechanism is fully functional and production-ready.
