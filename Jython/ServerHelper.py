import wl


def getServer(serverName):
	"""
	Returns the server with the specified name.

	@type  serverName: String
	@param serverName: the name of a managed server

	@rtype:            javax.management.MBeanServerInvocationHandler
	@return:           a managed server
	"""

	previousPath = wl.pwd()

	wl.serverConfig()
	wl.cd('/Servers')

	serverList = wl.cmo.getServers()
	for server in serverList:

		actualName = server.getName()

		if actualName==serverName:
			wl.cd(previousPath)
			return server

	wl.cd(previousPath)

	raise NameError('The server \'' + serverName + '\' doesn\'t exist!')



def getServerState(serverName):
	"""
	Returns the state of the server with the specified name.

	Following server states exist:
		SHUTDOWN
		STARTING
		RUNNING
		FORCE_SUSPENDING
		FAILED_NOT_RESTARTABLE

	@type  serverName: String
	@param serverName: the name of a managed server

	@rtype:            String
	@return:           the managed server's current state
	"""

	currentPath = wl.pwd()

	wl.domainRuntime()
	bean = wl.cmo.lookupServerLifeCycleRuntime(serverName)
	status = bean.getState()

	wl.cd(currentPath)

	return status



def isServerState(serverName, expectedState):
	"""
	Checks the server's state.

	@type     serverName: String
	@param    serverName: the name of a managed server
	@type  expectedState: String
	@param expectedState: the expected state

	@rtype:               Boolean
	@return:              True if the specified state matches the managed server's actual
	                      state, else False
	"""

	actualState = getServerState(serverName)

	if actualState==expectedState:
		return True
	else:
		return False



def getWebService(serviceName):
	"""
	Returns the server with the specified name.

	@type  serviceName: String
	@param serviceName: the name of a web service

	@rtype:             javax.management.MBeanServerInvocationHandler
	@return:            a service
	"""

	currentPath = wl.pwd()

	wl.serverConfig()
	wl.cd('/AppDeployments')

	servicesList = wl.cmo.getAppDeployments()
	for service in servicesList:

		actualName = service.getName()
		if actualName==serviceName:
			wl.cd(currentPath)
			return service

	wl.cd(currentPath)

	raise NameError('The service \'' + serviceName + '\' doesn\'t exist!')



def getWebServiceState(serviceName):
	"""
	Returns the state of the server with the specified name.

	Following service states exist:
		STATE_ACTIVE
		STATE_PREPARED
		STATE_FAILED

	@type  serviceName: String
	@param serviceName: the name of a web service

	@rtype:             String
	@return:            the service's current state
	"""

	currentPath = wl.pwd()


	wl.domainConfig()

	try:
		wl.cd ('/AppDeployments/' + serviceName + '/Targets')
	except:
		wl.cd(currentPath)
		raise NameError('No web service with the name \'' + serviceName + '\' exists!')

	mytargets = wl.ls(returnMap='true')


	wl.domainRuntime()
	wl.cd('/AppRuntimeStateRuntime/AppRuntimeStateRuntime')

	for targetinst in mytargets:
		status = wl.cmo.getCurrentState(serviceName,targetinst)
		wl.cd(currentPath)
		return status

	wl.cd(currentPath)

	raise AttributeError('No status could be determined for the service \'' + serviceName + '\'!')



def isWebServiceState(serviceName, expectedState):
	"""
	Checks the server's state.

	@type     serviceName: String
	@param    serviceName: the name of a web service
	@type   expectedState: String
	@param  expectedState: the expected state

	@rtype:                Boolean
	@return:               True if the specified state matches the web service's actual
	                       state, else False
	"""

	actualState = getWebServiceState(serviceName)

	if actualState==expectedState:
		return True
	else:
		return False



if __name__== "main":

	print 'This library cannot be executed!'
