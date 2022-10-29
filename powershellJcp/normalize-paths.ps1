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
		The script takes the specified array which contains file and directory paths
		and normalizes each path, i.e. retains only the java archive name.

	.SYNOPSIS
		The script normalizes the specified paths.

	.PARAMETER lines
		The variable contains directory and file paths.

#>

param(

	[String[]]
	$lines

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

[String] $PATH_KEY = 'PATH';
[String] $NAME_KEY = 'NAME';

[String] $PATTERN_1 = '^(?<PATH>([^.%\s]+|[.]))$';
[String] $PATTERN_2 = '^(?<PATH>([^\\\s]+[\\])+)(?<NAME>.+[.][j][a][r])$';
[String] $PATTERN_3 = '^(?<PATH>([%][^.%\s]+[%]))$';

	[boolean] processLine([String] $line, [ref] $resultList ) {

		return $false;
	}

}


class DirectoryPathProcessor : LineProcessor {

	[boolean] processLine([String] $line, [ref] $resultList ) {

		if ($line -match $this.PATTERN_1) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.PATH_KEY))) {

				throw 'The group ' + $this.PATH_KEY + ' is missing from the regular exception!';
			}

			[String] $path = $lineResult.($this.PATH_KEY);
			$resultList.Value.Add($path);

			return $true;
		}

		return $false;
	}

}


class FilePathProcessor : LineProcessor {

	[boolean] processLine([String] $line, [ref] $resultList ) {

		if ($line -match $this.PATTERN_2) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.PATH_KEY))) {

				throw 'The group ' + $this.PATH_KEY + ' is missing from the regular exception!';
			}
			if (!($lineResult.ContainsKey($this.NAME_KEY))) {

				throw 'The group ' + $this.NAME_KEY + ' is missing from the regular exception!';
			}

			[String] $name = $lineResult.($this.NAME_KEY);
			$resultList.Value.Add($name);

			return $true;
		}

		return $false;
	}

}


class VariableProcessor : LineProcessor {

	[boolean] processLine([String] $line, [ref] $resultList ) {

		if ($line -match $this.PATTERN_3) {

			[Hashtable] $lineResult = $Matches;

			if (!($lineResult.ContainsKey($this.PATH_KEY))) {

				throw 'The group ' + $this.PATH_KEY + ' is missing from the regular exception!';
			}

			[String] $path = $lineResult.($this.PATH_KEY);
			$resultList.Value.Add($path);

			return $true;
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

		[LineProcessor] $processor = [DirectoryPathProcessor]::New();
		$functions.add($processor);

		$processor = [FilePathProcessor]::New();
		$functions.add($processor);

		$processor = [VariableProcessor]::New();
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
		$content
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

				if ($function.processLine($line, $list)) {

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

if (!$lines) {

	Write-Host 'No input data was specified!';
	exit 2;
}

[System.Object] $result = parseContent $lines;

return $result;

