#!/bin/bash -e
if [ -z "$npm_config_argv" ]; then
	echo "ERROR: Must run with 'npm install'!"
	exit 1
fi
if [ -z "$HOME" ]; then
	echo "ERROR: 'HOME' environment variable is not set!"
	exit 1
fi
# Source https://github.com/bash-origin/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"


	function Deploy {
		BO_format "$VERBOSE" "HEADER" "Deploying system ..."


		BO_sourcePrototype ".0/0.CloudIDE.Genesis/scripts/activate.sh" $@
		BO_log "$VERBOSE" "WORKSPACE_DIR: $WORKSPACE_DIR"



		export PLATFORM_NAME="com.heroku"
		git remote add "$PLATFORM_NAME" git@heroku.com:zerosystem-workspace.git > /dev/null || true


		# TODO: Set 'Z0_REPOSITORY_URL' and 'Z0_REPOSITORY_COMMIT_ISH' based on package config
		#       and optionally set to linked source if using dev sources.


		BO_sourcePrototype ".0/0.CloudIDE.Genesis/scripts/deploy.sh" $@


		BO_format "$VERBOSE" "FOOTER"
	}

	Deploy $@
}
init $@