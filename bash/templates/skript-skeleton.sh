#!/bin/bash


#################################################################################
#
# Initialization
#

#================================================================================
#
# Function Declarations
#

#--------------------------------------------------------------------------------
#
# void newStdoutLogfile ()
#
# Creates a file name for the stdout log file and prints it to the console. The
# file name contains a timestamp.
#
function newStdoutLogfile ()
{
	echo "$(hostname)_$(date '+%Y%m%d_%H%M%S')_stdout.log"
	return
}

#--------------------------------------------------------------------------------
#
# void newStderrLogfile ()
#
# Creates a file name for the stderr log file and prints it to the console. The
# file name contains a timestamp.
#
function newStderrLogfile ()
{
	echo "$(hostname)_$(date '+%Y%m%d_%H%M%S')_stderr.log"
	return
}


#================================================================================
#
# Constant Declarations
#

LOG_FILE=$(newStdoutLogfile)
echo DEBUG:: LOG_FILE=$LOG_FILE

ERRORLOG_FILE=$(newStderrLogfile)
echo DEBUG:: ERRORLOG_FILE=$ERRORLOG_FILE

EMAIL_FILE=emails.txt
echo DEBUG:: EMAIL_FILE=$EMAIL_FILE


EMAIL_FILE=mails.txt
MAIL_COMMAND=mail


#================================================================================
#
# Initializing the Environment
#

exec >$LOG_FILE 2>$ERRORLOG_FILE


#################################################################################
#
# Function Declarations
#

#--------------------------------------------------------------------------------
#
# void timestamp ()
#
# Determines the current time and creates a timestamp which is then printed to
# the console.
#
function timestamp ()
{
	echo "$(date '+%Y-%m-%d_%H:%M:%S')"
	return
}


#--------------------------------------------------------------------------------
#
# void logInfo (String aMessage)
#
# Writes the specified message to the stdout logfile.
#
#
# @param aMessage
#        the message which should to be logged
#
function logInfo ()
{
	local ts=$(timestamp)
	echo $ts $*
	return
}


#--------------------------------------------------------------------------------
#
# void logError (String aMessage)
#
# Writes the specified message to the stderr logfile.
#
#
# @param aMessage
#        the error message which should be logged
#
function logError ()
{
	local ts=$(timestamp)
	echo $ts $* 1>&2
	return
}


#--------------------------------------------------------------------------------
#
# void logAction (String aMessage)
#
# Logs the specified message to the stdout logfile and stderr logfile.
#
#
# @param aMessage
#        the message which should be logged
#
function logAction ()
{
	logInfo $*
	logError $*
	return
}


#--------------------------------------------------------------------------------
#
# void getEmailAddresses ()
#
# Reads all email addresses from a separate text file (i.e. a text file which
# contains one email address per line). All email addresses are then printed as
# comma separated list to the console.
#
function getEmailAddresses ()
{
	logAction "call "${FUNCNAME[0]}"()"
	local functionName="("${FUNCNAME[0]}")"

	if [ ! -f $EMAIL_FILE ]
	then
		logError $functionName" The file "$EMAIL_FILE" which should contain all email addresses doesn´t exist!"
		return 2
	fi

	less $EMAIL_FILE | awk -vORS=, '{ print $1 }' | sed 's/,$/\n/'

	return
}


#--------------------------------------------------------------------------------
#
# void mailFile (String allRecipients, String aText, String aFilename)
#
#
# Sends an email to all specified recipients with the specified text and attaches
# the specified file.
#
#
# @param allRecipients
#        a comma spearated list of email addresses
# @param aText
#        an additional text which is to be sent
# @param aFilename
#        the path to a file which is to be sent
#
function mailFile ()
{
	logAction "call "${FUNCNAME[0]}"()"
	local functionName="("${FUNCNAME[0]}")"

	if [ $# -eq 0 ]
	then
		logError $functionName" No recipients were specified!"
		return 2
	fi

	if [ $# -eq 1 ]
	then
		logError $functionName" No text was specified!"
		return 3
	fi

	if [ $# -eq 2 ]
	then
		logError $functionName" No file has been specified!"
		return 4
	fi

	$MAIL_COMMAND -s $2 $1 < $3

	return
}


#################################################################################
#
# void main(String... allCommandLineParameters
#
# The actual script body.
#
#
# @param allCommandLineParameters
#        all command line parameters
#

recipients=$(getEmailAddresses)
if [ $? -ne 0 ]
then
	logError "An error occurred!"
	exit 2
fi


command[1]="do something "$MOUNT_NAME
# ToDo - add more actions
command[2]="mailFile "$recipients" stderr-log "$ERRORLOG_FILE
command[3]="mailFile "$recipients" stdout-log "$LOG_FILE


for (( i = 1; i <= 3; i++ ))
do
	${command[$i]}
	if [ $? -ne 0 ]
	then
		logError "An error occurred!"
		exit 3
	fi
done
