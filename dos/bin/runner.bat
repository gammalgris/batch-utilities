@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) 2018 Kristian Kutin
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
@rem ===   void main(String aScriptFile, String... someParameters)
@rem ===
@rem ===   This batch script invokes a powershell script and passes all command line
@rem ===   parameters to the invoked powershell script.
@rem ===
@rem ===
@rem ===   @param aScriptFile
@rem ===          the file name of a powershell script without path
@rem ===   @param someParameters
@rem ===          all remaining command line parameters
@rem ===

call:defineMacros


set "scriptFile=%1"
if '%scriptFile%'=='' (

	%cprintln% ^(%0^) No script file was specified!
	%return% 2
)
set "scriptFile=%scriptFile:"=%"
set "scriptFile=%~dp0%scriptFile%"

echo running %scriptFile%...


set parameters=

:while_processParameters

	shift

	if '%1'=='' (

		goto elihw_processParameters
	)

	call:addParameter parameters %1

	goto while_processParameters

:elihw_processParameters


start /B /WAIT powershell.exe -ExecutionPolicy ByPass -File "%scriptFile%" %parameters%
%ifError% (

	%return%
)


set scriptFile=
set parameters=

%return%


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void defineMacros()
@rem ---
@rem ---   This subroutine defines required macros.
@rem ---

:defineMacros

	set "ifError=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"
	
	set "cprintln=echo"
	set "cprint=echo|set /p="
	
	set "return=exit /b"

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void addParameter(String aVariableName, String aParameter)
@rem ---
@rem ---   This subroutine adds the specified parameter to the specified variable.
@rem ---
@rem ---
@rem ---   @param aVariableName
@rem ---          the name of a variable
@rem ---   @param aParameter
@rem ---          a parameter
@rem ---

:addParameter

	set "_variableName=%1"
	if '%_variableName%'=='' (
	
		%cprintln% ^(%0^) No variable name was specified!
		%return% 2
	)
	set "_variableName=%_variableName:"=%"

	set "_parameter=%2"
	if '%_parameter%'=='' (
	
		%return%
	)
	set "_parameter=%_parameter:"=%"


	setlocal EnableDelayedExpansion

		set "_value=!%_variableName%!"
		set "_newValue=%_value% %_parameter%"

	endlocal & set "%_variableName%=%_newValue%"


	set _variableName=
	set _parameter=

%return%
