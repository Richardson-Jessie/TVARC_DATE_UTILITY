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
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_VA_TVARC_DATE_UTILITY IMPLEMENTATION.


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
        textline1      = 'Variable Does Not Exist!'
        textline2      = 'Do You Wish To Create A New Variable?'
*        textline3      =
        text_option1   = 'Yes'(001)
        text_option2   = 'No'(002)
*       ICON_TEXT_OPTION1       = '@09@'
*       ICON_TEXT_OPTION2       = '555 '
        titel          = 'Create New Variable?'
        start_column   = 25
        start_row      = 10
*        cancel_display = 'X'
      IMPORTING
        answer         = answer.

    IF answer = 'A'.
      MESSAGE e122(cnv_10996).
    ELSEIF answer = '1'.
      retval = 'X'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
