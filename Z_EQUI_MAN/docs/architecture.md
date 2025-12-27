# Architecture

## Overview
This project is a custom SAP ABAP Cloud / RAP (RESTful ABAP Programming Model) application for managing Equipment and related Maintenance Orders.

The solution is implemented as a managed RAP BO with draft handling enabled to support transactional consistency and a Fiori-friendly UX (edit/validate/save phases).

## Business Objects
- Equipment (root entity): Represents a physical equipment master record.
- Maintenance Order (child entity): Represents a maintenance order linked to an equipment.

Relationship:
- Equipment -> Maintenance Orders is modeled as a composition association [0..*].
- Orders exist only in the context of an Equipment.

## Persistence Model
Custom transparent tables are used:
- ZEQUIPMENT: persistent table for Equipment
- ZORDER_MAN: persistent table for Maintenance Orders

Draft handling:
- Draft tables are used (managed by RAP runtime) for both entities:
  - ZEQUEQUIPMENT_D
  - ZORDORDER_MAN_D
Draft tables are runtime artifacts and are not part of the custom data model documentation.

## RAP Implementation
RAP is implemented with:
- Managed scenario (framework handles transactional lifecycle)
- Strict mode level 2 (compile-time checks and explicit lifecycle control)
- Draft enabled (optimized activation)
- Late numbering (business keys assigned during save)
- Additional save with full data (cross-entity logic during save)

Behavior implementation classes:
- ZEQUBP_R_EQUIPMENT (root behavior implementation)
- ZORDBP_R_ORDER_MAN (child behavior implementation)

## Locking and Concurrency
Equipment:
- ETag based on LocalLastChangedAt
- Total lock on root (lock master total) to ensure consistency across root and child during save

Order:
- Dependent locking by parent association (_equi)
- ETag based on LocalLastChangedAt

## Authorization
- Root authorization placeholder: authorization master (global)
- Child inherits root authorization: authorization dependent by _equi

## Service Exposure
- OData V4 service exposure
- Intended to be consumed by Fiori Elements (List Report / Object Page pattern)

## Key Business Flow (High Level)
- Equipment is created as active by default (IsActive = true).
- Orders can be created only if Equipment is active (feature control on association).
- When Equipment is deactivated:
  - the user receives a warning if related orders exist
  - open orders in status Created are automatically cancelled at save time

