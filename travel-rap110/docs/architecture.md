Travel RAP Business Object – Architecture Overview

This document provides a complete technical overview of the Travel RAP Business Object implemented in the travel-rap110 project.
It describes the domain model, CDS layers, behavior implementation, draft handling, virtual elements, business logic, and event processing.

⚙️ 1. Domain Model Overview

The project implements a classic Travel → Booking scenario.
It is structured as a Root Business Object (Travel) with a Child Node (Booking), following the SAP ABAP RAP programming model.

Root Entity

Travel

Each Travel contains:

Customer

Agency

Date range (BeginDate, EndDate)

Pricing information

Status

Attachments

Child Entity

Booking

Each Booking belongs to exactly one Travel

Contains customer, carrier, flight, date, booking status, pricing information

Event Table

ZRAP110_ETRAV00B stores events raised when a Travel is accepted or rejected.

🧱 2. Physical Database Tables
Root Table

ZRAP110_ATRAV00B

Stores active Travel records

Child Table

ZRAP110_ABOOK00B

Stores active Booking records

Draft Tables

ZRAP110_DTRAV00B

ZRAP110_DBOOK00B

Event Table

ZRAP110_ETRAV00B

🧩 3. CDS Layers (R, C, I Views)

The project follows the standard RAP CDS layering:

3.1 R-views (Data Model Layer)

Represent the persistence structure, associations, and semantics.

Travel R-View

ZRAP110_R_TRAVELTP_00B

Maps to ZRAP110_ATRAV00B

Defines associations to:

Agency

Customer

OverallStatus

Currency

Composition to Booking

Booking R-View

ZRAP110_R_BOOKINGTP_00B

Maps to ZRAP110_ABOOK00B

Associations to:

Customer

Carrier

Connection

Flight

Booking Status

Currency

3.2 C-views (Consumption Layer)

Define the OData exposure and UI-centric elements.

Travel C-View

ZRAP110_C_TRAVELTP_00B

Root view entity for transactional OData

Adds:

UI-related associations

Virtual element: OverallStatusIndicator

Text elements for Agency, Customer, OverallStatus

Booking C-View

ZRAP110_C_BOOKINGTP_00B

Projection on Booking R-view

Adds:

Multiple virtual elements (InitialDaysToFlight, RemainingDaysToFlight, Indicators)

Texts for Customer, Carrier, Status

Value helps

3.3 I-views (Interface Layer)

Define API-ready projections (if required by integration).

Travel I-View

ZRAP110_I_TRAVELTP_00B

Booking I-View

ZRAP110_I_BOOKINGTP_00B

These can be used for integration scenarios or EML tests.

🔧 4. Behavior Definition Layer

Three levels of behavior definitions:

4.1 Projection Behavior

For UI service:

ZRAP110_C_TRAVELTP_00B

ZRAP110_C_BOOKINGTP_00B

Defines:

Exposed actions (Edit, Activate, Discard)

Additional actions (acceptTravel, rejectTravel, createTravel)

4.2 Interface Behavior

Defines actions and draft behavior for I-views:

Supports:

create/update/delete

draft handling

instance features

side effects

custom actions

4.3 Implementation Behavior

Mapped to RAP handler classes.

Handler Classes

Travel handler: LHC_TRAVEL

Booking handler: LHC_BOOKING

Saver Class

Travel saver: LSC_ZRAP110_R_TRAVELTP_00B

Responsible for TravelID numbering

BookingID numbering

Event raising

Key responsibilities

Determinations:

setInitialTravelValues

setInitialBookingValues

calculateTotalPrice

Validations:

Agency validation

Customer validation

Date validation

Booking status validation

Actions:

acceptTravel

rejectTravel

createTravel

recalcTotalPrice

Feature control:

Disables editing when Travel is accepted

Restricts deletion based on status

📝 5. Draft Handling

Both entities support draft:

Draft tables:

ZRAP110_DTRAV00B

ZRAP110_DBOOK00B

Standard draft actions implemented:

Edit

Activate

Discard

Resume

Prepare

The draft engine automatically stores intermediate versions and handles optimistic concurrency via ETAGs.

📊 6. Pricing and Business Logic
Travel Price

TotalPrice = BookingFee + SUM(Bookings)

BookingID Numbering

Incremental by +10 for each new booking of a given Travel.

TravelID Numbering

Generated via number range object ZRAP11000B
Created via script in class ZCL_CREATE_INTERVAL.

Currency Conversion

Uses /DMO/CL_FLIGHT_AMDP=>CONVERT_CURRENCY.

🧮 7. Virtual Elements
Booking virtual elements

Calculated in class:

ZRAP110_CALC_BOOK_ELEM_00B

Elements:

InitialDaysToFlight

RemainingDaysToFlight

DaysToFlightIndicator

BookingStatusIndicator

Travel virtual elements

Calculated in class:

ZRAP110_CALC_TRAV_ELEM_00B

Elements:

OverallStatusIndicator

🛰️ 8. Actions and Side Effects
Custom Actions

acceptTravel

rejectTravel

createTravel

recalcTotalPrice

Side Effects

Booking changes affect:

Travel.TotalPrice

Travel BeginDate/EndDate affect:

validation messages

🚀 9. Business Events

Events are raised when:

Travel is accepted

Travel is rejected

Event handler class:

LHE_TRAVEL

Writes to:

Table ZRAP110_ETRAV00B

Fields include:

TravelID

AgencyID

CustomerID

OverallStatus

Description

TotalPrice

CurrencyCode

Database timestamp

UUID

📡 10. OData Service Exposure

Service definition:

ZRAI110_UI_TRAVEL_00B

Exposes:

Travel

Booking

Customer

Carrier

Connection

Flight

Value help entities

Binding:

Fiori Elements UI

Draft-enabled

Transactional processing

🏁 11. Summary

This project is a complete, fully functional RAP implementation including:

CDS data model

Full behavior logic

Draft handling

Pricing logic

Virtual elements

Custom actions

Side effects

Event management

Number range logic

EML testing suite

UI annotations

It represents a mature and production-ready example of the ABAP RESTful Application Programming Model (RAP) on SAP BTP / ABAP Cloud.
