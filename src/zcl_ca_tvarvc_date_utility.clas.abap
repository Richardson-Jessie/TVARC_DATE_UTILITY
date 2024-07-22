class ZCL_CA_TVARVC_DATE_UTILITY definition
  public
  final
  create public .

public section.

  class-methods POPUP_CONFIRM
    returning
      value(RETVAL) type BOOLEAN .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_CA_TVARVC_DATE_UTILITY IMPLEMENTATION.


  METHOD POPUP_CONFIRM .
    DATA answer TYPE c.
    CALL FUNCTION 'POPUP_TO_DECIDE'
      EXPORTING
*       defaultoption  = '1'
        textline1    = 'Variable Does Not Exist!'
        textline2    = 'Do You Wish To Create A New Variable?'
*       textline3    =
        text_option1 = 'Yes'(001)
        text_option2 = 'No'(002)
*       ICON_TEXT_OPTION1       = '@09@'
*       ICON_TEXT_OPTION2       = '555 '
        titel        = 'Create New Variable?'
        start_column = 25
        start_row    = 10
*       cancel_display = 'X'
      IMPORTING
        answer       = answer.

    IF answer = 'A'.
      MESSAGE e122(cnv_10996).
    ELSEIF answer = '1'.
      retval = 'X'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
