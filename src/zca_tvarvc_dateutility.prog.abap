*&---------------------------------------------------------------------*
*& Report zca_tvarvc_dateutility
*&---------------------------------------------------------------------*
*& Author: Jessie Richardson
*& Git Repo:https://github.com/Richardson-Jessie/TVARC_DATE_UTILITY.git
*& Sets Dates in TVARVC table + / - x Days relevant to the
*& time that the report was executed.
*&
*& Idea was adapted from Standard SAP Report RVSETDAT. Allowing users to
*& use dynamic date calculations relevant to a point in time, using
*& Variable Type "T" In Selection Screens.
*&---------------------------------------------------------------------*
REPORT zca_tvarvc_dateutility.

TABLES: tvarvc.

DATA: start_date_offset       TYPE scal-date,
      end_date_offset         TYPE scal-date,
      selection_operator      TYPE tvarvc-opti,
      start_offset_operand(1) TYPE c,
      end_offset_operand(1)   TYPE c.

DATA: cmnt_hgh(15) TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_name   LIKE tvarvc-name OBLIGATORY MATCHCODE OBJECT zca_d_var_name.
  SELECTION-SCREEN COMMENT /1(79) comm1.
  SELECTION-SCREEN COMMENT /1(79) cmnt_lw.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_wkstof TYPE i,
              rda_spls RADIOBUTTON GROUP rd2,
              rda_smin RADIOBUTTON GROUP rd2.
  SELECTION-SCREEN BEGIN OF BLOCK b2_2 WITH FRAME TITLE TEXT-003.
    SELECTION-SCREEN COMMENT /1(50) comm3.
    PARAMETERS: rda_oleq RADIOBUTTON GROUP rd3,
                rda_olle RADIOBUTTON GROUP rd3,
                rda_olge RADIOBUTTON GROUP rd3.
  SELECTION-SCREEN END OF BLOCK b2_2.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-004.
  PARAMETERS: p_wkndof TYPE i,
              rda_epls RADIOBUTTON GROUP rd4,
              rda_emin RADIOBUTTON GROUP rd4.
SELECTION-SCREEN END OF BLOCK b3.

INITIALIZATION.
  comm1 = 'Only Use Variables with prefixed with ''ZCA_D'''.
  comm3 = 'Options Only Valid for a Single Date'.

AT SELECTION-SCREEN.

  CLEAR:cmnt_lw,
        cmnt_hgh.

  TRY.
      cl_scal_utils=>date_get_week( EXPORTING iv_date      = sy-datum
                                    IMPORTING ev_year_week = DATA(year_week)
                                              ev_year      = DATA(year)
                                              ev_week      = DATA(week)
                                              ).
    CATCH cx_scal.
  ENDTRY.

  TRY.
      cl_scal_utils=>week_get_first_day( EXPORTING iv_year_week = year_week
                                                    iv_year      = year
                                                    iv_week      = week
                                         IMPORTING ev_date      = DATA(first_day)
                                        ).

    CATCH cx_scal.

  ENDTRY.

  start_date_offset   = SWITCH d( rda_spls WHEN 'X' THEN first_day + p_wkstof
                                                ELSE first_day - p_wkstof
                                                ).

  start_offset_operand = SWITCH #( rda_spls WHEN 'X' THEN '+'
                                                ELSE '-'
                                                ).


  end_date_offset = SWITCH d( rda_epls WHEN 'X' THEN first_day + p_wkndof
                                                ELSE first_day - p_wkndof
                                                ).

  end_offset_operand = SWITCH #( rda_epls WHEN 'X' THEN '+'
                                                ELSE '-'
                                                ).

  selection_operator = COND #( WHEN rda_oleq = 'X' AND p_wkndof IS INITIAL THEN 'EQ'
                               WHEN rda_olle = 'X' AND p_wkndof IS INITIAL THEN 'LE'
                               WHEN rda_olge = 'X' AND p_wkndof IS INITIAL THEN 'GE'
                               ELSE 'BT').

  IF start_date_offset  > end_date_offset AND p_wkndof IS NOT INITIAL. "Validation to make sure only valid ranges are entered into TVARVC
    MESSAGE i650(db).
  ENDIF.

  CLEAR:cmnt_lw,
cmnt_hgh.

  IF p_wkndof IS NOT INITIAL.
    cmnt_hgh  = | AND { end_date_offset+6(2) }.{ end_date_offset+4(2) }.{ end_date_offset+0(4) }|.
  ENDIF.

  IF p_wkstof IS NOT INITIAL.
    cmnt_lw = | { selection_operator } { start_date_offset+6(2) }.{ start_date_offset+4(2) }.{ start_date_offset+0(4) } { cmnt_hgh }|.
  ENDIF.

START-OF-SELECTION.

  IF p_name(5) NE |ZCA_D|. "Validation to Make sure other variables are not accidently changed.

    MESSAGE |Please Use Variable Prefixed with 'ZCA_D'| TYPE 'E'.

  ELSE.

    SELECT COUNT( * ) FROM tvarvc
      WHERE  name = @p_name
      AND type = 'S'
      AND numb = '0000' INTO @DATA(tvarvc_variable_count).

    IF tvarvc_variable_count IS INITIAL.
      zcl_va_tvarc_date_utility=>popup_confirm( RECEIVING retval = DATA(popup_answer) ).
      IF popup_answer = 'X'.
        zcl_va_tvarc_date_utility=>create_empty_select_opt_tvarvc( EXPORTING variable = p_name ).
      ENDIF.
    ENDIF.

    TRY.
        DATA(lr_lock_object) = cl_abap_lock_object_factory=>get_instance( iv_name = 'ESVARVC' ).

        lr_lock_object->enqueue(
          it_parameter  = VALUE #(  ( name = 'MANDT' value = REF #( sy-mandt ) )
                                    ( name = 'NAME' value =  REF #( p_name ) )
                                    ( name = 'TYPE' value =  REF #( 'S' ) )
                                  )
                               ).

      CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
        MESSAGE foreign_lock->get_text( ) TYPE 'E'.

      CATCH cx_abap_lock_failure INTO DATA(enque_lock_fail).
        MESSAGE enque_lock_fail->get_text( ) TYPE 'X'.

    ENDTRY.

    UPDATE tvarvc SET sign = 'I',
                      opti = @selection_operator,
                      low = @start_date_offset,
                      high = @( COND #( WHEN p_wkndof IS INITIAL OR p_wkstof = p_wkndof THEN ''
                                        ELSE end_date_offset
                                        ) )
                       WHERE name = @p_name
                                AND type = 'S'
                                AND numb = ''.
    TRY.
        lr_lock_object->dequeue( ).

      CATCH cx_abap_lock_failure INTO DATA(dequeue_lock_fail).
        MESSAGE dequeue_lock_fail->get_text( ) TYPE 'X'.
    ENDTRY.

    SELECT COUNT( * ) FROM tvarvc
      WHERE  name = @p_name
      AND type = 'S'
      AND numb = '0000' INTO @tvarvc_variable_count.

    DATA(success_message) = COND #( WHEN tvarvc_variable_count IS INITIAL
                                    THEN | Unsuccessful, No Variable In Table |
                                    ELSE | Variable { p_name }{ cmnt_lw } Created { COND #( WHEN p_wkndof IS INITIAL OR p_wkstof = p_wkndof
                                                                                            THEN ||
                                                                                            ELSE |, Selection Option Ignored For Range|
                                                                                          )
                                                                                  } |
                                   ).

    MESSAGE | { success_message } | TYPE 'S'.

  ENDIF.
