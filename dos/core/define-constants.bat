@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) 2014 Kristian Kutin
@rem
@rem Permission is hereby granted, free of charge, to any person obtaining a copy
@rem of this software and associated documentation files (the "Software"), to deal
@rem in the Software without restriction, including without limitation the rights
@rem to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@rem copies of the Software, and to permit persons to whom the Software is
@rem furnished to do so, subject to the following conditions:
@rem
@rem The above copyright notice and this permission notice shall be included in all
@rem copies or substantial portions of the Software.
@rem
@rem THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@rem IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@rem FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@rem AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@rem LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@rem OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@rem SOFTWARE.
@rem

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


call:defineConstant NO_ERROR 0
call:defineConstant GENERIC_FRAMEWORK_ERROR 2


call:defineConstant	FILE_IS_NOT_LOCKED 0
call:defineConstant FILE_IS_LOCKED 1

call:defineConstant	READ_ACCESS 0
call:defineConstant DENIED_READ_ACCESS 1

call:defineConstant WRITE_ACCESS 0
call:defineConstant DENIED_WRITE_ACCESS 1


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
