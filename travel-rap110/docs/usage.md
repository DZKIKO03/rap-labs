# Usage Guide – Travel RAP Business Object

This document explains how to use the Travel application through:
- The Fiori Elements UI
- OData V4 API calls
- EML (Entity Manipulation Language)

---

# 1. Fiori UI Usage

Open the UI from the active service binding.

You will see:

### Travel List Page
- Travel ID
- Customer
- Agency
- Booking Fee
- Total Price
- Overall Status (with indicator)
- Actions: Accept, Reject

### Travel Object Page
- Editable fields
- Booking table
- File upload area
- Status indicator
- Navigation to bookings

### Booking Table
Shows:
- Carrier
- Connection
- Flight date
- Booking price
- Days-to-flight indicators
- BookingStatus indicator

---

# 2. Travel Actions

### Accept Travel
Executes:
action Travel~acceptTravel

vbnet
Copia codice
Sets overall status to **A** (Accepted), raises an event, writes to event table.

### Reject Travel
Executes:
action Travel~rejectTravel

csharp
Copia codice
Sets status to **X** (Rejected) + raises event.

### Create Travel (factory)
action Travel~createTravel

yaml
Copia codice
Creates:
- 1 Travel instance
- 1 default Booking (based on DMO flight data)

---

# 3. Virtual Elements

### Booking
- InitialDaysToFlight  
- RemainingDaysToFlight  
- DaysToFlightIndicator (1–4)  
- BookingStatusIndicator (1–3)

### Travel
- OverallStatusIndicator (1–3)

These values are calculated dynamically using SADL exit classes.

---

# 4. Validations

On save:
- BeginDate < EndDate enforced
- BeginDate cannot be in the past
- Customer must exist
- Agency must exist
- BookingStatus must be valid

Errors are returned via RAP messages.

---

# 5. OData Usage Examples

### GET all Travel
GET /Travel

shell
Copia codice

### GET one Travel
GET /Travel(TravelID='0001')

shell
Copia codice

### GET Bookings of a Travel
GET /Travel(TravelID='0001')/Booking

pgsql
Copia codice

### POST create Travel
```json
{
  "CustomerID": "000001",
  "AgencyID": "070001",
  "BeginDate": "2025-01-01",
  "EndDate": "2025-01-10",
  "CurrencyCode": "EUR"
}
POST create Travel + Booking (factory action)
json
Copia codice
{
  "customer_id": "000001",
  "carrier_id": "AA",
  "connection_id": "0400",
  "flight_date": "2025-03-12"
}
6. EML Usage
Run class:

nginx
Copia codice
ZRAP110_EML_PLAYGROUND_00B
Example code fragment:

abap
Copia codice
READ ENTITIES OF ZRAP110_R_TravelTP_00B
  ENTITY Travel
    FIELDS ( TravelID CustomerID BeginDate EndDate )
    WITH VALUE #( ( TravelID = '0003' ) )
  RESULT DATA(result).
7. Events
Whenever a Travel is:

Accepted → event travel_accepted

Rejected → event travel_rejected

These events generate entries in:

nginx
Copia codice
ZRAP110_ETRAV00B
The system is now fully ready for end-to-end usage.

yaml
Copia codice

---

# ✅ **3. `data-model.md`**

```markdown
# Data Model – Travel RAP Business Object

This document describes the physical and logical data model used in the Travel RAP implementation.

---

# 1. Entities

## Root Entity – Travel
Represents one travel request.

Key attributes:
- TravelID
- CustomerID
- AgencyID
- BeginDate / EndDate
- BookingFee
- TotalPrice
- CurrencyCode
- OverallStatus
- Attachment (LOIO)
- Change / creation metadata

## Child Entity – Booking
Represents flight bookings associated with a travel.

Key attributes:
- BookingID
- TravelID (foreign key)
- CustomerID
- CarrierID
- ConnectionID
- FlightDate
- BookingStatus
- FlightPrice
- CurrencyCode

---

# 2. Physical Tables

### Travel Active Table
`ZRAP110_ATRAV00B`

### Booking Active Table
`ZRAP110_ABOOK00B`

### Draft Tables
- `ZRAP110_DTRAV00B`
- `ZRAP110_DBOOK00B`

### Event Table
`ZRAP110_ETRAV00B`

---

# 3. Associations

### Travel → Booking (Composition)
Travel 1 --- 0..* Booking

yaml
Copia codice

### Travel → Agency
1..1 optional

### Travel → Customer
1..1 optional

### Booking → Carrier / Connection / Flight
1..1 mandatory (DMO flight model)

---

# 4. CDS Layer Overview

| Layer | Entity | Purpose |
|-------|--------|----------|
| R-View | `ZRAP110_R_TRAVELTP_00B` | Persistence view |
| R-View | `ZRAP110_R_BOOKINGTP_00B` | Persistence view |
| C-View | `ZRAP110_C_TRAVELTP_00B` | OData + UI consumption |
| C-View | `ZRAP110_C_BOOKINGTP_00B` | OData + UI consumption |
| I-View | `ZRAP110_I_TRAVELTP_00B` | Integration / API |
| I-View | `ZRAP110_I_BOOKINGTP_00B` | Integration / API |

---

# 5. Draft & ETAG

Each root and child entity supports:
- Draft versioning
- ETag fields:
  - `LocalLastChangedAt`
  - `LastChangedAt` (Travel)

---

# 6. Additional Entities

### Abstract Parameter Entities
- `ZRAP110_A_TRAVEL_00B`  
- `ZRAP110_A_CREATE_TRAVEL_00B`  
- `ZRAP110_A_DAYS_TO_FLIGHT_00B`

### Purpose
- Input parameters for actions (createTravel)
- Virtual element outputs (days to flight)

---

# 7. Key Business Rules

### Price Calculation
TotalPrice = BookingFee + SUM(Booking price in Travel currency)

### Numbering
- TravelID → number range ZRAP11000B  
- BookingID → max(existing)+10 for each Travel

### Status Indicators
Calculated via SADL exits based on date/booking status.
