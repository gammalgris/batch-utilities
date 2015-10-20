@echo off


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


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Load prerequisites
@rem ---

call %~dp0%define-constants.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Error: Unable to initialize constants! >&2
	exit /b 3
)

call %~dp0%define-macros.bat 2>nul
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
@rem ---   void newArray(String __arrayName)
@rem ---
@rem ---   Creates a new 'array', i.e. the variable which contains the array's length
@rem ---   is initialized.
@rem ---
@rem ---
@rem ---   @param __arrayName
@rem ---          the name of a variable that represents an array
@rem ---

:PUBLIC_newArray

	set "__arrayName=%1"
	if '%__arrayName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "__arrayName=%__arrayName:"=%"


	if defined %__arrayName%.length (

		call:handleError InitializationFailedError %__arrayName%
		call:cleanUp
		%return% %returnCode%
	)


	set "%__arrayName%.length=0"


	set __arrayName=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void destroyArray(String _arrayName)
@rem ---
@rem ---   Destroys the specified  'array', i.e. the variables which contain the
@rem ---   array's length and content are undefined.
@rem ---
@rem ---
@rem ---   @param _arrayName
@rem ---          the name of a variable that represents an array
@rem ---

:PUBLIC_destroyArray

	set "_arrayName=%1"
	if '%_arrayName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "_arrayName=%_arrayName:"=%"


	if not defined %_arrayName%.length (

		call:handleError InvalidArrayError %_arrayName%
		call:cleanUp
		%return% %returnCode%
	)


	set _length=
	setlocal EnableDelayedExpansion

		set "tmp=!%_arrayName%.length!"

	endlocal & set _length=%tmp%


	for /L %%A in (1, 1, %_length%) do (

		set %_arrayName%[%%A]=
	)

	set %_arrayName%.length=


	set _length=
	set _arrayName=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void addArrayElement(String __arrayName, String __value)
@rem ---
@rem ---   Adds a new element to the specified array.
@rem ---
@rem ---
@rem ---   @param __arrayName
@rem ---          the name of a variable that represents an array
@rem ---   @param __value
@rem ---          the value of the new array element
@rem ---

:PUBLIC_addArrayElement

	set "__arrayName=%1"
	if '%__arrayName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "__arrayName=%__arrayName:"=%"

	set "__value=%2"
	if '%__value%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "__value=%__value:"=%"


	if not defined %__arrayName%.length (

		call:handleError InvalidArrayError %__arrayName%
		call:cleanUp
		%return% %returnCode%
	)


	set __length=
	setlocal EnableDelayedExpansion

		set "tmp=!%__arrayName%.length!"

	endlocal & set __length=%tmp%

	set /a __newLength=%__length%+1

	set "%__arrayName%[%__newLength%]=%__value%"
	set "%__arrayName%.length=%__newLength%"


	set __length=
	set __newLength=
	
	set __arrayName=
	set __value=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void printArray(String _arrayName)
@rem ---
@rem ---   Prints the specified array to the console.
@rem ---
@rem ---
@rem ---   @param _arrayName
@rem ---          the name of a variable that represents an array
@rem ---

:PUBLIC_printArray

	set "_arrayName=%1"
	if '%_arrayName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "_arrayName=%_arrayName:"=%"


	if not defined %_arrayName%.length (

		call:handleError InvalidArrayError %_arrayName%
		call:cleanUp
		%return% %returnCode%
	)


	set _length=
	setlocal EnableDelayedExpansion

		set "tmp=!%_arrayName%.length!"

	endlocal & set _length=%tmp%


	for /L %%A in (1, 1, %_length%) do (

		call arrays.bat printArrayElement %_arrayName% %%A
	)


	set _length=
	set _arrayName=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void printArrayElement(String __arrayName, int __index)
@rem ---
@rem ---   Prints an element of the specified array at the specified index to the
@rem ---   console.
@rem ---
@rem ---
@rem ---   @param __arrayName
@rem ---          the name of a variable that represents an array
@rem ---   @param __index
@rem ---          the index of an element of the array
@rem ---

:PUBLIC_printArrayElement

	set "__arrayName=%1"
	if '%__arrayName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "__arrayName=%__arrayName:"=%"

	set "__index=%2"
	if '%__index%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "__index=%__index:"=%"


	if not defined %__arrayName%[%__index%] (

		call:handleError InvalidArrayElementError %__arrayName% %__index%
		call:cleanUp
		%return% %returnCode%
	)


	setlocal EnableDelayedExpansion

		%cprintln% !%__arrayName%[%__index%]!

	endlocal


	set __arrayName=
	set __index=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void parseFile(String _fileName, String _arrayName)
@rem ---
@rem ---   Reads the specified file and adds the lines to the specified array.
@rem ---
@rem ---
@rem ---   @param _fileName
@rem ---          the name of an input file
@rem ---   @param _arrayName
@rem ---          the name of a variable that represents an array
@rem ---

:PUBLIC_parseFile

	set "_fileName=%1"
	if '%_fileName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "_fileName=%_fileName:"=%"

	set "_arrayName=%2"
	if '%_arrayName%'=='' (

		call:handleError MissingParameterError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "_arrayName=%_arrayName:"=%"


	if not exist "%_fileName%" (

		call:handleError FileNotFoundError "%_fileName%"
		call:cleanUp
		%return% %returnCode%
	)


	
	for /F "delims=" %%A in (%_fileName%) do (

		call arrays.bat addArrayElement %_arrayName% "%%A"
	)


	set _fileName=
	set _arrayName=

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
