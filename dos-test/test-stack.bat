@Echo Off


set ALL_TESTS=0
set FAILED_TESTS=0
set SUCCESSFUL_TESTS=0

set "BASEDIR=..\dos\"
set "STACK_DIR=%BASEDIR%stack\"


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Load prerequisites
@rem ---

call %BASEDIR%define-constants.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Unable to initialize constants! >&2
	exit /b 2
)

call %BASEDIR%define-macros.bat 2>nul
if "%ERRORLEVEL%"=="0" (

	@rem OK

) else (

	echo Unable to initialize macros! >&2
	exit /b 3
)


@rem
@rem The tests are executed with a static irder (last test first).
@rem
@rem ToDo
@rem Make the order of test execution random.
@rem

call:runSuite %0

call:testIsInitializedOnInitializedStack
call:testPopOnEmptyStack
call:testPeekOnEmptyStack
call:testPopOnInitializedStack
call:testPeekOnInitializedStack
call:testPushOnInitializedStack
call:testInitStack
call:testIsInitializedOnUnitializedStack
call:testPushOnUnitializedStack
call:testPeekOnUnitializedStack
call:testPopOnUnitializedStack

call:showSummary %0


@rem clean up after this test suite has been executed.

set ALL_TESTS=
set FAILED_TESTS=
set SUCCESSFUL_TESTS=

set BASEDIR=
set STACK_DIR=

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

	call %STACK_DIR%pop a
	%ifError% (

		call:passTest %0

	) else (

		call:failTest %0
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

	call %STACK_DIR%peek a
	%ifError% (

		call:passTest %0

	) else (

		call:failTest %0
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

	call %STACK_DIR%push "Hello World!"
	%ifError% (

		call:passTest %0

	) else (

		call:failTest %0
	)


	call:afterTest


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testIsInitializedOnUnitializedStack()
@rem ---
@rem ---   Checks if the stack is not initializzed.
@rem ---
@rem ---
@rem ---   Note:
@rem ---   The test is not reliable. It's not possible to detect a success. Sometimes
@rem ---   if this test fails then the test testPushOnUnitializedStack fails too.
@rem ---   There might be some unwanted side effects.
@rem ---

:testIsInitializedOnUnitializedStack

	call:beforeTest


	call:runTest %0

	call %STACK_DIR%isInitialized 2>&1 | findstr /b "The stack is not initialized!"
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

	call %STACK_DIR%initStack
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

	call %STACK_DIR%peek a
	%ifError% (

		call:passTest %0

	) else (

		call:failTest %0
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

	call %STACK_DIR%pop a
	%ifError% (

		call:passTest %0

	) else (

		call:failTest %0
	)


	set a=
	call:afterTest

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void testIsInitializedOnInitializedStack()
@rem ---
@rem ---   Checks if the stack is initializzed.
@rem ---
@rem ---
@rem ---   Note:
@rem ---   The test is not reliable. It's not possible to detect a success.
@rem ---

:testIsInitializedOnInitializedStack

	call:beforeTest
	call %STACK_DIR%initStack >nul 2>&1


	call:runTest %0

	call %STACK_DIR%isInitialized
	%ifError% (

		call:failTest %0

	) else (

		call:passTest %0
	)


	call:afterTest

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

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void afterTest()
@rem ---
@rem ---   Performs a clean up after a test.
@rem ---

:afterTest

	call %STACK_DIR%deleteStack.bat

%return%


@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void showSummary()
@rem ---
@rem ---   Prints a summary for this test suite.
@rem ---

:showSummary

	%cprintln%.
	%cprintln% %ALL_TESTS% tests were executed.
	%cprintln% %SUCCESSFUL_TESTS% tests were successful.
	%cprintln% %FAILED_TESTS% tests have failed.

%return%
