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

@Echo Off

@rem ================================================================================
@rem ===
@rem ===   void main()
@rem ===
@rem ===   This Batch script is a template for smaller scripts.
@rem ===

call:defineMacros
call:defineConstants


rem ToDo - add the main script body


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
@rem ---   void defineConstants()
@rem ---
@rem ---   The subroutine defines required constants.
@rem ---

:defineConstants

	set TRUE=TRUE
	set FALSE=FALSE

	set LOGFILE=%~n0.log

	rem ToDo - add additional constants

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void resetErrorlevel()
@rem ---
@rem ---   The subroutine resets the error level.
@rem ---

:resetErrorlevel

%return% 0


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void logInfo(String text)
@rem ---
@rem ---   The subroutine logs the specified info text.
@rem ---
@rem ---
@rem ---   @param text
@rem ---          an info text
@rem ---

:logInfo

	set "__text=%1"
	if '%__text%'=='' (
	
		call:logError "^(%0^) No text was specified!"
		%return% 2
	)
	set "__text=%__text:"=%"


	(
		%cprintln% %date%::%time%::INFO::%__text%
	)
	
	(
		%cprintln% %date%::%time%::INFO::%__text%
	) >> %LOGFILE%


	set __text=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void logError(String text)
@rem ---
@rem ---   The subroutine logs the specified error text.
@rem ---
@rem ---
@rem ---   @param text
@rem ---          an error text
@rem ---

:logError

	set "__text=%1"
	if '%__text%'=='' (
	
		call:logError "^(%0^) No text was specified!"
		%return% 2
	)
	set "__text=%__text:"=%"


	(
		echo %date%::%time%::ERROR::%__text%
	) 1>&2

	(
		echo %date%::%time%::ERROR::%__text%
	) >> %LOGFILE%


	set __text=

%return%
