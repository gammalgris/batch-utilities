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

@Echo Off

@rem ================================================================================
@rem ===
@rem ===   void main()
@rem ===
@rem ===   This batch script contains a collection of unit tests.
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Initialization
@rem ---

set ALL_TESTS=0
set FAILED_TESTS=0
set SUCCESSFUL_TESTS=0

set "BASEDIR=%~dp0..\dos\"
set "STACK_DIR=%BASEDIR%bin\stack\"
set "corePath=%BASEDIR%core\"


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Load prerequisites
@rem ---

call %corePath%define-constants.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Error: Unable to initialize constants! >&2
	exit /b 2
)

call %corePath%define-macros.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Error: Unable to initialize macros! >&2
	exit /b 3
)


@rem
@rem The tests within this test suite are defined.
@rem

set test.length=11
set test[1]=:testIsInitializedOnInitializedStack
set test[2]=:testPopOnEmptyStack
set test[3]=:testPeekOnEmptyStack
set test[4]=:testPopOnInitializedStack
set test[5]=:testPeekOnInitializedStack
set test[6]=:testPushOnInitializedStack
set test[7]=:testInitStack
set test[8]=:testIsInitializedOnUnitializedStack
set test[9]=:testPushOnUnitializedStack
set test[10]=:testPeekOnUnitializedStack
set test[11]=:testPopOnUnitializedStack

set MIN=1
set MAX=%test.length%

set test.order=


@rem
@rem Determine order of tests
@rem

%cprintln%.
%cprint% determine random order 

:loop

call:randomSetAppend test.order %MIN% %MAX%
%cprint% .

call:isCompleteSet test.order %MIN% %MAX%
%ifError% (

	goto loop
)

%cprintln% done.


@rem
@rem Run all tests.
@rem

call:runSuite %0

set testName=
set tmp=

for %%A in (%test.order%) do (

	call:invokeTest test%%A
)

call:showSummary %0


@rem
@rem clean up after this test suite has been executed.
@rem

set MIN=
set MAX=

for /L %%A in (1, 1, %test.length%) do (

	set test[%%A]=
)
set test.length=
set test.order=

set ALL_TESTS=
set SUCCESSFUL_TESTS=

set BASEDIR=
set STACK_DIR=


if "%FAILED_TESTS%"=="0" (

	@rem OK

) else (

	%return% %FAILED_TESTS%
)

%return%


@rem ================================================================================
@rem ===
@rem ===   Tests
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPopOnUnitializedStack()
@rem ---
@rem ---   Tries to remove an element from an uninitialized stack.
@rem ---

:testPopOnUnitializedStack

	call:beforeTest
	set a=


	call:runTest %0

	call %STACK_DIR%pop a 2>&1 | findstr /L %STACK_NOT_INITIALIZED_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	set a=
	call:afterTest

%return%

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPeekOnUnitializedStack()
@rem ---
@rem ---   Tries to read an element from an uninitialized stack.
@rem ---

:testPeekOnUnitializedStack

	call:beforeTest
	set a=


	call:runTest %0

	call %STACK_DIR%peek a 2>&1 | findstr /L %STACK_NOT_INITIALIZED_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	set a=
	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPushOnUnitializedStack()
@rem ---
@rem ---   Tries to push an element to an uninitialized stack.
@rem ---

:testPushOnUnitializedStack

	call:beforeTest


	call:runTest %0

	call %STACK_DIR%push "Hello World!" 2>&1 | findstr /L %STACK_NOT_INITIALIZED_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	call:afterTest


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testIsInitializedOnUnitializedStack()
@rem ---
@rem ---   Checks if the stack is not initializzed.
@rem ---

:testIsInitializedOnUnitializedStack

	call:beforeTest


	call:runTest %0

	call %STACK_DIR%isInitialized 2>&1 | findstr /L %STACK_NOT_INITIALIZED_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testInitStack()
@rem ---
@rem ---   Tries to initialize an uninitialized stack.
@rem ---

:testInitStack

	call:beforeTest


	call:runTest %0

	call %STACK_DIR%initStack 2>&1 | findstr /L %STACK_INITIALIZATION_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPushOnInitializedStack()
@rem ---
@rem ---   Tries to push an element to an initialized stack.
@rem ---

:testPushOnInitializedStack

	call:beforeTest
	call %STACK_DIR%initStack >nul 2>&1


	call:runTest %0

	call %STACK_DIR%push "Hello World!"
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPeekOnInitializedStack()
@rem ---
@rem ---   Tries to read an element from an initialized stack with at least one
@rem ---   element.
@rem ---

:testPeekOnInitializedStack

	call:beforeTest
	set a=
	call %STACK_DIR%initStack >nul 2>&1
	call %STACK_DIR%push "Hello World!" >nul 2>&1


	call:runTest %0

	call %STACK_DIR%peek a
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	set a=
	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPopOnInitializedStack()
@rem ---
@rem ---   Tries to remove an element from an initialized stack with at least one
@rem ---   element.
@rem ---

:testPopOnInitializedStack

	call:beforeTest
	set a=
	call %STACK_DIR%initStack >nul 2>&1
	call %STACK_DIR%push "Hello World!" >nul 2>&1


	call:runTest %0

	call %STACK_DIR%pop a
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	set a=
	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPeekOnEmptyStack()
@rem ---
@rem ---   Tries to read an element from an initialized empty stack.
@rem ---
@rem ---
@rem ---   Note:
@rem ---   The test is not reliable. It's not possible to detect a success.
@rem ---

:testPeekOnEmptyStack

	call:beforeTest
	set a=
	call %STACK_DIR%initStack >nul 2>&1


	call:runTest %0

	call %STACK_DIR%peek a 2>&1 | findstr /L %STACK_IS_EMPTY_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	set a=
	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testPopOnEmptyStack()
@rem ---
@rem ---   Tries to remove an element from an initialized empty stack.
@rem ---
@rem ---
@rem ---   Note:
@rem ---   The test is not reliable. It's not possible to detect a success.
@rem ---

:testPopOnEmptyStack

	call:beforeTest
	set a=
	call %STACK_DIR%initStack >nul 2>&1


	call:runTest %0

	call %STACK_DIR%pop a 2>&1 | findstr /L %STACK_IS_EMPTY_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	set a=
	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testIsInitializedOnInitializedStack()
@rem ---
@rem ---   Checks if the stack is initialized.
@rem ---

:testIsInitializedOnInitializedStack

	call:beforeTest
	call %STACK_DIR%initStack >nul 2>&1


	call:runTest %0

	call %STACK_DIR%isInitialized 2>&1 | findstr /L %STACK_ALREADY_INITIALIZED_MESSAGE%
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	call:afterTest

%return%


@rem ================================================================================
@rem ===
@rem ===   Test Framework functions
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void invokeTest(String variableName)
@rem ---
@rem ---   Invokes the test which is stored in the specified variable.
@rem ---
@rem ---
@rem ---   @param variableName
@rem ---          a variable which contains the name of a test.
@rem ---

:invokeTest

	@rem echo 	DEBUG^(%0^): variable^='%1'

	set __testName=
	set __tmp=


	setlocal EnableDelayedExpansion

		set __tmp=!%1!

	endlocal & set __testName=%__tmp%

	@rem echo 	DEBUG^(%0^): test name^='%__testName%

	call%__testName%


	set __testName=
	set __tmp=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void runSuite()
@rem ---
@rem ---   Prints the name of this test suite.
@rem ---

:runSuite

	%cprintln%.
	%cprintln% running tests from %1
	%cprintln%.
	%cprintln% [==========]

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void runTest()
@rem ---
@rem ---   Prints the name of this test.
@rem ---

:runTest

	%cprintln% [ RUN      ] %1
	set /a ALL_TESTS+=1

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void passTest()
@rem ---
@rem ---   Indicates that the current test has passed successfully.
@rem ---

:passTest

	%cprintln% [  PASSED  ] %1
	set /a SUCCESSFUL_TESTS+=1

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void failTest()
@rem ---
@rem ---   Indicates that the current test has failed.
@rem ---

:failTest

	%cprintln% [  FAILED  ] %1
	set /a FAILED_TESTS+=1

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void beforeTest()
@rem ---
@rem ---   The environment is put into a defined state before the test.
@rem ---

:beforeTest

	call %STACK_DIR%deleteStack.bat
	set STACK_NOT_INITIALIZED_MESSAGE="The stack is not initialized"
	set STACK_INITIALIZATION_MESSAGE="initialize stack ... done"
	set STACK_ALREADY_INITIALIZED_MESSAGE="The stack is already initialized"
	set STACK_IS_EMPTY_MESSAGE="The stack is empty"
	
%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void afterTest()
@rem ---
@rem ---   Performs a clean up after a test.
@rem ---

:afterTest

	call %STACK_DIR%deleteStack.bat
	set STACK_NOT_INITIALIZED_MESSAGE=
	set STACK_INITIALIZATION_MESSAGE=
	set STACK_ALREADY_INITIALIZED_MESSAGE=
	set STACK_IS_EMPTY_MESSAGE=

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void showSummary()
@rem ---
@rem ---   Prints a summary for this test suite.
@rem ---

:showSummary

	%cprintln% [==========]
	%cprintln%.
	%cprintln% %ALL_TESTS% tests were executed.
	%cprintln% %SUCCESSFUL_TESTS% tests were successful.
	%cprintln% %FAILED_TESTS% tests have failed.

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


	set tmp=

	call:randomNumber tmp %minValue% %maxValue%

	%cprintln% %value% | findstr /L [%tmp%] 1>nul 2>&1
	%ifError% (

		call:appendNumber %setName% [%tmp%]

	) else (

		@rem was found
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

	if defined __value (

		set "__value=%__value:"=%"
	)

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

	set _missingNumbers=


	for /L %%A in (%_minValue%, 1, %_maxValue%) do (

		%cprintln% %_value% | findstr /L [%%A] 1>nul 2>&1
		%ifError% (

			call:appendNumber _missingNumbers [%%A]

		) else (

			@rem was found
		)
	)


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
