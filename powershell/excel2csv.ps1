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

<#
	.DESCRIPTION
		The script extracts the content of the specified Excel document into
		one	or more CSV files which are placed in the specified output folder.

	.SYNOPSIS
		The script extracts an Excel document into CSV documents.

	.PARAMETER inputFile
		The parameter must contain a file path (relative or absolute).

	.PARAMETER outputDirectory
		The parameter must contain a directory path (relative or absolute).

	.PARAMETER worksheetName
		The parameter is optional and contains the name of the worksheet which
		is to be extracted.
#>

param(
	[String]
	$inputFile,

	[String]
	$outputDirectory,

	[String]
	$worksheetName

)


# ================================================================================
# ===
# ===   Constant Declarations
# ===

Set-Variable DEFAULT_ERROR_HANDLING -option Constant -scope Global -value ([String]($ErrorActionPreference));
Set-Variable HALT_ON_ALL_ERRORS -option Constant -scope Global -value ([String]("Stop"));

Set-Variable CSV_FILE_SUFFIX -option Constant -scope Global -value ([String](".csv"));


# ================================================================================
# ===
# ===   Function Declarations
# ===

<#
	.DESCRIPTION
		Checks if the specified file path exists and returns true. Else false is
		returned.

	.SYNOPSIS
		Checks if the file exists.

	.PARAMETER path
		A relative or absolute file path.
#>
function existsFile() {

	param(
		[Parameter(Mandatory = $true)]
		[String]
		$path
	)

	Process {

		[boolean] $result = Test-Path -Path $path -PathType leaf;

		return $result;
	}

}


<#
	.DESCRIPTION
		Checks if the specified directory path exists and returns true. Else false is
		returned.

	.SYNOPSIS
		Checks if the directory exists.

	.PARAMETER path
		A relative or absolute file path.
#>
function existsDirectory() {

	param(
		[Parameter(Mandatory = $true)]
		[String]
		$path
	)

	Process {

		[boolean] $result = Test-Path -Path $path -PathType Container;

		return $result;
	}

}


<#
	.DESCRIPTION
		Instantiates a new instance of Excel and returns a handle to it.

	.SYNOPSIS
		Instantiates a new instance of Excel.
#>
function newExcelInstance() {

	Begin {

		$ErrorActionPreference = $HALT_ON_ALL_ERRORS;
	}

	Process {

		[System.__ComObject] $instance = New-Object -ComObject Excel.Application;
		$instance.Visible = $false;
		$instance.DisplayAlerts = $false;

		return $instance;
	}

	End {

		$ErrorActionPreference = $DEFAULT_ERROR_HANDLING;
	}

}


<#
	.DESCRIPTION
		Uses the specified Excel instance to load the specified document.

	.SYNOPSIS
		Loads an Excel document.

	.PARAMETER instance
		A handle to a Excel instance.

	.PARAMETER path
		A relative or absolute file path of the input file.
#>
function loadExcelDocument() {

	param(
		[Parameter(Mandatory = $true)]
		[System.__ComObject]
		$instance,

		[Parameter(Mandatory = $true)]
		[String]
		$path
	)

	Begin {

		$ErrorActionPreference = $HALT_ON_ALL_ERRORS;
	}

	Process {

		[System.MarshalByRefObject] $document = $instance.Workbooks.Open($path);

		return $document;
	}

	End {

		$ErrorActionPreference = $DEFAULT_ERROR_HANDLING;
	}

}


<#
	.DESCRIPTION
		Exports the specified Excel document as a set of CSV files.

	.SYNOPSIS
		Exports the Excel document as CSV files.

	.PARAMETER document
		The specified Excel document.

	.PARAMETER basePath
		A relative or absolute file path for output files.
#>
function exportDocumentAsCsv() {

	param(
		[Parameter(Mandatory = $true)]
		[System.MarshalByRefObject]
		$document,

		[Parameter(Mandatory = $true)]
		[String]
		$basePath
	)

	Begin {

		$ErrorActionPreference = $HALT_ON_ALL_ERRORS;
	}

	Process {

		foreach ($worksheet in $document.Worksheets) {

			saveWorksheetAsCsv $document $worksheet $basePath;
		}
	}

	End {

		$ErrorActionPreference = $DEFAULT_ERROR_HANDLING;
	}

}


<#
	.DESCRIPTION
		Exports the specified worksheet from the specified Excel document as a CSV file.

	.SYNOPSIS
		Exports worksheet from the Excel document as CSV file.

	.PARAMETER document
		The specified Excel document.

	.PARAMETER basePath
		A relative or absolute file path for output files.

	.PARAMETER worksheetName
		The name of a worksheet within the Excel document.
#>
function exportWorksheetAsCsv() {

	param(
		[Parameter(Mandatory = $true)]
		[System.MarshalByRefObject]
		$document,

		[Parameter(Mandatory = $true)]
		[String]
		$basePath,

		[Parameter(Mandatory = $true)]
		[String]
		$worksheetName
	)

	Begin {

		$ErrorActionPreference = $HALT_ON_ALL_ERRORS;
	}

	Process {

		[boolean] $found = $false;
		[System.MarshalByRefObject] $currentWorksheet = $null;

		foreach ($worksheet in $document.Worksheets) {

			$currentWorksheet = $worksheet;
			[String] $actualWorksheetName = $currentWorksheet.Name;

			if ($worksheetName -eq $actualWorksheetName) {

				$found = $true;
				break;
			}
		}

		if (!$found) {

			throw "No Worksheet with the name `"$worksheetName`" exists!";
		}

		saveWorksheetAsCsv $document $currentWorksheet $basePath;
	}

	End {

		$ErrorActionPreference = $DEFAULT_ERROR_HANDLING;
	}

}


<#
	.DESCRIPTION
		Save the specified worksheet as CSV file.

	.SYNOPSIS
		Exports an Excel worksheet as CSV files.

	.PARAMETER document
		The specified Excel document.

	.PARAMETER worksheet
		The specified Excel worksheet.

	.PARAMETER basePath
		A relative or absolute file path for output files.
#>
function saveWorksheetAsCsv() {

	param(
		[Parameter(Mandatory = $true)]
		[System.MarshalByRefObject]
		$document,

		[Parameter(Mandatory = $true)]
		[System.MarshalByRefObject]
		$worksheet,

		[Parameter(Mandatory = $true)]
		[String]
		$basePath
	)

	Begin {

		$ErrorActionPreference = $HALT_ON_ALL_ERRORS;
	}

	Process {

		$worksheet.Activate();

		[String] $name = $worksheet.Name;
		[String] $newPath = $basePath.TrimEnd("/") + "/" + $name + $CSV_FILE_SUFFIX;
		[String] $resolvedNewPath = [System.IO.Path]::GetFullPath( $newPath );

		$document.SaveAs($resolvedNewPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSVWindows);
	}

	End {

		$ErrorActionPreference = $DEFAULT_ERROR_HANDLING;
	}

}


<#
	.DESCRIPTION
		Close the specified Excel instance.

	.SYNOPSIS
		Close the specified Excel instance.

	.PARAMETER instance
		A handle to an Excel instance.

#>
function closeExcelInstance() {

	param(
		[Parameter(Mandatory = $true)]
		[System.__ComObject]
		$instance
	)

	Begin {

		$ErrorActionPreference = $HALT_ON_ALL_ERRORS;
	}

	Process {

		$instance.Quit();
		while ( [System.Runtime.Interopservices.Marshal]::ReleaseComObject($instance) ) {};
		[System.GC]::Collect()
	}

	End {

		$ErrorActionPreference = $DEFAULT_ERROR_HANDLING;
	}
}


# ================================================================================
# ===
# ===   Main
# ===

if (!$inputFile) {

	Write-Host "No input file has been specified!";
	exit 1;
}

if (!$outputDirectory) {

	Write-Host "No output directory has been specified!";
	exit 2;
}


[String] $resolvedPath = [System.IO.Path]::GetFullPath( $inputFile );
[boolean] $fileExists = existsFile $resolvedPath;
if (!($fileExists)) {

	Write-Host "The file"$resolvedPath" doesn't exist!";
	exit 3;
}

[String] $resolvedOutputPath = [System.IO.Path]::GetFullPath( $outputDirectory );
[boolean] $directoryExists = existsDirectory $resolvedOutputPath;
if (!($directoryExists)) {

	Write-Host "The directory"$resolvedOutputPath" doesn't exist!";
	exit 4;
}


[System.__ComObject] $excelInstance = newExcelInstance;
[System.MarshalByRefObject] $excelDocument = loadExcelDocument $excelInstance $resolvedPath;

try {

	if (!$worksheetName) {

		exportDocumentAsCsv $excelDocument $resolvedOutputPath;

	} else {

		exportWorksheetAsCsv $excelDocument $resolvedOutputPath $worksheetName;
	}

} catch {

	Write-Host $_;
	exit 5;

} finally {

	closeExcelInstance $excelInstance;
}
