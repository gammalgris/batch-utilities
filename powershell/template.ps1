#
#   @date dd.mm.yyyy
#
#   {preamble and purpose of the script}
#
#   @author {an author}
#


# ================================================================================
# ===
# ===   Environment and execution settings
# ===

Set-StrictMode -Version Latest


# ================================================================================
# ===
# ===   Constant Declarations
# ===

Set-Variable TIMESTAMP_PATTERN -option Constant -scope Global -value ([String]("yyyy-mm-dd hh:mm:ss"));

Set-Variable LOGFILE_PATTERN -option Constant -scope Global -value ([String]("yyyy-mm-dd__hh-mm-ss"));
Set-Variable LOGS_SUBFOLDER -option Constant -scope Global -value ([String]("logs"));


# ================================================================================
# ===
# ===   Variable Declarations
# ===

Set-Variable logfileName -option AllScope -scope Global -value ([String](""));


# ================================================================================
# ===
# ===   Type Declarations
# ===

$OutputChannel = @'
public Enum OutputChannel {

	ERROR;
	INFO;
	WARNING;
	DEBUG;

}'@
Add-Type -TypeDefinition $OutputChannel

# ================================================================================
# ===
# ===   Function Declarations
# ===

<#
	.DESCRIPTION
		Initializes the logging mechanism (i.e. logging to a file).

	.SYNOPSIS
		Initializes the logging mechanism.
#>
function initLogging() {

	if ( !(Test-Path -Path $LOGS_SUBFOLDER) ) {

		New-Item -ItemType directory -Path $LOGS_SUBFOLDER;
	}

	[String] $fileName = "" + $env:ComputerName + "__";
	$fileName = $fileName + (createCurrentTimestamp $LOGFILE_PATTERN);
	$fileName = $fileName + ".log";

	$logfileName = $LOGS_SUBFOLDER + "\" + $fileName;
}


<#
	.DESCRIPTION
		Creates a timestamp that corresponds with the time of invocation.

	.SYNOPSIS
		Creates a timestamp.

	.PARAMETER datepattern
		The parameter must contain a date pattern (e.g. "yyyy.MM.dd").
#>
function createCurrentTimestamp() {

	param(
		[Parameter(Mandatory = $true)]
		[String]
		$datepattern
	)

	Process {

		[String] $timestamp = get-date -f $datepattern;
		return $timestamp
	}

}


<#
	.DESCRIPTION
		Returns the maximum length of output channel names (see enumeration).

	.SYNOPSIS
		Returns the maximum length of output channel names.
#>
function getMaxLength() {

	Process {

		[int] $maxLength = 0;

		foreach ( $item in [enum]::GetValues('OutputChannel') ) {

			[int] $length = $item.ToString().Length;
			if ( $length -gt $maxLength ) {

				$maxLength = $length;
			}
		}

		return $maxLength;
	}

}


<#
	.DESCRIPTION
		Normalizes the specified Message (i.e. adds some additional information).

	.SYNOPSIS
		Normalizes the specified Message.

	.PARAMETER aCategory
		The parameter contains a message category.

	.PARAMETER aMessage
		The parameter constains a message text.
#>
function normalizeMessage() {

	param(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]
		$aCategory,

		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]
		$aMessage
	)

	Process {

		[String] $timestamp = createCurrentTimestamp $TIMESTAMP_PATTERN;
		[String] $normalizedMessage = $timestamp + "  $env:UserName  " + $aCategory;

		[int] $requiredSpaces = (getMaxLength) - $aCategory.Length;

		for ( [int] $a = 0; $a -lt $requiredSpaces; $a++ ) {

			$normalizedMessage = $normalizedMessage + " ";
		}

		$normalizedMessage = $normalizedMessage + " :: $aMessage";
		return $normalizedMessage;
	}

}


<#
	.DESCRIPTION
		Writes the specified info message.

	.SYNOPSIS
		Writes the specified info message.

	.PARAMETER aMessage
		The parameter constains an info message.
#>
function logInfo() {

	param(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]
		$aMessage
	)

	Process {

		[String] $normalizedMessage = normalizeMessage ([OutputChannel]::INFO) $aMessage;
		Tee-Object -Append -FilePath $logfileName -InputObject $normalizedMessage;
	}

}

<#
	.DESCRIPTION
		Writes the specified debug message.

	.SYNOPSIS
		Writes the specified debug message.

	.PARAMETER aMessage
		The parameter constains a debug message.
#>
function logDebug() {

	param(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]
		$aMessage
	)

	Process {

		[String] $normalizedMessage = normalizeMessage ([OutputChannel]::DEBUG) $aMessage;
		Tee-Object -Append -FilePath $logfileName -InputObject $normalizedMessage;
	}

}


<#
	.DESCRIPTION
		Writes the specified warning message.

	.SYNOPSIS
		Writes the specified warning message.

	.PARAMETER aMessage
		The parameter constains a warning message.
#>
function logWarning() {

	param(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]
		$aMessage
	)

	Process {

		[String] $normalizedMessage = normalizeMessage ([OutputChannel]::WARNING) $aMessage;
		Tee-Object -Append -FilePath $logfileName -InputObject $normalizedMessage;
	}

}


<#
	.DESCRIPTION
		Writes the specified error message.

	.SYNOPSIS
		Writes the specified error message.

	.PARAMETER aMessage
		The parameter constains an error message.
#>
function logError() {

	param(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]
		$aMessage
	)

	Process {

		[String] $normalizedMessage = normalizeMessage ([OutputChannel]::ERROR) $aMessage;
		Tee-Object -Append -FilePath $logfileName -InputObject $normalizedMessage;
	}

}


# ================================================================================
# ===
# ===   Main
# ===

initLogging;

logError "Hallo Welt!";
logInfo "Hallo Welt!";
logWarning "Hallo Welt!";
logDebug "Hallo Welt!";
