#
# The MIT License (MIT)
#
# Copyright (c) 2019 Kristian Kutin
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
