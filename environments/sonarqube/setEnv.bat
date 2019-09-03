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

@Echo Off

@rem ================================================================================
@rem ===
@rem ===   void main()
@rem ===
@rem ===   This Batch script defines new environment variables and modifies existing
@rem ===   environment variables in order to invoke java and ant from console. The
@rem ===   changes are only active during a single console session.
@rem ===
@rem ===   This script can be copied for the purpose of having several distinct
@rem ===   java and ant environments. In this case paths have to be adjusted
@rem ===   accordingly.
@rem ===

call:defineMacros
call:defineVariables


set subroutineCalls.length=4
set subroutineCalls[1]=setJava
set subroutineCalls[2]=printInfo
set subroutineCalls[3]=checkEnvironment
set subroutineCalls[4]=setPath


for /L %%i in (1,1,%subroutineCalls.length%) do (

	call:invokeSubroutine %%i
	%ifError% (

		%return%
	)
)


call:changeConsoleTitle "Sonar Environment"


for /L %%i in (1,1,%subroutineCalls.length%) do (

	set subroutineCalls[%%i]=
)
set subroutineCalls.length=


call:cleanVariables

%return%


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void defineMacros()
@rem ---
@rem ---   The subroutine defines required macros.
@rem ---

:defineMacros

	set "ifError=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"
	
	set "cprintln=echo"
	set "cprint=echo|set /p="
	
	set "return=exit /b"

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void defineVariables()
@rem ---
@rem ---   The subroutine defines required variables.
@rem ---

:defineVariables

	set applications=0

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void cleanVariables()
@rem ---
@rem ---   The subroutine cleans up required variables.
@rem ---

:cleanVariables

	for /L %%i in (1,1,%applications%) do (

		set applicationNames[%%i]=
		set applicationHomeReferences[%%i]=
		set applicationExecutableReferences[%%i]=
		set applicationExpectedVersions[%%i]=
	)

	set applications=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void addApplication(String aName, String aHomeReference,
@rem ---                       String anExecutableReference, String anExpectedVersion)
@rem ---
@rem ---   The subroutine adds an application according to the specified parameters.
@rem ---
@rem ---
@rem ---   @param aName
@rem ---          the name of the application
@rem ---   @param aHomeReference
@rem ---          the name of the variable which contains the application's home
@rem ---          directory
@rem ---   @param anExecutableReference
@rem ---          the name of the variable which contains the application's
@rem ---          executable file
@rem ---   @param anExpectedVersion
@rem ---          the application's expected version
@rem ---

:addApplication

	set "_name=%1"
	if '%_name%'=='' (

		%cprintln% Error^(%0^): No application name has been specified! >&2
		%return% 2
	)
	set "_name=%_name:"=%"

	set "_homeReference=%2"
	if '%_homeReference%'=='' (

		%cprintln% Error^(%0^): No home reference has been specified! >&2
		%return% 2
	)
	set "_homeReference=%_homeReference:"=%"

	set "_executableReference=%3"
	if '%_executableReference%'=='' (

		%cprintln% Error^(%0^): No executable reference has been specified! >&2
		%return% 2
	)
	set "_executableReference=%_executableReference:"=%"

	set "_expectedVersion=%4"
	if '%_expectedVersion%'=='' (

		%cprintln% Error^(%0^): No expected version has been specified! >&2
		%return% 2
	)
	set "_expectedVersion=%_expectedVersion:"=%"


	set /a applications=%applications%+1
	set _currentIndex=%applications%
	

	set "applicationNames[%_currentIndex%]=%_name%"
	set "applicationHomeReferences[%_currentIndex%]=%_homeReference%"
	set "applicationExecutableReferences[%_currentIndex%]=%_executableReference%"
	set "applicationExpectedVersions[%_currentIndex%]=%_expectedVersion%"


	set _currentIndex=
	set _name=
	set _homeReference=
	set _executableReference=
	set _expectedVersion=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void loadProperties(String aFilename)
@rem ---
@rem ---   The subroutine loads the properties defined in the specified file.
@rem ---
@rem ---
@rem ---   @param aFilename
@rem ---          the name of the application
@rem ---

:loadProperties

	set "_filename=%1"
	if '%_filename%'=='' (

		%cprintln% Error^(%0^): No file name has been specified! >&2
		%return% 2
	)
	set "_filename=%_filename:"=%"


	if not exist "%_filename%" (

		%cprintln% Error^(%0^): The properties file %_filename% doesn't exist! >&2
		%return% 2
	)

	call %_filename%


	set _filename=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void setJava()
@rem ---
@rem ---   The subroutine defines several environment variables for java.
@rem ---

:setJava

	set "_settingsFile=%~dp0properties-java.bat"

	call:loadProperties "%_settingsFile%"
	%ifError% (

		%cprintln% Error^(%0^): Unable to load properties! >&2
		%return% 2
	)

	call:addApplication JAVA JAVA_HOME JAVA_EXE %JAVA_VERSION%
	%ifError% (

		%cprintln% Error^(%0^): Unable to register application! >&2
		%return% 2
	)

	set _settingsFile=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void setPath()
@rem ---
@rem ---   The path environment variable is modified.
@rem ---
@rem ---   The environment variable NEW_PATH is defined which can be used to verify
@rem ---   that the changes have not be reverted.
@rem ---

:setPath

	set NEW_PATH=C:\WINDOWS\system32
	set NEW_PATH=C:\WINDOWS;%NEW_PATH%

	set NEW_PATH=%JAVA_BIN%;%NEW_PATH%
	set NEW_PATH=.;%NEW_PATH%


	set "_normalizedOldPath=%PATH%"
	set "_normalizedOldPath=%_normalizedOldPath:"=%"

	set "_normalizedNewPath=%NEW_PATH%"
	set "_normalizedNewPath=%_normalizedNewPath:"=%"


	if "%_normalizedNewPath%"=="%_normalizedOldPath%" (

		rem OK, no changes required

	) else (

		set "OLD_PATH=%PATH%"
		set "PATH=%NEW_PATH%"
	)


	%cprintln%.
	%cprintln% PATH:
	%cprintln% %PATH%
	%cprintln%.
	%cprintln% current path:
	%cprintln% %CD%
	%cprintln%.


	set _normalizedNewPath=
	set _normalizedOldPath=
	set NEW_PATH=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkEnvironment()
@rem ---
@rem ---   The environment is checked (i.e. version check).
@rem ---

:checkEnvironment

	%cprintln%.

	set success=

	setlocal EnableDelayedExpansion

		set tmpSuccess=
	
		for /L %%i in (1,1,!applications!) do (

			call:existsExecutable !applicationExecutableReferences[%%i]!
			%ifError% (

				set tmpSuccess=!tmpSuccess!1
			)
		)
		
	endlocal & set success=%tmpSuccess%

	if defined success (
	
		%cprintln% The environment is not set up! >&2
		%return% 1
	)
	set success=


	setlocal EnableDelayedExpansion

		set tmpSuccess=

		for /L %%i in (1,1,!applications!) do (

			call:checkVersion !applicationExecutableReferences[%%i]! !applicationExpectedVersions[%%i]!
			if !ERRORLEVEL!==0 (

				rem OK

			) else (

				set tmpSuccess=!tmpSuccess!!ERRORLEVEL!
			)
		)

	endlocal & set success=%tmpSuccess%


	if defined success (
	
		%cprintln%.
		%cprintln% The environment is not set up! >&2
		%return% 2
	)
	set success=

	%cprintln%.

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void printInfo()
@rem ---
@rem ---   The subroutine prints some environment details to the console.
@rem ---

:printInfo

	%cprintln%.

	setlocal EnableDelayedExpansion

		set tmpSuccess=
	
		for /L %%i in (1,1,!applications!) do (

			call:printApplicationInfo !applicationNames[%%i]! !applicationHomeReferences[%%i]!
		)
		
	endlocal

	%cprintln%.

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void printApplicationInfo(String aName, String aHomeReference)
@rem ---
@rem ---   The subroutine prints some environment details to the console.
@rem ---
@rem ---
@rem ---   @param aName
@rem ---          the name of the application
@rem ---   @param aHomeReference
@rem ---          the name of the variable which contains the application's home
@rem ---          directory
@rem ---

:printApplicationInfo

	set "_name=%1"
	if '%_name%'=='' (

		%cprintln% Error^(%0^): No application name has been specified! >&2
		%return% 2
	)
	set "_name=%_name:"=%"

	set "_homeReference=%2"
	if '%_homeReference%'=='' (

		%cprintln% Error^(%0^): No home reference has been specified! >&2
		%return% 2
	)
	set "_homeReference=%_homeReference:"=%"


	setlocal EnableDelayedExpansion

		set "_tmp=!%_homeReference%!"

	endlocal & set "_home=%_tmp%"

	%cprintln% %_name% ... %_home%


	set _home=
	set _name=
	set _homeReference=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void existsExecutable(String anExecutableReference)
@rem ---   
@rem ---   Checks if the specified executable exists.
@rem ---
@rem ---
@rem ---   @param anExecutableReference
@rem ---          the name of the variable which contains the application's
@rem ---          executable
@rem ---

:existsExecutable

	set "_executableReference=%1"
	if '%_executableReference%'=='' (

		%cprintln% Error^(%0^): No executable reference has been specified! >&2
		%return% 2
	)
	set "_executableReference=%_executableReference:"=%"


	setlocal EnableDelayedExpansion

		set "_tmp=!%_executableReference%!"

	endlocal & set "_executable=%_tmp%"


	if not exist "%_executable%" (

		%cprintln% %_executable% doesn't exist!
		%return% 1
	)


	set _executable=
	set _executableReference=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkVersion(String aCommand, String anExpectedVersion)
@rem ---   
@rem ---   Checks the version of the specified command.
@rem ---
@rem ---
@rem ---   @param anExecutableReference
@rem ---          the name of the variable which contains the application's
@rem ---          executable
@rem ---   @param anExpectedVersion
@rem ---          the expected version
@rem ---

:checkVersion

	set "_executableReference=%1"
	if '%_executableReference%'=='' (

		%cprintln% Error^(%0^): No executable reference has been specified! >&2
		%return% 2
	)
	set "_executableReference=%_executableReference:"=%"

	set "_expectedVersion=%2"
	if '%_expectedVersion%'=='' (

		%cprintln% Error^(%0^): No expected version has been specified! >&2
		%return% 2
	)
	set "_expectedVersion=%_expectedVersion:"=%"


	setlocal EnableDelayedExpansion

		set "_tmp=!%_executableReference%!"

	endlocal & set "_executable=%_tmp%"


	call "%_executable%" -version 2>&1 | findstr /L "%_expectedVersion%" > NUL
	%ifError% (

		%cprintln% %_executable% ... %_expectedVersion% ... failed >&2
		%return% 1
		
	) else (

		%cprintln% %_executable% ... %_expectedVersion% ... OK
	)


	set _executable=
	set _executableReference=
	set _expectedVersion=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void changeConsoleTitle(String aTitle)
@rem ---
@rem ---   The subroutine changes the title of the console window.
@rem ---
@rem ---
@rem ---   @param aTitle
@rem ---          the new title of the console window
@rem ---

:changeConsoleTitle

	set "_title=%1"
	if '%_title%'=='' (

		%cprintln% Error^(%0^): No title has been specified! >&2
		%return% 2
	)
	set "_title=%_title:"=%"


	title %_title%


	set _title=

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

		%cprintln% Error^(%0^): No index has been specified! >&2
		%return% 2
	)
	set "_index=%_index:"=%"


	setlocal EnableDelayedExpansion

		set _tmpName=!subroutineCalls[%_index%]!

	endlocal & set _subroutineName=%_tmpName%


	%cprintln% execute %_subroutineName% ...


	call:%_subroutineName%
	%ifError% (

		%cprintln%.
		%cprintln% ERROR^(%_subroutineName%^): An error occured! >&2
		%return% 2
	)


	set _subroutineName=
	set _index=

%return%
