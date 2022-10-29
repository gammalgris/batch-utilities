#
# The MIT License (MIT)
#
# Copyright (c) 2022 Kristian Kutin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

<#

	.DESCRIPTION
		The script scans the specified input file and tries to identify the
		specified classpath. The classpath is normalized so that it can be
		processed (e.g. to identify changes). The current implementation makes
		certain assumptions (see code).

	.SYNOPSIS
		The script parses the specified input file.

	.PARAMETER inputFile
		An input file (i.e. a batch file which is used to start a program
		written with Java).

	.PARAMETER variableName
		The variable which is looked for in the script.

#>
param(

	[String]
	$inputFile,

	[String]
	$variableName

)


#===============================================================================
#===
#===	Global Variables and Constants
#===

$ErrorActionPreference = 'Stop';



#===============================================================================
#===
#===	Class Declarations
#===

class LineProcessor {

	[String] $JAR_KEY = 'JAR';
	[String] $JAR2_KEY = 'JAR2';
	[String] $NAME_KEY = 'NAME';
	[String] $NAME2_KEY = 'NAME2';
	[String] $NAME3_KEY = 'NAME3';

	[String] $PATTERN_1 = '^[s][e][t][ ](?<NAME>[^%"\s]+)[=](?<JAR>[^;\s]+)$';
	[String] $PATTERN_2 = '^[s][e][t][ ](?<NAME>[^%"\s]+)[=][%](?<NAME2>[^%"\s]+)[%][;][%](?<NAME3>[^%"\s]+)[%]$';
	[String] $PATTERN_3 = '^[s][e][t][ ](?<NAME>[^%"\s]+)[=][%](?<NAME2>[^%"\s]+)[%][;](?<JAR>.+)$';
	[String] $PATTERN_4 = '^[s][e][t][ ](?<NAME>[^%"\s]+)[=](?<JAR>.+)[;][%](?<NAME2>[^%"\s]+)[%]$';
	[String] $PATTERN_5 = '^[s][e][t][ ](?<NAME>[^%"\s]+)[=](?<JAR>[^%"\s]+)[;](?<JAR2>[^%"\s]+)$';

	[boolean] processLine([String] $line, [String] $variableName, [ref] $resultList ) {

		return $false;
	}

}


class DeclarationProcessor : LineProcessor {

	[boolean] processLine([String] $line, [String] $variableName, [ref] $resultList ) {

		if ($line -match $this.PATTERN_1) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.NAME_KEY))) {

				throw 'The group ' + $this.NAME_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.JAR_KEY))) {

				throw 'The group ' + $this.JAR_KEY + ' is missing from the regular exception!';
			}

			[String] $actualName = $lineResult.($this.NAME_KEY);

			if ($variableName -eq $actualName) {

				[String] $jar = $lineResult.($this.JAR_KEY);

				$resultList.Value.Clear();
				$resultList.Value.Add($jar);

				return $true;
			}
		}

		return $false;
	}

}


class VariableAppenderProcessor : LineProcessor {

	[boolean] processLine([String] $line, [String] $variableName, [ref] $resultList ) {

		if ($line -match $this.PATTERN_2) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.NAME_KEY))) {

				throw 'The group ' + $this.NAME_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.NAME2_KEY))) {

				throw 'The group ' + $this.NAME2_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.NAME3_KEY))) {

				throw 'The group ' + $this.NAME3_KEY + ' is missing from the regular exception!';
			}

			[String] $actualName = $lineResult.($this.NAME_KEY);
			if ($variableName -eq $actualName) {

				[String] $name2 = $lineResult.($this.NAME2_KEY);
				[String] $name3 = $lineResult.($this.NAME3_KEY);

				if (!($variableName -eq $name2)) {

					[String] $expandedName = '%' + $name2 + '%';
					$resultList.Value.Add($expandedName);
				}
				if (!($variableName -eq $name3)) {

					[String] $expandedName = '%' + $name3 + '%';
					$resultList.Value.Add($expandedName);
				}

				return $true;
			}
		}

		return $false;
	}

}


class JarAppenderProcessor : LineProcessor {

	[boolean] processLine([String] $line, [String] $variableName, [ref] $resultList ) {

		if ($line -match $this.PATTERN_3) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.NAME_KEY))) {

				throw 'The group ' + $this.NAME_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.JAR_KEY))) {

				throw 'The group ' + $this.JAR_KEY + ' is missing from the regular exception!';
			}

			[String] $actualName = $lineResult.($this.NAME_KEY);

			if ($variableName -eq $actualName) {

				[String] $jar = $lineResult.($this.JAR_KEY);

				$resultList.Value.Add($jar);

				return $true;
			}
		}

		return $false;
	}

}


class JarInserterProcessor : LineProcessor {

	[boolean] processLine([String] $line, [String] $variableName, [ref] $resultList ) {

		if ($line -match $this.PATTERN_4) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.NAME_KEY))) {

				throw 'The group ' + $this.NAME_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.JAR_KEY))) {

				throw 'The group ' + $this.JAR_KEY + ' is missing from the regular exception!';
			}

			[String] $actualName = $lineResult.($this.NAME_KEY);

			if ($variableName -eq $actualName) {

				[String] $jar = $lineResult.($this.JAR_KEY);

				$resultList.Value.Insert(0, $jar);

				return $true;
			}
		}

		return $false;
	}

}


class DoubleJarAppenderProcessor : LineProcessor {

	[boolean] processLine([String] $line, [String] $variableName, [ref] $resultList ) {

		if ($line -match $this.PATTERN_5) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.NAME_KEY))) {

				throw 'The group ' + $this.NAME_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.JAR_KEY))) {

				throw 'The group ' + $this.JAR_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.JAR2_KEY))) {

				throw 'The group ' + $this.JAR2_KEY + ' is missing from the regular exception!';
			}

			[String] $actualName = $lineResult.($this.NAME_KEY);
			if ($variableName -eq $actualName) {

				[String] $jar1 = $lineResult.($this.JAR_KEY);
				[String] $jar2 = $lineResult.($this.JAR2_KEY);

				$resultList.Value.Add($jar1);
				$resultList.Value.Add($jar2);

				return $true;
			}
		}

		return $false;
	}

}


#===============================================================================
#===
#===	Function Declarations
#===


function getFunctions() {

	try {

		[System.Object] $functions = New-Object Collections.Generic.List[LineProcessor];

		[LineProcessor] $processor = [DeclarationProcessor]::New();
		$functions.add($processor);

		$processor = [VariableAppenderProcessor]::New();
		$functions.add($processor);

		$processor = [JarAppenderProcessor]::New();
		$functions.add($processor);

		$processor = [JarInserterProcessor]::New();
		$functions.add($processor);

		$processor = [DoubleJarAppenderProcessor]::New();
		$functions.add($processor);

		return $functions;

	} catch {

		throw;
	}
}


function parseContent() {

	param(
		[Parameter(Mandatory = $true)]
		[String[]]
		$content,
		[Parameter(Mandatory = $true)]
		[String]
		$variableName
	)

	Try {

		[System.Object] $list = New-Object Collections.Generic.List[String];
		[System.Object] $functions = getFunctions;

		[String] $line = $null;
		foreach ($line in $content) {

			if (!$line) {

				continue;
			}

			[LineProcessor] $function = $null;
			foreach ($function in $functions) {

				if ($function.processLine($line, $variableName, $list)) {

					break;
				}
			}
		}

		return $list;

	} catch {

		throw;
	}

}


#===============================================================================
#===
#===	Main Block
#===

if (!$inputFile) {

	Write-Host 'No input file was specified!';
	exit 2;
}

if (!$variableName) {

	Write-Host 'No variable name was specified!';
	exit 3;
}

$resolvedInputFilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( $inputFile );

[String[]] $fileContent = Get-Content $resolvedInputFilePath;
[String[]] $normalizedContent = $fileContent | Where-Object {$_};
[System.Object] $result = parseContent $normalizedContent $variableName;

return $result;
