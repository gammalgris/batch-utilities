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

set INFO_FILE_SUFFIX=.info

set batchName=%0
set fullBatchPath=%~dpnx0
set infoFile=%~dp0%0%INFO_FILE_SUFFIX%
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
@rem ===   4) http://stackoverflow.com/questions/3215501/batch-remove-file-extension
@rem ===   5) http://stackoverflow.com/questions/17063947/get-current-batchfile-directory
@rem ===   6) http://stackoverflow.com/questions/8797983/can-a-dos-batch-file-determine-its-own-file-name
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void listSubroutines()
@rem ---
@rem ---   Lists all subroutines which are defined within this utility library.
@rem ---
@rem ---   See
@rem ---   1) http://stackoverflow.com/questions/10960467/windows-batch-delayed-expansion-in-a-for-loop
@rem ---

:PUBLIC_listSubroutines

	for /f "delims=*" %%A in ('findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%" %fullBatchPath% 2^>nul ^| sort') do (

		set "name=%%A"

		setlocal EnableDelayedExpansion

			set "name=!name:%PUBLIC_LABEL_PREFIX%=!"
			echo !name!

		endlocal
		
		set name=
	)

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void info(String subroutine)
@rem ---
@rem ---   Prints the info screen for the specified subroutine.
@rem ---

:PUBLIC_info

	set "subroutine=%1"
	if '%subroutine%'=='' (

		goto MISSING_PARAMETER_ERROR
	)
	set "subroutine=%subroutine:"=%"

	set "prefix=%PUBLIC_LABEL_PREFIX%%subroutine%%SPACE%"
	set BATCH_NAME_PATTERN={batch-name}
	set TABULATOR_PATTERN={tab}


	setlocal EnableDelayedExpansion

		for /f "delims=*" %%A in ('findstr /r /i /c:"^%prefix%" %infoFile% 2^>nul') do (

			set "line=%%A"
			set "line=!line:%prefix%=!"

			if '!line!'=='' (

				@rem do nothing

			) else (

				set "line=!line:%TABULATOR_PATTERN%=%TABULATOR%!"
				set "line=!line:%BATCH_NAME_PATTERN%=%batchName%!"
			)

			!cprintln!.!line!
		)

	endlocal


	set BATCH_NAME_PATTERN=

	set prefix=
	set subroutine=

goto END


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
	set INFO_FILE_SUFFIX=

	set batchName=
	set fullBatchPath=
	set infoFile=
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
