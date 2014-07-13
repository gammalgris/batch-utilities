@echo off

if defined __CONSTANTS__ (

	goto SILENT_END
)

echo execute %~n0...


@rem ================================================================================
@rem ===
@rem ===   Declarations of various constants.
@rem ===

set constantName=TAB
echo     define %constantName%
set "%constantName%=    "


set constantName=TRUE
echo %TAB%define %constantName%
set "%constantName%=TRUE"


set constantName=FALSE
echo %TAB%define %constantName%
set "%constantName%=FALSE"


set constantName=SLASH
echo %TAB%define %constantName%
set "%constantName%=/"


set constantName=BACKSLASH
echo %TAB%define %constantName%
set "%constantName%=\"


set __CONSTANTS__=loaded
goto END


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void cleanUp()
@rem ---
@rem ---   Deletes internally used variables. This subroutine is called before
@rem ---   exiting.
@rem ---

:cleanUp

	set constantName=

goto:eof


@rem ================================================================================
@rem ===
@rem ===   The end of this batch file.
@rem ===

:END

call:cleanUp
echo %~n0 done.

:SILENT_END

exit /b 0
