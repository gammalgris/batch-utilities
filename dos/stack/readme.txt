
PREMISES

1) The stack functionality is implemented as an independent mechanism.

2) All variables have a global scope.

3) The operations initStack, peek, pop and push are not meant to be called at
   the same time because the operations may override each other's variables.

4) The actual stack content is stored in a file and every line is a separate
   entry, thus the stack's state is persistent. Permissions to the file or the
   parent directory should never be changed during a console session. Read and
   write permissions must be assured.

5) A variable (i.e. STACK_FILE) contains the absolute path of the stack file.
   The file's path is not be changed during a console session.

6) A variable (i.e. STACK_SIZE) contains the number of entries within the
   stack. This variable's value is subject to change and should always reflect
   the current size of the stack.

7) The variable names don't adhere to the default naming convention in order
   for the stack functionality to work independently from other batch scripts
   (see {2}) and with as few restrictions as possible (see {3}).

8) By default a stack can only be initialized once during a console session.

9) The stack will only work properly if {4}, {5} and {6} contain matching
   data.


IMPLEMENTATION

The stack is implemented as five distinct batch scripts which represent the
stack's functionality. There are no dependencies to run these scripts other
than a system which provides a dos console.

   initStack

   Initializes the stack. An environment variable (i.e. __STACK__) ensures
   that the stack will only be initialized once during a console session.
   There exist some additional command line options (e.g. force, preserve).
   For details see the comments in that batch script.


   isInitialized

   Checks if the stack is initialized. If it is not initialized then the
   script fails (i.e. the errorlevel is set accordingly when the script
   terminates).


   peek

   Reads the last entry from the stack. The stack remains unchanged. The
   entry's value is assigned to a specified variable.


   pop

   Reads the last entry from the stack and removes it from the stack (i.e.
   currently the stack is rebuild which may not be very efficient with large
   stacks). The entry's value is assigned to a specified variable.


   push

   Add an entry to the stack (i.e. appends it to the end of the file).

There are no safeguards to prevent {3} and it's the programmer's duty to take
care of how the stack is used (i.e. how and when the functionality is invoked).

If multiple distinct stacks are required it is suggested to take these scripts
and to copy them to distinct directories where each directory represents a
separate stack. The scripts have to be modified (i.e. rename variables) in
order to prevent {3} when working with different stacks.

One purpose for the stack is to implement a mechanism which imitates the local
visibility of variables. Thus it will be used by all utility libraries.


TODO

There have been implemented several safeguards to make sure that the stack and
it's data are in a valid state (i.e. reflects the called operations). Still
gaps are possible.

1) The stack file is checked if it is blocked by another process. Still it is
   possible that at a subsequent step the file can be locked by another
   process. Handling this is aspect difficult.

2) Write and read operations can fail due to various reasons. Not all
   constellations have been considered with the current error handling.

3) It's possible to change the scripts so {3} doesn't apply any longer. That
   would require some synchronization/ blocking mechanism (or other, with a
   similar effect) in order to maintain a valid state of the stack.
