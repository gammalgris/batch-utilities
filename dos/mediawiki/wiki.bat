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
@rem ===   void main(String taskSwitch, String... args)
@rem ===
@rem ===   The script checks the mediawiki environment and calls certain maintenance
@rem ===   scripts according to the specified parameters.
@rem ===
@rem ===
@rem ===   @param taskSwitch
@rem ===          A switch to invoke the actual maintenance operation. Allowed
@rem ===          Values are:
@rem ===          1) import
@rem ===          2) export
@rem ===          3) cleanup
@rem ===   @param args
@rem ===          additional command line parameters as required
@rem ===

call:defineMacros
call:cleanEnvironment
call:defineConstants
call:resetErrorlevel


call:processParameters %*
%ifError% (

	%return%
)


set subroutineCalls.length=6
set subroutineCalls[1]=initLogging
set subroutineCalls[2]=init
set subroutineCalls[3]=checkZipInstallation
set subroutineCalls[4]=checkPhpInstallation
set subroutineCalls[5]=checkMaintenanceScripts
set subroutineCalls[6]=executeMaintenanceTask


for /L %%i in (1,1,%subroutineCalls.length%) do (

	call:invokeSubroutine %%i
	%ifError% (

		%return%
	)
)

for /L %%i in (1,1,%subroutineCalls.length%) do (

	set subroutineCalls[%%i]=
)
set subroutineCalls.length=


%return% 0


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void defineMacros()
@rem ---
@rem ---   Defines required macros.
@rem ---

:defineMacros

	set "ifError=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"
	
	set "cprintln=echo"
	set "cprint=echo|set /p="
	rem cprint is messing up the ERRORLEVEL. Even on a successful execution the
	rem ERRORLEVEL is set to 1.
	
	set "return=exit /b"

	call:logInfo .
	call:logInfo "Required macros are defined now."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void cleanEnvironment()
@rem ---
@rem ---   Deletes certain environment variables in order to allow a repeated
@rem ---   execution of this script without side effects.
@rem ---

:cleanEnvironment

	set DUMP_EXPORT_FILE=
	set DUMP_IMPORT_FILE=
	set LOGFILE_NAME=

	call:logInfo .
	call:logInfo "Some environment variables are deleted now."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void defineConstants()
@rem ---
@rem ---   Defines required constants.
@rem ---

:defineConstants

	set DEFAULT_INDEX_FILE=index.html
	set DEFAULT_FILE_EXTENSION=.xml
	set DEFAULT_FILE_PATTERN=*%DEFAULT_FILE_EXTENSION%

	set "CURRENT_DIR=%~dp0"
	set BATCH_NAME=%~n0

	set TASK_IMPORT=import
	set TASK_EXPORT=export
	set TASK_CLEANUP=cleanup

	set "TABULATOR=	"

	set BACKSLASH=\

	set TRUE=TRUE
	set FALSE=FALSE

	set DUMPFILE_SUFFIX=.dump
	set LOGFILE_SUFFIX=.log
	set TEMPFILE_SUFFIX=.tmp
	set CONFIGFILE_SUFFIX=.properties

	call:logInfo .
	call:logInfo "Required constants are defined now.."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void resetErrorlevel()
@rem ---
@rem ---   Resets the ERRORLEVEL. Certain operations mess up the ERRORLEVEL. Calling
@rem ---   this subroutine will reset the ERRORLEVEL.
@rem ---

:resetErrorlevel

%return% 0


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void processParameters(String... args)
@rem ---
@rem ---   Tries to identify the task which is to be performed and all additional
@rem ---   parameters which are required for executing said task.
@rem ---
@rem ---
@rem ---   @param args
@rem ---          any number of command line arguments
@rem ---

:processParameters

	set "_taskSwitch=%1"
	if '%_taskSwitch%'=='' (

		set "_taskSwitch=%TASK_EXPORT%"
	)
	set "_taskSwitch=%_taskSwitch:"=%"
	call:toLowerCase _taskSwitch


	set "TASK_SWITCH=%_taskSwitch%"
	set _taskSwitch=

	call:logInfo .
	call:logInfo "Parameter:"
	call:logInfo "%TABULATOR%TASK_SWITCH=%TASK_SWITCH%"

	if '%TASK_SWITCH%'=='%TASK_EXPORT%' (

		%return%
	)

	if '%TASK_SWITCH%'=='%TASK_CLEANUP%' (

		%return%
	)


	if '%TASK_SWITCH%'=='%TASK_IMPORT%' (

		goto:checkImportParameters
	)

	call:logError .
	call:logError "%TABULATOR%An invalid operation was specified ^(%TASK_SWITCH%^)!"

%return% 2


:checkImportParameters

	call:processFileParameter %*
	%ifError% (

		%return%
	)

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void processFileParameter(String... args)
@rem ---
@rem ---   Tries to identify additional command line parameters which are required.
@rem ---
@rem ---
@rem ---   @param args
@rem ---          any number of command line arguments
@rem ---

:processFileParameter

	set "_fileName=%2"
	if '%_fileName%'=='' (

		call:logError "ERROR ^(%0^): No dump file was specified!"
		%return% 2
	)
	set "_fileName=%_fileName:"=%"


	set "DUMP_IMPORT_FILE=%_fileName%"
	call:logInfo "%TABULATOR%DUMP_IMPORT_FILE=%DUMP_IMPORT_FILE%"


	set _fileName=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void initLogging()
@rem ---
@rem ---   Initializes the internal logging mechanism.
@rem ---

:initLogging

	set BATCH_NAME=%~n0

	call:getDate dateString yyyy-MM-dd
	call:getTime timeString hh-mm-ss

	set "LOGFILE_NAME=%CURRENT_DIR%%BATCH_NAME%_%dateString%_%timeString%%LOGFILE_SUFFIX%"

	call:logInfo "%TABULATOR%Following file contains a log: %LOGFILE_NAME%"

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void initDump()
@rem ---
@rem ---   Prepares the creation of a dump file.
@rem ---

:initDump

	set BATCH_NAME=%~n0

	call:getDate dateString yyyy-MM-dd
	call:getTime timeString hh-mm-ss

	set "DUMP_EXPORT_FILE=%CURRENT_DIR%%BATCH_NAME%_%dateString%_%timeString%%DUMPFILE_SUFFIX%"

	call:logInfo "%TABULATOR%Following file contains a dump: %DUMP_EXPORT_FILE%"

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void init()
@rem ---
@rem ---   Initializes the script environment.
@rem ---

:init

	set "propertiesFile=%CURRENT_DIR%%BATCH_NAME%%CONFIGFILE_SUFFIX%"


	call:loadProperties "%propertiesFile%"
	%ifError% (

		%return%
	)

	call:logInfo "%TABULATOR%The configuration was loaded."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkGzipInstallation()
@rem ---
@rem ---   Checks if a specific zip program is available.
@rem ---

:checkZipInstallation

	"%zipExe%" %zipCheckParameters% >nul 2>&1
	%ifError% (

		call:logError "ERROR ^(%0^): An error occurred while trying to invoke a zip program ^(%zipExe%^)!"
		%return% 5
	)

	call:logInfo "%TABULATOR%A required zip program was found."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkPhpInstallation()
@rem ---
@rem ---   Checks if a PHP runtime environment is available.
@rem ---

:checkPhpInstallation

	if not exist "%bitnamiPath%" (

		call:logError "ERROR ^(%0^): The Bitnami installation path couldn't be found ^(%bitnamiPath%^)!"
		%return% 2
	)

	if not exist "%phpPath%" (

		call:logError"ERROR ^(%0^): The PHP installation path couldn't be found ^(%phpPath%^)!"
		%return% 3
	)

	if not exist "%phpExe%" (

		call:logError "ERROR ^(%0^): No PHP interpreter was found ^(%phpExe%^)!"
		%return% 4
	)

	"%phpExe%" -version >nul 2>&1
	%ifError% (

		call:logError "ERROR ^(%0^): An error occurred while invoking the PHP interpreter ^(%phpExe%^)!"
		%return% 5
	)

	call:logInfo "%TABULATOR%A PHP runtime environment was found."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkMaintenanceScripts()
@rem ---
@rem ---   The subroutine checks if required maintenance scripts exist.
@rem ---

:checkMaintenanceScripts

	if not exist "%maintenancePath%" (

		call:logError "ERROR ^(%0^): The directory containing maintenance scripts couldn't be found ^(%maintenancePath%^)!"
		%return% 2
	)

	if not exist "%exportScript%" (

		call:logError "ERROR ^(%0^): The export script couldn't be found ^(%exportScript%^)!"
		%return% 3
	)

	if not exist "%importScript%" (

		call:logError "ERROR ^(%0^): The import script couldn't be found ^(%importScript%^)!"
		%return% 4
	)

	call:logInfo "%TABULATOR%The required maintenance scripts were found."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void executeMaintenanceTask(String taskSwitch)
@rem ---
@rem ---   Invokes a maintenance task according to the specified parameter.
@rem ---
@rem ---
@rem ---   @param taskSwitch
@rem ---          A switch to invoke the actual maintenance operation. Allowed
@rem ---          Values are:
@rem ---          1) import
@rem ---          2) export
@rem ---          3) cleanup
@rem ---

:executeMaintenanceTask

	if '%TASK_SWITCH%'=='%TASK_EXPORT%' (

		call:executeExport
		
	) else if '%TASK_SWITCH%'=='%TASK_IMPORT%' (

		call:executeImport

	) else if '%TASK_SWITCH%'=='%TASK_CLEANUP%' (

		call:executeCleanup

	) else (

		call:logError "ERROR ^(%0^): The specified option was is implemented yet!"
		%return% 2
	)

	%ifError% (

		call:logError "ERROR ^(%0^): An unexpected error occurred!"
		%return% 3
	)

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void executeExport()
@rem ---
@rem ---   A data export is performed and a dump file is created which contains all
@rem ---   arcticles (including images) of the underlying wiki.
@rem ---

:executeExport

	call:initDump

	call:logInfo .
	call:logInfo "start /B /WAIT %phpExe% %exportScript% --full --include-files --uploads --output=gzip:%DUMP_EXPORT_FILE%"
	start /B /WAIT %phpExe% %exportScript% --full --include-files --uploads --output=gzip:%DUMP_EXPORT_FILE% >> "%LOGFILE_NAME%" 2>&1
	%ifError% (

		call:LogError "ERROR ^(%0^): While creating the dump an error occurred! See the log for details."
		%return% 2
	)

	call:logInfo .
	call:logInfo "The creation of a dump was successful."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void executeImport()
@rem ---
@rem ---   A data import is performed. An existing dump file is being imported to
@rem ---   the underlying wiki.
@rem ---

:executeImport

	if not exist "%DUMP_IMPORT_FILE%" (

		call:logError "ERROR ^(%0^): The specified dump file ^(%DUMP_IMPORT_FILE%^) doesn't exist!"
		%return% 2
	)


	call:logInfo .
	call:logInfo "start /B /WAIT %phpExe% %importScript% --uploads %DUMP_IMPORT_FILE%"
	start /B /WAIT %phpExe% %importScript% --uploads %DUMP_IMPORT_FILE% >> "%LOGFILE_NAME%" 2>&1
	%ifError% (

		call:LogError "ERROR ^(%0^): While importing the dump an error occurred! See the log for details."
		%return% 3
	)

	call:logInfo .
	call:logInfo "The importing of a dump was successful."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void executeCleanup()
@rem ---
@rem ---   Performs a cleanup, i.e. deletes all logs and dumps which are older than a
@rem ---   defined threshold (specified in days).
@rem ---

:executeCleanup

	call:logInfo .
	call:logInfo "Dumps and logs that are older than %deletionThreshold% days are going to be deleted."
	call:logInfo "The directory %CURRENT_DIR% is scanned for existing dumps and logs."
	call:logInfo .

	call:deleteOldFiles "%CURRENT_DIR%" %deletionThreshold%
	%ifError% (

		call:logError "ERROR ^(%0^): An error occurred during the cleanup!"
		%return%
	)

	call:logInfo .
	call:logInfo "Cleaning up old dumps and logs was successful."

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void invokeSubroutine(int anIndex)
@rem ---
@rem ---   The subroutine invokes a subroutine which is specified in an array.
@rem ---
@rem ---
@rem ---   @param anIndex
@rem ---          the index of the subroutine
@rem ---

:invokeSubroutine

	set "_index=%1"
	if '%_index%'=='' (

		call:logError "Error^(%0^): No index parameter was specified!"
		%return% 2
	)
	set "_index=%_index:"=%"


	setlocal EnableDelayedExpansion

		set _tmpName=!subroutineCalls[%_index%]!

	endlocal & set _subroutineName=%_tmpName%


	call:logInfo .
	call:logInfo "invoke %_subroutineName%"

	call:%_subroutineName%
	%ifError% (

		call:logError "ERROR^(%_subroutineName%^): Invoking the subroutine resulted in an error!"
		%return% 2
	)


	set _subroutineName=
	set _index=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void getDate(String variableName, String datePattern)
@rem ---
@rem ---   A subroutine which determines the current date and creates a string
@rem ---   according to the specified date pattern. The result is assigned to the
@rem ---   specified variable.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      yyyy    Year
@rem ---      MM      Month in year
@rem ---      dd      Day in year
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          the name of a variable
@rem ---   @param datePattern
@rem ---          a date pattern (see above)
@rem ---

:getDate

	set "_variableName=%1"
	if '%_variableName%'=='' (

		call:logError "Error^(%0^): No variable name has been specified!"
		%return% 2
	)
	set "_variableName=%_variableName:"=%"

	set "_datePattern=%2"
	if '%_datePattern%'=='' (

		call:logError "Error^(%0^): No date pattern has been specified!"
		%return% 3
	)
	set "_datePattern=%_datePattern:"=%"


	set YEAR_PATTERN=yyyy
	set MONTH_PATTERN=MM
	set DAY_PATTERN=dd

	set _year=%date:~-4,4%
	set _month=%date:~-7,2%
	set _day=%date:~-10,2%


	setlocal EnableDelayedExpansion

		set "_output=!_datePattern!"
		set "_output=!_output:%YEAR_PATTERN%=%_year%!"
		set "_output=!_output:%MONTH_PATTERN%=%_month%!"
		set "_output=!_output:%DAY_PATTERN%=%_day%!"

	endlocal & set "%_variableName%=%_output%"


	set _variableName=
	set _datePattern=

	set _year=
	set _month=
	set _day=

	set YEAR_PATTERN=
	set MONTH_PATTERN=
	set DAY_PATTERN=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void getTime(String variableName, String timePattern)
@rem ---
@rem ---   A subroutine which determines the current time and creates a string
@rem ---   according to the specified time pattern. The result is assigned to the
@rem ---   specified variable.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      HH      Hour in day (0-23)
@rem ---      mm      Minute in hour
@rem ---      ss      Second in minute
@rem ---      ff      seconds fraction
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          the name of a variable
@rem ---   @param timePattern
@rem ---          a time pattern (see above)
@rem ---

:getTime

	set "_variableName=%1"
	if '%_variableName%'=='' (

		call:logError "Error^(%0^): No variable name has been specified!"
		%return% 2
	)
	set "_variableName=%_variableName:"=%"

	set "_timePattern=%2"
	if '%_timePattern%'=='' (

		call:logError "Error^(%0^): No time pattern has been specified!"
		%return% 3
	)
	set "_timePattern=%_timePattern:"=%"


	set HOUR_PATTERN=HH
	set MINUTE_PATTERN=mm
	set SECOND_PATTERN=ss
	set FRACTION_PATTERN=ff

	setlocal EnableExtensions

		for /f "tokens=1-4 delims=:,.-/ " %%i in ('%cprintln% %time: =0%') do (
		
			set _hours=%%i
			set _minutes=%%j
			set _seconds=%%k
			set _fraction=%%l
		)

		setlocal EnableDelayedExpansion

			set "_output=!_timePattern!"
			set "_output=!_output:%HOUR_PATTERN%=%_hours%!"
			set "_output=!_output:%MINUTE_PATTERN%=%_minutes%!"
			set "_output=!_output:%SECOND_PATTERN%=%_seconds%!"
			set "_output=!_output:%FRACTION_PATTERN%=%_fraction%!"

		endlocal & set "_tmp=%_output%"

	endlocal & set "%_variableName%=%_tmp%"


	set _variableName=
	set _timePattern=

	set HOUR_PATTERN=
	set MINUTE_PATTERN=
	set SECOND_PATTERN=
	set FRACTION_PATTERN=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void loadProperties(String filename)
@rem ---
@rem ---   The subroutine loads properties from the specified file (i.e. the file
@rem ---   is processed and for each entry a environment variable is set).
@rem ---
@rem ---
@rem ---   @param filename
@rem ---          the relative or absolute path of a property file
@rem ---

:loadProperties

	set "_fileName=%1"
	if '%_fileName%'=='' (

		call:logError "ERROR ^(%0^): No file name has been specified!"
		%return% 2
	)
	set "_fileName=%_fileName:"=%"


	if not exist %_fileName% (

		call:logError "ERROR ^(%0^): The specified file '%_fileName%' doesn't exist!"
		%return% 3
	)

	for /F "tokens=*" %%a in (%_fileName%) do (

		call:setProperty "%%a"
		%ifError% (

			%return%
		)
	)


	set _fileName=

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

		call:logError "ERROR ^(%0^): No declaration has been specified!"
		%return% 2
	)
	set "_declaration=%_declaration:"=%"
	if "%_declaration%"=="" (

		call:logError "ERROR ^(%0^): No declaration has been specified!"
		%return% 3
	)


	set "%_declaration%"


	set _declaration=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void toLowerCase(String variableName)
@rem ---
@rem ---   The subroutine converts the string in the specified variable to lower case.
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          the name of a variable
@rem ---

:toLowerCase

	set "_variableName=%1"
	if '%_variableName%'=='' (

		call:logError "Error^(%0^): No variable name has been specified!"
		%return% 2
	)
	set "_variableName=%_variableName:"=%"


	for %%i in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do (

		call:processReplacementRule %_variableName% %%i
	)


	set _variableName=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void toUpperCase(String variableName)
@rem ---
@rem ---   The subroutine converts the string in the specified variable to upper case.
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          the name of a variable
@rem ---

:toUpperCase

	set "_variableName=%1"
	if '%_variableName%'=='' (

		call:logError "Error^(%0^): No variable name has been specified!"
		%return% 2
	)
	set "_variableName=%_variableName:"=%"


	for %%i in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") do (

		call:processReplacementRule %_variableName% %%i
	)


	set _variableName=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void processReplacementRule(String variableName, String rule)
@rem ---
@rem ---   The subroutine executes the replacement rule on the string which is
@rem ---   referenced by the specified variable name.
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          the name of a variable
@rem ---   @param rule
@rem ---          a replacement rule
@rem ---

:processReplacementRule

	set "__variableName=%1"
	if '%__variableName%'=='' (

		call:logError "Error^(%0^): No variable name has been specified!"
		%return% 2
	)
	set "__variableName=%__variableName:"=%"

	set "__rule=%2"
	if '%__rule%'=='' (

		call:logError "Error^(%0^): No replacement rule has been specified!"
		%return% 3
	)
	set "__rule=%__rule:"=%"


	setlocal EnableDelayedExpansion

		set "__tmp=!%__variableName%!"

	endlocal & set "__string=%__tmp%"

	setlocal EnableDelayedExpansion

		set "__tmp=%__string%"
		set "__tmp=!__tmp:%__rule%!"

	endlocal & set "__string=%__tmp%"

	set "%__variableName%=%__string%"


	set __variableName=
	set __rule=
	set __string=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void logInfo(String message)
@rem ---
@rem ---   The subroutine logs the specified message. The message is written
@rem ---   to a log file (provided the logging mechanism is initialized correctly)
@rem ---   and to the console.
@rem ---
@rem ---
@rem ---   @param message
@rem ---          a message
@rem ---

:logInfo

	set "_message=%1"
	if '%_message%'=='' (

		%cprintln% Error^(%0^): No message has been specified! >&2
		%return% 2
	)
	set "_message=%_message:"=%"


	if '"%_message%"'=='"."' (

		%cprintln%.

	) else (

		%cprintln% %_message%
	)

	setlocal enableExtensions

		if defined LOGFILE_NAME (

			if '"%_message%"'=='"."' (

				%cprintln%. >> "%LOGFILE_NAME%"

			) else (

				%cprintln% %_message% >> "%LOGFILE_NAME%"
			)
		)

	endlocal


	set _message=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void logError(String message)
@rem ---
@rem ---   The subroutine logs the specified error message. The message is written
@rem ---   to a log file (provided the logging mechanism is initialized correctly)
@rem ---   and to the console.
@rem ---
@rem ---
@rem ---   @param message
@rem ---          a message
@rem ---

:logError

	set "_message=%1"
	if '%_message%'=='' (

		%cprintln% Error^(%0^): No message has been specified! >&2
		%return% 2
	)
	set "_message=%_message:"=%"


	if '"%_message%"'=='"."' (

		%cprintln%. >&2

	) else (

		%cprintln% %_message% >&2
	)

	setlocal enableExtensions

		if defined LOGFILE_NAME (

			if '"%_message%"'=='"."' (

				%cprintln%. >> "%LOGFILE_NAME%"

			) else (

				%cprintln% %_message% >> "%LOGFILE_NAME%"
			)
		)

	endlocal


	set _message=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void listOldFiles(String baseDirectory, int days)
@rem ---
@rem ---   The subroutine lists all directories within the specified base directory
@rem ---   which are older than the specified number of days.
@rem ---
@rem ---
@rem ---   @param baseDirectory
@rem ---          the base directoy
@rem ---   @param days
@rem ---          a threshold to identify old files
@rem ---

:listOldFiles

	set "__baseDirectory=%1"
	if '%__baseDirectory%'=='' (

		call:logError "ERROR ^(%0^): No directory has been specified!"
		%return% 2
	)
	set "__baseDirectory=%__baseDirectory:"=%"

	if "%__baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "__baseDirectory=%__baseDirectory%%BACKSLASH%"
	)

	if not exist %__baseDirectory% (

		call:logError "ERROR ^(%0^): The specified directory doesn't exist!"
		%return% 3
	)

	set "__days=%2"
	if '%__days%'=='' (

		call:logError "ERROR ^(%0^): No days have been specified!"
		%return% 4
	)
	set "__days=%__days:"=%"


	forfiles /D -%__days% /P %__baseDirectory% /M *%DUMPFILE_SUFFIX% 2>nul
	forfiles /D -%__days% /P %__baseDirectory% /M *%LOGFILE_SUFFIX% 2>nul


	set __baseDirectory=
	set __days=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void deleteOldFiles(String baseDirectory, int days)
@rem ---
@rem ---   The subroutine deletes all directories within the specified base directory
@rem ---   which are older than the specified number of days.
@rem ---
@rem ---
@rem ---   @param baseDirectory
@rem ---          the base directoy
@rem ---   @param days
@rem ---          a threshold to identify old directories
@rem ---

:deleteOldFiles

	set "_baseDirectory=%1"
	if '%_baseDirectory%'=='' (

		call:logError "ERROR ^(%0^): No directory has been specified!"
		%return% 2
	)
	set "_baseDirectory=%_baseDirectory:"=%"

	if "%_baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "_baseDirectory=%_baseDirectory%%BACKSLASH%"
	)

	if not exist %_baseDirectory% (

		call:logError "ERROR ^(%0^): The specified directory doesn't exist!"
		%return% 3
	)

	set "_days=%2"
	if '%_days%'=='' (

		call:logError "ERROR ^(%0^): No days have been specified!"
		%return% 4
	)
	set "_days=%_days:"=%"

	set "TEMPFILE=%CURRENT_DIR%filelist%TEMPFILE_SUFFIX%"


	if exist "%TEMPFILE%" (

		del /Q "%TEMPFILE%"
	)

	call:listOldFiles %_baseDirectory% %_days% > %TEMPFILE%

	if not exist "%TEMPFILE%" (

		call:logError "ERROR ^(%0^): No temporary file could be created!"
		%return% 5
	)

	call:getFileSize _fileSize %TEMPFILE%

	if %_fileSize%==0 (

		call:logInfo .
		call:logInfo "No dumps and logs exist. No deletions occurred."
		%return% 0
	)

	for /F "tokens=*" %%a in (%TEMPFILE%) do (

		call:deleteFile %_baseDirectory% %%a
	)


	set TEMPFILE=
	set _fileSize=
	set _baseDirectory=
	set _days=
	
%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void deleteFile(String baseDirectory, String fileName)
@rem ---
@rem ---   The subroutine deletes the specified file.
@rem ---
@rem ---
@rem ---   @param baseDirectory
@rem ---          the base directoy
@rem ---   @param fileName
@rem ---          the file name (including suffix and excluding the path)
@rem ---

:deleteFile

	set "__baseDirectory=%1"
	if '%__baseDirectory%'=='' (

		call:logError "ERROR ^(%0^): No directory has been specified!"
		%return% 2
	)
	set "__baseDirectory=%__baseDirectory:"=%"

	if "%__baseDirectory:~-1%" neq "%BACKSLASH%" (

		set "__baseDirectory=%__baseDirectory%%BACKSLASH%"
	)

	if not exist %__baseDirectory% (

		call:logError "ERROR ^(%0^): The specified directory doesn't exist!"
		%return% 3
	)

	set "__fileName=%2"
	if '%__fileName%'=='' (

		call:logError "ERROR ^(%0^): No file name has been specified!"
		%return% 4
	)
	set "__fileName=%__fileName:"=%"


	set "__path=%__baseDirectory%%__fileName%"


	call:logInfo "delete %__path%"

	if not exist "%__path%" (

		call:logError "ERROR ^(%0^): The specified file %__path% doesn't exist!"
		%return% 5
	)

	del /Q "%__path%"
	%ifError% (

		call:logError "ERROR ^(%0^): Unable to delete the specified file %__path%!"
		%return% 6
	)


	set __path=
	set __baseDirectory=
	set __fileName=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void getFileSize(String variableName, String path)
@rem ---
@rem ---   The subroutine determines the size of the specified file and stores it
@rem ---   within the specified variable.
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          the base directoy
@rem ---   @param path
@rem ---          the full file path (including path, name and suffix)
@rem ---

:getFileSize

	set "__variableName=%1"
	if '%__variableName%'=='' (

		call:logError "Error^(%0^): No variable name has been specified!"
		%return% 2
	)
	set "__variableName=%__variableName:"=%"

	set "__path=%2"
	if '%__path%'=='' (

		call:logError "Error^(%0^): No file path has been specified!"
		%return% 3
	)
	set "__path=%__path:"=%"


	if not exist "%__path%" (

		call:logError "Error^(%0^): The specified file doesn't exist!"
		%return% 4
	)

	for %%a in (%__path%) do (

		set %__variableName%=%%~za
	)


	set __variableName=
	set __path=

%return%
