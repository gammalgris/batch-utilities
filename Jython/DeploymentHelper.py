#
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Kristian Kutin
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

"""

WebLogic Version: 12.1.2.0.0

"""

import wl
import traceback


DEFAULT_TIMEOUT = 30000


def stopWebService(serviceName):
	"""
	Stops the specified web service.

	@type  serviceName: String
	@param serviceName: the name of a web service
	"""

	printStartAction('Stop ' + serviceName)

	try:
		wl.stopApplication(serviceName, block='true')
	except:
		print 'Unable to stop ' + serviceName + '!'
		traceback.print_exc()
		raise

	printStopAction()



def undeployWebService(serviceName):
	"""
	Undeploys the specified web service.

	@type  serviceName: String
	@param serviceName: the name of a web service
	"""

	printStartAction('Undeploy ' + serviceName)

	try:
		wl.undeploy(serviceName, block='true')
	except:
		print 'Unable to undeploy ' + serviceName + '!'
		traceback.print_exc()
		raise

	printStopAction()



def deployWebService(serviceName, earFile, server):
	"""
	Deploys the specified web service.

	@type  serviceName: String
	@param serviceName: the name of a web service
	@type      earFile: String
	@param     earFile: the path of a .ear archive
	@type       server: String
	@param      server: the name of a managed server
	"""

	printStartAction('Deploy ' + serviceName)

	try:
		wl.deploy(serviceName, path=earFile, targets=server, upload='true')
	except:
		print 'Unable to deploy ' + serviceName + '!'
		traceback.print_exc()
		raise

	printStopAction()



def startWebService(serviceName):
	"""
	Starts the specified web service.

	@type  serviceName: String
	@param serviceName: the name of a web service
	"""

	printStartAction('Start ' + serviceName)

	try:
		wl.startApplication(serviceName, timeout=DEFAULT_TIMEOUT)
	except:
		print 'Unable to start ' + serviceName + '!'
		traceback.print_exc()
		raise

	printStopAction()



def printStartAction(action):
	"""
	Print before an action.

	@type  action: String
	@param action: the name of an action
	"""

	print ''
	print ''
	print action + '...'
	print ''



def printStopAction():
	"""
	Print at the end of an action.
	"""

	print ''



if __name__== "main":

	print 'This library cannot be executed!'
