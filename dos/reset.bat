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

echo execute %~n0...

set "$TAB=%TAB%"

call:undefine SPACE
call:undefine TAB
call:undefine TABULATOR
call:undefine TRUE
call:undefine FALSE
call:undefine SLASH
call:undefine BACKSLASH
call:undefine LEFT_CHEVRON
call:undefine RIGHT_CHEVRON
call:undefine LEFT_PARENTHESIS
call:undefine RIGHT_PARENTHESIS
call:undefine AMPERSAND
call:undefine LEFT_CHEVRON_REPLACEMENT
call:undefine RIGHT_CHEVRON_REPLACEMENT
call:undefine LEFT_PARENTHESIS_REPLACEMENT
call:undefine RIGHT_PARENTHESIS_REPLACEMENT
call:undefine AMPERSAND_REPLACEMENT
call:undefine PRIME
call:undefine DOUBLE_PRIME
call:undefine NO_ERROR
call:undefine GENERIC_FRAMEWORK_ERROR
call:undefine FILE_IS_NOT_LOCKED
call:undefine FILE_IS_LOCKED
call:undefine READ_ACCESS
call:undefine DENIED_READ_ACCESS
call:undefine WRITE_ACCESS
call:undefine DENIED_WRITE_ACCESS

echo.

call:undefine ifError
call:undefine cprintln
call:undefine cprintln
call:undefine return

echo.

call:undefine __CONSTANTS__
call:undefine __MACROS__

set $TAB=

echo %~n0 done.

exit /b 0


@rem ================================================================================
@rem ===
@rem ===   Internal Subroutines
@rem ===

@rem --------------------------------------------------------------------------------
@rem ---
@rem ---   void undefine(String name)
@rem ---
@rem ---   The subroutine undefines the specified constant or macro .
@rem ---

:undefine

	echo %$TAB%undefine %1
	set %1=

goto:eof
