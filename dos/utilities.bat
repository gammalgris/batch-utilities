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

findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%%1" "%~dpnx0" > nul
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

		call:handleError MissingParameterError
		call:cleanUp
		%return% %code%
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

		call:handleError MissingParameterError
		call:cleanUp
		%return% %code%
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
	
		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %code%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter fileName %2
	%ifError% (
	
		call:handleError MissingFileNameError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %code%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter filePatterns %2
	%ifError% (

		call:handleError MissingFilePatternsError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %code%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryName %2
	%ifError% (

		call:handleError MissingDirectoryNameError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %code%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryPatterns %2
	%ifError% (

		call:handleError MissingDirectoryPatternsError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingPathError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingParameterError
		call:cleanUp
		%return% %code%
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

		call:handleError MissingVariableNameError %0
		call:cleanUp
		%return% %code%
	)


	if '%2'=='' (

		call:handleError MissingCommandStringError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %code%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter targetDirectory %2
	%ifError% (

		call:handleError MissinTargetDirectoryError
		call:cleanUp
		%return% %code%
	)

	if "%targetDirectory:~-1%" neq "%BACKSLASH%" (

		set "targetDirectory=%targetDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter filePatterns %3
	%ifError% (

		call:handleError MissingFilePatternsError
		call:cleanUp
		%return% %code%
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

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %code%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter targetDirectory %2
	%ifError% (

		call:handleError MissingTargetDirectoryError %0
		call:cleanUp
		%return% %code%
	)

	if "%targetDirectory:~-1%" neq "%BACKSLASH%" (

		set "targetDirectory=%targetDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryPatterns %3
	%ifError% (

		call:handleError MissingDirectoryPatternsError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingPromptMessageError %0
		call:cleanUp
		%return% %code%
	)

	call:inputText enteredText "%promptMessage%"
	%ifError% (

		call:handleError InvalidTextError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingMessageError %0
		call:cleanUp
		%return% %code%
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

		call:handleError MissingProgramPathError %0
		call:cleanUp
		%return% %code%
	)

	call:checkAndAssignParameter executableName %2
	%ifError% (

		call:handleError MissingExecutableNameError %0
		call:cleanUp
		%return% %code%
	)

	call:checkAndAssignParameter someParameters %3
	%ifError% (

		call:handleError MissingParametersError %0
		call:cleanUp
		%return% %code%
	)

	%cprintln% DEBUG::program path ...... %programPath%
	%cprintln% DEBUG::executable name ... %executableName%
	%cprintln% DEBUG::some parameters ... %someParameters%


	set BATCH_SUFFIX=.bat
	set EXE_SUFFIX=.exe
	set COM_SUFFIX=.com

	if not exist "%programPath%%executableName%" (

		call:handleError NonexistantProgramError %0
		call:cleanUp
		%return% %code%
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

				call:handleError NoExecutableSpecifiedError %0
				call:cleanUp
				%return% %code%
			)
		)
	)


	%cprintln% DEBUG::%invocationPrefix% "%programPath%%executableName%" %someParameters%
	%invocationPrefix% "%programPath%%executableName%" %someParameters%
	%ifError% (

		call:handleError FailedInvocationError %0
		call:cleanUp
		%return% %code%
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
	
		%return% 2
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

			%return% 3
		)

		set "_newValue=%_newValue:"=%"
	endlocal & set "%_variableName%=%_newValue%"

	set _variableName=
	set _value=
	set _newValue=

%return%


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
	
		%return% 2
	)

	set "_promptMessage=%2"
	if '%_promptMessage%'=='' (
	
		%return% 3
	)


	set %_variableName%=

:inputText_repeat

	set /P %_variableName%=%_promptMessage%

	if not defined %_variableName% (

		goto inputText_repeat
	)


	set _variableName=
	set _propmptMessage=

%return%


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

	if "%1"=="" (

		goto handleError_showMessage
	)

	set placeholder={%i%}

	set tmp=!tmp:%placeholder%=%1%!
	
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
