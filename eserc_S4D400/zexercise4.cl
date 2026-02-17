CLASS zexercise4 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zexercise4 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  data: lv_result type p decIMALS 2.
data(lv_number1) =  -8 .
data(lv_number2) = 3.
lv_result = lv_number1 / lv_number2 .



data(lv_output) = | il risultato di { lv_number1 } diviso { lv_number2 } è { lv_result } |.

out->write( lv_output ).
  ENDMETHOD.
ENDCLASS.
