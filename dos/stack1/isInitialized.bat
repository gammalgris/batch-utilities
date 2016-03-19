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
@rem ---      isInitialized
@rem ---
@rem ---   Checks if the stack is initialized. The errorlevel represents the result
@rem ---   of the check. Possible values are:
@rem ---
@rem ---      0   the stack is initialized
@rem ---      1   the stack is not initialized
@rem ---

if defined __STACK1__ (

	echo The stack is initialized.
	exit /b 0

) else (

	echo The stack is not initialized! >&2
	exit /b 1
)
