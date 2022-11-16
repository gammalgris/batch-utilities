#
# The MIT License (MIT)
#
# Copyright (c) 2021 Kristian Kutin
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
# ===   Main - Parameter declarations that this script expects
# ===

Set-Variable DEFAULT_TIMEOUT -option Constant -scope Global -value ([int]60);


# ================================================================================
# ===
# ===   Function Declarations
# ===

<#
	.DESCRIPTION
		Starts the internet explorer and returns a handle for the instance.

	.SYNOPSIS
		Starts the internet explorer.
#>
function startInternetExplorer() {

	Process {

		[String] $applicationName = "InternetExplorer.Application";
		[System.__ComObject] $handle = New-Object -ComObject $applicationName;
		$handle.Visible = $True;

		return $handle;
	}

}


<#
	.DESCRIPTION
		Waits until the internet explorer is ready and returns the time in
		seconds the internet explorer was busy.

	.SYNOPSIS
		Waits until the internet explorer is ready.

	.PARAMETER handle
		A handle on an instance of the internet explorer.
#>
function waitUntilReady() {

	param (
		[Parameter(mandatory = $true)]
		[System.__ComObject]
		$handle
	)

	Process {

		[int] $waited = 0;

		while ($handle.Busy) {

			Start-Sleep -Seconds 1;
			$waited++;

			if ($waited -gt $DEFAULT_TIMEOUT) {

				throw "Timeout Exception: The page couldn't be loaded! The element woith the ID '$id' doesn't exists.";
			}
		}

		return $waited;
	}

}


<#
	.DESCRIPTION
		Waits until the HTML element with the specified ID exists within the
		current web page (which may still be loading). After a certain wait
		time a timeout exception is thrown.

	.SYNOPSIS
		Waits until a specific HTML element exists.

	.PARAMETER handle
		A handle on an instance of the internet explorer.

	.PARAMETER id
		The Id of a html element.
#>
function waitForElementById() {

	param (
		[Parameter(mandatory = $true)]
		[System.__ComObject]
		$handle,
		
		[Parameter(mandatory = $true)]
		[String]
		$id
	)

	Process {

		[int] $waited = waitUntilReady $handle;

		[mshtml.HTMLDocumentClass] $doc = $handle.Document;
		[bool] $loop = $true;

		while($loop) {

			$element = $doc.IHTMLDocument3_getElementByID($id);
			if (!$element) {

				Start-Sleep -Seconds 1;
				$waited++;

			} else {

				$loop = $false;
			}

			if ($waited -gt $DEFAULT_TIMEOUT) {

				throw "Timeout Exception: The page couldn't be loaded! The element woith the ID '$id' doesn't exists.";
			}
		}

		return $id;
	}
}

<#
	.DESCRIPTION
		Waits until one of the HTML elements with thespecified ID exists within the current
		web page (which may still be loading). After a certain wait time a timeout exception
		is thrown. Returns the ID of the HTML element which was identified.

	.SYNOPSIS
		Waits until a specific HTML Element exists.

	.PARAMETER ie
		A handle on an instance of the internet explorer

	.PARAMETER id1
		The ID of a html element.

	.PARAMETER id2
		The ID of a html element
#>
function waitForOneElementById() {

	param(
		[Parameter(mandatory = $true)]
		[System.__ComObject]
		$ie,

		[Parameter(mandatory = $true)]
		[String]
		$id1,

		[Parameter(mandatory = $true)]
		[String]
		$id2
	)

	Process {

		[int] $waited = waitUntilReady $ie;

		[mshtml.HTMLDocumentClass] $doc = $ie.Document;

		while ($true) {

			$element = $doc.IHTMLDocument3_getElementByID($id1);
			if ($element) {

				return $id1;
			}

			$element = $doc.IHTMLDocument3_getElementByID($id2);
			if ($element) {

				return $id2;
			}

			Start-Sleep -Seconds 1;
			$waited++;

			if ($waited -gt $DEFAULT_TIMEOUT) {

				throw "Timeout Exception: The page couldn't be loaded! No element with the ID '$id1' or '$id2' exists!";
			}
		}
	}

}


<#
	.DESCRIPTION
		Tries to retrieve a handle on the process identified by the console window handle (HNWD).

	.SYNOPSIS
		Tries to retrieve a handle on the process identified by the console window handle (HWND).

	.PARAMETER handle
		A console window handle
#>
function connectIExplorer() {

	param {
		$HWND
	}

	Process {

		$objectShellApp =New-Object -ComObject Shell.Application;

		try {

			$objNewIE = $objShellApp.Windows() | ?{$_.HWND -eq $HWND}
			$objNewIE.Visible = $true;

		} catch {

			# It may happen that the Shell.Application does not find the window in a timely manner.
			# Therefore wait and try again.
			Write-Host "Waiting for page to be loaded ..."
			Start-Sleep -Milliseconds 500

			try {

				$objNewIE = $objShellApp.Windows() | ?{$_.HWND -eq $HWND}
				$objNewIE.Visible = $true;

			} catch {

				Write-Host "Could not retrieve the Com Object InternetExplorer. Aborting!" -ForegroundColor Red
				$objNewIE = $null
			}
		}

		return $objNewIE
	}

}


# ================================================================================
# ===
# ===   Main
# ===

# example
#
# [System.__ComObject] $ie = startInternetExplorer;
# $hwnd = $ie.HWND;
# $ie.navigate("some URL");
#
# Start-Sleep -Milliseconds 1000;
# $ie = connectIExplorer $hwnd;
#
# [int] $waitTime = waitUntilReady $ie;
#
# [mshtml.HTMLDocumentClass] $doc = $ie.Document;
#
# waitForElementById $ie "some HTML element ID"
# $element = $doc.IHTMLDocument3_getElementByID("some HTML element ID");
#
# # if element is input field
# $element.value = some value
#
# # if element is link, image or button
# $element = click();
#
# [String] $foundID = waitForOneElementById $ie "some HTML element ID" "another HTML element ID";
# if ($foundID -eq "some HTML element ID") {
#	...
# } elseif ($foundID -eq "another HTML element ID")
# 	...
# }
