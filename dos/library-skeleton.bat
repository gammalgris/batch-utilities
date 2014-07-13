@echo off


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Load prerequisites
@rem ---

call define-constants.bat
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	goto MISSING_CONSTANTS_ERROR
)

call define-macros.bat
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	goto MISSING_MACROS_ERROR
)


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Check the specified subroutine.
@rem ---
@rem ---   See
@rem ---   1) http://stackoverflow.com/questions/834882/recovering-from-an-invalid-goto-command-in-a-windows-batch-file
@rem ---   2) http://stackoverflow.com/questions/1645843/resolve-absolute-path-from-relative-path-and-or-file-name
@rem ---

if "%1"=="" (

	goto NO_SUBROUTINE_ERROR
)


set LABEL_PREFIX=:
set PUBLIC_PREFIX=PUBLIC_
set PUBLIC_LABEL_PREFIX=%LABEL_PREFIX%%PUBLIC_PREFIX%

findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%%1" %~dpnx0>nul
%ifError% (

	goto INVALID_SUBROUTINE_ERROR
)

set batchName=%0
set subroutineName=%1
shift

goto %PUBLIC_PREFIX%%subroutineName%


@rem ================================================================================
@rem ===
@rem ===   Public Subroutines
@rem ===

@rem ===
@rem ===   General Resources
@rem ===
@rem ===   1) http://www.robvanderwoude.com/escapechars.php
@rem ===   2) http://www.dostips.com/DtTipsStringManipulation.php
@rem ===   3) http://ss64.com/nt/delayedexpansion.html
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void test()
@rem ---
@rem ---   A subroutine for testing purposes.
@rem ---

:PUBLIC_test

	%cprint%Test
	%cprint%....
	%cprintln% done.

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

	set LABEL_PREFIX=
	set PUBLIC_PREFIX=
	set PUBLIC_LABEL_PREFIX=

	set batchName=
	set subroutineName=

goto:eof


@rem ================================================================================
@rem ===
@rem ===   Error Handling
@rem ===
@rem ===   User defined errors should have an error code > 2 in order to distinguish
@rem ===   them from unforeseen errors.
@rem ===


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A prerequisite (constants) is missing.
@rem ---

:MISSING_CONSTANTS_ERROR

echo Error: A prerequisite (constants) is missing!
call:cleanUp

exit /b 2


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A prerequisite (macros) is missing.
@rem ---

:MISSING_MACROS_ERROR

echo Error: A prerequisite (macros) is missing!
call:cleanUp

exit /b 3


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   No subroutine has been specified.
@rem ---

:NO_SUBROUTINE_ERROR

echo Error: No subroutine has been specified!
call:cleanUp

exit /b 4


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   An invalid subroutine has been specified.
@rem ---

:INVALID_SUBROUTINE_ERROR

echo Error: No subroutine with the name "%1" exists!
call:cleanUp

exit /b 5


@rem ================================================================================
@rem ===
@rem ===  The end of this batch file.
@rem ===

:END

call:cleanUp

exit /b 0
