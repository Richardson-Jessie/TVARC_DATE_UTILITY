function z_crte_tvarv_select_option.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CTU) LIKE  APQI-PUTACTIVE DEFAULT 'X'
*"     VALUE(MODE) LIKE  APQI-PUTACTIVE DEFAULT 'N'
*"     VALUE(UPDATE) LIKE  APQI-PUTACTIVE DEFAULT 'L'
*"     VALUE(GROUP) LIKE  APQI-GROUPID OPTIONAL
*"     VALUE(USER) LIKE  APQI-USERID OPTIONAL
*"     VALUE(KEEP) LIKE  APQI-QERASE OPTIONAL
*"     VALUE(HOLDDATE) LIKE  APQI-STARTDATE OPTIONAL
*"     VALUE(NODATA) LIKE  APQI-PUTACTIVE DEFAULT '/'
*"     VALUE(NAME_001) LIKE  BDCDATA-FVAL DEFAULT 'ZTEST'
*"     VALUE(RB_TYPE_P_002) LIKE  BDCDATA-FVAL DEFAULT ''
*"     VALUE(RB_TYPE_S_003) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(RB_TYPE_S_005) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------


subrc = 0.

perform bdc_nodata      using NODATA.

perform open_group      using GROUP USER KEEP HOLDDATE CTU.

perform bdc_dynpro      using 'SAPMS38V' '1100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TOGGLE'.
perform bdc_field       using 'BDC_CURSOR'
                              'I_TVARVC_PARAMS-NAME(01)'.
perform bdc_dynpro      using 'SAPMS38V' '1100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SINGLE'.
perform bdc_field       using 'BDC_CURSOR'
                              'I_TVARVC_PARAMS-NAME(01)'.
perform bdc_dynpro      using 'SAPMS38V' '1001'.
perform bdc_field       using 'BDC_CURSOR'
                              'TVARVC-NAME'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ADD'.
perform bdc_field       using 'TVARVC-NAME'
                              NAME_001.
perform bdc_field       using 'RB_TYPE_P'
                              RB_TYPE_P_002.
perform bdc_field       using 'RB_TYPE_S'
                              RB_TYPE_S_003.
perform bdc_dynpro      using 'SAPMS38V' '0600'.
perform bdc_field       using 'BDC_CURSOR'
                              'SEL_VAL-LOW'.
perform bdc_field       using 'BDC_OKCODE'
                              '=USAV'.
perform bdc_dynpro      using 'SAPLSPO2' '0100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=OPT2'.
perform bdc_dynpro      using 'SAPMS38V' '1001'.
perform bdc_field       using 'BDC_CURSOR'
                              'TVARVC-NAME'.
perform bdc_field       using 'BDC_OKCODE'
                              '=RETN'.
perform bdc_field       using 'RB_TYPE_S'
                              RB_TYPE_S_005.
perform bdc_dynpro      using 'SAPMS38V' '1100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=RETN'.
perform bdc_field       using 'BDC_CURSOR'
                              'I_TVARVC_PARAMS-NAME(01)'.
perform bdc_transaction tables messtab
using                         'STVARVC'
                              CTU
                              MODE
                              UPDATE.
if sy-subrc <> 0.
  subrc = sy-subrc.
  exit.
endif.

perform close_group using     CTU.





ENDFUNCTION.
INCLUDE BDCRECXY .
