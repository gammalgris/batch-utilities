
<#
	.DESCRIPTION
		Creates a shortcut according to the specified parameters.

	.SYNOPSIS
		Creates a shortcut.

	.PARAM shortcutName
		the name of the shortcut

	.PARAM shortcutDirectory
		the directory where the shortcut is to be places

	.PARAM targetPath
		the target path of the shortcut

	.PARAM iconPath
		the path to an icon file which is used for the shortcut

#>

param(
	[String]
	$shortcutName,

	[String]
	$shortcutDirectory,

	[String]
	$targetPath,

	[String]
	$iconPath
)


# ================================================================================
# ===
# ===   Initializations
# ===

Set-Variable DEFAULT_ERROR_HANDLING -option Constant -scope Global -value ([String]($ErrorActionPreference));
Set-Variable HALT_ON_ALL_ERRORS -option Constant -scope Global -value ([String]("Stop"));

$ErrorActionPreference = $HALT_ON_ALL_ERRORS;


# ================================================================================
# ===
# ===   Main
# ===

Write-Host "DEBUG:: shortcutName='$shortcutName'";
Write-Host "DEBUG:: shortcutDirectory='$shortcutDirectory'";
Write-Host "DEBUG:: targetPath='$targetPath'";
Write-Host "DEBUG:: iconPath='$iconPath'";


if ([String]::IsNullOrEmpty($shortcutName)) {

	Write-Host "ERROR: No shortcut name has been specified!";
	exit 2;
}

if ([String]::IsNullOrEmpty($shortcutDirectory)) {

	Write-Host "ERROR: No directory for the shortcut was specified!";
	exit 2;
}

if ([String]::IsNullOrEmpty($targetPath)) {

	Write-Host "ERROR: No target path has been specified!";
	exit 2;
}

if ([String]::IsNullOrEmpty($iconPath)) {

	Write-Host "INFO: No path to an icon was specified!";
}


[String] $shortcutPath = [System.String]::Concat($shortcutDirectory, "\", $shortcutName);

[System.MarshalByRefObject] $wshShell = New-Object -ComObject WScript.Shell;

[System.MarshalByRefObject] $shortcut = $wshShell.CreateShortcut($shortcutPath);
$shortcut.TargetPath = $targetPath;

if (![String]::IsNullOrEmpty($iconPath)) {

	$shortcut.IconLocation = $iconPath;
}

$shortcut.Save();
