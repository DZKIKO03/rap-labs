# Associations

## Equipment -> Orders
- Association name: _ORDER
- Cardinality: [0..*]
- Semantics: composition (Orders exist only within an Equipment context)
- Draft alignment: with draft on association

Creation rule:
- Create on _ORDER is controlled via instance feature control:
  - Disabled when Equipment is inactive
  - Enabled when Equipment is active

## Order -> Equipment
- Association name: _equi
- Parent reference back to Equipment
- Draft alignment: with draft on association
- Locking and authorization are dependent by _equi

