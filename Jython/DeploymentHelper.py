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
