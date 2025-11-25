# RAP Travel Application – Architecture Overview

This document describes the technical architecture of the RAP Travel demo project.

---

## 1. Layers Overview

The project is implemented using the standard RAP layered architecture:

### **Data Model**
- Transparent table `ztravel_tab`
- Draft table `ztravel_tab_d`

### **Business Object (BO)**
- Root View Entity: `ZR_TRAVEL_TAB`
- Projection View: `ZC_TRAVEL_TAB`
- Behavior Definition: `ZR_TRAVEL_TAB.bdef`
- Behavior Implementation: `ZBP_R_TRAVEL_TAB`

### **Service Exposure**
- Service Definition: `ZUI_TRAVEL_TAB_O4`
- OData V4 UI Service Binding (screenshot included)

---

## 2. Behavior Logic

The BO contains:
- **Early numbering** for TravelID  
- **Determination**: set status to `O` (Open)  
- **Validations**:
  - Customer must exist
  - Begin date cannot be in the past
  - End date must be >= Begin date

All validation and determination logic is implemented in class:
`ZBP_R_TRAVEL_TAB`.

---

## 3. Attachments Handling

The project uses:
- `@Semantics.largeObject`  
- MIME type and file name semantics  
- Acceptable MIME types restricted to images  

Image files can be uploaded from the UI Preview (Fiori Elements).

---

## 4. UI Annotations

Projection view contains a separate annotation file (`ZC_TRAVEL_TAB.annotate`) with:
- LineItem configuration  
- Identification section  
- Field visibility rules  
- Custom facets  
- Hidden technical fields  

---

## 5. Demo Data Loader

Class `ZCL_TRAVEL_ESER` loads sample records using SQL and CASE expressions.
It also clears both active and draft tables before inserting test data.

---

## 6. Service Binding

The OData V4 UI Service Binding exposes the Travel entity set.
A visual screenshot is provided in:

`/docs/screenshots/service-binding.png`


