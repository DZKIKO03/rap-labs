" SAP object: ZORDBP_R_ORDER_MAN
" RAP Behavior Pool for Maintenance Order root entity

CLASS zordbp_r_order_man DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zequr_equipment.
ENDCLASS.

CLASS zordbp_r_order_man IMPLEMENTATION.
ENDCLASS.


" Order behavior handler
" Implements order lifecycle and state transitions
CLASS lhc_ZordrOrderMan000 DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PROTECTED SECTION.
    CONSTANTS:
        " Centralized order lifecycle states
      BEGIN OF STATUS_ORDER,
        Created  TYPE C LENGTH 10 VALUE 'Created',
        Release  TYPE C LENGTH 10 VALUE 'Release',
        Complete TYPE C LENGTH 10 VALUE 'Complete',
        Cancel   TYPE C LENGTH 10 VALUE 'Cancel',
      END OF STATUS_ORDER.

  PRIVATE SECTION.


    METHODS SET_PRIORITY FOR DETERMINE ON MODIFY
      IMPORTING KEYS FOR ZordrOrderMan000~SET_PRIORITY.


    METHODS GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
      IMPORTING KEYS REQUEST REQUESTED_FEATURES FOR ZordrOrderMan000 RESULT RESULT.

    METHODS GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST REQUESTED_AUTHORIZATIONS FOR ZordrOrderMan000 RESULT RESULT.


    METHODS completedOrder FOR MODIFY
      IMPORTING KEYS FOR ACTION ZordrOrderMan000~completedOrder RESULT RESULT.

    METHODS releaseOrder FOR MODIFY
      IMPORTING KEYS FOR ACTION ZordrOrderMan000~releaseOrder RESULT RESULT.
    METHODS cancelledOrder FOR MODIFY
      IMPORTING KEYS FOR ACTION ZordrOrderMan000~cancelledOrder RESULT RESULT.
    METHODS SET_DEFAULTS FOR DETERMINE ON MODIFY
      IMPORTING KEYS FOR ZordrOrderMan000~SET_DEFAULTS.




ENDCLASS.

CLASS lhc_ZordrOrderMan000 IMPLEMENTATION.

" Set default priority only when not provided by caller
  METHOD SET_PRIORITY.
    READ ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
      ENTITY ZordrOrderMan000
        FIELDS ( Priority )
        WITH CORRESPONDING #( KEYS )
      RESULT DATA(ORDERS).

    " Prepare update table
    DATA UPDATES TYPE TABLE FOR UPDATE ZEQUR_EQUIPMENT\\ZordrOrderMan000.
    UPDATES = CORRESPONDING #( ORDERS ).

    " Only set default when field is not filled
    LOOP AT UPDATES ASSIGNING FIELD-SYMBOL(<U>).
      IF <U>-Priority IS INITIAL.
        <U>-Priority = 'M'.
        <U>-%CONTROL-Priority = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
    ENDLOOP.

    " Persist updates
    IF UPDATES IS NOT INITIAL.
      MODIFY ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
        ENTITY ZordrOrderMan000
          UPDATE FROM UPDATES.
    ENDIF.
  ENDMETHOD.


" Enable or disable actions and operations based on order status

  METHOD GET_INSTANCE_FEATURES.

    READ ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
      ENTITY ZordrOrderMan000
         FIELDS ( OrderID STATUS )
         WITH CORRESPONDING #( KEYS )
       RESULT DATA(ORDERS)
       FAILED FAILED.

    " evaluate the conditions, set the operation state, and set result parameter
    RESULT = VALUE #( FOR ORDER IN orderS
                       ( %TKY                   = ORDER-%TKY

                         %ACTION-cancelledOrder   = COND #( WHEN ORDER-Status = STATUS_ORDER-CANCEL OR
                                                                 ORDER-Status = STATUS_ORDER-COMPLETE
                                                            THEN IF_ABAP_BEHV=>FC-O-DISABLED
                                                            ELSE  IF_ABAP_BEHV=>FC-O-ENABLED )
                         %ACTION-completedOrder   =  COND #( WHEN ORDER-Status = STATUS_ORDER-COMPLETE OR
                                                                 ORDER-Status = STATUS_ORDER-CANCEL
                                                            THEN IF_ABAP_BEHV=>FC-O-DISABLED
                                                            ELSE  IF_ABAP_BEHV=>FC-O-ENABLED )
                         %ACTION-releaseOrder     = COND #( WHEN ORDER-Status = STATUS_ORDER-RELEASE OR
                                                                 ORDER-Status = STATUS_ORDER-COMPLETE OR
                                                                 ORDER-Status = STATUS_ORDER-CANCEL
                                                            THEN IF_ABAP_BEHV=>FC-O-DISABLED
                                                            ELSE  IF_ABAP_BEHV=>FC-O-ENABLED )
                          %FEATURES-%DELETE =   COND #( WHEN ORDER-Status =  STATUS_ORDER-COMPLETE OR
                                                                 ORDER-Status = STATUS_ORDER-CANCEL
                                                            THEN IF_ABAP_BEHV=>FC-O-DISABLED
                                                            ELSE  IF_ABAP_BEHV=>FC-O-ENABLED )
                         %FEATURES-%UPDATE =   COND #( WHEN ORDER-Status =  STATUS_ORDER-COMPLETE OR
                                                                 ORDER-Status = STATUS_ORDER-CANCEL
                                                            THEN IF_ABAP_BEHV=>FC-O-DISABLED
                                                            ELSE  IF_ABAP_BEHV=>FC-O-ENABLED )
                      ) ).
  ENDMETHOD.

  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.


" Complete order and set completion timestamp
  METHOD completedOrder.
    READ ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
    ENTITY ZordrOrderMan000
    FIELDS ( Status )
    WITH CORRESPONDING #( KEYS )
    RESULT DATA(ORDERS).

    DATA UPDATES TYPE TABLE FOR UPDATE ZEQUR_EQUIPMENT\\ZordrOrderMan000.

    UPDATES = CORRESPONDING #( ORDERS ).

    DATA LV_TS TYPE TIMESTAMP.
    GET TIME STAMP FIELD LV_TS.

    LOOP AT UPDATES ASSIGNING FIELD-SYMBOL(<U>).
      IF <U>-Status <> STATUS_ORDER-COMPLETE.
        <U>-Status = STATUS_ORDER-COMPLETE.
        <U>-%CONTROL-Status = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
      IF <U>-CompletionDate IS INITIAL.
        <U>-CompletionDate =  LV_TS.
        <U>-%CONTROL-CompletionDate = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
    ENDLOOP.

    IF UPDATES IS NOT INITIAL.
      MODIFY ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
       ENTITY ZordrOrderMan000
            UPDATE FROM UPDATES.
    ENDIF.
  ENDMETHOD.
" Release order to active processing state
  METHOD releaseOrder.
    READ ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
    ENTITY ZordrOrderMan000
    FIELDS ( Status )
    WITH CORRESPONDING #( KEYS )
    RESULT DATA(ORDERS).

    DATA UPDATES TYPE TABLE FOR UPDATE ZEQUR_EQUIPMENT\\ZordrOrderMan000.

    UPDATES = CORRESPONDING #( ORDERS ).

    LOOP AT UPDATES ASSIGNING FIELD-SYMBOL(<U>).
      IF <U>-Status <> STATUS_ORDER-RELEASE.
        <U>-Status = STATUS_ORDER-RELEASE.
        <U>-%CONTROL-Status = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
    ENDLOOP.

    IF UPDATES IS NOT INITIAL.
      MODIFY ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
       ENTITY ZordrOrderMan000
            UPDATE FROM UPDATES.
    ENDIF.
  ENDMETHOD.
" Cancel order and block further changes
  METHOD cancelledOrder.
    READ ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
    ENTITY ZordrOrderMan000
    FIELDS ( Status )
    WITH CORRESPONDING #( KEYS )
    RESULT DATA(ORDERS).

    DATA UPDATES TYPE TABLE FOR UPDATE ZEQUR_EQUIPMENT\\ZordrOrderMan000.

    UPDATES = CORRESPONDING #( ORDERS ).

    LOOP AT UPDATES ASSIGNING FIELD-SYMBOL(<U>).
      IF <U>-Status <> STATUS_ORDER-CANCEL.
        <U>-Status = STATUS_ORDER-CANCEL.
        <U>-%CONTROL-Status = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
    ENDLOOP.

    IF UPDATES IS NOT INITIAL.
      MODIFY ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
       ENTITY ZordrOrderMan000
            UPDATE FROM UPDATES.
    ENDIF.
  ENDMETHOD.

" Initialize order status and creation timestamp on create
  METHOD SET_DEFAULTS.
    READ ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
    ENTITY ZordrOrderMan000
    FIELDS ( creationDate Status )
  WITH CORRESPONDING #( KEYS )
  RESULT DATA(ORDERS).

    DATA UPDATES TYPE TABLE FOR UPDATE ZEQUR_EQUIPMENT\\ZordrOrderMan000.

    UPDATES = CORRESPONDING #( ORDERS ).

    DATA LV_TS TYPE TIMESTAMP.
    GET TIME STAMP FIELD LV_TS.

    LOOP AT UPDATES ASSIGNING FIELD-SYMBOL(<U>).
      IF <U>-Status IS INITIAL.
        <U>-Status = STATUS_ORDER-CREATED.
        <U>-%CONTROL-Status = IF_ABAP_BEHV=>MK-ON.
      ENDIF.

      IF <U>-CreationDate IS INITIAL.
        <U>-CreationDate =  LV_TS.
        <U>-%CONTROL-CreationDate = IF_ABAP_BEHV=>MK-ON.
      ENDIF.
    ENDLOOP.

    IF UPDATES IS NOT INITIAL.
      MODIFY ENTITIES OF ZEQUR_EQUIPMENT IN LOCAL MODE
       ENTITY ZordrOrderMan000
            UPDATE FROM UPDATES.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
