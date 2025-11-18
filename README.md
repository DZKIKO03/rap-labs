# 📘 Course & Schedule RAP Project

Complete SAP RAP (ABAP RESTful Application Programming Model) exercise demonstrating:

- Domain model based on UUID
- Composition (1:N) between Course → Schedule
- Interface View (ZI)
- Projection View (ZC)
- UI Annotations (Fiori Elements)
- OData V2 Service Exposure
- Fiori preview for List Report & Object Page

---

## 🚀 Architecture Overview

### **Database Tables**
Located in `/db`:
- `zcourse_sap_rap` – Course master data
- `zcourse_sched` – Course schedule (child entity)

Relationship:
Course (1) --- (N) Schedule

yaml
Copia codice

---

## 📂 Project Structure

course-schedule-rap/
│
├── db/ # SQL and CDS tables
├── cds/ # Interface and projection CDS (ZI/ZC)
├── service/ # RAP service exposure
├── annotations/ # UI.Annotations for Fiori Elements
├── docs/ # Documentation (Word files)
└── screenshots/ # Fiori preview images

markdown
Copia codice

---

## 🧩 RAP Layers Used

### **1. Interface Views (ZI)**
- Define the domain model
- Add associations
- Include composition
- Expose semantic information (currency, amount, timestamps)

### **2. Projection Views (ZC)**
- UI-facing model
- Search annotations
- Value helps
- Redirection of associations
- Field selection for UI

### **3. UI Annotations**
Located in `annotations/`:
- Facets (Object Page structure)
- LineItems (List Report table)
- Identification (Object Page fields)
- HeaderInfo (title/subtitle)
- PresentationVariant (default sort)

### **4. Service Exposure**
`ZUI_COURSE_SAP` exposes:
- Courses
- Schedules
- I_Country
- I_Currency

Service binding: **OData V2**  
Used automatically by Fiori Elements preview.

---

## 📸 Screenshots

Place your preview images here:
screenshots/
fiori-list-report.png
fiori-course-objectpage.png
fiori-schedule-objectpage.png
service-binding.png

yaml
Copia codice

---

## 🎯 Purpose of This Project

This project is designed as a learning and reference template for:

- Understanding RAP end-to-end  
- Building parent/child models with composition  
- Implementing full UI metadata  
- Preparing for SAP BTP ABAP Developer certification  
- Training for technical interviews  

---

## 📚 Documentation

In the `/docs` folder:
- Lesson summary  
- Explanation of annotations  
- Metadata UI documentation  
- OData V2 / V4 comparison  

---

## ✔️ Status
Project **completed** and ready as a learning template.

---

## 🔧 Author
Training repository for SAP BTP ABAP/RAP development path.
