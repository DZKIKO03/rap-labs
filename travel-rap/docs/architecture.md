RAP Travel Application – Architecture Overview

This document describes the technical architecture of the RAP Travel application, built using the ABAP RESTful Application Programming Model (RAP).
It provides a complete overview of the Business Object, behavior implementation, service exposure, UI annotations, dynamic feature control, and test automation.

1. Layers Overview

The project follows the standard RAP layered architecture:

1.1 Data Model

Transparent table:
ztravel_tab

Draft table:
ztravel_tab_d
(managed draft with ETag fields)

1.2 Business Object (BO)

Root View Entity: ZR_TRAVEL_TAB

Projection View: ZC_TRAVEL_TAB

Behavior Definition: ZR_TRAVEL_TAB.bdef

Behavior Projection: ZC_TRAVEL_TAB.bdef

Behavior Implementation Class: ZBP_R_TRAVEL_TAB
(local handler class inside behavior pool)

1.3 Service Exposure

Service Definition: ZUI_TRAVEL_TAB_O4

OData V4 UI Service Binding (Fiori Elements preview)

2. Business Object Behavior

The BO uses:

managed implementation

strict mode strict(2)

draft support (with draft)

ETag-based locking

extensibility support

early numbering for the TravelID

Implemented in ZR_TRAVEL_TAB.bdef.

3. Determinations and Validations
3.1 Determinations
setStatusToOpen

Triggered on creation

Automatically initializes OverallStatus = 'O'

3.2 Validations
validateCustomer

Ensures:

CustomerID is not initial

Customer exists in /DMO/CUSTOMER

Error message raised via behavior messages

validateDates

Ensures:

BeginDate and EndDate are provided

BeginDate is not in the past

EndDate ≥ BeginDate

All above logic is implemented in ZBP_R_TRAVEL_TAB.

4. Business Actions

The BO provides four custom actions extending the functional scope.

4.1 deductDiscount (instance, non-factory, with parameter)

Applies a percentage discount on BookingFee

Parameter structure: /dmo/a_travel_discount

Validation:

Discount > 0

Discount ≤ 100

Returns updated instance

Implemented in: ZBP_R_TRAVEL_TAB → deductDiscount

4.2 copyTravel (factory action)

Creates a new Travel instance from an existing one.

Default adjustments:

BeginDate = system date

EndDate = system date + 30

Status = Open

TravelID automatically assigned (early numbering)

Implemented in:
ZBP_R_TRAVEL_TAB → copyTravel

4.3 acceptTravel (instance, non-factory)

Sets:

OverallStatus = 'A' (Accepted)


Returns updated instance.

4.4 rejectTravel (instance, non-factory)

Sets:

OverallStatus = 'X' (Rejected)


Returns updated instance.

5. Dynamic Feature Control

The BO implements instance-based dynamic enabling/disabling of operations:

update

delete

edit

deductDiscount

acceptTravel

rejectTravel

Behavior definition uses:

(features : instance)


The logic is handled in:

ZBP_R_TRAVEL_TAB → get_instance_features

Feature Rules
Status	Update	Delete	Edit	deductDiscount	acceptTravel	rejectTravel
Open (O)	Enabled	Enabled	Enabled	Enabled	Enabled	Enabled
Accepted (A)	Disabled	Enabled	Disabled	Disabled	Disabled	Enabled
Rejected (X)	Disabled	Disabled	Disabled	Disabled	Enabled	Disabled

Result:
Fiori buttons appear enabled/disabled based on the Travel’s lifecycle.

6. UI Annotations

Annotations are maintained in the projection annotation file:

ZC_TRAVEL_TAB.annotate

It defines:

LineItem fields

Identification section

Facets

Mandatory fields

Hidden technical fields

Action buttons for:

deductDiscount (with parameter popup)

copyTravel

acceptTravel

rejectTravel

Button availability depends on feature control logic.

7. Attachments Handling

The BO supports image upload using:

@Semantics.largeObject

@Semantics.mimeType

@Semantics.fileName

Only image MIME types are accepted.
Attachment handling is fully supported in the generated Fiori Elements UI.

8. Demo Data Loader

Class ZCL_TRAVEL_ESER provides:

Cleanup of active and draft tables

Loading of sample demo data with SQL and CASE constructs

Used during initialization of the local test environment

9. ABAP Unit Testing (Test Automation)

A complete ABAP Unit test class exists:

Class:
zrap_tc_travel_eml_

Uses:

CDS Test Double Framework (cl_cds_test_environment)

SQL Test Double Framework (cl_osql_test_environment)

Test Coverage

The test validates:

Creation of a Travel instance (EML)

Action acceptTravel

Action deductDiscount

Behavior messages (should be empty)

Commit Entities

Persisted data validation

TravelID automatic numbering

Discount logic → BookingFee recalculated

Correct status transition (Open → Accepted)

The test class ensures functional correctness of the BO behavior and actions.

10. Service Binding

The service binding (ZUI_TRAVEL_TAB_O4) exposes:

Travel entity set

All annotated actions

Draft support

OData V4 UI preview enabled

This allows runtime execution of actions, determinations, validations, and dynamic features in a Fiori Elements environment.

11. Summary

The RAP Travel application now includes:

Full CRUD + draft support

Determinations and validations

4 custom business actions

Dynamic feature control

Attachment support

Complete UI metadata

Test automation with CDS/SQL test doubles

Updated behavior definition and projection

Robust service exposure for Fiori Elements

The architecture is aligned with RAP best practices and fully extensible for further development.
