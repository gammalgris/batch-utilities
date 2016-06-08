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
set DELTA=%BASEDIR%delta.dump


if not exist %STATE0% (

	%cprintln% Error^(%0^): Missing dump state0! >&2
	%return% 2
)

if not exist %STATE1% (

	%cprintln% Error^(%0^): Missing dump state1! >&2
	%return% 2
)

findstr /vixg:%STATE0% %STATE1% > %DELTA%
%ifError% (

	%cprintln% Error^(%0^): Unable to compare state dumps! >&2
	%return% 2
)


call:isEmptyFile %DELTA%


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
@rem ---   void isEmptyFile(String aFilename)
@rem ---
@rem ---   The subroutine defines required macros.
@rem ---
@rem ---
@rem ---
@rem ---
@rem ---

:isEmptyFile

	set "_filename=%1"
	if '%_filename%'=='' (

		%cprintln% Error^(%0^): No file name has been specified! >&2
		%return% 2
	)
	set "_filename=%_filename:"=%"


	if %~z1==0 (

		%cprintln% There are no changes in the environemnt variables.

	) else (

		%cprintln% There are changes in the environment variables.
	)


	set _filename=

%return%
