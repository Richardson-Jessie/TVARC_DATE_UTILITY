CLASS zcl_va_tvarc_date_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS create_empty_select_opt_tvarvc
      IMPORTING
        !variable TYPE tvarvc-name .
    CLASS-METHODS popup_confirm
      RETURNING
        VALUE(retval) TYPE boolean .
    CLASS-METHODS enque_variable
      IMPORTING
        !lv_name TYPE tvarvc-name
        !lv_type TYPE tvarvc-type
        !lv_numb TYPE tvarvc-numb .
    CLASS-METHODS deque_variable
      IMPORTING
        !lv_name TYPE tvarvc-name
        !lv_type TYPE tvarvc-type
        !lv_numb TYPE tvarvc-numb .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS zcl_va_tvarc_date_utility IMPLEMENTATION.


  METHOD create_empty_select_opt_tvarvc.

    DATA:bdc_variable TYPE bdcdata-fval.

    bdc_variable  = variable.

    CALL FUNCTION 'Z_CRTE_TVARV_SELECT_OPTION'
      EXPORTING
*       CTU      = 'X'
*       MODE     = 'N'
*       UPDATE   = 'L'
*       GROUP    =
*       USER     =
*       KEEP     =
*       HOLDDATE =
*       NODATA   = '/'
        name_001 = bdc_variable.
*   RB_TYPE_P_002       = ''
*   RB_TYPE_S_003       = 'X'
*   RB_TYPE_S_005       = 'X'
* IMPORTING
*   SUBRC               =
* TABLES
*   MESSTAB             =
    .


  ENDMETHOD.


  METHOD popup_confirm .
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


  METHOD enque_variable.
    CALL FUNCTION 'ENQUEUE_ESVARVC'
      EXPORTING
        mode_tvarvc    = 'E'
        name           = lv_name
        type           = lv_type
        numb           = lv_numb
        _scope         = '2'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
  ENDMETHOD.


  METHOD deque_variable.
      CALL FUNCTION 'DEQUEUE_ESVARVC'
    exporting
       mode_tvarvc = 'E'
       name        = lv_name
       type        = lv_type
       numb        = lv_numb
       _scope      = '3'
       _synchron   = ' '.
  ENDMETHOD.
ENDCLASS.
