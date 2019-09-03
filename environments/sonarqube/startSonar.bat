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
@rem ===   This script sets up the environment for SonarQube and starts SonarQube.
@rem ===

set "initializerPath=%~dp0"
set initializerRunner=setEnv.bat
set environmentCheck=checkEnv.bat


set sonarVersion=5.3
set "sonarPath=C:\sonarqube-6.7.7\bin\windows-x86-64"
set sonarRunner=StartSonar.bat


set "windowTitle=SonarQube %sonarVersion%"
title %windowTitle%


cd /D "%initializerPath%"

call %initializerRunner% 2>nul
if %ERRORLEVEL%==0 (

	rem OK

) else (

	echo ERROR %ERRORLEVEL%: The environment couldn't be set up! >&2
	pause
	exit /b %ERRORLEVEL%
)


call %environmentCheck% 2>nul
if %ERRORLEVEL%==0 (

	rem OK

) else (

	echo ERROR %ERRORLEVEL%: The environment couldn't be set up! >&2
	pause
	exit /b %ERRORLEVEL%
)


cd /D "%sonarPath%" 2>nul
if %ERRORLEVEL%==0 (

	rem OK

) else (

	echo ERROR %ERRORLEVEL%: The path to sonar ^(%sonarPath%^) is invalid! >&2
	pause
	exit /b %ERRORLEVEL%
)


echo.
echo.

call %sonarRunner%
if %ERRORLEVEL%==0 (

	rem OK
	echo ^(%ERRORLEVEL%^)

) else (

	if %ERRORLEVEL%==130 (

		echo ^(%ERRORLEVEL%^) Shutdown by Ctrl+C.

	) else (

		echo ERROR %ERRORLEVEL%: An error occurred while invoking the sonar runner! >&2
		pause
		exit /b %ERRORLEVEL%
	)
)

pause


set initializerPath=
set initializerRunner=
set sonarVersion=
set sonarPath=
set sonarRunner=
set windowTitle=
