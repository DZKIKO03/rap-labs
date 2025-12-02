# Behavior Flow – Travel RAP Business Object

This document explains the complete behavior orchestration of the Travel RAP BO: CRUD, determinations, validations, actions, late numbering, feature control and event raising.

---

# 1. Create Flow

### 1. User creates Travel (draft)
- Draft record created in `ZRAP110_DTRAV00B`

### 2. Determination: `setInitialTravelValues`
- Default BeginDate, EndDate, Currency, OverallStatus

### 3. User adds Bookings
- Draft entry created in `ZRAP110_DBOOK00B`

### 4. Determination: `setInitialBookingValues`
- Default BookingStatus = N (New)
- BookingDate = Today
- CustomerID inherited from Travel

### 5. Save / Activate Draft
Triggers:
- Validation: Agency  
- Validation: Customer  
- Validation: Dates  
- Validation: BookingStatus  

### 6. Late Numbering (Saver Class)
- TravelID assigned via number range
- BookingID assigned via local max+10 logic

### 7. Determination: `calculateTotalPrice`
Executed on:
- Travel save
- Booking modification

---

# 2. Update Flow

Any modification to:
- BookingFee  
- CurrencyCode  
- Booking.FlightPrice  
Triggers recalculation via:
action Travel~recalcTotalPrice

yaml
Copia codice

---

# 3. Delete Flow

Rules enforced via **feature control**:
- Travel with `Accepted` cannot be edited or deleted
- Booking deletions allowed unless parent Travel is locked by status

---

# 4. Actions Flow

### acceptTravel
1. Set OverallStatus = A  
2. Save  
3. Event raised → `travel_accepted`  
4. Event handler writes entry to event table

### rejectTravel
1. Set OverallStatus = X  
2. Save  
3. Event raised → `travel_rejected`  
4. Handler writes to DB

### createTravel (factory)
Based on provided parameters:
- Creates Travel  
- Creates one Booking via composition  
- Prepopulates fields using DMO flight data  

---

# 5. Side Effects

### From Booking to Travel
Changes in:
- FlightPrice  
- CurrencyCode  

Affect:
- Travel.TotalPrice

### From Travel Dates
Validation messages shown in UI.

---

# 6. Virtual Elements Flow

### Booking virtual elements
Calculated in:
ZRAP110_CALC_BOOK_ELEM_00B

shell
Copia codice

### Travel status indicator
Calculated in:
ZRAP110_CALC_TRAV_ELEM_00B

pgsql
Copia codice

Both executed on READ or UI load.
