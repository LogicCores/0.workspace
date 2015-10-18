0.workspace
===========

The Zero System base workspace which you can deploy and add your stacks to.


Instructions
------------

  1. Configure `./_Deployments/127.0.0.1:8090.profile.ccjson` to point to your own github application
  2. Rename and configure `./_Deployments/zerosystem-workspace.herokuapp.com.profile.ccjson` to point to your own heroku application for your workspace
  3. Rename and add remote for the heroku application `git remote add heroku git@heroku.com:zerosystem-workspace.git`


Commands
--------

The workspace is based on [0.CloudIDE.Genesis](https://github.com/CloudIDE-Plugins/0.CloudIDE.Genesis):

	# In Terminal to boot System Workspace:

	npm install
	npm start


	# In Cloud9 Terminal to run & deploy System and its enhanced Workspace:

	dev.sh          # Run local development server
	# A list of hostnames for access with a browser will be logged

	deploy.sh       # Deploy to heroku
	publish.sh      # Publish releases for distribution


	# In Terminal to reset the System Workspace when done:

	npm run clean
