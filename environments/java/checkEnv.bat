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
@rem ===   This Batch script checks if the environment variables have been changed.
@rem ===   Depending on the security settings changes to environment variables will
@rem ===   be reverted after a batch file has finished execution.
@rem ===

if not defined OLD_PATH (

	echo ERROR^(%0^): The environment hasn't been set or the modifications have been reverted. >&2
	exit /b 2
)


set "_currentPath=%PATH%"
set "_currentPath=%_currentPath:"=%"

set "_previousPath=%OLD_PATH%"
set "_previousPath=%_previousPath:"=%"


if "%_currentPath%"=="%_previousPath%" (

	echo Error^(%0^): The path variable is unchanged! >&2
	echo /b 2

) else (

	echo.
	echo The modifications to the path variable have been retained.
)


exit /b
