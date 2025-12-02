# Setup Guide – Travel RAP Business Object

This document explains how to set up, deploy, and run the **Travel RAP Business Object** from the `travel-rap110` repository on an ABAP environment (Steampunk / ABAP Cloud / BTP Trial).

---

# 1. Prerequisites

### Mandatory
- SAP BTP ABAP Environment or ABAP Cloud (Steampunk)
- ADT (ABAP Development Tools) latest version
- `/DMO/*` flight reference data model available
- Active user with developer authorizations
- abapGit installed (ADT plugin)
- System supports RAP (>= ABAP Platform 2021+)

### Optional
- Fiori preview via service binding
- SAP Gateway Client (if using on-premise)

---

# 2. Import the Repository

1. Clone the GitHub repo locally  
2. Open ADT → File → Import → abapGit Repositories  
3. Choose:
   - **Pull** into your ABAP Cloud package (e.g., `/ZRAP110/`)
4. Activate all objects (ADT will propose mass-activation)

---

# 3. Create Number Range for TravelID

The root Travel entity requires automatic number assignment.

Run the executable class:

ZCL_CREATE_INTERVAL

yaml
Copia codice

This creates the following number ranges for object **ZRAP11000B**:

| Range | From      | To        |
|-------|-----------|-----------|
| 01    | 00000001  | 19999999  |
| 02    | 20000000  | 29999999  |

---

# 4. Activate the OData V4 Service Binding

Navigate to:

Service Binding → ZRAP110_UI_TRAVEL_00B

yaml
Copia codice

1. Activate the binding  
2. Select: **OData V4 – UI**  
3. Publish the service  
4. Test in Fiori Elements preview

---

# 5. Optional: Initialize Sample Data

You can add sample Travel or Booking records manually or using scripts in:

script/eml_playground.abap

cpp
Copia codice

Run class:

ZRAP110_EML_PLAYGROUND_00B

yaml
Copia codice

---

# 6. Run the Application

### Via Fiori preview
- Open the service binding
- Use “Preview” → “Travel” application
- Supports draft, actions, attachments, indicators

### Via EML
Use `ZRAP110_EML_PLAYGROUND_00B` to test:
- Reads
- Virtual elements
- getDaysToFlight execution

### Via OData API
Use your service binding URL, e.g.:

/sap/opu/odata4/sap/zrap110_ui_travel_00b/srvd_a2x/sap/travel/0001/

yaml
Copia codice

---

# 7. Deployment Checklist

✔ R-, C-, I- views activated  
✔ Behavior definitions activated  
✔ Handler classes activated  
✔ Saver class activated  
✔ Number range object exists  
✔ Service binding active  
✔ Fiori UI reachable  
✔ /DMO data model available  

The system should now run the complete Travel RAP application end to end.
