@echo off

if defined __MACROS__ (

	goto SILENT_END
)

echo execute %~n0...


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


@rem ================================================================================
@rem ===
@rem ===   Declarations of various macros.
@rem ===
@rem ===   The macros should be tested after declaration to ensure that they work as
@rem ===   expected.
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A macro to check the error level.
@rem ---
@rem ---   See
@rem ---   http://stackoverflow.com/questions/10935693/foolproof-way-to-check-for-nonzero-error-return-code-in-windows-batch-file
@rem ---

set macroName=ifError
echo %TAB%define %macroName%
set "%macroName%=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"

call error.bat
%ifError% (

	@rem OK, the macro works

) else (

	goto MACRO_ERROR
)

call ok.bat
%ifError% (

	goto MACRO_ERROR

) else (

	@rem OK, the macro works
)


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A macro for printing text to the console. A line feed will follow the
@rem ---   specified text.
@rem ---

set macroName=cprintln
echo %TAB%define %macroName%
set "%macroName%=echo"

%cprintln% Test > nul
%ifError% (

	goto MACRO_ERROR
)


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A macro for printing text to the console. No line feed will follow the
@rem ---   specified text.
@rem ---

set macroName=cprint
echo %TAB%define %macroName%
set "%macroName%=echo|set /p="

%cprint% Test > nul
if "%ERRORLEVEL%"=="1" (

	@rem OK, the macro works

) else (

	goto MACRO_ERROR
)


set __MACROS__=loaded
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

	set macroName=

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
@rem ---   A macro which has been defined failed a test.
@rem ---

:MACRO_ERROR

echo Error: The macro "%macroName%" doesn't work as expected!
call:cleanUp

exit /b 3


@rem ================================================================================
@rem ===
@rem ===   The end of this batch file.
@rem ===

:END

call:cleanUp
echo %~n0 done.

:SILENT_END

exit /b 0