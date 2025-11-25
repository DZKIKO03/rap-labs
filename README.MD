# RAP Project – Overview

This repository contains a RAP (RESTful ABAP Programming Model) application built on SAP BTP ABAP Environment.  
The project follows clean-core principles and implements a complete end-to-end scenario using CDS, behaviors, business logic, and service exposure.

---

## 1. Project Architecture

The solution is based on the standard RAP layered architecture:

- **Data Model Layer**
  - CDS entities
  - CDS views and projections
  - Associations and value helps
  - Semantic annotations

- **Behavior Layer**
  - Behavior Definitions (BDEF)
  - Behavior Implementations (Class LHC\*)
  - Determinations, validations, actions
  - Authorization (if applicable)

- **Service Layer**
  - Service Definition
  - Service Binding (OData V2/V4 or UI)
  - Draft handling (if enabled)

- **UI Layer**
  - Fiori Elements app (optional)
  - Local annotations

---

## 2. Technical Scope

This repository demonstrates how to implement a complete RAP solution including:

- Creation of CDS data model  
- Definition of projection views  
- Behavior definitions with business logic  
- Validation and determination examples  
- Automated key generation (if required)  
- Draft handling  
- Exposure via OData service  
- UI generation via Fiori Elements  

---

## 3. Repository Structure

/data-model
*.ddls -- CDS entities and projections
/behavior
*.bdef -- Behavior definitions
*.clas.abap -- Behavior implementations
/service
*.srv -- Service definitions
*.binding -- Service bindings
/ui (optional)
*.xml, *.json, manifests
/docs
architecture.md
decisions.md


---

## 4. Prerequisites

- SAP BTP ABAP Environment (Steampunk, Embedded Steampunk, or Trial)  
- ABAP Development Tools (ADT)  
- OData V2/V4 knowledge  
- Basic understanding of RAP concepts  

---

## 5. How to Run the Project

1. Import the repository into your ADT workspace.  
2. Activate all CDS, Behavior, and Service objects.  
3. Open the **Service Binding** and publish the OData service.  
4. Test the service using:
   - ADT Service Explorer  
   - SAP API Business Hub Sandbox  
   - Fiori Elements preview  

---

## 6. Development Guidelines

- Follow clean-core principles.  
- Keep business logic inside behavior implementation classes.  
- Avoid modifying generated artifacts.  
- Use meaningful naming conventions.  
- Document key design decisions inside `/docs`.

---

## 7. Testing

This project can be tested using:

- **ADT Preview** for OData  
- **Fiori Elements Preview**  
- Local unit tests (if implemented)  

---

## 8. Future Enhancements

- Add more validations and determinations  
- Extend associations and value helps  
- Add custom actions  
- Implement draft-enabled UI  
- Integrate with other RAP services  

---

## 9. License

This project is provided under the MIT License unless stated otherwise.

