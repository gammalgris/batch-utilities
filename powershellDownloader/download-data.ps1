
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
