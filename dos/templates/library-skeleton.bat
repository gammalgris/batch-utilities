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

@rem ================================================================================
@rem ===
@rem ===   void main(String aSubroutine, String... someParameters)
@rem ===
@rem ===   This batch script is a template for smaller scripts.
@rem ===
@rem ===
@rem ===   @param aSubroutine
@rem ===          the name of a subroutine
@rem ===   @param someParameters
@rem ===          parameters required by the subroutine
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Initialization
@rem ---

call:setUp

set "batchName=%0"
set "fullBatchPath=%~dpnx0"
set "infoFile=%~dp0%~n0%INFO_FILE_SUFFIX%"
set "errorsFile=%~dp0%~n0%ERRORS_FILE_SUFFIX%"
set subroutineName=%1
set "corePath=%~dp0..\core\"


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Load prerequisites
@rem ---

call %corePath%define-constants.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Error: Unable to initialize constants! >&2
	exit /b 3
)

call %corePath%define-macros.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Error: Unable to initialize macros! >&2
	exit /b 4
)


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Check the specified subroutine.
@rem ---

if "%1"=="" (

	call:handleError NoSubroutineError
	call:cleanUp
	%return% %returnCode%
)


findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%%1" %~dpnx0>nul
%ifError% (

	call:handleError InvalidSubroutineError %subroutineName%
	call:cleanUp
	%return% %returnCode%
)


shift
goto %PUBLIC_PREFIX%%subroutineName%


@rem ================================================================================
@rem ===
@rem ===   Public Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void listSubroutines()
@rem ---
@rem ---   Lists all subroutines which are defined within this utility library.
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
@rem ---   void info(String subroutineName)
@rem ---
@rem ---   Prints the info screen for the specified subroutine.
@rem ---
@rem ---
@rem ---   @param subroutineName
@rem ---          the name of a subroutine (without the internal prefix)
@rem ---

:PUBLIC_info

	set "subroutineName=%1"
	if '%subroutineName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "subroutineName=%subroutineName:"=%"

	set "prefix=%PUBLIC_LABEL_PREFIX%%subroutineName%%SPACE%"
	set BATCH_NAME_PATTERN={batch-name}
	set TABULATOR_PATTERN={tab}


	findstr /r /i /c:"^%prefix%" %infoFile% >nul
	%ifError% (
	
		call:handleError InvalidSubroutineError %subroutineName%
		call:cleanUp
		%return% %returnCode%
	)


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
	set TABULATOR_PATTERN=

	set prefix=
	set subroutineName=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void about()
@rem ---
@rem ---   Prints a general description of this batch script.
@rem ---

:PUBLIC_about

	set "prefix=%LABEL_PREFIX%about%SPACE%"
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
	set TABULATOR_PATTERN=

	set prefix=

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
@rem ---   void setUp()
@rem ---
@rem ---   Initializes internally used constants. This subroutine is called at the
@rem ---   start of the script (i.e. macros and constants may not be available when
@rem ---   called).
@rem ---

:setUp

	set INFO_FILE_SUFFIX=.info
	set ERRORS_FILE_SUFFIX=.errors

	set LABEL_PREFIX=:
	set PUBLIC_PREFIX=PUBLIC_
	set PUBLIC_LABEL_PREFIX=%LABEL_PREFIX%%PUBLIC_PREFIX%

exit /b


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
	set corePath=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void extractLine(String variableName, String linePattern, String fileName)
@rem ---
@rem ---   Looks within the specified file for a matching line (i.e. a line which
@rem ---   starts with the specified pattern) and assigns the line string to the
@rem ---   specified variable.
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          the name of a variable
@rem ---   @param linePattern
@rem ---          a search pattern
@rem ---   @param fileName
@rem ---          the name of the file which is searched
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


	set "fileName=%3"
	if '%fileName%'=='' (

		call:printErrorMessage "(%0) No file name has been specified!"
		%return% %GENERIC_FRAMEWORK_ERROR%
	)
	set "fileName=%fileName:"=%"


	setlocal EnableDelayedExpansion

		for /f "delims=*" %%A in ('findstr /r /i /C:"^%linePattern%" "%fileName%" 2^>nul') do (

			set "line=%%A"
			set "line=!line:%linePattern%=!"
		)

	endlocal & set "%variableName%=%line%"

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void printErrorMessage(String errorMessage)
@rem ---
@rem ---   Prints the specified error message to the console (i.e. error channel).
@rem ---
@rem ---
@rem ---   @param errorMessage
@rem ---          an error message
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
@rem ---
@rem ---   @param errorName
@rem ---          the identifier for an error
@rem ---   @param someDetails
@rem ---          additional details which added to the error message
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


	set returnCode=
	call:extractLine returnCode %errorCodeKey% %errorsFile%
	if '%returnCode%'=='' (

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

%return% %returnCode%


@rem ================================================================================
@rem ===
@rem ===  The end of this batch file.
@rem ===

:END

call:cleanUp

%return% %NO_ERROR%
