#
# The MIT License (MIT)
#
# Copyright (c) 2022 Kristian Kutin
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


<#

	.DESCRIPTION
		The script compares the declared java classpaths within the specified
		input files and returns a summary.
			
	.SYNOPSIS
		The script compares the classpaths within the specified input files.
	
	.PARAMETER configFile
		An input file (i.e. a batch script) which contains the declaration of a
		classpath.
				
#>

param(

	[String]
	$configFile

)


#===============================================================================
#===
#===	Global Variables and Constants
#===

$ErrorActionPreference = 'Stop';


#===============================================================================
#===
#===	Class Declarations
#===

class ConfigMarkups {

	static [String] $CONFIG_ELEMENT_NAME = 'config';
	static [String] $CLASSPATH_ELEMENT_NAME = 'classpath';
	static [String] $FILE_ELEMENT_NAME = 'file';
	static [String] $VARIABLE_ELEMENT_NAME = 'variable';
	static [String] $REMOVE_ELEMENT_NAME = 'remove';
	static [String] $ENTRY_ELEMENT_NAME = 'entry';

}


#===============================================================================
#===
#===	Function Declarations
#===

function getRemovableEntriesList() {

	param(
		[Parameter(Mandatory = $true)]
		[System.Xml.XmlLinkedNode]
		$removeElement
	)

	[XmlHelper]::checkElement($removeElement, [ConfigMarkups]::REMOVE_ELEMENT_NAME);

	[System.Object] $list = New-Object Collections.Generic.List[String];

	[System.Xml.XmlLinkedNode] $entryElement = $null;
	foreach ($entryElement in $removeElement.ChildNodes) {

		[XmlHelper]::checkElement($entryElement, [ConfigMarkups]::ENTRY_ELEMENT_NAME);
		$list.Add($entryElement.InnerText);
	}

	return $list;
}


function getList() {

	param(
		[Parameter(Mandatory = $true)]
		[System.Xml.XmlLinkedNode]
		$classpathElement
	)

	[XmlHelper]::checkElement($classpathElement, [ConfigMarkups]::CLASSPATH_ELEMENT_NAME);

	Try {

		[XmlHelper]::checkElement($classpathElement.ChildNodes[0], [ConfigMarkups]::FILE_ELEMENT_NAME);
		[String] $file = $classpathElement.file;
		[XmlHelper]::checkElement($classpathElement.ChildNodes[1], [ConfigMarkups]::VARIABLE_ELEMENT_NAME);
		[String] $variable = $classpathElement.variable;

		[System.Object] $remove = getRemovableEntriesList $classpathElement.remove;

		[System.Object] $list = $null;
		$list = .\normalize-jcp.ps1 $file $variable;
		$list = .\normalize-paths.ps1 $list;

		[System.Object] $result = [Collections.Generic.List[String]]::new();

		[String] $entry = $null;
		foreach ($entry in $list) {

			$result.Add($entry);
		}

		foreach ($entry in $remove) {

			$result.remove($entry) | Out-Null;
		}


		return $result;

	} catch {

		throw;
	}
}


#===============================================================================
#===
#===	Main Block
#===

if (!$configFile) {

	Write-Host 'No config file was specified!';
	exit 2;
}


[String] $resolvedConfigFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( $configFile );

[xml] $xmlContent = Get-Content $resolvedConfigFile
[XmlHelper]::checkDocument($xmlContent);

[System.Xml.XmlLinkedNode] $configElement = $xmlContent.ChildNodes[1];
[XmlHelper]::checkElement($configElement, [ConfigMarkups]::CONFIG_ELEMENT_NAME);
[XmlHelper]::checkChildNodes($configElement, 2);

[System.Object] $list1 = getList ($configElement.classpath[0]);
[System.Object] $list2 = getList ($configElement.classpath[1]);
[PSCustomObject] $diff = Compare-Object -ReferenceObject $list1 -DifferenceObject $list2;

if (!$diff) {

	return $true;

} else {

	return $false;
}
