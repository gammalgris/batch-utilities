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

class AutomationHelper {

	[String] $applicationName;

	[String] $applicationPath;

	[System.ComponentModel.Component] $processHandle;

	[System.MarshalByRefObject] $wshell;

	AutomationHelper([String] $anApplicationName, [String] $anApplicationPath) {

		if ([string]::IsNullOrEmpty($anApplicationName)) {

			throw "No application name (NULL) was specified!";
		}

		$this.applicationName = $anApplicationName;

		if ([string]::IsNullOrEmpty($anApplicationPath)) {

			throw "No application path (NULL) was specified!";
		}

		$this.applicationPath = $anApplicationPath;
	}

	[void] startApplication() {

		if (!$this.processHandle) {

			$this.processHandle = Start-Process $this.applicationPath -PassThru;

			[String] $name = $NULL;
			while($TRUE) {

				$name = $this.processHandle.MainWindowTitle;
				Write-Host "DEBUG::MainWindowTitle=$name";
				Write-Host "DEBUG::Responding="$this.processHandle.Responding;

				if ([string]::IsNullOrEmpty($name) -eq $FALSE) {
					if ($name -eq $this.applicationName) {

						break;
					}
				}

				Start-Sleep -Milliseconds 500;
				$this.processHandle.Refresh();
			}

			[String] $name = $this.processHandle.MainWindowTitle
			Write-Host "DEBUG::MainWindowTitle=$name";

		} else {

			throw "A process has already been started!";
		}
	}

	[void] activateApplication() {

		if ($this.wshell -eq $NULL) {

			$this.wshell = New-Object -ComObject wscript.shell;
		}

		$this.wshell.AppActivate($this.applicationName);
	}

	[void] typeKey([String] $key) {

		if (!$key) {

			Write-Host "No key was specified! Doing nothing.";
		}

		$this.wshell.SendKeys($key);
	}

}
