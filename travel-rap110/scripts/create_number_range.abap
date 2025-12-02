" Script: create_number_range.abap
" Purpose: Creates number range intervals for object ZRAP11000B

REPORT z_create_number_range_00b.

DATA: lv_object   TYPE cl_numberrange_objects=>nr_attributes-object,
      lt_interval TYPE cl_numberrange_intervals=>nr_interval,
      ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.

lv_object = 'ZRAP11000B'.

" Interval 01
ls_interval-nrrangenr  = '01'.
ls_interval-fromnumber = '00000001'.
ls_interval-tonumber   = '19999999'.
ls_interval-procind    = 'I'.
APPEND ls_interval TO lt_interval.

" Interval 02
ls_interval-nrrangenr  = '02'.
ls_interval-fromnumber = '20000000'.
ls_interval-tonumber   = '29999999'.
APPEND ls_interval TO lt_interval.

TRY.
    WRITE: / 'Creating intervals for object:', lv_object.

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

  CATCH cx_number_ranges INTO DATA(lx_rng).
    WRITE: / 'Error creating number range:', lx_rng->get_text( ).
ENDTRY.
