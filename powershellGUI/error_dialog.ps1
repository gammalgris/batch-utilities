
<#
	.DESCRIPTION
		Shows an error dialog. This can be used from within a batch script.

	.SYNOPSIS
		Shows an error dialog.

	.PARAM additionalDetails
		The error text which should be displayed in the error dialog
#>

param(
	[String]
	$additionalDetails
)


# ================================================================================
# ===
# ===   Initializations
# ===

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
Add-Type -AssemblyName PresentationFramework;


# ================================================================================
# ===
# ===   Main
# ===

[String] $errorMessage = "Error:: ";

if (![String]::IsNullOrEmpty($additionalDetails)) {

	$errorMessage = [System.String]::Concat($errorMessage, " (", $additionalDetails, ")");

}

$errorMessage = [System.String]::Concat($errorMessage, "!");


[String] $dialogResult = [System.Windows.Forms.MessageBox]::Show($errorMessage, "Error", 0, [System.Windows.Forms.MessageBoxIcon]::Error);
