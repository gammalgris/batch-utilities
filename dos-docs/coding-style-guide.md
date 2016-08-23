# Coding Style Guide Batch-Programming

Most guidelines presented here reflect a personal preference to layout and presentation
of code.

## Comments

Comments are important to document various aspects of a batch script (e.g. authorship,
implementation details, etc.).

### General

The ```REM``` command is used to mark comments (see example below)

```
@rem some comment
```

and should always be preceded by a ```@```. This has the effect that comment lines are not printed
if ```echo on``` has been set, avoiding clutter in console output.

### Copyright Notice

Each batch file has to start with a copyright notice (i.e. MIT license) showing the date of the
first creation of the batch file and all contributing authors.

```
@rem
@rem The MIT License (MIT)
@rem
@rem Copyright (c) {date} {author}
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
```

### Documenting a Batch Script

The main execution block has to start with a description which shows

* a quasi signature
* a description of the scripts purpose and functionalities
* a list of expected (mandatory) command line parameters

Following example shows a batch script which doesn't expect command line parameters:

```
@rem ================================================================================
@rem ===
@rem ===   void main()
@rem ===
@rem ===   This is a batch script which doesn't expect command line parameters.
@rem ===
```

Following example shows a batch script which expects a command line parameter:

```
@rem ================================================================================
@rem ===
@rem ===   void main(String aString)
@rem ===
@rem ===   This is a batch script which expects a command line parameter.
@rem ===
@rem ===
@rem ===   @param aString
@rem ===          a string
@rem ===
```

### Documenting a Subroutine

Subroutines are documented similar to the main excution block. The subroutine's label is used
within the quasi signature.

Following example shows a subroutine which doesn't expect parameters:

```
@rem ================================================================================
@rem ===
@rem ===   void subroutine1()
@rem ===
@rem ===   This is a subroutine which doesn't expect parameters.
@rem ===

:subroutine1
```

### Quasi Signature

As shown in the previous chapters the documentation for the main execution block and subroutines contains
a quasi signature. A quasi signature orients itself on high-level programming languages but in reality
there is no such equivalent in batch programming. Its main purpose is to show the number of expected parameters.

Batch programming actually only knows one data type (i.e. ```string```). The quasi signature may on the
other hand depict parameters as

* int
* string
* boolean

This classifier shows what is to be expected when processing a parmeter.


## Data Types

### General

Following principles are always valid:

* Batch prgramming is not case sensitive when it comes to variable names.
* There is no distinction between variables and constants.
* Constants are just variables which can be changed (but obviously shouldn't be changed).
* The scope of a variable is always global.

The rules defined below have no impact on those principles but are provided as a means to provide additional
information for a variable. The goal is to improve understanability of a batch script.

### Constants

Constants must be named in capital letters.

```
set CONSTANT=some Value
```

If the constant name is a composite name then the parts must be separated by an underscore.

```
set CONSTANT_ONE=some Value
```

### Variables

#### Global Variables

Variables must be named in small case letters.

```
set variable=some Value
```

If the variable name is a composite name then every name component starts with a capital letter except for the
first name component.

```
set variableOne=some Value
```

#### Script Local Variables

Local variables must be named in small case letters and is preceded by an underscore.

```
set _variable=some Value
```

If the variable name is a composite name then every name component starts with a capital letter except for the
first name component.

```
set _variableOne=some Value
```

#### Subroutine Local Variables

Local variables in subroutines must be named in small case letters and is preceded by two underscores.

```
set __variable=some Value
```

If the variable name is a composite name then every name component starts with a capital letter except for the
first name component.

```
set __variableOne=some Value
```

### Macros

Macros are just variables but they are assigned a set of commands. Macros can make the code more readable but
making debugging more difficult at the same time.

When introducing a new macro the programmer has to make sure that the macro works corretly (i.e. it has to be
tested throroughly).

### Clean Up

The programmer is responsible for cleaning up variables and constants after they are no longer needed. The
naming of should represent the actual scope.

In certain situations (e.g. the script execution is stopped due to an unrecoverable error) a clean up cannot
be done easily. It shouldn't be done to make debugging easier.


## Stop Execution

A script or subroutine should always be exited with ```exit /b {return code}``` or ```exit /b``` which has the
effect that the execution is resumed with the invoker. If there is no invoker then the execution will stop.

It is possible to explicitely specify a return code. Not providing a return code results in the
current ```ERRORLEVEL``` to be returned implicitely.


## Indentation

Code must be indented to improve readability.

### Main Execution Block

The main execution block is not indented.

### Subroutines

The subroutines's code must be indented except for its label and the return statement.

```
:subroutine

	echo Do something.

exit /b 0
```

### Blocks

Within a main execution block and a subroutine there can be blocks of code which must have a deeper
indentation.

A block within the main execution block:
```
(
	echo Do something in this block
)
```

A block within a subroutine:
```
:subroutine

	(
		echo Do something in this block
	)

exit /b 0
```

For easier readability a block can be spread over several lines. The interpreter treats all commands
within the block as if they had been specified in a single line thus resolving variables and constants
immediately. With complex computations the block has to be moved into a subroutine for correctly
resolving variables (i.e. avoid variables being resolved too early).


## Control Flows

### Conditional

In a conditional statement the if clause and the else clause must always be a block encased by round
brackets.

```
	if %a%==%b% (

		echo a

	) else (

		echo b
	)
```

### Loops

In a loop the loop body must always be a block encased by round brackets.

```
	for /L %%i in ( 5, -1, 1) do (

		echo %%i
	)
```

### Goto

Gotos must be used with care and best in a limited and local scope.

```
:subroutine

	if %a%==%b% (

		goto SKIP
	)

	...

:SKIP

	...

exit /b 0

```


## Validation

Parameters which are provided when invoking a batch script or a subroutine must be checked and validated.
Quotes must be be removed. See example.

```
	...
	set "_name=%1"
	if '%_name%'=='' (

		echo Error^(%0^): No application name has been specified! >&2
		exit /b 2
	)
	set "_name=%_name:"=%"
	...
```


## File Addressing

For an easier handling (e.g. concatenation of path names) directory paths must end with a backslash.


## Console Output

By default ```echo off``` must be set. For debugging purposes ```echo on``` can be set.


## Error Handling

### Checking

Not every invocation of a subroutine or executable has to be checked. This is only necessary for vital
operations where a failure singals that the computation must stop.

### Error messages

When writing error messages to the console the console output must be redirected to the error channel.

```
	...
    echo An error message! >&2
    ...
```
