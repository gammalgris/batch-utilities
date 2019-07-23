from time import sleep

import ServerHelper
import DeploymentHelper


server = 'albatros01'
service = 'TestServices'
file = 'D:\Workspace\TestServices\deployment\TestServices.ear'


serverState = ServerHelper.getServerState(server)
if serverState == 'RUNNING':
	print ServerHelper.getServerState(server)
else:
	raise EnvironmentError('The server \'' + server + '\' is not running!')


edit()
startEdit()


undeployRequired = True;

try:
	ServerHelper.getWebService(service)
except:
	print 'The web service \'' + service + '\' does not exist.'
	undeployRequired = False


if undeployRequired:
	if ServerHelper.isWebServiceState(service, 'STATE_ACTIVE'):
		DeploymentHelper.stopWebService(service)
	else:
		print 'The web service \'' + service + '\' is not running.'
		DeploymentHelper.undeployWebService(service)


sleep(10)


DeploymentHelper.deployWebService(service, file, server)
DeploymentHelper.startWebService(service)

activate(60000, block='true')
