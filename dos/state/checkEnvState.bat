@Echo Off

@rem ================================================================================
@rem ===
@rem ===   void main(String aParam)
@rem ===
@rem ===   This Batch script saves the current environment variables to a file.
@rem ===
@rem ===
@rem ===   @param aParam
@rem ===          an optional command line parameter. Only specific values have an
@rem ===          impact on processing (i.e. 'verbose', 'default')
@rem ===

call:defineMacros


set "_param=%1"
if '%_param%'=='' (

	set _param=default
)
set "_param=%_param:"=%"


set BASEDIR=%~dp0
set STATE0=%BASEDIR%state0.dump
set STATE1=%BASEDIR%state1.dump


if not exist %STATE0% (

	%cprintln% Error^(%0^): Missing dump state0! >&2
	%return% 2
)

if not exist %STATE1% (

	%cprintln% Error^(%0^): Missing dump state1! >&2
	%return% 2
)


if '%_param%'=='verbose' (

	goto verbose

) else (

	goto default
)


:verbose

fc /c %STATE0% %STATE1%

goto end


:default

fc /c %STATE0% %STATE1% >nul 2>&1
%ifError% (

	%cprintln% There are changes in the environment variables.

) else (

	%cprintln% There are no changes in the environemnt variables.
)

goto end


:end

set _param=


%return% 0


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
