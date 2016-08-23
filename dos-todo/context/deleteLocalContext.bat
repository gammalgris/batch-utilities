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
@rem ---   Syntax:
@rem ---
@rem ---      deleteLocalContext
@rem ---
@rem ---   Deletes the current local context and restores the previous local context.
@rem ---   (i.e. the previous value of the variable LOCAL is restored).
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

if not defined 告fError (

	set "告fError=set foundErr=1&(if errorlevel 0 if not errorlevel 1 set foundErr=)&if defined foundErr"
)


set "STACK_PATH=%~dp0..\stack\"

call %STACK_PATH%isInitialized >nul 2>&1
%告fError% (

	echo The stack is not available^! >&2
	exit /b 1
)


call %STACK_PATH%pop LOCAL
%告fError% (

	echo The previous local context couldn't be restored^! >&2
	exit /b 2
)


exit /b 0
