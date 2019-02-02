#
# The MIT License (MIT)
#
# Copyright (c) 2018 Kristian Kutin
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

# ================================================================================
# ===
# ===   Constant Declarations
# ===

Set-Variable YESTERDAY -option Constant -scope Global -value ([int]-1);


# ================================================================================
# ===
# ===   Function Declarations
# ===

<#
	.DESCRIPTION
		Gets all recent items (i.e. links to documents, pictures, etc. which where accessed
		most recently) for the current user.

	.SYNOPSIS
		Gets all recent items.
#>
function getRecentItems() {

	Process {

		[System.Array] $results = get-item "${env:USERPROFILE}\AppData\Roaming\Microsoft\Windows\Recent\*.lnk"

		return $results;
	}

}


<#
	.DESCRIPTION
		Takes an array of links and resolves the links to the respective target files. An array list with resolved links is returned.

	.SYNOPSIS
		Takes an array of links and resolves the links to the respective target files. An array list with resolved links is returned.

	.PARAMETER itemArray
		An array of links
#>
function transformLinkArray2FileArrayList() {

	param(
		[Parameter(Mandatory = $true)]
		[System.Array]
		$itemArray
	)

	Process {

		[System.Collections.ArrayList] $results = New-Object System.Collections.ArrayList;
		[System.MarshalByRefObject] $WshShell = New-Object -ComObject WScript.Shell;

		foreach ($item in $itemArray) {

			[System.MarshalByRefObject] $link = $WshShell.CreateShortcut($item);

			[String] $path = $link.TargetPath;
			if ([string]::IsNullOrEmpty($path)) {

				Write-Host "The link ("$link.FullName") cannot be resolved!";

			} elseif (Test-Path $link.TargetPath) {

				[System.IO.FileSystemInfo] $file = get-item $link.TargetPath;
				[void]$results.Add($file);

			} else {

				Write-Host "The link ("$link.TargetPath") doesn't exist any more!";
			}
		}

		return $results;
	}

}


<#
	.DESCRIPTION
		Takes an array list of files and checks which of the files have been accessed since yesterday (i.e. yesterday midnight). An array list
		with the files which were accessed during that time is returned.

	.SYNOPSIS
		Takes an array list of files and checks which of the files have been accessed since yesterday (i.e. yesterday midnight). An array list
		with the files which were accessed during that time is returned.

	.PARAMETER itemArray
		An array list of files
#>
function filterFiles() {

	param(
		[Parameter(Mandatory = $true)]
		[System.Collections.ArrayList]
		$files
	)

	Process {

		[System.Collections.ArrayList] $results = New-Object System.Collections.ArrayList;

		[DateTime] $midnight = Get-Date -Hour 00 -Minute 0 -Second 00;
		[DateTime] $threshold = $midnight.AddDays($YESTERDAY);

		foreach ($file in $files) {

			[DateTime] $lastAccess = $file.LastAccessTime;
			[bool] $wasRecentlyAccessed = $lastAccess -gt $threshold;

			if ($wasRecentlyAccessed) {

				[void]$results.Add($file);
			}
		}

		return $results;
	}

}


<#
	.DESCRIPTION
		Opens all specified documents with their default application.

	.SYNOPSIS
		Opens all specified documents with their default application.

	.PARAMETER itemArray
		An array list of files
#>
function openDocuments() {

	param(
		[Parameter(Mandatory = $true)]
		[System.Collections.ArrayList]
		$files
	)

	Process {

		foreach ($file in $files) {

			Write-Host "open file $file...";
			explorer $file;
		}
	}

}


# ================================================================================
# ===
# ===   Main
# ===

[System.Array] $recentItems = getRecentItems;
[System.Collections.ArrayList] $files = transformLinkArray2FileArrayList $recentItems;
[System.Collections.ArrayList] $filteredFiles = filterFiles $files;
openDocuments $filteredFiles;
