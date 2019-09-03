@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) 2019 Kristian Kutin
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
@rem ===   void main(String aTitle)
@rem ===
@rem ===   The script starts the a WLST console session.
@rem ===
@rem ===
@rem ===   @param aTitle
@rem ===          The new window title. If no title is specified a default value is
@rem ===          used.
@rem ===

call:defineMacros

call:loadWlstProperties
%ifError% (

	%return%
)


set "_title=%1"
if '%_title%'=='' (

	set _title=WLST
)
set "_title=%_title:"=%"

title %_title%

set _title=


echo current directory: %CD%
echo WLST location: %WLST_EXECUTABLE%


if not exist "%WLST_EXECUTABLE%" (

	%cprintln% Error^(%0^): The path "%WLST_EXECUTABLE%" is invalid! >&2
	%return% 3
)


call "%WLST_EXECUTABLE%"
%ifError% (

	%cprintln% Error^(%0^): An unexpected error occurred! >&2
	%return% 4
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
@rem ---   void loadWlstProperties()
@rem ---
@rem ---   The subroutine loads properties/ environment variables required for
@rem ---   invoking the WebLogic scripting tool (WLST).
@rem ---

:loadWlstProperties

	set _settingsFile=%~dp0properties-wlst.bat

	call:loadProperties "%_settingsFile%"
	%ifError% (

		%cprintln% Error^(%0^): Unable to load properties! >&2
		%return% 2
	)

	set _settingsFile=

%return%
