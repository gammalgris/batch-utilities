@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) 2016 Kristian Kutin
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
