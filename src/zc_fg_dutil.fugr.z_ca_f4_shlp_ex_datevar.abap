FUNCTION z_ca_f4_shlp_ex_datevar.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"----------------------------------------------------------------------
  CASE callcontrol-step.
    WHEN 'SELONE'.
    WHEN 'PRESEL1'.
    WHEN 'SELECT'.
    WHEN 'DISP'.
      LOOP AT record_tab.
        IF record_tab-string+3(5) NE 'ZCA_D'.
          DELETE record_tab INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
    WHEN 'RETURN'.
  ENDCASE.
ENDFUNCTION.
