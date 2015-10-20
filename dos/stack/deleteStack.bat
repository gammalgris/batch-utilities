@echo off

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   Syntax:
@rem ---
@rem ---      deleteStack
@rem ---
@rem ---   Deletes the stack (LIFO). This script is mainly provided as a convenience
@rem ---   operation for purposes of testing (i.e. to reset the stack to an undefined
@rem ---   state).
@rem ---

if not defined __STACK__ (

	exit /b 0
)

del /Q %STACK_FILE%

set STACK_FILE=
set STACK_SIZE=
set __STACK__=

exit /b 0
