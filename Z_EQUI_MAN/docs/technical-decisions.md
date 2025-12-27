# Technical Decisions

## Why RAP Managed
The project uses RAP managed to leverage framework-managed transactional behavior, consistency handling, and standard save sequence. This reduces custom persistence code and aligns with ABAP Cloud guidelines.

## Strict Mode 2
Strict mode level 2 is enabled to enforce explicit RAP semantics, prevent implicit behavior, and increase compile-time checks. This supports cloud-ready, clean RAP usage.

## Draft Handling
Draft is enabled to support:
- Separation of edit/validation/save phases
- Better UX for Fiori Elements
- Transactional consistency when editing Equipment and its composed Orders

Optimized draft activation is used for Activate.

## Late Numbering
Business keys are assigned during save (late numbering) for both Equipment and Orders:
- Equipment: number range object ZEQUI, interval 01
- Order: number range object ZORDER, interval 01
Numbering is implemented in the saver adjust_numbers hook to guarantee consistent ID assignment for newly created instances.

## Locking Strategy
Equipment uses lock master total to ensure save-time consistency across root and child.
Orders use dependent locking by parent to avoid conflicting updates outside the Equipment transaction.

## Feature Control Strategy
Feature control is used to enforce business rules at runtime:
- Association _ORDER create is disabled when Equipment is inactive
- Equipment IsActive becomes read-only when blocking orders exist (Released/Complete)
- Equipment update/delete are disabled when completed orders exist
- Order actions and update/delete are enabled/disabled based on order status

This provides a single source of truth for UI behavior and backend enforcement.

## Validation vs Determination
- Validations are used for data integrity and user feedback (e.g., category validation, deactivation warning).
- Determinations are used for defaulting and enforcing invariants at save (e.g., cancelling open orders on equipment deactivation).

## Fully Custom Scope
The project is intentionally fully custom:
- Custom persistence tables
- No integration with standard SAP PM objects
This keeps the focus on RAP patterns (managed, draft, feature control, actions, determinations, validations, numbering).

