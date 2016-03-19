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

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Syntax:
@rem ---
@rem ---      push [value]
@rem ---
@rem ---   Pushes the specified value to the stack.
@rem ---

@rem define an important macro which is used to identify an error.

if not defined $ifError (

	set "$ifError=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"
)


@rem Check if the stack is initialized.

call %~dp0%isInitialized.bat >nul 2>&1
%$ifError% (

	echo ^(%0^) The stack is not initialized^! >&2
	exit /b 1
)


@rem Check the specified parameter. Only one parameter is allowed. The parameter
@rem can be surrounded by quotes.

set "$more=%2"
if '%$more%'=='' (

	@rem OK

) else (

	echo ^(%0^) Only one parameter is allowed but more than one parameter was specified^! >&2
	exit /b 2
)
set $more=


set "$value=%1"
if '%$value%'=='' (

	echo ^(%0^) No value has been specified^! >&2
	exit /b 3
)
set "$value=%$value:"=%"


@rem Check if the stack is used by another process.

2>nul (

	>>%STACK_FILE% echo off

) && (

	rem OK

) || (

	echo ^(%0^) Another process is using the stack^! >&2
	exit /b 4
)


@rem Add the specified value to the stack.

echo %$value%>> %STACK_FILE%
%$ifError% (

	echo ^(%0^) The specified value ^(^"%$value%^"^) couldn't be pushed to the stack^! >&2
	exit /b 5
)

set /a STACK_SIZE+=1

set $value=

exit /b 0
