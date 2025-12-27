
# Equipment Maintenance – RAP Managed Application

## Overview
This project is a custom SAP ABAP Cloud application built with the RESTful ABAP Programming Model (RAP).

It manages **Equipment** master data and their related **Maintenance Orders**, implemented using a **managed RAP scenario with draft handling**, feature control, actions, determinations, and validations.

The project is fully custom and focuses on demonstrating correct RAP modeling, clean separation of concerns, and business-rule-driven behavior.

---

## Business Context
- Equipment represents a physical asset.
- Maintenance Orders represent corrective or operational activities related to an Equipment.
- Orders exist only in the context of an Equipment and follow a controlled lifecycle.

Key rules:
- Orders can be created only when the Equipment is active.
- Deactivating an Equipment automatically cancels open (Created) orders.
- Order lifecycle is controlled through explicit business actions.

---

## Technical Highlights
- RAP **managed** scenario
- **Strict mode level 2**
- **Draft-enabled** transactional processing
- **Composition** relationship (Equipment → Orders)
- **Late numbering** for business keys
- **Dynamic feature control** for UI and backend consistency
- **OData V4** service exposure
- Designed for **Fiori Elements** consumption

---

## Data Model
- Custom persistent tables:
  - `ZEQUIPMENT` – Equipment master data
  - `ZORDER_MAN` – Maintenance Orders
- Draft tables are generated and managed by the RAP runtime.
- Reference data handled via custom domains and data elements.

Details:
- See `rap-model/data-model/`

---

## RAP Behavior Model
- Equipment is the **root BO**
- Maintenance Order is a **composed child entity [0..*]**
- Draft lifecycle with optimized activation
- Business logic implemented via:
  - Validations
  - Determinations
  - Actions
  - Instance feature control

Details:
- See `rap-model/behavior/`

---

## Business Rules & Lifecycle
### Equipment
- IsActive is defaulted on create
- Category is validated against reference data
- Deactivation triggers warnings and order cancellation

### Maintenance Order
- Status lifecycle: Created → Release → Complete / Cancel
- Priority defaulting
- Actions control all state transitions
- Update/Delete restricted based on status

Details:
- See `docs/business-rules.md`

---

## Architecture & Design Decisions
The solution follows Clean Core and ABAP Cloud principles:
- No standard SAP PM integration
- No implicit persistence logic
- Explicit lifecycle control
- Centralized business rule enforcement in RAP behavior

Details:
- `docs/architecture.md`
- `docs/technical-decisions.md`

---

## Service Exposure
- Protocol: **OData V4**
- Draft-enabled
- Intended for Fiori Elements List Report / Object Page applications

Details:
- `rap-model/services/service-binding.md`

---

## Project Structure
equipment-maintenance-rap/
---

## Purpose of This Project
This project is intended to demonstrate:
- Correct usage of RAP managed + draft
- Clean separation between model, behavior, and implementation
- Business-rule-driven feature control and actions
- Readiness for technical interviews and real-world RAP projects

├── src/abap/ # RAP source artifacts (behavior, CDS, classes, DDIC)
├── docs/ # Architecture and design documentation
├── rap-model/ # Conceptual RAP model documentation
└── screenshots/ # Application runtime evidence

