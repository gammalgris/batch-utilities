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

if defined __STACK0__ (

	echo The stack is initialized.
	exit /b 0

) else (

	echo The stack is not initialized! >&2
	exit /b 1
)
