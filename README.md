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

The workspace is based on `0.CloudIDE.Genesis`:

	./expand.sh
	./run.sh
	
	# In Cloud9 terminal
	
	dev.sh          # Run local development server

	deploy.sh       # Deploy to heroku
	
	./contract.sh

