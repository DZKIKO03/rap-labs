# RAP Labs – ABAP Cloud & RESTful ABAP Programming Model

This repository contains a collection of projects and exercises based on the
**RESTful ABAP Programming Model (RAP)**, developed in the **SAP BTP ABAP Environment**.

The goal of this repository is to consolidate RAP concepts through
hands-on implementations, following **Clean Core** and **ABAP Cloud** principles,
and to serve as a long-term reference for real-world RAP development.

---

## Scope of the Repository

This repository covers the full RAP stack, including:

- CDS-based data modeling
- Managed RAP scenarios
- Behavior definitions and implementations
- Validations, determinations, and actions
- Draft-enabled transactional processing
- Feature control driven by business rules
- OData V2 / OData V4 service exposure
- Fiori Elements consumption

Projects range from learning-oriented exercises (RAP100 / RAP110)
to complete, interview-ready RAP applications.

---

## Projects

### Equipment Maintenance – Managed RAP Application

**Path:** `Z_EQUI_MAN/`

A complete RAP managed application implementing a real-world scenario:

- Root / child composition (Equipment → Maintenance Orders)
- Managed RAP with **strict mode level 2**
- **Draft-enabled** transactional handling
- Business-rule-driven **feature control**
- Actions controlling lifecycle transitions
- Determinations and validations
- Late numbering for business keys
- OData **V4** service exposure
- Fiori Elements List Report / Object Page UI

This project is intended as a **reference implementation**
for managed RAP applications and technical interviews.

---

## Project Architecture (General)

All projects in this repository follow the standard RAP layered architecture:

- **Data Model Layer**
  - CDS entities and projections
  - Associations and value helps
  - Semantic annotations

- **Behavior Layer**
  - Behavior definitions (BDEF)
  - Behavior implementation classes
  - Actions, determinations, validations
  - Feature control and draft handling

- **Service Layer**
  - Service definitions
  - Service bindings (OData V2 / V4)

- **UI Layer**
  - Fiori Elements (when applicable)
  - Local annotations

---

## Repository Structure

Each project inside this repository follows a consistent structure:

# RAP Labs – ABAP Cloud & RESTful ABAP Programming Model

This repository contains a collection of projects and exercises based on the
**RESTful ABAP Programming Model (RAP)**, developed in the **SAP BTP ABAP Environment**.

The goal of this repository is to consolidate RAP concepts through
hands-on implementations, following **Clean Core** and **ABAP Cloud** principles,
and to serve as a long-term reference for real-world RAP development.

---

## Scope of the Repository

This repository covers the full RAP stack, including:

- CDS-based data modeling
- Managed RAP scenarios
- Behavior definitions and implementations
- Validations, determinations, and actions
- Draft-enabled transactional processing
- Feature control driven by business rules
- OData V2 / OData V4 service exposure
- Fiori Elements consumption

Projects range from learning-oriented exercises (RAP100 / RAP110)
to complete, interview-ready RAP applications.

---

## Projects

### Equipment Maintenance – Managed RAP Application

**Path:** `Z_EQUI_MAN/`

A complete RAP managed application implementing a real-world scenario:

- Root / child composition (Equipment → Maintenance Orders)
- Managed RAP with **strict mode level 2**
- **Draft-enabled** transactional handling
- Business-rule-driven **feature control**
- Actions controlling lifecycle transitions
- Determinations and validations
- Late numbering for business keys
- OData **V4** service exposure
- Fiori Elements List Report / Object Page UI

This project is intended as a **reference implementation**
for managed RAP applications and technical interviews.

---

## Project Architecture (General)

All projects in this repository follow the standard RAP layered architecture:

- **Data Model Layer**
  - CDS entities and projections
  - Associations and value helps
  - Semantic annotations

- **Behavior Layer**
  - Behavior definitions (BDEF)
  - Behavior implementation classes
  - Actions, determinations, validations
  - Feature control and draft handling

- **Service Layer**
  - Service definitions
  - Service bindings (OData V2 / V4)

- **UI Layer**
  - Fiori Elements (when applicable)
  - Local annotations

---

## Repository Structure

Each project inside this repository follows a consistent structure:
<project>/
├── src/abap/ # RAP source artifacts (CDS, behavior, classes, DDIC)
├── docs/ # Architecture, business rules, technical decisions
├── rap-model/ # Conceptual RAP model documentation
└── screenshots/ # Runtime evidence (UI, draft, actions, feature control)



This separation keeps **source code**, **conceptual documentation**, and
**runtime evidence** clearly isolated.

---

## Prerequisites

- SAP BTP ABAP Environment (Steampunk / Embedded Steampunk / Trial)
- ABAP Development Tools (ADT)
- Basic knowledge of:
  - CDS
  - RAP concepts
  - OData (V2 / V4)

---

## How to Use the Projects

1. Import the repository into ADT.
2. Navigate to the desired project folder.
3. Activate CDS, behavior, and service artifacts.
4. Publish the service binding.
5. Test the service via:
   - ADT Service Explorer
   - Fiori Elements Preview

Refer to the project-specific `README.md` and `docs/` folder for details.

---

## Development Guidelines

- Follow **Clean Core** principles.
- Keep business logic inside RAP behavior implementations.
- Avoid modifying framework-generated artifacts.
- Prefer explicit lifecycle control over implicit behavior.
- Document architectural and technical decisions in `/docs`.

---

## Purpose

This repository is designed to:
- Consolidate RAP knowledge through real implementations
- Provide reusable reference projects
- Support technical interview preparation
- Serve as a long-term ABAP Cloud learning archive

---

## License

This repository is provided under the MIT License unless stated otherwise.
