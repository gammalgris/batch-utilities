@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) 2017 Kristian Kutin
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
@rem ===   void main(Enumeration option, String baseDirectory, int numberOfDays)
@rem ===
@rem ===   This batch script is used to identify or delete files within the specified
@rem ===   directory which are older than the specified number of days.
@rem ===
@rem ===
@rem ===   @param option
@rem ===          an option (e.g. delete or scan)
@rem ===   @param baseDirectory
@rem ===          the base directory
@rem ===   @param numberOfDays
@rem ===          a threshold to identify old files
@rem ===

call:defineMacros
call:defineConstants


set "option=%1"
if '%option%'=='' (

	call:logError "^(%0^) No option was specified!"
	%return% 2
)
set "option=%option:"=%"


if "%option%"=="%SCAN_OPTION%" (

	call:listDirectories %2 %3
	%return%
)

if "%option%"=="%DELETE_OPTION%" (

	call:deleteDirectories %2 %3
	%return%
)


call:logError "^(%0^) The specified option '%option%' is unknown!"
%return% 3


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

	set SCAN_OPTION=scan
	set DELETE_OPTION=delete

	set SCRIPTFILE=%~n0%~x0
	set LOGFILE=%~n0.log

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
@rem ---   void logInfo(String aText)
@rem ---
@rem ---   The subroutine logs the specified info text.
@rem ---
@rem ---
@rem ---   @param aText
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
@rem ---   void logError(String aText)
@rem ---
@rem ---   The subroutine logs the specified error text.
@rem ---
@rem ---
@rem ---   @param aText
@rem ---          an error text
@rem ---

:logError

	set "__text=%1"
	if '%__text%'=='' (
	
		echo ^(%0^) No text was specified! >&2
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


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void listDirectories(String baseDirectory, int numberOfDays)
@rem ---
@rem ---   The subroutine lists all directories within the specified base directory
@rem ---   which are older than the specified number of days.
@rem ---
@rem ---
@rem ---   @param baseDirectory
@rem ---          the base directoy
@rem ---   @param numberOfDays
@rem ---          a threshold to identify old directories
@rem ---

:listDirectories

	set "__baseDirectory=%1"
	if '%__baseDirectory%'=='' (
	
		call:logError "^(%0^) No base directory was specified!"
		%return% 2
	)
	set "__baseDirectory=%__baseDirectory:"=%"


	set "__numberOfDays=%2"
	if '%__numberOfDays%'=='' (
	
		call:logError "^(%0^) No age threshold ^(i.e. number of days^) was specified!"
		%return% 3
	)
	set "__numberOfDays=%__numberOfDays:"=%"


	forfiles /D -%__numberOfDays% /P %__baseDirectory% /C "cmd /c if /i @isdir==%TRUE% ( echo @path )" 2>nul


	set __baseDirectory=
	set __numberOfDays=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void deleteDirectories(String baseDirectory, int numberOfDays)
@rem ---
@rem ---   The subroutine deletes all directories within the specified base
@rem ---   directory which are older than the specified number of days.
@rem ---
@rem ---
@rem ---   @param baseDirectory
@rem ---          the base directoy
@rem ---   @param numberOfDays
@rem ---          a threshold to identify old directories
@rem ---

:deleteDirectories

	set "_baseDirectory=%1"
	if '%_baseDirectory%'=='' (
	
		call:logError "^(%0^) No base directory was specified!"
		%return% 2
	)
	set "_baseDirectory=%_baseDirectory:"=%"


	set "_numberOfDays=%2"
	if '%_numberOfDays%'=='' (
	
		call:logError "^(%0^) No age threshold ^(i.e. number of days^) was specified!"
		%return% 3
	)
	set "_numberOfDays=%_numberOfDays:"=%"


	call:logInfo "delete directories in %_baseDirectory% older than %_numberOfDays%..."

	for /F %%I in ('%SCRIPTFILE% scan %_baseDirectory% %_numberOfDays%') do (

		call:deleteDirectory %%I
	)


	set _baseDirectory=
	set _numberOfDays=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void deleteDirectory(String path)
@rem ---
@rem ---   The subroutine deletes the specified directory.
@rem ---
@rem ---
@rem ---   @param path
@rem ---          a path to a directory
@rem ---

:deleteDirectory

	set "__path=%1"
	if '%__path%'=='' (
	
		call:logError "^(%0^) No path was specified!"
		%return% 2
	)
	set "__path=%__path:"=%"


	call:logInfo "deleting %__path%..."

	(
		del /F /S /Q "%__path%"
	) >> %LOGFILE% 2>&1
	%ifError% (

		%return% 3
	)

	(
		rmdir /S /Q "%__path%"
	) >> %LOGFILE% 2>&1
	%ifError% (

		%return% 4
	)

	set __path=

%return%
