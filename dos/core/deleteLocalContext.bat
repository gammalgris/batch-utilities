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
echo DEBUG:: stack path^=%STACK_PATH%

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
