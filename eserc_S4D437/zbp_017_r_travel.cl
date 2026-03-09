CLASS zbp_017_r_travel DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF z017_r_travel.
ENDCLASS.

CLASS zbp_017_r_travel IMPLEMENTATION.
ENDCLASS.

CLASS lsc_z017_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

  PRIVATE SECTION.
    METHODS map_message
      IMPORTING i_msg        TYPE symsg
      RETURNING VALUE(r_msg) TYPE REF TO if_abap_behv_message.

ENDCLASS.

CLASS lsc_z017_r_travel IMPLEMENTATION.

  METHOD save_modified.
    DATA(model) = NEW /lrn/cl_s4d437_tritem( i_table_name = 'Z017_TRITEM' ).

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).
      DATA(msg_d) = model->delete_item( i_uuid = <item_d>-itemuuid ).
      IF msg_d IS NOT INITIAL.
        APPEND VALUE #(
         %tky-itemuuid = <item_d>-itemuuid
         %msg = map_message( msg_d ) )
         TO reported-item.
      ENDIF.
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).
*   model->create_item( i_item = CORRESPONDING #( <item_c> ) ).
      DATA(msg_c) = model->create_item( i_item = CORRESPONDING #( <item_c> MAPPING FROM ENTITY ) ).
      IF msg_c IS NOT INITIAL.
        APPEND VALUE #(
         %tky-itemuuid = <item_c>-itemuuid
         %msg = map_message( msg_c ) )
         TO reported-item.
      ENDIF.
    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
      DATA(msg_u) = model->update_item( i_item = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
                           i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY USING CONTROL ) ).
      IF msg_u IS NOT INITIAL.
        APPEND VALUE #(
        %tky-itemuuid = <item_u>-itemuuid
         %msg = map_message( msg_u ) )
         TO reported-item.
      ENDIF.
    ENDLOOP.


*    IF create-travel IS NOT INITIAL.
*      RAISE ENTITY EVENT Z017_R_Travel~TravelCreated FROM CORRESPONDING #( create-travel ) .

      DATA event_in TYPE TABLE FOR EVENT Z017_R_Travel~TravelCreated.

      IF create-travel IS NOT INITIAL.
        RAISE ENTITY EVENT Z017_R_Travel~TravelCreated
        FROM VALUE #( FOR <new_travel> IN create-travel (
        AgencyId = <new_travel>-AgencyId
        TravelId = <new_travel>-TravelId
        origin = 'Z017_R_TRAVEL' ) ).
      ENDIF.
*    ENDIF.

  ENDMETHOD.

  METHOD map_message.
    DATA(severity) = SWITCH #( i_msg-msgty
    WHEN 'S' THEN if_abap_behv_message=>severity-success
    WHEN 'I' THEN if_abap_behv_message=>severity-information
    WHEN 'W' THEN if_abap_behv_message=>severity-warning
    WHEN 'E' THEN if_abap_behv_message=>severity-error
     ELSE if_abap_behv_message=>severity-none ).

    r_msg = new_message(
    id = i_msg-msgid
    number = i_msg-msgno
    severity = severity
    v1 = i_msg-msgv1
    v2 = i_msg-msgv2
    v3 = i_msg-msgv3
    v4 = i_msg-msgv4 ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR item~validateFlightDate.
    METHODS determineTravelDates FOR DETERMINE ON MODIFY
      IMPORTING keys FOR item~determineTravelDates.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD validateFlightDate.
    CONSTANTS: c_area TYPE string VALUE `FLIGHTDATE`.

    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY item
    FIELDS ( AgencyId TravelId FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<lfs_items>).

      reported-item = VALUE #(  BASE reported-item
                              ( %tky = <lfs_items>-%tky
                                %state_area = c_area )
                              ).

      IF <lfs_items>-FlightDate IS INITIAL.
        failed-item = VALUE #( BASE failed-item
                               ( %tky = <lfs_items>-%tky )
                             ).

        reported-item = VALUE #(  BASE reported-item
                                ( %tky = <lfs_items>-%tky
                                  %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                                  %element-flightdate = if_abap_behv=>mk-on
                                  %state_area = c_area
                                  %path-travel = CORRESPONDING #( <lfs_items> ) )
                                ).
      ELSEIF <lfs_items>-FlightDate < cl_abap_context_info=>get_system_date( ).
        failed-item = VALUE #( BASE failed-item
                              ( %tky = <lfs_items>-%tky )
                            ).

        reported-item = VALUE #(  BASE reported-item
                                ( %tky = <lfs_items>-%tky
                                  %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>flight_date_past )
                                  %element-flightdate = if_abap_behv=>mk-on
                                  %state_area = c_area
                                  %path-travel = CORRESPONDING #( <lfs_items> ) )
                                ).
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD determineTravelDates.

    READ ENTITIES OF z017_r_travel IN LOCAL MODE
    ENTITY item
    FIELDS ( FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items)

    BY \_Travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)
    LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      ASSIGN travels[ KEY id %tky = link[ KEY id source-%tky = <item>-%tky ]-target-%tky ] TO FIELD-SYMBOL(<travel>).

      IF <travel>-EndDate < <item>-FlightDate.
        <travel>-EndDate = <item>-FlightDate.
      ENDIF.

      IF <item>-FlightDate > cl_abap_context_info=>get_system_date( ) AND <item>-FlightDate < <travel>-BeginDate.
        <travel>-BeginDate = <item>-FlightDate.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF z017_r_travel IN LOCAL MODE
    ENTITY travel
    UPDATE
    FIELDS ( BeginDate EndDate )
     WITH CORRESPONDING #( travels ).



  ENDMETHOD.

ENDCLASS.

CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION travel~cancel_travel.
    METHODS validatedescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedescription.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.
    METHODS validatebegindate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatebegindate.
    METHODS validatedatesequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedatesequence.

    METHODS validateenddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateenddate.
    METHODS determinestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~determinestatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).

*    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
*      DATA(rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <result>-agencyid i_actvt = '02' ).
*      IF rc <> 0.
*        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
*        <result>-%update = if_abap_behv=>auth-unauthorized.
*      ELSE.
*        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
*        <result>-%update = if_abap_behv=>auth-allowed.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)
    FAILED failed
    REPORTED reported.


    LOOP AT travels ASSIGNING FIELD-SYMBOL(<lfs_travels>).
      IF <lfs_travels>-Status <> 'C'.
        MODIFY ENTITIES OF Z017_R_Travel IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( status )
        WITH VALUE #( ( %tky = <lfs_travels>-%tky
                        status = 'C' ) )
        FAILED failed
        REPORTED reported.
      ELSE.
        APPEND VALUE #( %tky = <lfs_travels>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_travels>-%tky
                        %msg = NEW zcm_017_travel( textid = zcm_017_travel=>already_canceled ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.

  METHOD validateDescription.
    CONSTANTS c_area TYPE string VALUE `DESC`.
    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( Description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.


      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area = c_area ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.
    CONSTANTS c_area TYPE string VALUE `CUST`.
    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS (  CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-customerid = if_abap_behv=>mk-on
                        %state_area = c_area  ) TO reported-travel.
      ELSE.
        SELECT SINGLE
        FROM /dmo/i_customer
         FIELDS CustomerID
         WHERE CustomerID = @<travel>-CustomerId
         INTO @DATA(dummy).
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>customer_not_exist )
                          %element-customerid = if_abap_behv=>mk-on
                          %state_area = c_area  ) TO reported-travel.
        ENDIF.
      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD validateBeginDate.
    CONSTANTS c_area TYPE string VALUE `BDAT`.
    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( BeginDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #(  %tky = <travel>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %state_area = c_area ) TO reported-travel.
      ELSEIF <travel>-BeginDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #(  %tky = <travel>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>begin_date_past )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %state_area = c_area ) TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDateSequence.
    CONSTANTS c_area TYPE string VALUE `EDAT`.
    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
          ENTITY travel
          FIELDS ( BeginDate EndDate )
          WITH CORRESPONDING #( keys )
          RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-EndDate < <travel>-BeginDate.
        APPEND VALUE #(  %tky = <travel>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>dates_wrong_sequence )
                        %element = VALUE #( EndDate = if_abap_behv=>mk-on
                                            BeginDate = if_abap_behv=>mk-on )
                        %state_area = c_area ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.
    CONSTANTS c_area TYPE string VALUE `SDAT`.
    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
          ENTITY travel
          FIELDS ( EndDate )
          WITH CORRESPONDING #( keys )
          RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #(  %tky = <travel>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-EndDate = if_abap_behv=>mk-on
                        %state_area = c_area  ) TO reported-travel.
      ELSEIF <travel>-EndDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #(  %tky = <travel>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>begin_date_past )
                        %element-EndDate = if_abap_behv=>mk-on
                        %state_area = c_area  ) TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( ).
    mapped-travel = CORRESPONDING #( entities ).
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-AgencyId = agencyid.
      <mapping>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel).


    DELETE travel WHERE status IS NOT INITIAL.

    CHECK travel IS NOT INITIAL.


    MODIFY ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( status )
    WITH VALUE #( FOR key IN travel ( %tky = key-%tky status = 'N' ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).



  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( status BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND CORRESPONDING #( <travel> ) TO result
      ASSIGNING FIELD-SYMBOL(<result>).

      IF <travel>-%is_draft = if_abap_behv=>mk-on.
        READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
         ENTITY Travel
          FIELDS ( BeginDate EndDate )
         WITH VALUE #( ( %key = <travel>-%key ) )
         RESULT DATA(travels_active).
        IF travels_active IS NOT INITIAL.
          <travel>-BeginDate = travels_active[ 1 ]-BeginDate.
          <travel>-EndDate = travels_active[ 1 ]-EndDate.
        ELSE.
          CLEAR <travel>-BeginDate.
          CLEAR <travel>-EndDate.
        ENDIF.
      ENDIF.

      IF <travel>-Status = 'C' OR ( <travel>-EndDate IS NOT INITIAL AND
       <travel>-EndDate < cl_abap_context_info=>get_system_date( ) ).

        <result>-%features-%update = if_abap_behv=>fc-o-disabled.
        <result>-%features-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
      ELSE.

        <result>-%features-%update = if_abap_behv=>fc-o-enabled.
        <result>-%features-%action-cancel_travel = if_abap_behv=>fc-o-enabled.

      ENDIF.

      IF <travel>-BeginDate IS NOT INITIAL AND <travel>-BeginDate < cl_abap_context_info=>get_system_date( ).
        <result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
      ELSE.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
      ENDIF.
    ENDLOOP.





  ENDMETHOD.

  METHOD determineDuration.

    READ ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-EndDate IS NOT INITIAL AND <travel>-BeginDate IS NOT INITIAL.
        <travel>-duration = <travel>-EndDate - <travel>-BeginDate.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF Z017_R_Travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( duration )
    WITH CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.
