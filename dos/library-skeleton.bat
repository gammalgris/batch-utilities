@echo off


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Initialization
@rem ---

set INFO_FILE_SUFFIX=.info
set ERRORS_FILE_SUFFIX=.errors

set "batchName=%0"
set "fullBatchPath=%~dpnx0"
set "infoFile=%~dp0%~n0%INFO_FILE_SUFFIX%"
set "errorsFile=%~dp0%~n0%ERRORS_FILE_SUFFIX%"
set subroutineName=%1


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Load prerequisites
@rem ---

call define-constants.bat
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	call:handleError MissingConstantsError
	call:cleanUp
	%return% %code%
)

call define-macros.bat
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	call:handleError MissingMacrosError
	call:cleanUp
	%return% %code%
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

	call:handleError NoSubroutineError
	call:cleanUp
	%return% %code%
)


set LABEL_PREFIX=:
set PUBLIC_PREFIX=PUBLIC_
set PUBLIC_LABEL_PREFIX=%LABEL_PREFIX%%PUBLIC_PREFIX%

findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%%1" %~dpnx0>nul
%ifError% (

	call:handleError InvalidSubroutineError %subroutineName%
	call:cleanUp
	%return% %code%
)


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
@rem ===   7) http://stackoverflow.com/questions/6359318/how-do-i-send-a-message-to-stderr-from-cmd
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

	for /f "delims=*" %%A in ('findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%" "%fullBatchPath%" 2^>nul ^| sort') do (

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

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %code%
	)
	set "subroutine=%subroutine:"=%"

	set "prefix=%PUBLIC_LABEL_PREFIX%%subroutine%%SPACE%"
	set BATCH_NAME_PATTERN={batch-name}
	set TABULATOR_PATTERN={tab}


	setlocal EnableDelayedExpansion

		for /f "delims=*" %%A in ('findstr /r /i /c:"^%prefix%" "%infoFile%" 2^>nul') do (

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
	set ERRORS_FILE_SUFFIX=

	set batchName=
	set fullBatchPath=
	set infoFile=
	set errorsFile=
	set subroutineName=

%return%

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void extractLine(String variableName, String linePattern, String file name)
@rem ---
@rem ---   Looks within the specified file for a matching line (i.e. a line which
@rem ---   starts with the specified pattern) and assigns the line value to the
@rem ---   specified variable.
@rem ---

:extractLine

	set "variableName=%1"
	if '%variableName%'=='' (

		call:printErrorMessage "(%0) No variable name has been specified!"
		%return% %GENERIC_FRAMEWORK_ERROR%
	)
	set "variableName=%variableName:"=%"


	set "linePattern=%2"
	if '%linePattern%'=='' (

		call:printErrorMessage "(%0) No line pattern has been specified!"
		%return% %GENERIC_FRAMEWORK_ERROR%
	)
	set "linePattern=%linePattern:"=%"


	set "filename=%3"
	if '%filename%'=='' (

		call:printErrorMessage "(%0) No file name has been specified!"
		%return% %GENERIC_FRAMEWORK_ERROR%
	)
	set "filename=%filename:"=%"


	setlocal EnableDelayedExpansion

		for /f "delims=*" %%A in ('findstr /r /i /C:"^%linePattern%" "%filename%" 2^>nul') do (

			set "line=%%A"
			set "line=!line:%linePattern%=!"
		)

	endlocal & set "%variableName%=%line%"

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void printErrorMessage(String errorMessage)
@rem ---
@rem ---   Prints the specified error message to the console.
@rem ---

:printErrorMessage

	%cprintln% Error: %~1 1>&2

%return%


@rem ================================================================================
@rem ===
@rem ===   Error Handling
@rem ===
@rem ===   User defined errors should have an error code > 1 in order to distinguish
@rem ===   them from unforeseen errors.
@rem ===


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void handleError(String errorName, String... someDetails)
@rem ---
@rem ---   A subroutine for handling errors. The first parameter is the error
@rem ---   identifier. Additionally further details can be specified which will be
@rem ---   included in the error message.
@rem ---

:handleError

	set "CODE_SUFFIX=.code@"
	set "MESSAGE_SUFFIX=.message@"


	set "errorName=%1"
	if '%errorName%'=='' (

		call:printErrorMessage "(%0) Errorhandling cannot proceed beacuse no error was specified!"
		%return% %GENERIC_FRAMEWORK_ERROR%
	)
	set "errorName=%errorName:"=%"

	set errorCodeKey=%errorName%%CODE_SUFFIX%
	set errorMessageKey=%errorName%%MESSAGE_SUFFIX%


	set code=
	call:extractLine code %errorCodeKey% %errorsFile%
	if '%code%'=='' (

		call:printErrorMessage "(%0) No error code has been specified for the error '%errorName%'!"
		%return% %GENERIC_FRAMEWORK_ERROR%
	)

	set message=
	call:extractLine message %errorMessageKey% %errorsFile%
	if "%message%"=="" (

		call:printErrorMessage "(%0) No error message has been specified for the error '%errorName%'!"
		%return% %GENERIC_FRAMEWORK_ERROR%
	)


	setlocal EnableDelayedExpansion

	set "tmp=%message%"
	shift

	set i=1

:handleError_loop

	if "%~1"=="" (

		goto handleError_showMessage
	)

	set placeholder={%i%}

	set tmp=!tmp:%placeholder%='%~1%'!
	
	shift
	set /A i=i+1

	goto handleError_loop

:handleError_showMessage

	endlocal & set "message=%tmp%"
	
	call:PrintErrorMessage "%message%"


	set CODE_SUFFIX=
	set MESSAGE_SUFFIX=

	set errorName=
	set errorCodeKey=
	set errorMessageKey=
	set message=

%return% %code%


@rem ================================================================================
@rem ===
@rem ===  The end of this batch file.
@rem ===

:END

call:cleanUp

%return% %NO_ERROR%
