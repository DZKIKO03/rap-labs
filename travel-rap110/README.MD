# Travel RAP Project (RAP110 Exercises – Extended Version)

This repository contains a complete SAP RAP (RESTful ABAP Programming Model) project implementing a full **Travel & Booking Business Object**, including:

- Managed RAP BO (root: Travel, child: Booking)
- Draft handling
- Determinations, Validations, Actions
- Virtual elements
- Business events (accepted/rejected travel)
- Number range handling
- EML test playground
- Fiori Elements UI annotations
- Complete technical documentation (`/docs`)
- Test scripts (`/script`)
- UI screenshots (`/screenshot`)

---

## 📂 Repository Structure

travel-rap110/
│
├── docs/
│ ├── architecture.md
│ ├── setup.md
│ ├── usage.md
│ ├── data-model.md
│ ├── behavior-flow.md
│ └── events.md
│
├── script/
│ ├── create_number_range.abap
│ ├── eml_playground.abap
│ ├── reset_database.sql
│ ├── run_virtual_elements_test.abap
│ └── test_payloads/
│ ├── create_travel.json
│ ├── create_travel_and_booking.json
│ ├── update_travel.json
│ └── update_booking.json
│
├── screenshot/
│ ├── travel_list_page.png
│ ├── travel_object_page.png
│ ├── travel_bookings_table.png
│ ├── accept_travel_action.png
│ ├── reject_travel_action.png
│ ├── validation_error_example.png
└── src/
ABAP + CDS sources

yaml
Copia codice

---

## 🚀 Overview

This project implements a real-world Travel Management scenario using the **SAP BTP ABAP Environment** and the **RESTful ABAP Programming Model (RAP)**.

It includes:

### ✔ Root Entity: `Travel`
- BookingFee, Currency, TotalPrice
- Description
- Begin/End Date validation
- File Attachment support
- Status + criticality indicator
- Factory action `createTravel`
- Actions `acceptTravel`, `rejectTravel`
- Business events

### ✔ Child Entity: `Booking`
- Booking status, flight data
- Automatic initial values
- Price aggregation into Travel
- Virtual elements:
  - RemainingDaysToFlight
  - InitialDaysToFlight
  - DaysToFlightIndicator
  - BookingStatusIndicator

### ✔ Infrastructure
- Number range object
- Determinations for automatic values
- Validations for customer/agency/dates
- Custom business events persisted in table `ZRAP110_ETRAV00B`
- EML test program

---

## 📸 Screenshots

A selection of UI screenshots is provided under `/screenshot/`.

Examples:

### Travel List Page
![Travel List](screenshot/travel_list_page.png)

### Travel Object Page
![Travel OP](screenshot/travel_object_page.png)

### Bookings Table
![Bookings](screenshot/travel_bookings_table.png)

---

## 📚 Documentation

The full project documentation is available in the `/docs` folder:

- [Architecture](docs/architecture.md)
- [Setup](docs/setup.md)
- [Usage](docs/usage.md)
- [Data Model](docs/data-model.md)
- [Behavior Flow](docs/behavior-flow.md)
- [Events](docs/events.md)

---

## 🧪 Testing & Scripts

All testing utilities are located in the `/script` folder.

### EML Playground  
Run:
script/eml_playground.abap

bash
Copia codice

### Virtual Elements Test  
script/run_virtual_elements_test.abap

bash
Copia codice

### Number Range Setup  
script/create_number_range.abap

shell
Copia codice

### Reset Database  
script/reset_database.sql

graphql
Copia codice

### JSON Payloads for API Testing  
script/test_payloads/

yaml
Copia codice

---

## 🔧 Technical Highlights

### RAP Features Implemented
- Managed RAP BO (Travel + Booking)
- Draft handling
- Determinations + Validations
- Actions + Factory Actions
- Late numbering & custom number ranges
- Side effects
- EML usage
- Virtual elements (Booking & Travel)
- Check, Prepare, Activate, Edit draft actions
- Fiori Elements Annotations (UI.*)

### Advanced Logic
- Multi-currency price aggregation
- Travel acceptance/rejection workflow
- Event-driven architecture
- Flight validation against DMO demo tables
- Data-driven dynamic criticality indicators

---

## 🧱 System Requirements

- SAP BTP ABAP Environment (Steampunk)
- SAP ADT (ABAP Development Tools)
- RAP Generator / CDS / Behavior Definitions enabled

---

## 🏁 How to Start

1. Import the project into an ABAP Cloud system.
2. Run number range creation script.
3. Check/activate CDS, BDEF, classes.
4. Activate the service binding.
5. Open Fiori Elements App Preview.
6. Create, update and test Travels and Bookings.
7. Check events table for accepted/rejected Travel logs.

---

## 📬 Contact

If you want to discuss ABAP Cloud, RAP, BTP, or architecture topics, feel free to reach out or open an issue.

---

## ⭐ Support

If you find this project useful, consider starring the repository.  
It helps visibility and supports the project!
