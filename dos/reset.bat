@echo off

echo execute %~n0...

set "$TAB=%TAB%"

call:undefine SPACE
call:undefine TAB
call:undefine TABULATOR
call:undefine TRUE
call:undefine FALSE
call:undefine SLASH
call:undefine BACKSLASH
call:undefine LEFT_CHEVRON
call:undefine RIGHT_CHEVRON
call:undefine LEFT_PARENTHESIS
call:undefine RIGHT_PARENTHESIS
call:undefine AMPERSAND
call:undefine LEFT_CHEVRON_REPLACEMENT
call:undefine RIGHT_CHEVRON_REPLACEMENT
call:undefine LEFT_PARENTHESIS_REPLACEMENT
call:undefine RIGHT_PARENTHESIS_REPLACEMENT
call:undefine AMPERSAND_REPLACEMENT
call:undefine PRIME
call:undefine DOUBLE_PRIME
call:undefine NO_ERROR
call:undefine GENERIC_FRAMEWORK_ERROR
call:undefine FILE_IS_NOT_LOCKED
call:undefine FILE_IS_LOCKED
call:undefine READ_ACCESS
call:undefine DENIED_READ_ACCESS
call:undefine WRITE_ACCESS
call:undefine DENIED_WRITE_ACCESS

echo.

call:undefine ifError
call:undefine cprintln
call:undefine cprintln
call:undefine return

echo.

call:undefine __CONSTANTS__
call:undefine __MACROS__

set $TAB=

echo %~n0 done.

exit /b 0


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void undefine(String name)
@rem ---
@rem ---   The subroutine undefines the specified constant or macro .
@rem ---

:undefine

	echo %$TAB%undefine %1
	set %1=

goto:eof
