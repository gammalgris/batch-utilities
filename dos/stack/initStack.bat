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
@rem ---   The stack is persisted within a file. The environment variable STACK_FILE
@rem ---   contains the file name of the storage file. It is not recommended that the
@rem ---   path contains spaces. The environment variable STACK_SIZE contains the
@rem ---   current size (i.e. number of entries) of the stack.
@rem ---

if '%1'=='force' (

	goto init
)


if defined __STACK__ (

	echo The stack is already initialized! >&2
	exit /b 1
)

:init

echo | set /p=initialize stack

set STACK_FILE=%~dp0.stack
set STACK_SIZE=0

if '%1'=='preserve' (

	goto skipDeletion
)

if exist %STACK_FILE% (

	del /Q %STACK_FILE%
)

:skipDeletion

set __STACK__=defined

echo  ... done.

exit /b 0
