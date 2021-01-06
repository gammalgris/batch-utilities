@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) 2020 Kristian Kutin
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
@rem ===   Starts the IDE (i.e. JDeveloper).
@rem ===

call:defineMacros
call:resetErrorlevel


@rem define additional environment variables which are stored in files

set propertyFiles.length=3
set "propertyFiles[1]=%~dp0\java.properties"
set "propertyFiles[2]=%~dp0\oracle.properties"
set "propertyFiles[3]=%~dp0\jdev.properties"


for /L %%i in (1, 1, %propertyFiles.length%) do (

	call:loadPropertiesByVariableName propertyFiles[%%i]
	%ifError% (

		echo ^(%0^) Initialization is aborted! 1>&2
		%return%
	)
)


for /L %%i in (1, 1, %propertyFiles.length%) do (

	set propertyFiles[%%i]=
)

set propertyFiles.length=


echo Initialization is done.


@rem check plausibilities

set variableNames.length=4
set variableNames[1]=ORACLE_HOME
set variableNames[2]=JAVA_HOME
set variableNames[3]=JDEV_HOME_DIR
set variableNames[4]=JDEV_INSTALL_DIR


for /L %%i in (1, 1, %variableNames.length%) do (

	call:checkVariable variableNames[%%i]
	%ifError% (

		echo ^(%0^) Plausibility check is aborted! 1>&2
		%return%
	)
)


for /L %%i in (1, 1, %variableNames.length%) do (

	set variableNames[%%i]=
)

set variableNames.length=


echo Plausubilities check is done.


@rem check for the executable and start the IDE

set "JDEV_EXE=%JDEV_INSTALL_DIR%\bin\jdev64.exe"
if not exist "%JDEV_EXE%" (

	echo The executable "%JDEV_EXE%" doesn't exist! 1>&2
	%return% 2

) else (

	echo The executable "%JDEV_EXE%" exists.
)


echo DEBUG::call "%JDEV_EXE%"
call "%JDEV_EXE%"
%ifError% (

	%return%
)


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
@rem ---   void resetErrorlevel()
@rem ---
@rem ---   The subroutine resets the errorlevel to zero.
@rem ---

:resetErrorlevel

%return% 0


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void loadProperties(String _filePath)
@rem ---
@rem ---   The subroutine loads the properties in the specified file.
@rem ---
@rem ---
@rem ---   @param _filePath
@rem ---          a file path to a property file
@rem ---

:loadProperties

	set "_filePath=%1"
	if '%_filePath%'=='' (

		echo ^(%0^) No file path was specified! 1>&2
		%return% 2
	)
	set "_filePath=%_filePath:"=%"


	echo load properties from %_filePath%...

	if not exist "%_filePath%" (

		echo ^(%0^) The file "%_filePath%" doesn't exist! 1>&2
		%return% 3
	)

	for /F "tokens=*" %%a in (%_filePath%) do (

		call set %%a
	)


	set _filePath=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void loadPropertiesByVariableName(String _filePath)
@rem ---
@rem ---   The subroutine determines the path in the psecified variable and loads the
@rem ---   properties.
@rem ---
@rem ---
@rem ---   @param _variableName
@rem ---          a variable name and the variable contains a file path to a property file
@rem ---

:loadPropertiesByVariableName

	set "_variableName=%1"
	if '%_variableName%'=='' (

		echo ^(%0^) No variable name was specified! 1>&2
		%return% 2
	)
	set "_variableName=%_variableName:"=%"


	setlocal EnableDelayedExpansion

		set _value=!%_variableName%!

	endlocal & set _retained=%_value%

	call:loadProperties "%_retained%"
	%ifError% (

		%return%
	)


	set _variableName=
	set _retained=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void checkVariable(String _filePath)
@rem ---
@rem ---   The subroutine checks if the specified variable exists and if the value of
@rem ---   the variable points to an existing directory.
@rem ---
@rem ---
@rem ---   @param _variableName
@rem ---          a variable name and the variable points to an existing directory
@rem ---

:checkVariable

	set "_variableName=%1"
	if '%_variableName%'=='' (

		echo ^(%0^) No variable name was specified! 1>&2
		%return% 2
	)
	set "_variableName=%_variableName:"=%"


	setlocal EnableDelayedExpansion

		set _value=!%_variableName%!

	endlocal & set _actualVariable=%_value%

	echo check variable %_actualVariable%...

	if not defined %_actualVariable% (

		echo ^(%0^) The variable %_actualVariable% is not defined! 1>&2
		%return% 3
	)

	setlocal EnableDelayedExpansion

		set _value=!%_actualVariable%!

	endlocal & set _actualPath=%_value%

	if not exist "%_actualPath%" (

		echo ^(%0^) The path "%_actualPath%" doesn't exist! 1>&2
		%return% 4
	)


	set _variableName=
	set _retained=

%return%
