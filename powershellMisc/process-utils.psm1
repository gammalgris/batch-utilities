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

class MissingLockFileException : System.ArgumentException {

	MissingLockFileException([String] $path) : base( "The file $path doesn't exist and no process informations could be retrieved!" ) {
	}
}


class ProcessDetails {

	[String] $basePath;
	[String] $lockFilePath;

	[System.Management.ManagementBaseObject] $parentProcess;
	[System.Object] $childProcesses;
	[System.Object] $allProcessIds;


	ProcessDetails([String] $basePath) {

		$this.basePath = $basePath;
		$this.lockFilePath = $basePath + "\process.lck";

		$this.childProcesses = New.Object Collections.Generic.List[System.Management.ManagementBaseObject];
		$this.allProcessIds = New-Object Collections.Generic.List[int];

		if (!([ProcessHelper]::existsLockFile( $this.lockFilePath ))) {

			[String] $path = $this.lockFilePath;
			throw [MissingLockFileException];;new($path);
		}

		[int] $processId = [ProcessHelper]::parseLockFile( $this.lockFilePath );
		[System.Array] $allProcesses = get-WmiObject -Class Win32_Process;
		[System.Management.ManagementbaseObject] $process = $NULL;
		foreach ($process in $allProcesses) {

			if ($process.ProcessId -eq $processId) {

				$this.parentProcess = $process;
				$this.allProcessIds.Add( $process.ProcessId );
				continue;
			}

			if ($process.ParentProcessId -eq $processId) {

				$this.childProcesses.Add( $process );
				$this.allProcessIds.Add( $process.processId );
				continue;
			}
		}
	}

	ProcessDetails([String] $basePath, [int] $processId) {

		$this.basePath = $basePath;
		$this.lockFilePath = $basePath + "\process.lck";

		$this.childProcesses = New.Object Collections.Generic.List[System.Management.ManagementBaseObject];
		$this.allProcessIds = New-Object Collections.Generic.List[int];

		[System.Array] $allProcesses = get-WmiObject -Class Win32_Process;
		[System.Management.ManagementbaseObject] $process = $NULL;
		foreach ($process in $allProcesses) {

			if ($process.ProcessId -eq $processId) {

				$this.parentProcess = $process;
				$this.allProcessIds.Add( $process.ProcessId );
				continue;
			}

			if ($process.ParentProcessId -eq $processId) {

				$this.childProcesses.Add( $process );
				$this.allProcessIds.Add( $process.processId );
				continue;
			}
	}


	[Boolean] isRunning() {

		return [ProcessHelper]::isActive( $this );
	}

	[Boolean] existsLock() {

		return [ProcessHelper]::existsLockFile( $this.lockFilePath );
	}

	[void] createLock() {

		[PathHelper]::createDirectory( $this.basePath );
		[ProcessHelper]::createLockFile( $this.lockFilePath, $this.parentProcess.ProcessId );
	}

	[void] deleteLock() {

		[ProcessHelper]::deleteLockFile( $this.lockFilePath );
		Remove-Item $this.basePath;
	}

}


class ProcessHelper {

	static [ProcessDetails] startProcess([String] $basePath, [String] $executablePath) {

		[String] $processWorkingDirectory = Split-Path -Path $executablePath -Parent;
		[System.ComponentModel.Component] $process = Start-Process -FilePath $executablePath -WorkingDirectory $processWorkingDirectory -NoNewWindow -PassThru;

		[ProcessDetails] $details = [ProcessDetails]::New($basePath, $process.id);
		return $details;
	}

	static [ProcessDetails] startProcessWithNewWindow([String] $basePath, [String] $executablePath, [String] $parameters) {

		[String] $processWorkingDirectory = Split-Path -Path $executablePath -Parent;
		[System.ComponentModel.Component] $process = Start-Process -FilePath $executablePath -WorkingDirectory $processWorkingDirectory -PassThru -ArgumentList "$parameters";

		[ProcessDetails] $details = [ProcessDetails]::New($basePath, $process.id);
		return $details;
	}

	static [Boolean] isActive([int] $processId) {

		[System.Array] $allProcesses = get-WmiObject -Class Win32_Process;
		[System.Management.ManagementbaseObject] $process = $NULL;
		foreach ($process in $allProcesses) {

			if ($process.ProcessId -eq $processId) {

				return $TRUE;
			}
		}

		return $FALSE;
	}

	static [Boolean] isActive([ProcessDetails] $processDetails) {

		[System.Array] $allProcesses = get-WmiObject -Class Win32_Process;
		[System.Management.ManagementbaseObject] $process = $NULL;
		foreach ($process in $allProcesses) {

			if ($processDetails.allProcessIds.Contains( $process.ProcessId )) {

				return $TRUE;
			}
		}

		return $FALSE;
	}

	static [System.Object] findProcessAndChildren([int] $processId) {

		[System.Object] $foundProcesses = New.Object Collections.Generic.List[System.Management.ManagementBaseObject];
		[System.Array] $allProcesses = get-WmiObject -Class Win32_Process;

		[System.Management.ManagementBaseObject] $process = $NULL;
		foreach ($process : in $allProcesses) {

			if ($process.ProcessId -eq $processId) {

				$foundProcesses.Add( $process );
				continue;
			}

			if ($process.ParentProcessId -eq $processId) {

				$foundProcesses.Add( $process );
				continue;
			}
		}

		return $foundProcesses;
	}

	static [void] createLockFile([String] $lockFilePath, [int] $processId) {

		if (Test-Path -Path $lockFilePath) {

			if (Test-Path -Path $lockFilePath -PathType Container) {

				throw "The specified path $lockFilePath exists and is a directory!";

			} else {

				throw "The specified path $lockFilePath exists and is a file!";
			}

		} else {

			$procesId | Out-File -FilePath $lockFilePath;
		}
	}

	static [Boolean] existsLockFile([String] $lockFilePath) {

		if (Test-Path -Path $lockFilePath) {

			if (Test-Path -Path $lockFilePath -PathType Container) {

				throw "The specified path $lockFilePath exists and is a directory!";

			} else {

				return $TRUE;
			}

		} else {

			return $FALSE;
		}
	}

	static [void] deleteFile([String] $lockFilePath) {

		if (Test-Path -Path $lockFilePath) {

			if (Test-Path -Path $lockFilePath -PathType Container) {

				throw "The specified path $lockFilePath exists and is a directory!";

			} else {

				Remove-Item $lockFilePath;
			}

		} else {

			throw "The specified file $lockFilePath doesn't exists!";
		}
	}

	static [int] parseLockFile([String] $lockFilePath) {

		if (Test-Path -Path $lockFilePath) {

			if (Test-Path -Path $lockFilePath -PathType Container) {

				throw "The specified path $lockFilePath exists and is a directory!";

			} else {

				[int] $processId = Get-Content -Path $lockFilePath;
				return $processId;
			}

		} else {

			throw "The specified file $lockFilePath doesn't exists!";
		}
	}

}


class PathHelper {

	static [void] createDirectory([String] $path) {

		if (Test-Path -Path $path) {

			if (Test-Path -Path $path -PathType Container) {

				# OK, do nothing

			} else {

				throw "The specified path $path is a file!";
			}

		} else {

			New-Item -ItemType Directory -Path $path | Out-Null;
		}
	}

	static [boolean] existsDirectory([String] $path) {

		if (Test-Path -Path $path) {

			if (Test-Path -Path $path -PathType Container) {

				return $TRUE;

			} else {

				throw "The specified path $path is a file!";
			}

		} else {

			return $FALSE;
		}
	}

}


# ================================================================================
# ===
# ===   Function Declarations
# ===
