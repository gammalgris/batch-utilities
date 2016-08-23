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
@rem ===   This batch script contains a collection of utility functions.
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


findstr /r /i /c:"^%PUBLIC_LABEL_PREFIX%%1" "%~dpnx0" > nul
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
			!cprintln! !name!

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
@rem ---
@rem ---   @param datePattern
@rem ---          a date pattern (see above)
@rem ---

:PUBLIC_today

	call:checkAndAssignParameter input %1
	%ifError% (

		call:handleError MissingParameterError
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param timePattern
@rem ---          a time pattern (see above)
@rem ---

:PUBLIC_now

	call:checkAndAssignParameter input %1
	%ifError% (

		call:handleError MissingParameterError
		call:cleanUp
		%return% %returnCode%
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
@rem ---   
@rem ---   @param baseDirectory
@rem ---          a base directory which is to be searched
@rem ---   @param fileName
@rem ---          a file name
@rem ---

:PUBLIC_findFile

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (
	
		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter fileName %2
	%ifError% (
	
		call:handleError MissingFileNameError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param baseDirectory
@rem ---          a base directory which is to be searched
@rem ---   @param filePatterns
@rem ---          a set of file name patterns
@rem ---

:PUBLIC_findFileSets

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter filePatterns %2
	%ifError% (

		call:handleError MissingFilePatternsError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param baseDirectory
@rem ---          a base directory which is to be searched
@rem ---   @param directoryName
@rem ---          a directory name
@rem ---

:PUBLIC_findDirectory

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryName %2
	%ifError% (

		call:handleError MissingDirectoryNameError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param baseDirectory
@rem ---          a base directory which is to be searched
@rem ---   @param directoryPatterns
@rem ---          a set of directory name patterns
@rem ---

:PUBLIC_findDirectorySets

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryPatterns %2
	%ifError% (

		call:handleError MissingDirectoryPatternsError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param fullPath
@rem ---          the full path of a file or directory
@rem ---

:PUBLIC_checkFile

	call:checkAndAssignParameter fullPath %1
	%ifError% (

		call:handleError MissingPathError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param string
@rem ---          a string
@rem ---

:PUBLIC_stringLength

	call:checkAndAssignParameter string %1
	%ifError% (

		call:handleError MissingParameterError
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param variableName
@rem ---          the name of a variable
@rem ---   @param commandString
@rem ---          a string representing a command invocation, including passed
@rem ---          parameters
@rem ---

:PUBLIC_assignResult

	call:checkAndAssignParameter variableName %1
	%ifError% (

		call:handleError MissingVariableNameError %0
		call:cleanUp
		%return% %returnCode%
	)


	if '%2'=='' (

		call:handleError MissingCommandStringError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param baseDirectory
@rem ---          the source directory
@rem ---   @param targetDirectory
@rem ---          the target directory
@rem ---   @param filePatterns
@rem ---          a set of file name patterns
@rem ---

:PUBLIC_copyFiles

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter targetDirectory %2
	%ifError% (

		call:handleError MissinTargetDirectoryError
		call:cleanUp
		%return% %returnCode%
	)

	if "%targetDirectory:~-1%" neq "%BACKSLASH%" (

		set "targetDirectory=%targetDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter filePatterns %3
	%ifError% (

		call:handleError MissingFilePatternsError
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param baseDirectory
@rem ---          the source directory
@rem ---   @param targetDirectory
@rem ---          the target directory
@rem ---   @param directoryPatterns
@rem ---          a set of directory name patterns
@rem ---

:PUBLIC_copyDirectories

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter targetDirectory %2
	%ifError% (

		call:handleError MissingTargetDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%targetDirectory:~-1%" neq "%BACKSLASH%" (

		set "targetDirectory=%targetDirectory%%BACKSLASH%"
	)


	call:checkAndAssignParameter directoryPatterns %3
	%ifError% (

		call:handleError MissingDirectoryPatternsError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---
@rem ---   @param baseDirectory
@rem ---          the base directoy
@rem ---   @param numberOfDays
@rem ---          a threshold to identify old files
@rem ---

:PUBLIC_listOldDirectories

	call:checkAndAssignParameter baseDirectory %1
	%ifError% (

		call:handleError MissingBaseDirectoryError %0
		call:cleanUp
		%return% %returnCode%
	)

	if "%baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "baseDirectory=%baseDirectory%%BACKSLASH%"
	)

	if not exist %baseDirectory% (

		call:handleError NonexistantDirectoryError %0 %baseDirectory%
		call:cleanUp
		%return% %returnCode%
	)


	call:checkAndAssignParameter days %2
	%ifError% (

		call:handleError MissingDaysError %0
		call:cleanUp
		%return% %returnCode%
	)


	forfiles /D -%days% /P %baseDirectory% /C "cmd /c if /i @isdir==%TRUE% ( echo @path )" 2>nul


	set baseDirectory=
	set days=

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void deleteOldDirectories(String baseDirectory, int numberOfDays)
@rem ---
@rem ---   The subroutine deletes all directories within the specified base directory
@rem ---   which are older than the specified number of days.
@rem ---
@rem ---
@rem ---   @param baseDirectory
@rem ---          the base directoy
@rem ---   @param numberOfDays
@rem ---          a threshold to identify old directories
@rem ---

:PUBLIC_deleteOldDirectories

	@rem TODO

goto END


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void inputText(String promptMessage)
@rem ---
@rem ---   The subroutine prompts the user to enter a text. The text is printed to
@rem ---   the console.
@rem ---
@rem ---
@rem ---   @param promptMessage
@rem ---          a prompt message
@rem ---

:PUBLIC_inputText

	call:checkAndAssignParameter promptMessage %1
	%ifError% (

		call:handleError MissingPromptMessageError %0
		call:cleanUp
		%return% %returnCode%
	)

	call:inputText enteredText "%promptMessage%"
	%ifError% (

		call:handleError InvalidTextError %0
		call:cleanUp
		%return% %returnCode%
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
@rem ---   The subroutine prints the specified message to the console. If an output
@rem ---   file has been specified then the message will be written to a file as well.
@rem ---
@rem ---
@rem ---   @param message
@rem ---          a log message
@rem ---   @param outputFile
@rem ---          (optional) the name of an output file
@rem ---

:PUBLIC_logMessage

	call:checkAndAssignParameter message %1
	%ifError% (

		call:handleError MissingMessageError %0
		call:cleanUp
		%return% %returnCode%
	)

	call:checkAndAssignParameter outputFile %2
	%ifError% (

		goto logMessage_onlyConsoleOutput
	)


	if "%message%"=="" (

		%cprintln%. >> %outputFile%
	
	) else (
	
		%cprintln% %message% >> %outputFile%
	)

:logMessage_onlyConsoleOutput

	if "%message%"=="" (

		%cprintln%.

	) else (

		%cprintln% %message%
	)


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
@rem ---
@rem ---   TODO
@rem ---   The subroutine can be trimmed with the use of shift and %* to pass all remaining
@rem ---   parameters.
@rem ---
@rem ---
@rem ---   @param programPath
@rem ---          the path where to find the executable
@rem ---   @param executableName
@rem ---          the name of the execuatble
@rem ---   @param someParameters
@rem ---          all parameters that are to be passed on invocation
@rem ---

:PUBLIC_callProgram

	call:checkAndAssignParameter programPath %1
	%ifError% (

		call:handleError MissingProgramPathError %0
		call:cleanUp
		%return% %returnCode%
	)

	call:checkAndAssignParameter executableName %2
	%ifError% (

		call:handleError MissingExecutableNameError %0
		call:cleanUp
		%return% %returnCode%
	)

	call:checkAndAssignParameter someParameters %3
	%ifError% (

		call:handleError MissingParametersError %0
		call:cleanUp
		%return% %returnCode%
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
		%return% %returnCode%
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
				%return% %returnCode%
			)
		)
	)


	%cprintln% DEBUG::%invocationPrefix% "%programPath%%executableName%" %someParameters%
	%invocationPrefix% "%programPath%%executableName%" %someParameters%
	%ifError% (

		call:handleError FailedInvocationError %0
		call:cleanUp
		%return% %returnCode%
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


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void loadProperties(String filename)
@rem ---
@rem ---   The subroutine loads properties from the specified file (i.e. the file
@rem ---   is processed and for each entry a environment variable is set).
@rem ---
@rem ---
@rem ---   @param filename
@rem ---          the relative of absolute path of a property file
@rem ---

:PUBLIC_loadProperties

	set "_fileName=%1"
	if '%_fileName%'=='' (

		call:handleError MissingFileNameError %0
		call:cleanUp
		%return% %returnCode%
	)
	set "_fileName=%_fileName:"=%"


	if not exist %_fileName% (

		call:handleError NonexistantFileError %0 "%_fileName%"
		call:cleanUp
		%return% %returnCode%
	)

	for /F "tokens=*" %%a in (%_fileName%) do (

		call:setProperty "%%a"
		%ifError% (

			%return%
		)
	)


	set _fileName=

%return%


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
@rem ---   TODO
@rem ---   There are still some issues with parameters that contain spaces and ".
@rem ---
@rem ---
@rem ---   @param _variableName
@rem ---          the name of a variable
@rem ---   @param _value
@rem ---          the value which is to assigned to the specified variable
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
@rem ---
@rem ---   @param _variableName
@rem ---          the name of a variable
@rem ---   @param _promptMessage
@rem ---          a prompt message
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
@rem ---   void extractLine(String variableName, String linePattern, String file name)
@rem ---
@rem ---   Looks within the specified file for a matching line (i.e. a line which
@rem ---   starts with the specified pattern) and assigns the line value to the
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
@rem ---
@rem ---   @param errorMessage
@rem ---          an error message
@rem ---

:printErrorMessage

	%cprintln% Error: %~1 1>&2

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void setProperty(String declaration)
@rem ---
@rem ---   The subroutine sets an environment variable according to the specified
@rem ---   declaration. Referenced variables will be resolved.
@rem ---
@rem ---
@rem ---   @param declaration
@rem ---          the declaration of a property (e.g. propertyName=someValue)
@rem ---

:setProperty

	set "_declaration=%1"
	if '%_declaration%'=='' (

		call:handleError MissingDeclarationError %0
		%return% %returnCode%
	)
	set "_declaration=%_declaration:"=%"
	if "%_declaration%"=="" (

		call:handleError MissingDeclarationError %0
		%return% %returnCode%
	)


	set "%_declaration%"


	set _declaration=

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
