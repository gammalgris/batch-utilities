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

findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%%1" "%~dpnx0" > nul
%ifError% (

	goto INVALID_SUBROUTINE_ERROR
)

set INFO_FILE_SUFFIX=.info

set "batchName=%0"
set "fullBatchPath=%~dpnx0"
set "infoFile=%~dp0%~n0%INFO_FILE_SUFFIX%"
set subroutineName=%1
shift

goto %PUBLIC_PREFIX%%subroutineName%


@rem ================================================================================
@rem ===
@rem ===   Public Subroutines
@rem ===

@rem ===
@rem ===   TODO
@rem ===
@rem ===   - provide compatibility informations (e.g. WinXP, Windows Vista, Windows 7,
@rem ===     Windows8, Windows 8.1) for each subroutine.
@rem ===
@rem ===   - provide unit tests for the various public subroutines. This serves two purposes:
@rem ===     1) to check correctness and 2) to provide good and bad examples of usage.
@rem ===
@rem ===   - check the scope of "local variables" and "global variable". How is this aspect
@rem ===     handled by the batch interpreter, especially with regard to variable names that
@rem ===     are more commonly used?
@rem ===
@rem ===   - the clean up doesn't clean up variables which are defined inside a subroutine. If
@rem ===     a subroutine runs into an error there will still be variables that haven't been
@rem ===     cleaned up.
@rem ===
@rem ===   - the command 'set /P' changes the error level even if the call seemed successful.
@rem ===     This needs further investigation.
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
			!cprintln! !name!

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

	call:checkAndAssignParameter subroutine %1
	%ifError% (
	
		goto MISSING_PARAMETER_ERROR
	)


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
@rem ---   void today(String datePattern)
@rem ---
@rem ---   A subroutine which prints the current date to the console according to
@rem ---   the specified date pattern.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      yyyy    Year
@rem ---      MM      Month in year
@rem ---      dd      Day in year
@rem ---

:PUBLIC_today

	call:checkAndAssignParameter input %1
	%ifError% (

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
@rem ---   A subroutine which prints the current time to the console according to
@rem ---   the specified time pattern.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      HH      Hour in day (0-23)
@rem ---      mm      Minute in hour
@rem ---      ss      Second in minute
@rem ---      ff      seconds fraction
@rem ---

:PUBLIC_now

	call:checkAndAssignParameter input %1
	%ifError% (

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
@rem ---   void findFile(String baseDirectory, String fileName)
@rem ---
@rem ---   A subroutine which looks for files with the specified name at the
@rem ---   specified location and prints a list of matching files to the console.
@rem ---
@rem ---   See
@rem ---   1) http://stackoverflow.com/questions/12712905/how-to-check-if-the-user-input-ends-with-a-specific-string-in-batch-bat-scrip
@rem ---

:PUBLIC_findFile

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (
	
		goto MISSING_BASE_DIRECTORY_ERROR
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter fileName %2
	%ifError% (
	
		goto MISSING_FILE_NAME_ERROR
	)


	for /f "delims=*" %%A in ('dir /A-D /B /S "%baseDirectory%%fileName%" 2^>nul ^| sort') do (

		%cprintln% %%A
	)


	set baseDirectory=
	set fileName=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void findFileSets(String baseDirectory, String filePatterns)
@rem ---
@rem ---   A subroutine which looks for files which match the specified pattern name
@rem ---   at the specified location and prints a list of matching files to the
@rem ---   console.
@rem ---
@rem ---   A file pattern is provided as a quoted list (e.g. ".pdf .txt .csv").
@rem ---

:PUBLIC_findFileSets

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		goto MISSING_BASE_DIRECTORY_ERROR
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter filePatterns %2
	%ifError% (

		goto MISSING_FILE_PATTERNS_ERROR
	)


	for %%i in (%filePatterns%) do (

		call utilities.bat findFile "%baseDirectory%" "*%%i"
	)


	set baseDirectory=
	set filePatterns=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void findDirectory(String baseDirectory, String directoryName)
@rem ---
@rem ---   A subroutine which looks for directories with the specified name at the
@rem ---   specified location and prints a list of matching directories to the
@rem ---   console.
@rem ---

:PUBLIC_findDirectory

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		goto MISSING_BASE_DIRECTORY_ERROR
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryName %2
	%ifError% (

		goto MISSING_DIRECTORY_NAME_ERROR
	)


	for /f "delims=*" %%A in ('dir /AD /B /S "%baseDirectory%%directoryName%" 2^>nul ^| sort') do (

		%cprintln% %%A
	)


	set baseDirectory=
	set directoryName=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void findDirectorySets(String baseDirectory, String directoryPatterns)
@rem ---
@rem ---   A subroutine which looks for directories which match the specified pattern
@rem ---   at the specified location and prints a list of matching files to the
@rem ---   console.
@rem ---
@rem ---   A directory pattern is provided as a quoted list (e.g. "test1 test2").
@rem ---

:PUBLIC_findDirectorySets

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		goto MISSING_BASE_DIRECTORY_ERROR
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryPatterns %2
	%ifError% (

		goto MISSING_DIRECTORY_PATTERNS_ERROR
	)


	for %%i in (%directoryPatterns%) do (

		call utilities.bat findDirectory "%baseDirectory%" "*%%i"
	)


	set baseDirectory=
	set directoryPatterns=

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

	call:checkAndAssignParameter fullPath %1
	%ifError% (

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


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void stringLength(String string)
@rem ---
@rem ---   The subroutine determines the length of the specified string and prints
@rem ---   the result to the console.
@rem ---

:PUBLIC_stringLength

	call:checkAndAssignParameter string %1
	%ifError% (

		goto MISSING_PARAMETER_ERROR
	)


	setlocal EnableDelayedExpansion
	
		set index=0

	:stringLength_loop

		set char=!string:~%index%,1!

		if defined char (

			set /A index += 1
			goto stringLength_loop

		) else (

			%cprintln% %index%
		)

	endlocal

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void assignResult(String variableName, String commandString)
@rem ---
@rem ---   The specified command is executed and the console printout assigned to the
@rem ---   specified variable.
@rem ---
@rem ---   TODO
@rem ---
@rem ---   - the current implementation would assign the last line of the console
@rem ---     output to the variable.
@rem ---
@rem ---   - test when and how variables within the specified command string are
@rem ---     evaluated and check the repercussions thereof.
@rem ---
@rem ---   - provide examples for the command string, especially with regard to
@rem ---     special characters (e.g. chevrons) and how they need to be escaped.
@rem ---
@rem ---   - some kind of error handling is required, else the last line of the
@rem ---     executed command is assigned to the specified variable.
@rem ---
@rem ---   - an alternaive implementation assignArrayResult is required.
@rem ---

:PUBLIC_assignResult

	call:checkAndAssignParameter variableName %1
	%ifError% (

		goto MISSING_VARIABLE_NAME_ERROR
	)


	if '%2'=='' (

		goto MISSING_COMMAND_STRING_ERROR
	)


	setlocal EnableDelayedExpansion

		set string=%2
		set "string=!string:%LEFT_CHEVRON%=%LEFT_CHEVRON_REPLACEMENT%!"
		set "string=!string:%RIGHT_CHEVRON%=%RIGHT_CHEVRON_REPLACEMENT%!"
		set "string=!string:%LEFT_PARENTHESIS%=%LEFT_PARENTHESIS_REPLACEMENT%!"
		set "string=!string:%RIGHT_PARENTHESIS%=%RIGHT_PARENTHESIS_REPLACEMENT%!"
		set "string=!string:%AMPERSAND%=%AMPERSAND_REPLACEMENT%!"
		set "string=!string:%DOUBLE_PRIME%=!"

	endlocal & set "commandString=%string%"

	for /F "delims=*" %%i in ('%commandString%') do (
	
		set "%variableName%=%%i"
	)


	set variableName=
	set commandString=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void copyFiles(String baseDirectory, String targetDirectory, String filePatterns)
@rem ---
@rem ---   All files that match the specified file patterns are copied from the
@rem ---   specified base directory to the specified target directory.
@rem ---

:PUBLIC_copyFiles

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		goto MISSING_BASE_DIRECTORY_ERROR
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter targetDirectory %2
	%ifError% (

		goto MISSING_TARGET_DIRECTORY_ERROR
	)

	if "%targetDirectory:~-1%" neq "%BACKSLASH%" (

		set "targetDirectory=%targetDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter filePatterns %3
	%ifError% (

		goto MISSING_FILE_PATTERNS_ERROR
	)


	for /F "delims=*" %%i in ('call utilities.bat findFileSets "%baseDirectory%" "%filePatterns%"') do (

		set "newFileName=%%i"

		setlocal EnableDelayedExpansion

			set "newFileName=!newFileName:%baseDirectory%=%targetDirectory%!"
			echo xcopy /E /H /I /Y "%%i" "!newFileName!*"
			xcopy /E /H /I /Y "%%i" "!newFileName!*"

		endlocal
	)


	set newFileName=

	set baseDirectory=
	set targetDirectory=
	set filePatterns=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void copyDirectories(String baseDirectory, String targetDirectory, String directoryPatterns)
@rem ---
@rem ---   All directories that match the specified file patterns are copied (including
@rem ---   their contents) from the specified base directory to the specified target
@rem ---   directory.
@rem ---
@rem ---   A set of directory patterns is provided as a quoted list (e.g. "test1 test2").
@rem ---

:PUBLIC_copyDirectories

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		goto MISSING_BASE_DIRECTORY_ERROR
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter targetDirectory %2
	%ifError% (

		goto MISSING_TARGET_DIRECTORY_ERROR
	)

	if "%targetDirectory:~-1%" neq "%BACKSLASH%" (

		set "targetDirectory=%targetDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryPatterns %3
	%ifError% (

		goto MISSING_DIRECTORY_PATTERNS_ERROR
	)


	for /F "delims=*" %%i in ('call utilities.bat findDirectorySets "%baseDirectory%" "%directoryPatterns%"') do (

		set "newDirectoryName=%%i"

		setlocal EnableDelayedExpansion

			set "newDirectoryName=!newDirectoryName:%baseDirectory%=%targetDirectory%!"
			echo xcopy /E /H /I /Y "%%i" "!newDirectoryName!"
			xcopy /E /H /I /Y "%%i" "!newDirectoryName!"

		endlocal
	)


	set newDirectoryName=

	set baseDirectory=
	set targetDirectory=
	set filePatterns=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void listOldDirectories(String baseDirectory, int numberOfDays)
@rem ---
@rem ---   The subroutine lists all directories within the specified base directory
@rem ---   which are older than the specified number of days.
@rem ---

:PUBLIC_listOldDirectories

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void deleteOldDirectories(String baseDirectory, int numberOfDays)
@rem ---
@rem ---   The subroutine deletes all directories within the specified base directory
@rem ---   which are older than the specified number of days.
@rem ---

:PUBLIC_deleteOldDirectories

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void inputText(String promptMessage)
@rem ---
@rem ---   The subroutine prompts the user to enter a text. The text is printed to
@rem ---   the console.
@rem ---

:PUBLIC_inputText

	call:checkAndAssignParameter promptMessage %1
	%ifError% (

		goto MISSING_PROMPT_MESSAGE_ERROR
	)

	call:inputText enteredText "%promptMessage%"
	%ifError% (

		goto INVALID_TEXT_ERROR
	)

	%cprintln% %enteredText%


	set promptMessage=
	set enteredText=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void logMessage(String message)
@rem ---   void logMessage(String message, String outputFile)
@rem ---
@rem ---   The subroutine prints the specified message to the console. If a output
@rem ---   has been specified then the message will be written to a file as well.
@rem ---

:PUBLIC_logMessage

	call:checkAndAssignParameter message %1
	%ifError% (

		goto MISSING_MESSAGE_ERROR
	)

	call:inputText outputFile %2
	%ifError% (

		goto logMessage_consoleOutputOnly
	)


	%cprintln% %message% >> %outputFile%

:logMessage_consoleOutputOnly

	%cprintln% %message%


	set message=
	set outputFile=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void callProgram(String programPath, String executableName, String someParameters)
@rem ---
@rem ---   The subroutine calls the specified program. Before actually calling the program
@rem ---   several plausibility checks are performed (e.g. Does it exist? Is it a batch file?
@rem ---   etc.).
@rem ---

:PUBLIC_callProgram

	call:checkAndAssignParameter programPath %1
	%ifError% (

		goto MISSING_PROGRAM_PATH_ERROR
	)

	call:checkAndAssignParameter executableName %2
	%ifError% (

		goto MISSING_EXECUTABLE_NAME_ERROR
	)

	call:checkAndAssignParameter someParameters %3
	%ifError% (

		goto MISSING_PARAMETERS_ERROR
	)

	%cprintln% DEBUG::program path ...... %programPath%
	%cprintln% DEBUG::executable name ... %executableName%
	%cprintln% DEBUG::some parameters ... %someParameters%


	set BATCH_SUFFIX=.bat
	set EXE_SUFFIX=.exe
	set COM_SUFFIX=.com

	if not exist "%programPath%%executableName%" (

		goto NONEXISTANT_PROGRAM_ERROR
	)

	set "foundSuffix=%executableName:~-4%"
	%cprintln% DEBUG::found suffix ...... %foundSuffix%

	set invocationPrefix=


	if "%foundSuffix%"=="%BATCH_SUFFIX%" (

		set invocationPrefix=call

	) else (
	
		if "%foundSuffix%"=="%EXE_SUFFIX%" (

			@rem OK, no prefix

		) else (

			if "%foundSuffix%"=="%COM_SUFFIX%" (

				@rem OK, no prefix

			) else (

				goto NO_EXECUTABLE_SPECIFIED_ERROR
			)
		)
	)


	%cprintln% DEBUG::%invocationPrefix% "%programPath%%executableName%" %someParameters%
	%invocationPrefix% "%programPath%%executableName%" %someParameters%
	%ifError% (

		goto FAILED_INVOCATION_ERROR
	)


	set programPath=
	set executableName=
	set someParameters=
	set foundSuffix=
	set invocationPrefix=

	set BATCH_SUFFIX=
	set EXE_SUFFIX=
	set COM_SUFFIX=

goto END


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===
@rem ===
@rem ===   Implementation Guidelines
@rem ===
@rem ===   1) Names of "local variables" should be preceded by '_' to avoid naming
@rem ===      conflicts.
@rem ===
@rem ===   2) Calling other internal subroutines should be done with care due to
@rem ===      issues regarding the scope of "local variables" and "global variables".
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkAndAssignParameter(String _variableName, String _value)
@rem ---
@rem ---   The subroutine assigns the specified value to the specified variable.
@rem ---   Surrounding quotes are removed. If no value has been specified then the
@rem ---   subroutine exits with an error.
@rem ---
@rem ---   Note:
@rem ---   This internal subroutine doesn't check the specified parameters because
@rem ---   it expects them to be provided correctly by the caller. Additional
@rem ---   checks might be necessary to make the subroutine more robust, though.
@rem ---

:checkAndAssignParameter

	set "_variableName=%1"
	if '%_variableName%=='' (
	
		exit /b 2
	)

	set "_value=%2"
	set "_newValue=%2"

	set "%_variableName%=%_value%
	setlocal EnableDelayedExpansion

		if '!%_variableName%!'=='' (
		
			endlocal

			set _variableName=
			set _value=
			set _newValue=

			exit /b 3
		)

		set "_newValue=%_newValue:"=%"
	endlocal & set "%_variableName%=%_newValue%"

	set _variableName=
	set _value=
	set _newValue=

goto:eof


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void inputText(String _variableName, String _promptMessage)
@rem ---
@rem ---   The subroutine prompts the user to enter a text and stores the text in
@rem ---   the specified variable.
@rem ---

:inputText

	set "_variableName=%1"
	if '%_variableName%'=='' (
	
		exit /b 2
	)

	set "_promptMessage=%2"
	if '%_promptMessage%'=='' (
	
		exit /b 3
	)


	set %_variableName%=

:inputText_repeat

	set /P %_variableName%=%_promptMessage%

	if not defined %_variableName% (

		goto inputText_repeat
	)


	set _variableName=
	set _propmptMessage=

exit /b 0


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
@rem ===   User defined errors should have an error code > 1 in order to distinguish
@rem ===   them from unforeseen errors.
@rem ===


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A prerequisite (constants) is missing.
@rem ---

:MISSING_CONSTANTS_ERROR

echo Error: A prerequisite (constants) is missing! 1>&2
call:cleanUp

exit /b 2


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A prerequisite (macros) is missing.
@rem ---

:MISSING_MACROS_ERROR

echo Error: A prerequisite (macros) is missing! 1>&2
call:cleanUp

exit /b 3


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   No subroutine has been specified.
@rem ---

:NO_SUBROUTINE_ERROR

echo Error: No subroutine has been specified! 1>&2
call:cleanUp

exit /b 4


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   An invalid subroutine has been specified.
@rem ---

:INVALID_SUBROUTINE_ERROR

echo Error: No subroutine with the name "%1" exists! 1>&2
call:cleanUp

exit /b 5


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a parameter but none was specified.
@rem ---

:MISSING_PARAMETER_ERROR

echo Error: The subroutine with the name "%0" expects a parameter but none was specified! 1>&2
call:cleanUp

exit /b 6


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a directory but none was specified.
@rem ---

:MISSING_BASE_DIRECTORY_ERROR

echo Error: The subroutine with the name "%0" expects a directory but none was specified! 1>&2
call:cleanUp

exit /b 7


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a file name but none was specified.
@rem ---

:MISSING_FILE_NAME_ERROR

echo Error: The subroutine with the name "%0" expects a file name but none was specified! 1>&2
call:cleanUp

exit /b 8


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a file pattern but none was specified.
@rem ---

:MISSING_FILE_PATTERNS_ERROR

echo Error: The subroutine with the name "%0" expects a file pattern but none was specified! 1>&2
call:cleanUp

exit /b 9


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a path but none was specified.
@rem ---

:MISSING_PATH_ERROR

echo Error: The subroutine with the name "%0" expects a path but none was specified! 1>&2
call:cleanUp

exit /b 10


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a path but none was specified.
@rem ---

:MISSING_DIRECTORY_NAME_ERROR

echo Error: The subroutine with the name "%0" expects a directory name but none was specified! 1>&2
call:cleanUp

exit /b 11


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a variable name but none was specified.
@rem ---

:MISSING_VARIABLE_NAME_ERROR

echo Error: The subroutine with the name "%0" expects a variable name but none was specified! 1>&2
call:cleanUp

exit /b 12


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a variable name but none was specified.
@rem ---

:MISSING_COMMAND_STRING_ERROR

echo Error: The subroutine with the name "%0" expects a command string but none was specified! 1>&2
call:cleanUp

exit /b 13


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a target directory but none was specified.
@rem ---

:MISSING_TARGET_DIRECTORY_ERROR

echo Error: The subroutine with the name "%0" expects a target directory but none was specified! 1>&2
call:cleanUp

exit /b 14


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a directory pattern but none was specified.
@rem ---

:MISSING_DIRECTORY_PATTERNS_ERROR

echo Error: The subroutine with the name "%0" expects a directory pattern but none was specified! 1>&2
call:cleanUp

exit /b 15


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a prompt message but none was specified.
@rem ---

:MISSING_PROMPT_MESSAGE_ERROR

echo Error: The subroutine with the name "%0" expects a prompt message but none was specified! 1>&2
call:cleanUp

exit /b 16


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   An invalid text was entered.
@rem ---

:INVALID_TEXT_ERROR

echo Error: The subroutine with the name "%0" prompted for an input and the entered text is invalid! 1>&2
call:cleanUp

exit /b 17


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a message but none was specified.
@rem ---

:MISSING_MESSAGE_ERROR

echo Error: The subroutine with the name "%0" expects a message but none was specified! 1>&2
call:cleanUp

exit /b 18


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects a program path but none was specified.
@rem ---

:MISSING_PROGRAM_PATH_ERROR

echo Error: The subroutine with the name "%0" expects a program path but none was specified! 1>&2
call:cleanUp

exit /b 19


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects the name of an executable but none was specified.
@rem ---

:MISSING_EXECUTABLE_NAME_ERROR

echo Error: The subroutine with the name "%0" expects the name of an executable but none was specified! 1>&2
call:cleanUp

exit /b 20


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine expects some parameters but none were specified.
@rem ---

:MISSING_PARAMETERS_ERROR

echo Error: The subroutine with the name "%0" expects some parameters but none were specified! 1>&2
call:cleanUp

exit /b 21


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine tries to call a program which doesn't exist.
@rem ---

:NONEXISTANT_PROGRAM_ERROR

echo Error: The subroutine with the name "%0" tries to call a program which doesn't exist! 1>&2
call:cleanUp

exit /b 22


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine tries to call a program which is no executable.
@rem ---

:NO_EXECUTABLE_SPECIFIED_ERROR

echo Error: The subroutine with the name "%0" tries to call a program which is no executable! 1>&2
call:cleanUp

exit /b 23


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   A subroutine called an external program and an error occurred.
@rem ---

:FAILED_INVOCATION_ERROR

echo Error: The subroutine with the name "%0" called an external program and an error occurred! 1>&2
call:cleanUp

exit /b 24


@rem ================================================================================
@rem ===
@rem ===  The end of this batch file.
@rem ===

:END

call:cleanUp

exit /b 0
