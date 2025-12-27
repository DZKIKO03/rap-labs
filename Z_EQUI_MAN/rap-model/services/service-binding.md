# Service Exposure (OData V4)

## Service Model
The application exposes the Equipment root and its composed Maintenance Orders through an OData V4 service.

## Binding
- Protocol: OData V4
- Intended consumption: Fiori Elements application (List Report / Object Page)

## Draft
Draft handling is enabled for transactional consistency and UX:
- users can edit and validate in draft
- activation performs final checks and persists data

