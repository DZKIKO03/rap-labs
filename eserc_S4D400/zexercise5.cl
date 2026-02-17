CLASS zexercise5 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zexercise5 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  data: lv_result type p decIMALS 2.
  data(lv_op) = '/' .

  data(lv_number1) = 10.
  data(lv_number2) = 0.

  if lv_op na '+-/*'.
  OUT->WRITE( 'Operando errato' ).
  else.
  case lv_op.
  when '+'.
  lv_result = lv_number1 + lv_number2.
  when '/'.
try.
  lv_result = lv_number1 / lv_number2.
catCH   CX_SY_ZERODIVIDE into data(lo_mess).
out->write( lo_mess->if_message~get_text(  ) ).
endTRY.
    when '-'.
  lv_result = lv_number1 - lv_number2.
    when '*'.
  lv_result = lv_number1 * lv_number2.
  endcase.
  out->write( lv_result ).
  endif.
  ENDMETHOD.
ENDCLASS.
