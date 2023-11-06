*&---------------------------------------------------------------------*
*& Report zca_tvarvc_dateutility
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zca_tvarvc_dateutility_clean.

TABLES: tvarvc.

DATA: start_date_offset  TYPE scal-date,
      end_date_offset    TYPE scal-date,
      selection_operator TYPE tvarvc-opti.

DATA: start_offset_operand(1) TYPE c,
      end_offset_operand(1)   TYPE c,
      tvarvc_variant_count    TYPE i.

DATA: cmnt_hgh(15) TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_name   LIKE tvarvc-name OBLIGATORY MATCHCODE OBJECT zca_d_var_name.
  SELECTION-SCREEN COMMENT /1(79) comm1.
  SELECTION-SCREEN COMMENT /1(79) comm2.
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
  comm2 = 'Variables Need To Be Created In STVARV First'.
  comm3 = 'Options Only Valid for a Single Date'.

AT SELECTION-SCREEN.

  CLEAR:cmnt_lw,
        cmnt_hgh.

  TRY.
      CALL METHOD cl_scal_utils=>date_get_week
        EXPORTING
          iv_date      = sy-datum
        IMPORTING
          ev_year_week = DATA(year_week)
          ev_year      = DATA(year)
          ev_week      = DATA(week).
    CATCH cx_scal.
  ENDTRY.

  TRY.
      CALL METHOD cl_scal_utils=>week_get_first_day
        EXPORTING
          iv_year_week = year_week
          iv_year      = year
          iv_week      = week
        IMPORTING
          ev_date      = DATA(first_day).
      .
    CATCH cx_scal.
  ENDTRY.

  start_date_offset = SWITCH #( rda_spls WHEN 'X' THEN first_day + p_wkstof
                                                ELSE first_day - p_wkstof
                                                ).

  start_offset_operand = SWITCH #( rda_spls WHEN 'X' THEN '+'
                                                ELSE '-'
                                                ).


  end_date_offset = SWITCH #( rda_epls WHEN 'X' THEN first_day + p_wkndof
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
    CONCATENATE
    ' AND '
    end_date_offset+6(2)
    '.'
     end_date_offset+4(2)
    '.'
     end_date_offset+0(4)
     INTO cmnt_hgh RESPECTING BLANKS.
  ENDIF.

  IF p_wkstof IS NOT INITIAL.
    CONCATENATE selection_operator
    ' '
    start_date_offset+6(2)
    '.'
    start_date_offset+4(2)
    '.'
    start_date_offset+0(4)
    cmnt_hgh
    INTO cmnt_lw RESPECTING BLANKS.
  ENDIF.

START-OF-SELECTION.

  IF p_name(5) NE 'ZCA_D'. "Validation to Make sure other variables are not accidently changed.

    MESSAGE 'Please Use Variable Prefixed with ''ZCA_D''' TYPE 'E'.

  ELSE.

    SELECT COUNT( * ) FROM tvarvc
      WHERE  name = @p_name
      AND type = 'S'
      AND numb = '0000' INTO @tvarvc_variant_count.

    IF tvarvc_variant_count IS INITIAL.
*
      MESSAGE 'Variable Not Found, Please Create Variable in STVARV Transaction First' TYPE 'E'.

    ENDIF.

    IF p_wkndof IS INITIAL OR p_wkstof = p_wkndof.

      UPDATE tvarvc
      SET sign = 'I'
          opti = selection_operator
          low = start_date_offset
          high = ''
      WHERE name = p_name
      AND type = 'S'
      AND numb = ''.

    ELSE.

      UPDATE tvarvc
      SET sign = 'I'
          opti = selection_operator
          low = start_date_offset
          high = end_date_offset
      WHERE name = p_name
      AND type = 'S'
      AND numb = ''.
      MESSAGE 'Selection Option Ignored For Range' TYPE 'S'.
    ENDIF.

  ENDIF.
