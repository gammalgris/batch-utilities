@Echo Off

@rem ================================================================================
@rem ===
@rem ===   void main()
@rem ===
@rem ===   This Batch script saves the current environment variables to a file.
@rem ===

call:defineMacros


set BASEDIR=%~dp0
set STATE0=%BASEDIR%state0.dump
set STATE1=%BASEDIR%state1.dump


if exist %STATE0% (

	del /Q %STATE0% >nul 2>&1
	%ifError% (

		%cprintln% Error^(%0^): Unable to delete state0! >&2
		%return% 2
	)
)

if exist %STATE1% (

	copy /Y %STATE1% %STATE0% >nul 2>&1
	%ifError% (

		%cprintln% Error^(%0^): Unable to create state0! >&2
		%return% 2
	)
)

call:sleep 1

set > %STATE1%
%ifError% (

	%cprintln% Error^(%0^): Unable to create state1! >&2
	%return% 2
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
@rem ---   void sleep(int aDuration)
@rem ---
@rem ---   The subroutine sleeps approximately for the specified duration.
@rem ---
@rem ---
@rem ---   @param aDuration
@rem ---          a duration in seconds
@rem ---

:sleep

	set "_duration=%1"
	if '%_duration%'=='' (

		%cprintln% Error^(%0^): No duration has been specified! >&2
		%return% 2
	)
	set "_duration=%_duration:"=%"


	set /a _duration=%_duration%+1

	ping 127.0.0.1 -n %_duration% >nul 2>&1


	set _duration=

%return%
