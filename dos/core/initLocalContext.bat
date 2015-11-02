@echo off

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Syntax:
@rem ---
@rem ---      initLocalContext
@rem ---
@rem ---   Initializes the local context (i.e. a numeric value is assigned to the
@rem ---   variable LOCAL and additionally the value is stored in the stack).
@rem ---
@rem ---
@rem ---   Implementation notes:
@rem ---
@rem ---   The variable LOCAL can be used to provide a prefix for variables which are
@rem ---   used in a batch script or subroutine. Thus variables with this prefix are
@rem ---   unique. By calling deleteLocalContext the current local context is
@rem ---   destroyed and the previous local context restored.
@rem ---   This mechanism doesn't work reliably when invoked by two or more different
@rem ---   processes!
@rem ---

@rem define an important macro which is used to identify an error.

if not defined §ifError (

	set "§ifError=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"
)


set "STACK_PATH=%~dp0..\stack\"
echo DEBUG:: stack path^=%STACK_PATH%

call %STACK_PATH%isInitialized >nul 2>&1
%§ifError% (

	goto initialize_stack

) else (

	goto skip_initialization
)


:initialize_stack

call %STACK_PATH%initStack >nul 2>&1
%§ifError% (

	echo The stack is not available^! >&2
	exit /b 1
)


:skip_initialization

call:today §tmp1 "yyyyMMdd"
call:now §tmp2 "HHmmssff"

set LOCAL=%§tmp1%%§tmp2%
echo DEBUG:: LOCAL=%LOCAL%


call %STACK_PATH%push %LOCAL%
%§ifError% (

	echo A local context couldn't be initialized^! >&2
	exit /b 2
)

set §tmp1=
set §tmp2=

exit /b 0


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void today(String §variableName, String §datePattern)
@rem ---
@rem ---   A subroutine which builds a string according to the specified date pattern
@rem ---   and assigns it to the specified variable.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      yyyy    Year
@rem ---      MM      Month in year
@rem ---      dd      Day in year
@rem ---
@rem ---
@rem ---   @param §variableName
@rem ---          a variable name
@rem ---   @param §datePattern
@rem ---          a date pattern (see above)
@rem ---

:today

	set "§variableName=%1"
	if '%§variableName%'=='' (

		echo No variable has been specified^! >&2
		exit /b 1
	)
	set §variableName=%§variableName:"=%

	set "§datePattern=%2"
	if '%§datePattern%'=='' (

		echo No date pattern has been specified^! >&2
		exit /b 2
	)
	set §datePattern=%§datePattern:"=%


	set YEAR_PATTERN=yyyy
	set MONTH_PATTERN=MM
	set DAY_PATTERN=dd

	set §year=%date:~-4,4%
	set §month=%date:~-7,2%
	set §day=%date:~-10,2%

	setlocal EnableDelayedExpansion

		set "§output=!§datePattern!"
		set "§output=!§output:%YEAR_PATTERN%=%§year%!"
		set "§output=!§output:%MONTH_PATTERN%=%§month%!"
		set "§output=!§output:%DAY_PATTERN%=%§day%!"

	endlocal & set "%§variableName%=%§output%"

	
	set §datePattern=
	set §variableName=

	set §year=
	set §month=
	set §day=

	set YEAR_PATTERN=
	set MONTH_PATTERN=
	set DAY_PATTERN=

exit /b 0


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void now(String §variableName, String §timePattern)
@rem ---
@rem ---   A subroutine which builds a string according to the specified time pattern
@rem ---   and assigns it to the specified variable.
@rem ---
@rem ---   Supported patterns:
@rem ---
@rem ---      HH      Hour in day (0-23)
@rem ---      mm      Minute in hour
@rem ---      ss      Second in minute
@rem ---      ff      seconds fraction
@rem ---
@rem ---
@rem ---   @param §variableName
@rem ---          a variable name
@rem ---   @param §timePattern
@rem ---          a time pattern (see above)
@rem ---

:now

	set "§variableName=%1"
	if '%§variableName%'=='' (

		echo No variable has been specified^! >&2
		exit /b 1
	)
	set §variableName=%§variableName:"=%

	set "§timePattern=%2"
	if '%§timePattern%'=='' (

		echo No time pattern has been specified^! >&2
		exit /b 2
	)
	set §timePattern=%§timePattern:"=%


	set HOUR_PATTERN=HH
	set MINUTE_PATTERN=mm
	set SECOND_PATTERN=ss
	set FRACTION_PATTERN=ff

	setlocal EnableExtensions

		for /f "tokens=1-4 delims=:,.-/ " %%i in ('echo %time%') do (
		
			set §hours=%%i
			set §minutes=%%j
			set §seconds=%%k
			set §fraction=%%l
		)

		set §result=

		setlocal EnableDelayedExpansion

			set "§output=!§timePattern!"
			set "§output=!§output:%HOUR_PATTERN%=%§hours%!"
			set "§output=!§output:%MINUTE_PATTERN%=%§minutes%!"
			set "§output=!§output:%SECOND_PATTERN%=%§seconds%!"
			set "§output=!§output:%FRACTION_PATTERN%=%§fraction%!"

		endlocal & set "§result=%§output%"

	endlocal & set "%§variableName%=%§result%"


	set §variableName=
	set §timePattern=

	set HOUR_PATTERN=
	set MINUTE_PATTERN=
	set SECOND_PATTERN=
	set FRACTION_PATTERN=

exit /b 0
