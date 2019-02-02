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


# ================================================================================
# ===
# ===   Initializations
# ===

#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing");
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
Add-Type -AssemblyName PresentationFramework;


# ================================================================================
# ===
# ===   Constant Declarations
# ===

Set-Variable DEFAULT_ERROR_HANDLING -option Constant -scope Global -value ([String]($ErrorActionPreference));
Set-Variable HALT_ON_ALL_ERRORS -option Constant -scope Global -value ([String]("Stop"));


# ================================================================================
# ===
# ===   Function Declarations
# ===

<#
	.DESCRIPTION
		Returns the name of the currently active user.

	.SYNOPSIS
		Returns the name of a user.

	.PARAM filePath
		A file path to a WPF configuration file (absolute or relative).
#>
function newForm() {

	param(
		[Parameter(Mandatory = $true)]
		[String]
		$filePath
	)

	Begin {

		$ErrorActionPreference = $HALT_ON_ALL_ERRORS;
	}

	Process {

		[String] $resolvedPath = [System.IO.Path]::GetFullPath( $filePath );
		[xml] $xaml = Get-Content $resolvedPath;

		[System.Xml.XmlReader] $reader = (New-Object System.Xml.XmlNodeReader $xaml);
		[System.Windows.Controls.ContentControl] $window = [Windows.Markup.XamlReader]::Load($reader);
		return $window;
	}

	End {

		$ErrorActionPreference = $DEFAULT_ERROR_HANDLING;
	}

}


<#
	.DESCRIPTION
		Returns the name of the currently active user.

	.SYNOPSIS
		Returns the name of a user.
#>
function getUserName() {

	Process {

		[String] $username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
		$username = $username -creplace '^[^\\]*\\', '';

		return $username;
	}
}


# ================================================================================
# ===
# ===   Main
# ===

[System.Windows.Controls.ContentControl] $form = newForm "login_dialog.xml";
$form.Title = "Login to ?";

[System.Windows.Controls.Primitives.TextBoxBase] $userTextBox = $form.FindName("UserTextBox");
[System.Windows.Controls.Control] $passwordTextBox = $form.FindName("PaasswordTextBox");
[System.Windows.Controls.Primitives.ButtonBase] $loginButton = $form.FindName("LoginButton");
[System.Windows.Controls.Primitives.ButtonBase] $cancelButton = $form.FindName("CancelButton");

[String] $username = getUserName;
$userTextBox.Text = $username;


$cancelButton.Add_Click({
	$form.Close();
});

$loginButton.Add_Click({
	$form.DialogResult = $TRUE;
	$form.Close();
});


[boolean] $result = $form.showDialog();

if ($result) {

	# Do something
}

Write-Host $result;
