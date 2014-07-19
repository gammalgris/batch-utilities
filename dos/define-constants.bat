@echo off

if defined __CONSTANTS__ (

	goto SILENT_END
)

echo execute %~n0...


@rem ================================================================================
@rem ===
@rem ===   Declarations of various constants.
@rem ===

set constantName=SPACE
echo     define %constantName%
set "%constantName%= "


set constantName=TAB
echo     define %constantName%
set "%constantName%=%SPACE%%SPACE%%SPACE%%SPACE%"


set constantName=TABULATOR
echo     define %constantName%
set "%constantName%=%TAB%"


call:defineConstant TRUE TRUE
call:defineConstant FALSE FALSE

call:defineConstant SLASH /
call:defineConstant BACKSLASH \


set constantName=LEFT_CHEVRON
echo     define %constantName%
set "%constantName%=^<"

set constantName=RIGHT_CHEVRON
echo     define %constantName%
set "%constantName%=^>"

set constantName=LEFT_PARENTHESIS
echo     define %constantName%
set "%constantName%=^("

set constantName=RIGHT_PARENTHESIS
echo     define %constantName%
set "%constantName%=^)"

set constantName=AMPERSAND
echo     define %constantName%
set "%constantName%=^&"


set constantName=LEFT_CHEVRON_REPLACEMENT
echo     define %constantName%
set "%constantName%=^^^<"

set constantName=RIGHT_CHEVRON_REPLACEMENT
echo     define %constantName%
set "%constantName%=^^^>"

set constantName=LEFT_PARENTHESIS_REPLACEMENT
echo     define %constantName%
set "%constantName%=^^^("

set constantName=RIGHT_PARENTHESIS_REPLACEMENT
echo     define %constantName%
set "%constantName%=^^^)"

set constantName=AMPERSAND_REPLACEMENT
echo     define %constantName%
set "%constantName%=^^^&"


call:defineConstant PRIME '
call:defineConstant DOUBLE_PRIME "


set __CONSTANTS__=loaded
goto END


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void defineConstant(String constantName, String value)
@rem ---
@rem ---   The subroutine defines the specified constant and initializes it with the
@rem ---   specified value.
@rem ---
@rem ---   Constants which represent special characters cannot be defined and
@rem ---   initialized by calling this subroutine.
@rem ---

:defineConstant

	set constantName=%1
	echo %TAB%define %constantName%
	set "%constantName%=%2"

goto:eof


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
