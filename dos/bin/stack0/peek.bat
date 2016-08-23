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

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Syntax:
@rem ---
@rem ---      peek [variableName]
@rem ---
@rem ---   Reads the last entry from the stack and assigns the value to the
@rem ---   specified variable.
@rem ---

@rem define an important macro which is used to identify an error.

if not defined $ifError (

	set "$ifError=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"
)


@rem Check if the stack is initialized.

call %~dp0%isInitialized.bat >nul 2>&1
%$ifError% (

	echo ^(%0^) The stack is not initialized^! >&2
	exit /b 1
)


@rem Check the stack size.

if '%STACK0_SIZE%'=='0' (

	echo ^(%0^) The stack is empty^! >&2
	exit /b 2
)


@rem Check the specified parameter. Only one parameter is allowed. The parameter
@rem can be surrounded by quotes.

set "$more0=%2"
if '%$more0%'=='' (

	@rem OK

) else (

	echo ^(%0^) Only one parameter is allowed but more than one parameter was specified^! >&2
	exit /b 3
)
set $more0=


set "$variableName0=%1"
if '%$variableName0%'=='' (

	echo ^(%0^) No variable name has been specified^! >&2
	exit /b 4
)
set "$variableName0=%$variableName0:"=%"


@rem read the last entry and assign it to the specified variable

set $index0=0

for /f "delims=" %%A in (%STACK0_FILE%) do (

	call:processEntry $index0 %$variableName0% "%%A"
	%$ifError% (

		echo ^(%0^) An error occurred while reading the stack^! >&2
		exit /b 5
	)
)


set $variableName0=
set $index0=

exit /b 0


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   private void processEntry(String indexVariableName, String variableName,
@rem ---                             String value)
@rem ---
@rem ---   Processes the specified entry (i.e. determines the last element of the
@rem ---   stack and assigns it to the specified variable).
@rem ---
@rem ---
@rem ---   @param indexVariableName
@rem ---          the name of the variable which contains the current index
@rem ---   @param variableName
@rem ---          the name of the variable to which is assigned the last element
@rem ---          of the stack
@rem ---   @param value
@rem ---          the value of the last element of the stack
@rem ---

:processEntry

	set "$tmpValue0=%3"
	if '%$tmpValue0%'=='' (

		echo ^(%0^) No value has been specified^! >&2
		exit /b 6
	)
	set "$tmpValue0=%$tmpValue0:"=%"


	set /a %1+=1
	set $tmpIndex0=
	setlocal EnableDelayedExpansion

		set $tmp0=!%1%!

	endlocal & set $tmpIndex0=%$tmp0%

	if '%STACK0_SIZE%'=='%$tmpIndex0%' (

		set "%2=%$tmpValue0%"
	)


	set $tmpIndex0=
	set $tmpValue0=

exit /b 0
