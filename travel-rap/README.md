# RAP Travel Application

This repository contains a full RAP (RESTful ABAP Programming Model) application implemented on SAP BTP ABAP Environment.  
The project demonstrates a complete end-to-end Business Object scenario including data modelling, behavior implementation, draft handling, validations, determinations, attachments, and OData V4 UI exposure.

---

## 1. Overview

The RAP Travel application manages simple travel records including:
- Agency
- Customer
- Booking data
- Dates and pricing
- Status management
- Image attachments

The Business Object is fully draft-enabled and implements input validations, early numbering, automatic status assignment, and semantic annotations for both business data and file handling.

---

## 2. Architecture

A detailed technical explanation is provided in:

📄 **[docs/architecture.md](docs/architecture.md)**

High-level components include:

### **Data Model**
- Active table `ztravel_tab`
- Draft table `ztravel_tab_d`

### **Business Object**
- Root View Entity: `ZR_TRAVEL_TAB`
- Projection View: `ZC_TRAVEL_TAB`
- UI Annotation file: `ZC_TRAVEL_TAB.annotate`
- Behavior Definition: `ZR_TRAVEL_TAB.bdef`
- Behavior Implementation: `ZBP_R_TRAVEL_TAB`

### **Service**
- Service Definition: `ZUI_TRAVEL_TAB_O4`
- OData V4 UI Service Binding (screenshots included)

### **Utilities**
- Demo data loader script: `/scripts/load_demo_data.abap`
- Cleanup script: `/scripts/cleanup_tables.abap`

---

## 3. Repository Structure

/src
ztravel_tab.abap
ztravel_tab_d.abap
ZR_TRAVEL_TAB.ddls
ZC_TRAVEL_TAB.ddls
ZC_TRAVEL_TAB.annotate
ZR_TRAVEL_TAB.bdef
ZBP_R_TRAVEL_TAB.clas.abap
ZCL_TRAVEL_ESER.clas.abap
ZUI_TRAVEL_TAB_O4.srvd

/scripts
load_demo_data.abap
cleanup_tables.abap

/docs
architecture.md
/screenshots
service binding.pdf
preview.pdf

.gitignore
README.md


---

## 4. Technical Features

### **RAP Concepts Implemented**
- Draft-enabled Business Object
- Determinations (auto-set status to Open)
- Validations (customer must exist, date rules, etc.)
- Early Numbering strategy (TravelID)
- Semantic annotations:
  - Amount/currency
  - Dates
  - Large Object (attachment)
  - MIME type and file name
- Value Help annotations with filters
- OData V4 UI service binding
- Fiori Elements auto-generated UI

### **Attachment Handling**
Implemented using:

@Semantics.largeObject
@Semantics.mimeType


Allowing upload & preview of:
- .png
- .jpeg

---

## 5. Running the Application

1. Import the `/src` files into an ADT project.
2. Activate all CDS, Behavior, and Class objects.
3. Open the **Service Binding (OData V4 - UI)** and publish the service.
4. Click **Preview** to open the generated Fiori Elements UI.
5. (Optional) Load demo data by running:
   - `/scripts/load_demo_data.abap`
   - or class `ZCL_TRAVEL_ESER` in ADT

---

## 6. Screenshots

### **Service Binding**
![Service Binding](docs/screenshots/service%20binding.pdf)

### **UI Preview**
![UI Preview](docs/screenshots/preview.pdf)

---

## 7. License

This project is provided under the MIT License.


