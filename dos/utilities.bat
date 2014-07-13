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

findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%%1" %~dpnx0 > nul
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
@rem ---   void today(String datePattern)
@rem ---
@rem ---   A subroutine which prints the current date according to the specified
@rem ---   date pattern.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      yyyy    Year
@rem ---      MM      Month in year
@rem ---      dd      Day in year
@rem ---

:PUBLIC_today

	set input=%1
	set "input=%input:"=%"

	if "%input%"=="" (
	
		goto MISSING_PARAMETER_ERROR
	)

	set YEAR_PATTERN=yyyy
	set MONTH_PATTERN=MM
	set DAY_PATTERN=dd

	set year=%date:~-4,4%
	set month=%date:~-7,2%
	set day=%date:~-10,2%

	setlocal EnableDelayedExpansion

		set "output=!input!"
		set "output=!output:%YEAR_PATTERN%=%year%!"
		set "output=!output:%MONTH_PATTERN%=%month%!"
		set "output=!output:%DAY_PATTERN%=%day%!"

	endlocal & %cprintln% %output%

	set input=

	set year=
	set month=
	set day=

	set YEAR_PATTERN=
	set MONTH_PATTERN=
	set DAY_PATTERN=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void now(String timePattern)
@rem ---
@rem ---   A subroutine which prints the current time according to the specified
@rem ---   time pattern.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      HH      Hour in day (0-23)
@rem ---      mm      Minute in hour
@rem ---      ss      Second in minute
@rem ---      ff      seconds fraction
@rem ---

:PUBLIC_now

	set input=%1
	set "input=%input:"=%"

	if "%input%"=="" (
	
		goto MISSING_PARAMETER_ERROR
	)

	set HOUR_PATTERN=HH
	set MINUTE_PATTERN=mm
	set SECOND_PATTERN=ss
	set FRACTION_PATTERN=ff

	setlocal EnableExtensions

		for /f "tokens=1-4 delims=:,.-/ " %%i in ('%cprintln% %time%') do (
		
			set hours=%%i
			set minutes=%%j
			set seconds=%%k
			set fraction=%%l
		)

	setlocal EnableDelayedExpansion

		set "output=!input!"
		set "output=!output:%HOUR_PATTERN%=%hours%!"
		set "output=!output:%MINUTE_PATTERN%=%minutes%!"
		set "output=!output:%SECOND_PATTERN%=%seconds%!"
		set "output=!output:%FRACTION_PATTERN%=%fraction%!"

	endlocal & %cprintln% %output%
	endlocal

	set input=

	set HOUR_PATTERN=
	set MINUTE_PATTERN=
	set SECOND_PATTERN=
	set FRACTION_PATTERN=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void findFiles(String baseDirectory, String fileName)
@rem ---
@rem ---   A subroutine which looks for the specified files at the specified
@rem ---   location.
@rem ---
@rem ---   See
@rem ---   1) http://stackoverflow.com/questions/12712905/how-to-check-if-the-user-input-ends-with-a-specific-string-in-batch-bat-scrip
@rem ---

:PUBLIC_findFiles

	set baseDirectory=%1
	set "baseDirectory=%baseDirectory:"=%"

	if "%baseDirectory%"=="" (
	
		goto MISSING_BASE_DIRECTORY_ERROR
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	set fileName=%2
	set "fileName=%fileName:"=%"

	if "%fileName%"=="" (
	
		goto MISSING_FILE_NAME_ERROR
	)


	for /f "delims=*" %%A in ('dir /A-D /B /S "%baseDirectory%%fileName%" ^| sort') do (

		%cprintln% %%A
	)


	set baseDirectory=
	set fileName=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkFile(String fullPath)
@rem ---
@rem ---   A subroutine which checks if the specified path represents a file or
@rem ---   directory. The result is printed to the console.
@rem ---
@rem ---   Return values:
@rem ---
@rem ---      1) file        the path represents a file
@rem ---      2) directory   the path represents a directory
@rem ---      3) invalid     the path doesn't represent an existing file or directory
@rem ---

:PUBLIC_checkFile

	set fullPath=%1
	set "fullPath=%fullPath:"=%"

	if "%fullPath%"=="" (
	
		goto MISSING_PATH_ERROR
	)


	if not exist "%fullPath%" (

		%cprintln% invalid
		goto END_checkFile
	)


	set "currentDir=%CD%"

	cd /D "%fullPath%" > nul 2> nul
	%ifError% (

		%cprintln% file

	) else (

		%cprintln% directory
	)

	cd /D %currentDir%


:END_checkFile

	set fullPath=
	set currentDir=

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


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a parameter but none wasn't specified.
@rem ---

:MISSING_PARAMETER_ERROR

echo Error: The subroutine with the name "%0" expects a parameter but none was specified!
call:cleanUp

exit /b 6


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a directory but none wasn't specified.
@rem ---

:MISSING_BASE_DIRECTORY_ERROR

echo Error: The subroutine with the name "%0" expects a directory but none was specified!
call:cleanUp

exit /b 7


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a file name but none wasn't specified.
@rem ---

:MISSING_FILE_NAME_ERROR

echo Error: The subroutine with the name "%0" expects a file name but none was specified!
call:cleanUp

exit /b 8


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a path but none wasn't specified.
@rem ---

:MISSING_PATH_ERROR

echo Error: The subroutine with the name "%0" expects a path but none was specified!
call:cleanUp

exit /b 9


@rem ================================================================================
@rem ===
@rem ===  The end of this batch file.
@rem ===

:END

call:cleanUp

exit /b 0
