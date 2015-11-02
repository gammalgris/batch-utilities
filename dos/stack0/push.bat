@Echo Off

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Syntax:
@rem ---
@rem ---      push [value]
@rem ---
@rem ---   Pushes the specified value to the stack.
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


@rem Check the specified parameter. Only one parameter is allowed. The parameter
@rem can be surrounded by quotes.

set "$more0=%2"
if '%$more0%'=='' (

	@rem OK

) else (

	echo ^(%0^) Only one parameter is allowed but more than one parameter was specified^! >&2
	exit /b 2
)
set $more0=


set "$value0=%1"
if '%$value0%'=='' (

	echo ^(%0^) No value has been specified^! >&2
	exit /b 3
)
set "$value0=%$value0:"=%"


@rem Check if the stack is used by another process.

2>nul (

	>>%STACK0_FILE% echo off

) && (

	rem OK

) || (

	echo ^(%0^) Another process is using the stack^! >&2
	exit /b 4
)


@rem Add the specified value to the stack.

echo %$value0%>> %STACK0_FILE%
%$ifError% (

	echo ^(%0^) The specified value ^(^"%$value0%^"^) couldn't be pushed to the stack^! >&2
	exit /b 5
)

set /a STACK0_SIZE+=1

set $value0=

exit /b 0
