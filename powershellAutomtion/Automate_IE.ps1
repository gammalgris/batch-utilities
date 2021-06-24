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

	param {
		[Parameter(Mandatory = $True)]
		[System.__ComObject]
		$handle
	}

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

	param {
		[Parameter(Mandatory =$True)]
		[System.__ComObject]
		$handle,
		
		[Parameter(Mandatory =$True)]
		[String]
		$id
	}

	Process {

		[int] $waited = waitUntilReady $handle;

		[mshtml.HTMLDocumentClass] $doc = $handle.Document;
		[bool] $loop = $True;

		while($loop) {

			$element = $doc.IHTMLDocument3_getElementByID($id);
			if (!$element) {

				Start-Sleep -Seconds 1;
				$waited++;

			} else {

				$loop = $False;
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

	param {
		[Parameter(Mandatory =$True)]
		[System.__ComObject]
		$handle,
		
		[Parameter(Mandatory =$True)]
		[String]
		$id
	}

	Process {

		[int] $waited = waitUntilReady $handle;

		[mshtml.HTMLDocumentClass] $doc = $handle.Document;
		[bool] $loop = $True;

		while($loop) {

			$element = $doc.IHTMLDocument3_getElementByID($id);
			if (!$element) {

				Start-Sleep -Seconds 1;
				$waited++;

			} else {

				$loop = $False;
			}

			if ($waited -gt $DEFAULT_TIMEOUT) {

				throw "Timeout Exception: The page couldn't be loaded! The element woith the ID '$id' doesn't exists.";
			}
		}

		return $id;
	}

}


# ================================================================================
# ===
# ===   Main
# ===

