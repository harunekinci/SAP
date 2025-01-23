AT SELECTION-SCREEN.

  CASE sscrfields-ucomm.
    WHEN'FC01'.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action                         = 'S'
          view_name                      = 'ZEPRE_T022'
          no_warning_for_clientindep     = 'X'
          generate_maint_tool_if_missing = 'X'.
  ENDCASE. 