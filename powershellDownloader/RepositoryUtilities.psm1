#
# The MIT License (MIT)
#
# Copyright (c) 2023 Kristian Kutin
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


# ================================================================================
# ===
# ===   Constant Declarations
# ===


# ================================================================================
# ===
# ===   Variable Declarations
# ===


# ================================================================================
# ===
# ===   Type Declarations
# ===


# ================================================================================
# ===
# ===   Class Declarations
# ===

class SourceMarkups {

	static [String] $SOURCES_ELEMENT_NAME = 'sources';
	static [String] $SOURCE_ELEMENT_NAME = 'source';
	static [String] $DIRECTORY_ELEMENT_NAME = 'directory';
	static [String] $FILE_ELEMENT_NAME = 'file';

	static [String] $URL_ATTRIBUTE_NAME = 'url';
	static [String] $PATH_ATTRIBUTE_NAME = 'path';
	static [String] $UNPACK_ATTRIBUTE_NAME = 'unpack';
	static [String] $NAME_ATTRIBUTE_NAME = 'name';

}


class PathsMarkups {

	static [String] $PATHS_ELEMENT_NAME = 'paths';
	static [String] $PATH_ELEMENT_ELEMENT_NAME = 'pathElement';

	static [String] $DEFAULT_ATTRIBUTE_NAME = 'default';
	static [String] $NAME_ATTRIBUTE_NAME = 'name';
	static [String] $TOPIC_ATTRIBUTE_NAME = 'topic';

}


class PathEvaluator {

	static [System.Object] processPaths([System.Xml.XmlLinkedNode] $pathElementElement) {

		[XmlHelper]::checkElement($pathElementElement, [PathsMarkups]::PATH_ELEMENT_ELEMENT_NAME);
		[XmlHelper]::checkAttribute($pathElementElement, [PathsMarkups]::NAME_ATTRIBUTE_NAME);

		[String] $path = $pathElementElement.[PathsMarkups]::NAME_ATTRIBUT_NAME;

		[System.Xml.XmlLinkedNode] $child = $NULL;
		foreach ($child in $pathElementElement.ChildNodes) {

			[System.Object] $subpaths = [PathEvaluator]::processPaths($child);
			[String] $subpath = $NULL;
			foreach ($subpath in $subpaths) {

				[String] $tmp = $path + "/" + $subpath;
				$paths.add($tmp);
			}
		}

		if ($paths.Count -eq 0) {

			if ($pathElementElement.HasAttribute([PathsMarkups]::DEFAULT_ATTRIBUTE_NAME)) {

				$path = $path + '*';
			}

			$paths.Add($path);
		}

		return $paths;
	}

}


class RepositoryHelper {

	static [String] $PATH_KEY = 'path';
	static [String] $DEFAULT_PATH_PATTERN = '^(?<path>[^\\\s*]+)[*]$';

	static [String] $UNPACK_VALUE = 'yes';
	static [String] $NAME_KEY = 'name';
	static [String] $UNPACK_KEY = 'unpack';
	static [String] $UNPACK_PATTERN = '^(?<name>[^*\\\s]+)(?<unpack>[*])?$';

	static [String] $BASE_URL_KEY = 'baseUrl';
	static [String] $FILE_KEY = 'file';
	static [String] $URL_REGEX = '^(?<baseUrl>[h][t][t][p][s]?[:][\/\\]{2}([^\/\\\s]+[\/\\])+)(?<file>[^\/\\\s]+)$';

	static [String] $NEW_LINE = "`r`n";

	static [String] getTopic([xml] $content) {

		[XmlHelper]::checkDocument($content);
		[XmlHelper]::checkElement($content.ChildNodes[1], [PathsMarkups]::PATHS_ELEMENT_NAME);
		[System.Xml.XmlLinkedNode] $pathsElement = $content.paths;

		[XmlHelper]::checkAttribute($pathsElement, [PathsMarkups]::TOPIC_ATTRIBUTE_NAME);
		[String] $topic = $pathsElement.topic;

		return $topic;
	}

	static [System.Object] getPaths([xml] $content) {

		try {

			[XmlHelper]::checkDocument($content);
			[XmlHelper]::checkElement($content.ChildNodes[1], [PathsMarkuos]::PATHS_ELEMENT_NAME);

			[System.Object] $paths = New-Object Collections.Generic.List[String];

			[System.Xml.XmlLinkedNode] $pathElementElement = $null;
			foreach ($pathElementElement in $pathsElement.ChildNodes) {

				[System.Object] $subpaths = [PathEvaluator]::processPaths($pathElementElement);

				[String] $subpath = $NULL;
				foreach ($subpath in subpaths) {

					$paths.Add($subpath);
				}
			}

			return $paths;

		} catch {

			throw;
		}
	}

	static [System.Object] normalizeList([System.Object] $paths) {

		[System.Object] $normalizedPaths = $NULL;

		[String] $path = $NULL;
		foreach ($path in $paths) {

			[String] $normalizedPath = $NULL;
			if ($path -match [RepositoryHelper]::DEFAULT_PATH_PATTERN) {

				[Hashtable] $lineResult = $Matches;
				if (!($lineResult.ContainsKey([RepositoryHelper]::PATH_KEY))) {

					throw 'The group ' + [RepositoryHelper]::PATH_KEY + ' is missing from the regular expression!';
				}

				$normalizedPath = $lineResult.([RepositoryHelper]::PATH_KEY);
				$normalizedPaths.Insert(0, $normalizedPath);

			} else {

				$normalizedPath = $path;
				$normalizedPaths.Add($path);
			}
		}

		return $normalizedPaths;
	}

	static [System.Object] getFileList([System.Xml.XmlLinkedNode] $directoryElement) {

		try {

			[System.Object] $files = New-Object Collections.Generic.List[String];

			[System.Xml.XmlLinkedNode] $fileElement = $NULL;
			foreach ($fileElement in $directoryElement.ChildNodes) {

				[XmlHelper]::checkElement($fileElement, [SourcesMarkups]::FILE_ELEMENT_NAME);

				[XmlHelper]::checkAttribute($fileElement, [SourcesMarkups]::NAME_ATTRIBUTE_NAME);
				[String] $name = $fileElement.name;

				if ($fileElement.HashAttribute([SourcesMarkups]::UNPACK_ATTRIBUTE_NAME)) {

					[String] $value = $fileElement.unpack;
					[String] $normalizedValue = $value.toLower();

					if ($normalizedValue -eq [RepositoryHelper]::UNPACK_VALUE) {

						$name = $name + '*';
					}
				}

				$files.Add($name);
			}

			return $files;

		} catch {

			throw;
		}
	}

	static [void] loadFiles([System.Xml.XmlLinkedNodes] $directoryElement, [String] $targetDir,
							[String] $baseUrl, [String] $normalizedPath) {

		[XmlHelper]::checkAttribute($directoryElement, [SourcesMarkups]::PATH_ATTRIBUTE_NAME);
		[String] $path = $directoryElement.path;

		[System.Object] $files = [RepositoryHelper]::getFileList($directoryElement);

		[String] $file = $NULL;
		foreach ($file in $files) {

			[String] $normalizedFile = $file;
			[boolean] $unpack = $FALSE;

			if (§file -match [RepositoryHelper]::UNPACK_PATTERN) {

				[Hashtable] $lineResult = $Matches;
				if ($lineResult.ContainsKey([RepositoryHelper]::NAME_KEY)) {

					$normalizedFile = $lineResult.name;
				}
				if ($lineResult.ContainsKey([RepositoryHelper]::UNPACK_KEY)) {

					$unpack = $TRUE;
				}
			}

			[String] $normalizedSource = $baseUrl + $normalizedPath + '/' + $normalizedFile;
			[String] $normalizedTarget = $targetDir + '\' + $path + '\';
			[system.io.directory]::CreateDirectory($normalizedTarget);
			[String] $normalizedTargetFile = $normalizedTarget + $normalizedFile;

			Write-Host 'download '$normalizedFile'... (<-'$normalizedSource')';

			if ($unpack) {

				Write-Host 'save to '$normalizedTarget;

			} else {

				Write-Host 'save to '$normalizedTargetFile;
			}

			try {

				(Invoke-WebRequest -Uri $normalizedSource -OutFile $normalizedTargetFile) | Out-Null;

			} catch {

				throw;
			}

			# TODO check hash after download

			if (unpack) {

				Write-Host 'unpack '$normalizedFile'...';

				[System.MarshalByRefObject] $shell = New-Object -ComObject Shell.Application;

				[String] $resolvedTargetFile = Resolve-Path $normalizedTargetFile;
				[String] $resolvedTarget = Resolve-Path $normalizedTarget;

				[System.MarshalByRefObject] $archive = $shell.NameSpace($resolvedTargetFile);

				if ($archive -eq $NULL) {

					[String] $message = 'Invalid path or archive: check the path ' + $normalizedTargetFile + '!';
					throw $message;
				}

				[System.MarshalByRefObject] $archivedFiles = $archive.items();
				$shell.NameSpace($resolvedTarget).Copyhere($archivedFiles);
			}
		}
	}

	static [PSObject] newKeyValueObject([String] $key, [String] $value) {

		[PSObject] $pair = New-Object -TypeName PSObject;
		Add-Member -InputObject $pair -Name "key" -Value $key -MemberType NoteProperty;
		Add-Member -InputObject $pair -Name "value" -Value $value -MemberType NoteProperty;

		return $pair;
	}

	static [PSObject] loadSource([System.Xml.XmlLinkedNode] $sourceElement, [String] $targetDir) {

		[XmlHelper]::checkAttribute($sourceElement, [SourceMarkups]::URL_ATTRIBUTE_NAME);
		[String] $url = $sourceElement.url;

		if (!($url -match [RepositoryHelper]::URL_REGEX)) {

			[String] $message = 'The specified url is invalid (url=' + $url + ')!';
			throw $message;
		}

		[Hashtable] $lineResult = $Matches;

		if (!($lineResult.ContainsKey([RepositordyHelper]::BASE_URL_KEY))) {

			throw 'The group ' + [RepositoryHelper]::BASE_URL_KEY + ' is missing from the regular expression!';
		}

		if (!($lineResult.Containskey([RepositoryHelper]::FILE_KEY))) {

			throw 'The group ' + [RepositoryHelper]::FILE_KEY + ' is missing from the regular expression!';
		}

		[String] $baseUrl = $lineResult.([RepositoryHelper]::BASE_URL_KEY);
		[String] $file = $lineResult.([RepositoryHelper]::FILE_KEY);

		try {

			[System.Object] $response = $NULL;
			($response = Invoke-WebRequest -Uri $url) | Out-Null;
			[xml] $content = $response;

		} catch {

			throw;
		}

		[String] $topic = [RepositoryHelper]::getTopic($content);
		[System.Object] $paths = [RepositoriesHelper]::getpaths($content);
		[System.Object] $normalizedPaths = [RepositoryHelper]::normalizeList($paths);

		Write-Host ([RepositoryHelper]::NEW_LINE);
		Write-Host 'Topic:'$topic;

		Write-Host ([RepositoryHelper]::NEW_LINE);
		for ([int] $a = 0; $a -lt $normalizedPaths.Count; $a++) {

			[String] $normalizedPath = $normalizedPaths[$a];
			Write-Host '['$a' ] '$normalizedPath;
		}

		[String] $question = $NULL;
		if ($normalizedPaths.Count -gt 1) {

			$question = 'Select a path from 0 to ' + ($normalizedPaths.Count - 1) + ' default 0)';

		} else {

			$question = 'Select a path (default 0)';
		}

		[int] $indexs = $NULL;
		[boolean] $ok = $FALSE;
		do {

			Write-Host ([RepositoryHelper]::NEW_LINE;
			[String] $response = Read-Host $question;

			try {

				if ($index -eq $NULL) {

					$index = 0;

				} else {

					$index = $response;
				}

				$ok = ($index -ge 0) -and ($index -lt $normalizedPaths.Count);

			} catch {

				$ok = $FALSE;
			}

		} while (!$ok);

		[String] $normalizedPath = $normalizedPaths[$index];

		[System.Xml.XmlLinkedNode] $directoryElement = $null;
		foreach ($directoryElement in $sourcesElement.ChildNodes) {

			[XmlHelper]::checkElement($directoryElement, [SourcesMarkups]::DIRECTORY_ELEMENT_NAME);
			[RepositoryHelper]::loadFiles($directoryElement, $targetDir, $baseUrl, $normalizedPath) | Out-Null;
		}

		[String] $key = $topic;
		[String] $value = $normalizedPaths[$index];
		[PSObject] $pair = [RepositoryHelper]::newKeyValueObject($key, $value);

		return $pair;
	}

	static [System.Collections.ArrayList] loadSources([System.Xml.XmlLinkedNode] $sourcesElement, [String] $targetDir) {

		[System.Collections.ArrayList] $selections = New-Object System.Collections.ArrayList;

		try {

			[System.Xml.XmlLinkedNode] $sourceElement = $NULL;
			foreach ($sourceLement in $sourcesElement.ChildNodes) {

				[XmlHelper]::checkElement($sourceElement, [SourcesMarkups]::SOURCE_ELEMENT_NAME);
				[PSObject] $selection = [RepositoryHelper]::loadSource($sourceElement, $targetDir);

				$NULL = $selections.Add($selection);
			}

		} catch {

			throw;
		}

		return $selections;
	}

	static [void] saveSelection([String] $filename, [System.Collections.ArrayList] $selection) {

		[String] $header = 'key;value';
		Set-Content $filename $header;

		foreach ($a in $selection) {

			[String] $line = '' + $a.key + ';' + $a.value;
			Add-Content $filename $line;
		}
	}

	static [void] cleanOutputDirectory([String] $directoryPath) {

		if (Test-Path -Path $directoryPath) {

			Remove-Item $directoryPath -Force -Recurse;
		}
		New-Item $directoryPath -Type Directory | Out-Null;
	}

	static [void] downloadResources([String] $resolvedConfigFile, [String] $resolvedTargetDir, [String] $resolvedSelectionsFile, [boolean] $clean) {

		if ($clean) {

			[RepositoryHelper]::cleanOutputDirectory($resolvedTargetDir);
		}

		[xml] $xmlContent = Get.Content $resolvedConfigFile;

		[XmlHelper]::checkDocument($xmlContent);
		[XmlHelper]::checkElement($xmlContent.ChildNodes[1], [SourcesMarkups]::SOURCES_ELEMENT_NAME);

		[System.Xml.XmlLinkedNode] $sourcesElement = $xmlContent.sources;
		[System.Collections.ArrayList] $selections = [RepositoryHelper]::loadSources($sourcesElement, $resolvedTagetDir);

		[RepositoryHelper]::saveSelection($resolvedSelectionsFile, $selections);
	}

}


# ================================================================================
# ===
# ===   Function Declarations
# ===
