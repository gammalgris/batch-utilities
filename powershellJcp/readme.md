
General informations:

The script compares two batch files, evaluates the variable which contains the JAVA
classpath and compares the classpaths.
In certain situations it is necessary to check certain conditions in order to stop
CI/CD pipelines gracefully.


Before using the tools:

All required parameters are provided via configuration file (see config.xml).
The structure of the configuration file should be self explaining.


How to use the tool:

PS>./compare-jcp ./config.xml


Notes:

1) Check the powershell execution policy on your machine. Depending on the policy
   it may be required to sign scripts before execution.
