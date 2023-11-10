#
# The MIT License (MIT)
#
# Copyright (c) 2023 Kristian Kutin
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

using module .\XmlUtilities.psm1;
using module .\RepositoryUtilities.psm1;


<#

	.DESCRIPTION
		The script loads files from a web repository.

	.SYNOPSIS
		The script loads files from a web repository.

	.PARAMETER configFile
		An input file (i.e. configuration file) which contains the information
		of where the files are lcoated on the web repository.

	.PARAMETER targetDir
		A target directory where to store the files.

#>

param(

	[String]
	$configFile,

	[String]
	$targetDir

)


# ================================================================================
# ===
# ===   Constant Declarations
# ===

[String] $SELECTIONS_FILE = 'selections.csv';


# ================================================================================
# ===
# ===   Variable Declarations
# ===

$ErrorActionPreference = 'Stop';


# ================================================================================
# ===
# ===   Type Declarations
# ===


# ================================================================================
# ===
# ===   Class Declarations
# ===


# ================================================================================
# ===
# ===   Function Declarations
# ===


# ================================================================================
# ===
# ===   Main
# ===

if (!$configFile) {

	Write-Host 'No config file was specified!';
	exit 2;
}

if (!$targetDir) {

	Write-Host 'No target directory was specified!';
	exit 3;
}

[String] $resolvedConfigFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( $configFile );
[String] $resolvedTargetDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( $targetDir );
[String] $resolvedSelectionsFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( $SELECTIONS_FILE );

[RepositoryHelper]::downloadResources($resolvedConfigFile, $resolvedTargetDir, $resolvedSelectionsFile, $TRUE);
return $resolvedSelectionsFile;
