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
@rem ---      initStack
@rem ---      initStack force
@rem ---      initStack preserve
@rem ---
@rem ---   Initializes the stack (LIFO). Initialization happens only once. By
@rem ---   providing the parameter 'force' the stack can be initialized without
@rem ---   regard to the stack's current content. The parameter 'preserve' will
@rem ---   retain an existing stack.
@rem ---
@rem ---
@rem ---   Implementation notes:
@rem ---
@rem ---   The stack is persisted within a file. The environment variable STACK1_FILE
@rem ---   contains the file name of the storage file. It is not recommended that the
@rem ---   path contains spaces. The environment variable STACK_SIZE contains the
@rem ---   current size (i.e. number of entries) of the stack.
@rem ---

if '%1'=='force' (

	goto init
)


if defined __STACK1__ (

	echo The stack is already initialized! >&2
	exit /b 1
)

:init

echo | set /p=initialize stack

set STACK1_FILE=%~dp0.stack
set STACK1_SIZE=0

if '%1'=='preserve' (

	goto skipDeletion
)

if exist %STACK1_FILE% (

	del /Q %STACK1_FILE%
)

:skipDeletion

set __STACK1__=defined

echo  ... done.

exit /b 0
