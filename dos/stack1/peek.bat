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

if '%STACK1_SIZE%'=='0' (

	echo ^(%0^) The stack is empty^! >&2
	exit /b 2
)


@rem Check the specified parameter. Only one parameter is allowed. The parameter
@rem can be surrounded by quotes.

set "$more1=%2"
if '%$more1%'=='' (

	@rem OK

) else (

	echo ^(%0^) Only one parameter is allowed but more than one parameter was specified^! >&2
	exit /b 3
)
set $more1=


set "$variableName1=%1"
if '%$variableName1%'=='' (

	echo ^(%0^) No variable name has been specified^! >&2
	exit /b 4
)
set "$variableName1=%$variableName1:"=%"


@rem read the last entry and assign it to the specified variable

set $index1=0

for /f "delims=" %%A in (%STACK1_FILE%) do (

	call:processEntry $index1 %$variableName1% "%%A"
	%$ifError% (

		echo ^(%0^) An error occurred while reading the stack^! >&2
		exit /b 5
	)
)


set $variableName1=
set $index1=

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

	set "$tmpValue1=%3"
	if '%$tmpValue1%'=='' (

		echo ^(%0^) No value has been specified^! >&2
		exit /b 6
	)
	set "$tmpValue1=%$tmpValue1:"=%"


	set /a %1+=1
	set $tmpIndex1=
	setlocal EnableDelayedExpansion

		set $tmp0=!%1%!

	endlocal & set $tmpIndex1=%$tmp0%

	if '%STACK1_SIZE%'=='%$tmpIndex1%' (

		set "%2=%$tmpValue1%"
	)


	set $tmpIndex1=
	set $tmpValue1=

exit /b 0
