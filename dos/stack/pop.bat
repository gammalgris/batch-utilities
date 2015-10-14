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

	echo ^(%0^) The stack isn't initialized^! >&2
	exit /b 1
)


@rem Check the stack size.

if '%STACK_SIZE%'=='0' (

	echo ^(%0^) The stack is empty^! >&2
	exit /b 2
)


@rem Check the specified parameter. Only one parameter is allowed. The parameter
@rem can be surrounded by quotes.

set "$more=%2"
if '%$more%'=='' (

	@rem OK

) else (

	echo ^(%0^) Only one parameter is allowed but more than one parameter was specified^! >&2
	exit /b 3
)
set $more=


set "$variableName=%1"
if '%$variableName%'=='' (

	echo ^(%0^) No variable name has been specified^! >&2
	exit /b 4
)
set "$variableName=%$variableName:"=%"


@rem Check if the stack is used by another process.

2>nul (

	>>%STACK_FILE% echo off

) && (

	rem OK

) || (

	echo ^(%0^) Another process is using the stack^! >&2
	exit /b 5
)


@rem read the last entry and assign it to the specified variable

set $tmpFile=%STACK_FILE%tmp

if exist %$tmpFile% (

	del /Q %$tmpFile%
)


set $index=0

for /f "delims=" %%A in (%STACK_FILE%) do (

	call:processEntry %$tmpFile% $index %$variableName% "%%A"
	%$ifError% (

		echo ^(%0^) An error occurred while rebuilding the stack^! >&2
		exit /b 6
	)
)

if '%STACK_SIZE%'=='1' (

	type NUL > %$tmpFile%
)


copy /Y %$tmpFile% %STACK_FILE% >nul 2>&1
%$ifError% (

	echo ^(%0^) An error occurred while rebuilding the stack^! >&2
	exit /b 7
)
del /Q %$tmpFile% >nul 2>&1

set /a STACK_SIZE-=1


set $tmpFile=
set $variableName=
set $index=

exit /b 0


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   private void processEntry(String tmpFile, String indexVariableName,
@rem ---                             String variableName, String value)
@rem ---
@rem ---   Processes the specified entry (i.e. determines the last element of the
@rem ---   stack and assigns it to the specified variable). The stack is rebuild
@rem ---   without the last entry.
@rem ---
@rem ---
@rem ---   @param tmpFile
@rem ---          a relative or absolute path which represents a temporary file
@rem ---   @param indexVariableName
@rem ---          the name of the variable which contains the current index
@rem ---   @param variableName
@rem ---          the name of the variable to which is assigned the last element
@rem ---          of the stack
@rem ---   @param value
@rem ---          the value of the last element of the stack
@rem ---

:processEntry

	set "$tmpValue=%4"
	if '%$tmpValue%'=='' (

		echo ^(%0^) No value has been specified^! >&2
		exit /b 8
	)
	set "$tmpValue=%$tmpValue:"=%"


	set /a %2+=1
	set $tmpIndex=
	setlocal EnableDelayedExpansion

		set $tmp=!%2%!

	endlocal & set $tmpIndex=%$tmp%

	if '%STACK_SIZE%'=='%$tmpIndex%' (

		set "%3=%$tmpValue%"

	) else (

		echo %$tmpValue%>> %1
	)


	set $tmpIndex=
	set $tmpValue=

exit /b 0
