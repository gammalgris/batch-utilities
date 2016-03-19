@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) 2014 Kristian Kutin
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


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Load prerequisites
@rem ---

call define-constants.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Unable to initialize constants! >&2
	exit /b 2
)

call define-macros.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Unable to initialize macros! >&2
	exit /b 3
)


@rem http://stackoverflow.com/questions/5777400/how-to-use-random-in-batch-script

set MIN=1
set MAX=20

set b=

for /L %%A in (%MIN%, 1, %MAX%) do (

	call:randomNumber b 1 10
	
	setlocal EnableDelayedExpansion

		echo iteration %%A: !b!

	endlocal
)

set b=


echo.


%cprint% determine random order 

:loop

call:randomSetAppend c %MIN% %MAX%
@rem echo DEBUG^(%0^):: c^='%c%'
%cprint% .

call:isCompleteSet c %MIN% %MAX%
%ifError% (

	goto loop
)

%cprintln% done.
%cprintln%.
%cprintln% %c%


set c=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void randomNumber(String _variableName, int _minValue, int _maxValue)
@rem ---
@rem ---   Generates a random number (minValue <= number <= maxValue) and assigns it
@rem ---   to the specified variable.
@rem ---
@rem ---
@rem ---   @param _variableName
@rem ---          the name of a variable
@rem ---   @param _minValue
@rem ---          a minimum value
@rem ---   @param _maxValue
@rem ---          a maximum value
@rem ---

:randomNumber

	set "_variableName=%1"
	if '%_variableName%'=='' (

		call:printErrorMessage "^(%0^) No variable name has been specified^!"
		%return% 2
	)
	set "_variableName=%_variableName:"=%"


	set "_minValue=%2"
	if '%_minValue%'=='' (

		call:printErrorMessage "^(%0^) No minimum value has been specified^!"
		%return% 3
	)
	set "_minValue=%_minValue:"=%"


	set "_maxValue=%3"
	if '%_maxValue%'=='' (

		call:printErrorMessage "^(%0^) No maximum value has been specified^!"
		%return% 4
	)
	set "_maxValue=%_maxValue:"=%"


	set /a _tmp=%RANDOM% * (%_maxValue% - %_minValue% + 1) / 32768 + %_minValue%
	set %_variableName%=%_tmp%


	set _tmp=
	set _variableName=
	set _minValue=
	set _maxValue=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void randomSetAppend(String setName, int minValue, int maxValue)
@rem ---
@rem ---   Adds a random number (minValue <= number <= maxValue) to the specified
@rem ---   set. If the random number already exists within the set then the set
@rem ---   remains unchanged.
@rem ---
@rem ---
@rem ---   Examples of valid sets:
@rem ---
@rem ---   1) sequence1=""
@rem ---   2) sequence2="[1]"
@rem ---   3) sequence3="[2] [1]"
@rem ---
@rem ---
@rem ---   Implementation Note:
@rem ---   Numbers are surrounded by brackets because it makes it easier to identify
@rem ---   individual numbers. E.g. with brackets [1] and [11] are distinguishable,
@rem ---   without them 1 and 11 are undistinguishable.
@rem ---
@rem ---
@rem ---   @param setName
@rem ---          the name of a variable which contains a set of numbers
@rem ---   @param minValue
@rem ---          a minimum value
@rem ---   @param maxValue
@rem ---          a maximum value
@rem ---

:randomSetAppend

	set "setName=%1"
	if '%setName%'=='' (

		call:printErrorMessage "^(%0^) No variable name has been specified!"
		%return% 2
	)
	set "setName=%setName:"=%"

	set "minValue=%2"
	if '%minValue%'=='' (

		call:printErrorMessage "^(%0^) No minimum value has been specified^!"
		%return% 3
	)
	set "minValue=%minValue:"=%"


	set "maxValue=%3"
	if '%maxValue%'=='' (

		call:printErrorMessage "^(%0^) No maximum value has been specified^!"
		%return% 4
	)
	set "maxValue=%maxValue:"=%"


	set tmp=
	set value=

	setlocal EnableDelayedExpansion
	
		set "tmp=!%setName%!"

	endlocal & set "value=%tmp%"

	@rem echo 	DEBUG^(%0^):: value^=%value%
	set tmp=

	@rem echo 	DEBUG^(%0^):: call:randomNumber tmp %minValue% %maxValue%
	call:randomNumber tmp %minValue% %maxValue%
	@rem echo 	DEBUG^(%0^):: tmp^=%tmp%

	%cprintln% %value% | findstr /L [%tmp%] 1>nul 2>&1
	%ifError% (

		@rem echo 	DEBUG^(%0^):: call:append %setName% [%tmp%]
		call:appendNumber %setName% [%tmp%]

	) else (

		@rem echo 	DEBUG^(%0^):: found [%tmp%]
	)

	set tmp=
	set value=
	set setName=
	set minValue=
	set maxValue=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void appendNumber(String __setName, int __newNumber)
@rem ---
@rem ---   Checks if the specified set doesn't contain the specified number and
@rem ---   appends it to the set.
@rem ---
@rem ---   @param __setName
@rem ---          the name of a variable which contains a set of numbers
@rem ---   @param __newNumber
@rem ---          a new value
@rem ---

:appendNumber

	set "__setName=%1"
	if '%__setName%'=='' (

		call:printErrorMessage "^(%0^) No variable name has been specified^!"
		%return% 2
	)
	set "__setName=%__setName:"=%"

	set "__newNumber=%2"
	if '%__newNumber%'=='' (

		call:printErrorMessage "^(%0^) No number has been specified!"
		%return% 3
	)
	set "__newNumber=%__newNumber:"=%"


	set __value=
	set __tmp=

	setlocal EnableDelayedExpansion

		set "__tmp=!%__setName%!"
	
	endlocal & set "__value=%__tmp%"
	@rem echo 		DEBUG^(%0^):: __value^='%__value%'
	if defined __value (

		@rem echo 		DEBUG^(%0^):: set "__value=%__value:"=%"
		set "__value=%__value:"=%"
	)
	@rem echo 		DEBUG^(%0^):: __value^='%__value%'

	@rem echo 		DEBUG^(%0^):: if '%__value%'=='' ^(...^) else ^(...^)
	@rem echo 		DEBUG^(%0^):: if '%__value%'=='' ^( set "%__setName%=%__newNumber%" ^) else ^( set "%__setName%=%__value% %__newNumber%" ^)
	if "%__value%"=="" (

		set "%__setName%=%__newNumber%"

	) else (

		set "%__setName%=%__value% %__newNumber%"
	)


	set __value=
	set __tmp=
	set __newNumber=
	set __setName=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void isCompleteSet(String _setName, int _minValue, int _maxValue)
@rem ---
@rem ---   Checks if the specified set contains numbers within the specified interval
@rem ---   (including the borders).
@rem ---
@rem ---
@rem ---   @param _setName
@rem ---          the name of a variable which contains a set of numbers
@rem ---   @param _minValue
@rem ---          a minimum value
@rem ---   @param _maxValue
@rem ---          a maximum value
@rem ---

:isCompleteSet

	set "_setName=%1"
	if '%_setName%'=='' (

		call:printErrorMessage "^(%0^) No variable name has been specified^!"
		%return% 2
	)
	set "_setName=%_setName:"=%"


	set "_minValue=%2"
	if '%_minValue%'=='' (

		call:printErrorMessage "^(%0^) No minimum value has been specified^!"
		%return% 3
	)
	set "_minValue=%_minValue:"=%"


	set "_maxValue=%3"
	if '%_maxValue%'=='' (

		call:printErrorMessage "^(%0^) No maximum value has been specified^!"
		%return% 4
	)
	set "_maxValue=%_maxValue:"=%"


	set _tmp=
	set _value=

	setlocal EnableDelayedExpansion
	
		set "_tmp=!%_setName%!"

	endlocal & set "_value=%_tmp%"
	@rem echo 	DEBUG^(%0^):: _value^='%_value%'

	set _missingNumbers=

	@rem for /L %%A in (%_minValue%, 1, %_maxValue%) do (
	@rem
	@rem 	echo %%A
	@rem )

	@rem echo 	DEBUG^(%0^):: for /L %%A in ^(%_minValue%, 1, %_maxValue%^) do ^(...^)
	for /L %%A in (%_minValue%, 1, %_maxValue%) do (

		@rem echo 		DEBUG^(%0^):: %%A
		@rem echo 		DEBUG^(%0^):: %cprintln% %_value% ^| findstr /L [%%A] 1^>nul 2^>^&1
		%cprintln% %_value% | findstr /L [%%A] 1>nul 2>&1
		%ifError% (

			@rem echo 		DEBUG^(%0^):: call:appendNumber _missingNumbers [%%A]
			call:appendNumber _missingNumbers [%%A]
			@rem echo 		DEBUG^(%0^):: call:appendNumber _missingNumbers
			@rem call:appendNumber _missingNumbers

		) else (

			@rem echo 		DEBUG^(%0^):: found [%%A]
		)

		@rem echo 		DEBUG^(%0^):: _missingNumbers^='%_missingNumbers%'
	)

	@rem echo 	DEBUG^(%0^):: _missingNumbers^='%_missingNumbers%'

	set _tmp=
	set _value=
	set _setName=
	set _minValue=
	set _maxValue=

	if defined _missingNumbers (

		%return% 1
	)

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void printErrorMessage(String errorMessage)
@rem ---
@rem ---   Prints the specified error message to the console (i.e. error channel).
@rem ---
@rem ---
@rem ---   @param errorMessage
@rem ---          an error message
@rem ---

:printErrorMessage

	%cprintln% Error: %~1 1>&2

%return%
