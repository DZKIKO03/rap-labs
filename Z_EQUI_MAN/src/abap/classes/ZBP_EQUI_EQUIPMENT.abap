" SAP object: ZEQUBP_R_EQUIPMENT
" RAP Behavior Pool for Equipment root entity

class ZEQUBP_R_EQUIPMENT definition
  public
  abstract
  final
  for behavior of ZEQUR_EQUIPMENT .

public section.
protected section.
private section.
ENDCLASS.



CLASS ZEQUBP_R_EQUIPMENT IMPLEMENTATION.
ENDCLASS.

" Saver class handling late numbering for Equipment and Orders

CLASS lsc_zequr_equipment DEFINITION INHERITING FROM cl_abap_behavior_saver.
" Protected scope used by RAP framework
" Not exposed to consumers
  PROTECTED SECTION.


" Redefinition of standard saver hook
" Used to assign business keys during save (late numbering)
    METHODS adjust_numbers REDEFINITION.
" Optional hook to react after modify phase
" Currently empty, reserved for future cross-entity logic
    METHODS save_modified REDEFINITION.



ENDCLASS.

CLASS lsc_zequr_equipment IMPLEMENTATION.

  METHOD adjust_numbers.
    DATA: lv_number TYPE n LENGTH 8.
" mapped-* tables contain instances created during this save cycle
" Only process numbering if new Equipment instances exist
    IF mapped-zequrequipment IS NOT INITIAL.
      TRY.
" Standard SAP API for number range consumption
" Cloud-safe and allowed in ABAP Cloud
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'ZEQUI'   "'ZRAP110###'
              quantity          = CONV #( lines( mapped-zequrequipment ) )
            IMPORTING
              number            = DATA(number_range_key)
              returncode        = DATA(number_range_return_code)
              returned_quantity = DATA(number_range_returned_quantity)
          ).
        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          RAISE SHORTDUMP TYPE cx_number_ranges
            EXPORTING
              previous = lx_number_ranges.
      ENDTRY.

      ASSERT number_range_returned_quantity = lines( mapped-zequrequipment ).
      lv_number = number_range_key - number_range_returned_quantity.
      LOOP AT mapped-zequrequipment ASSIGNING FIELD-SYMBOL(<equi>).
        lv_number += 1.
        <equi>-EquiID = lv_number.
      ENDLOOP.
    ENDIF.
" Separate number range for Orders

    IF mapped-zordrorderman000 IS NOT INITIAL.
      TRY.

          cl_numberrange_runtime=>number_get(
                   EXPORTING
                   nr_range_nr       = '01'
                   object            = 'ZORDER'   "'ZRAP110###'
                   quantity          = CONV #( lines( mapped-zordrorderman000 ) )
                   IMPORTING
                    number            = DATA(number_range_key2)
                   returncode        = DATA(number_range_return_code2)
                   returned_quantity = DATA(number_range_returned_quant)
               ).
        CATCH cx_number_ranges INTO DATA(lx_number_ranges2).
          RAISE SHORTDUMP TYPE cx_number_ranges
            EXPORTING
              previous = lx_number_ranges2.
      ENDTRY.

      ASSERT number_range_returned_quant = lines( mapped-zordrorderman000 ).
      lv_number = number_range_key2 - number_range_returned_quant.
      LOOP AT mapped-zordrorderman000 ASSIGNING FIELD-SYMBOL(<ord>).
        lv_number += 1.
        <ord>-OrderID = lv_number.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD save_modified.
  " Reserved for future save enhancements
  ENDMETHOD.

ENDCLASS.


CLASS lhc_zequr_equipment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PROTECTED SECTION.
    CONSTANTS:
     " Centralized order status values used across Equipment logic
      BEGIN OF status_order,
        Created  TYPE c LENGTH 10 VALUE 'Created',
        Release  TYPE c LENGTH 10 VALUE 'Release',
        Complete TYPE c LENGTH 10 VALUE 'Complete',
        Cancel   TYPE c LENGTH 10 VALUE 'Cancel',
      END OF status_order.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZequrEquipment
        RESULT result,
      set_default_isactive FOR DETERMINE ON MODIFY
        IMPORTING keys FOR ZequrEquipment~set_default_isactive.

    METHODS validate_category FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZequrEquipment~validate_category.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZequrEquipment RESULT result.
    METHODS warn_isactive FOR VALIDATE ON SAVE
      IMPORTING keys FOR zequrequipment~warn_isactive.
    METHODS cancel_order FOR DETERMINE ON SAVE
      IMPORTING keys FOR zequrequipment~cancel_order.




ENDCLASS.

CLASS lhc_zequr_equipment IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.



  METHOD set_default_isactive.
    READ ENTITIES OF zequr_equipment IN LOCAL MODE
    ENTITY ZequrEquipment
    FIELDS ( IsActive )
     WITH CORRESPONDING #( keys )
      RESULT DATA(Equipment).

    DATA: updates TYPE TABLE FOR UPDATE zequr_equipment\\ZequrEquipment.
    updates = CORRESPONDING #( Equipment ).

    LOOP AT updates ASSIGNING FIELD-SYMBOL(<lfs_update>).
     " Default Equipment is active on creation
      IF <lfs_update>-IsActive IS INITIAL.
        <lfs_update>-IsActive = abap_true.
        <lfs_update>-%control-IsActive = if_abap_behv=>mk-on.
      ENDIF.
    ENDLOOP.

    IF updates IS NOT INITIAL.
      MODIFY ENTITIES OF zequr_equipment IN LOCAL MODE
      ENTITY ZequrEquipment
        UPDATE FROM updates.
    ENDIF.


  ENDMETHOD.
 " Validate Category against custom reference table
  METHOD validate_category.
    READ ENTITIES OF zequr_equipment IN LOCAL MODE
    ENTITY ZequrEquipment
    FIELDS (  Category )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Equipment).

    DATA: category TYPE SORTED TABLE OF z_categ_search_help WITH UNIQUE KEY value.
    category = CORRESPONDING #( equipment DISCARDING DUPLICATES MAPPING value = Category EXCEPT * ).

    IF category IS NOT INITIAL.
      SELECT value
      FROM z_categ_search_help
      FOR ALL ENTRIES IN @category
      WHERE value EQ @category-value
      INTO TABLE @DATA(lt_valid_categ).

      LOOP AT equipment ASSIGNING FIELD-SYMBOL(<lfs_equi>).
        IF NOT line_exists( lt_valid_categ[ value = <lfs_equi>-Category ] ).
         " Invalid category blocks save
          APPEND VALUE #(  %tky = <lfs_equi>-%tky ) TO failed-ZequrEquipment.
          APPEND VALUE #(  %tky        = <lfs_equi>-%tky
                           %state_area = 'VALIDATE_CATEGORY'
                           %msg        = new_message_with_text(
                                            severity = if_abap_behv_message=>severity-error
                                            text     = 'Category is not valid'
                                         )
                           %element-category = if_abap_behv=>mk-on
                        ) TO reported-ZequrEquipment.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
 " Feature control depends on related Order lifecycle
  METHOD get_instance_features.


    READ ENTITIES OF zequr_equipment IN LOCAL MODE
    ENTITY ZequrEquipment
    FIELDS ( IsActive )
    WITH CORRESPONDING #( keys )
    RESULT DATA(equipment)
    FAILED failed.

    READ ENTITIES OF zequr_equipment IN LOCAL MODE
      ENTITY ZequrEquipment
      BY \_order
      FIELDS ( OrderID EquipmentID Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(orders)
      FAILED failed.


    result = VALUE #( FOR equi IN equipment
    " Active Orders restrict Equipment changes
     LET lv_has_blocking_order = xsdbool(
      line_exists(
        orders[ EquipmentID = equi-%key-EquiID Status = status_order-release
        ]
      )
      OR
      line_exists(
         orders[ EquipmentID = equi-%key-EquiID Status = status_order-complete
        ]
      ) )

       lv_has_blocking_equi = xsdbool(
      line_exists(
         orders[ EquipmentID = equi-%key-EquiID Status = status_order-complete
        ]
      ) )

      IN

                        (   %tky                   = equi-%tky
                         " Disable Order creation if Equipment is inactive
                           %assoc = VALUE #(
                                    _order = COND abp_behv_op_ctrl(
                                              WHEN equi-IsActive IS INITIAL
                                              THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled )  )


                         %field = VALUE #(
                                  IsActive = COND #(
                                             WHEN lv_has_blocking_order IS INITIAL
                                             THEN if_abap_behv=>fc-f-unrestricted
                                             ELSE if_abap_behv=>fc-f-read_only ) )
 " Prevent update/delete when completed Orders exist
                         %features-%delete = COND #(
                                             WHEN lv_has_blocking_equi IS NOT INITIAL
                                              THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled )

                        %features-%update = COND #(
                                             WHEN lv_has_blocking_equi IS NOT INITIAL
                                              THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled )

                        )
                           ) .



  ENDMETHOD.



  METHOD warn_isactive.
    READ ENTITIES OF zequr_equipment IN LOCAL MODE
    ENTITY ZequrEquipment
    FIELDS ( IsActive )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_equi).

    READ ENTITIES OF zequr_equipment IN LOCAL MODE
      ENTITY ZequrEquipment
      BY \_order
      FIELDS ( OrderID Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DELETE lt_orders WHERE status = status_order-cancel.

    LOOP AT lt_equi ASSIGNING FIELD-SYMBOL(<equi>).
" Warn user: deactivating Equipment affects existing Orders
      IF <equi>-IsActive IS INITIAL
         AND lt_orders IS NOT INITIAL.

        APPEND VALUE #(
          %tky        = <equi>-%tky
          %state_area = if_abap_behv=>state_area_all
        ) TO reported-ZequrEquipment.

        APPEND VALUE #(
          %tky = <equi>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-warning
                   text     = 'Equip deact. will also remove related orders.'
                 )
          %element-IsActive = if_abap_behv=>mk-on
        ) TO reported-ZequrEquipment.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.
" Cancel open Orders when Equipment is deactivated
  METHOD cancel_order.

    READ ENTITIES OF zequr_equipment IN LOCAL MODE
      ENTITY ZequrEquipment
      FIELDS ( EquiID IsActive )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_equi).

    DELETE lt_equi WHERE IsActive = abap_true.

    DATA lt_updates TYPE TABLE FOR UPDATE zequr_equipment\\ZordrOrderMan000.

    LOOP AT lt_equi INTO DATA(ls_equi).

      READ ENTITIES OF zequr_equipment IN LOCAL MODE
        ENTITY ZequrEquipment
        BY \_order
        FIELDS ( OrderID EquipmentID Status )
        WITH VALUE #( ( %tky = ls_equi-%tky ) )
        RESULT DATA(lt_orders).
   " Only Orders not yet released are cancelled
      LOOP AT lt_orders INTO DATA(ls_order)
        WHERE Status = status_order-created.

        APPEND VALUE #(
          %tky = ls_order-%tky
          Status = status_order-cancel
          %control-Status = if_abap_behv=>mk-on
        ) TO lt_updates.

      ENDLOOP.

    ENDLOOP.

    IF lt_updates IS NOT INITIAL.
      MODIFY ENTITIES OF zequr_equipment IN LOCAL MODE
        ENTITY ZordrOrderMan000
        UPDATE FROM lt_updates.
    ENDIF.

  ENDMETHOD.


ENDCLASS.
