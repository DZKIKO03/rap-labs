# 📘 Course & Schedule RAP Project

Complete hands-on project built using the **SAP ABAP RESTful Application Programming Model (RAP)**.

This example demonstrates:

- Domain model based on UUID keys  
- Composition (1:N) — Course → Schedule  
- Interface Views (ZI)  
- Projection Views (ZC)  
- Full UI annotations for Fiori Elements  
- Service exposure via **OData V2**  
- Fiori Elements List Report & Object Page preview  

---

## 🚀 Architecture Overview

### **Database Tables (DB Layer)**
Located in `/db`:

| Table | Purpose |
|-------|---------|
| `zcourse_sap_rap` | Course master data |
| `zcourse_sched` | Schedule (child entity) |

Relationship:

Course (1) ──── (N) Schedule

---

## 📂 Project Structure
course-schedule-rap/
│
├── db/ # Tables (CDS DDL sources)
├── cds/ # Interface & Projection CDS (ZI/ZC)
├── service/ # RAP Service Definition & Binding
├── annotations/ # UI.Annotations for Fiori Elements
├── docs/ # Word documentation
└── screenshots/ # Fiori preview PNGs


---

## 🧩 RAP Layers Used

### **1. Interface Views – ZI\_***
The canonical domain model:
- Composition definition  
- Associations (Country, Currency)  
- Semantic annotations:  
  - `@Semantics.amount.currencyCode`
  - `@Semantics.systemDateTime.localInstanceLastChangedAt`

### **2. Projection Views – ZC\_***
Frontend-facing model:
- Search annotations  
- Value help definitions  
- UI redirection for compositions  
- Field exposure for Fiori Elements  

### **3. UI Annotations**
Located in `/annotations`:
- `@UI.headerInfo`  
- `@UI.facet`  
- `@UI.lineItem`  
- `@UI.identification`  
- `@UI.presentationVariant`  

These generate automatically:
- List Report page  
- Object Page  
- Navigation between Course → Schedule  

### **4. Service Layer**
`ZUI_COURSE_SAP` exposes:

- Course (ZC_COURSE_SAP_RAP)
- Schedule (ZC_COURSE_SCHED)
- I_Country
- I_Currency

Service Binding: **OData V2 – UI**

This produces the Fiori Elements preview.

---

## 📸 Screenshots

Screenshots located in `/screenshots`:

- `list_courses.png`
- `list_schedules.png`
- `object_course.png`
- `object_schedule.png`
- `service_binding.png`

These illustrate:
- List Report of Courses  
- List Report of Schedules  
- Object Page of Course  
- Object Page of Schedule  
- Service Binding & Metadata  

---

## 📚 Documentation (in /docs)

- **Riassunto lezione**  
- **Spiegazione annotazioni & projection**  
- **Metadata UI + spiegazione OData V2/V4/WebAPI**  

Perfect for:
- Studying RAP architecture  
- Reviewing CDS layers  
- Preparing for SAP certifications  
- Interview prep for ABAP Cloud & RAP  

---

## 🎯 Purpose of This Project

This repository serves as a **reference template** to understand RAP end-to-end:

- DB → ZI → ZC → UI → Service Binding  
- Composition modeling  
- Semantic annotations  
- Fiori Elements auto-generation  
- OData V2 usage within RAP  

---

## ✔️ Status

Project **completed** ✔  
Ready as reusable template for future RAP exercises.

---

## 🔧 Author
Daniele Zambrano — SAP Technical Architect.

