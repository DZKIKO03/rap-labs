class ZCL_CREATE_INTERVAL definition
  public
  final
  create public .

  public section.
  INTERFACES if_oo_adt_classrun.
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_CREATE_INTERVAL IMPLEMENTATION.
METHOD if_oo_adt_classrun~main.
DATA: lv_object   TYPE cl_numberrange_objects=>nr_attributes-object,
      lt_interval TYPE cl_numberrange_intervals=>nr_interval,
      ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.

    lv_object = 'ZRAP11000B'.

*   intervals
    ls_interval-nrrangenr  = '01'.
    ls_interval-fromnumber = '00000001'.
    ls_interval-tonumber   = '19999999'.
    ls_interval-procind    = 'I'.
    APPEND ls_interval TO lt_interval.

    ls_interval-nrrangenr  = '02'.
    ls_interval-fromnumber = '20000000'.
    ls_interval-tonumber   = '29999999'.
    APPEND ls_interval TO lt_interval.

*   create intervals
    TRY.

        out->write( |Create Intervals for Object: { lv_object } | ).

        CALL METHOD cl_numberrange_intervals=>create
          EXPORTING
            interval  = lt_interval
            object    = lv_object
            subobject = ' '
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error)
            error_iv  = DATA(lt_error_iv)
            warning   = DATA(lv_warning).

       ENDTRY.
endmethod.
ENDCLASS.
