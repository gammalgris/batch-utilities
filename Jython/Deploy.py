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

from time import sleep

import ServerHelper
import DeploymentHelper


server = 'a-server-name'
service = 'a-service-or-application-name'
file = 'the-war-or-ear-file-path'


undeployRequired = True;
stopRequired = True;

try:
	ServerHelper.getWebService(service)
except:
	print 'The web service \'' + service + '\' does not exist.'
	undeployRequired = False
	stopRequired = False


if stopRequired:
	serverState = ServerHelper.getServerState(server)
	if serverState == 'RUNNING':
		print ServerHelper.getServerState(server)
		DeploymentHelper.stopWebService(service)

sleep(10)

if undeployRequired:
	DeploymentHelper.undeployWebService(service)


sleep(10)

edit()
startEdit()

DeploymentHelper.deployWebService(service, file, server)
DeploymentHelper.startWebService(service)

save()
stopEdit(defaultAnswer = 'y')

sleep(10)

startEdit()
activate(60000, block='true')
