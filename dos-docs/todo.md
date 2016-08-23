
# TODO

- provide compatibility informations (e.g. WinXP, Windows Vista, Windows 7,
  Windows8, Windows 8.1) for each subroutine.

- provide unit tests for the various public subroutines. This serves two purposes:
  1) to check correctness and
  2) to provide good and bad examples of usage.

- check the scope of "local variables" and "global variable". How is this aspect
  handled by the batch interpreter, especially with regard to variable names that
  are more commonly used?

- the clean up doesn't clean up variables which are defined inside a subroutine. If
  a subroutine runs into an error there will still be variables that haven't been
  cleaned up.

- the command 'set /P' changes the error level even if the call seemed successful.
  This needs further investigation.

