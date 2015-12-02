#!/bin/bash -e
if [ -z "$HOME" ]; then
	echo "ERROR: 'HOME' environment variable is not set!"
	exit 1
fi

if [ -e "node_modules/.bin/bash.origin" ]; then
	node_modules/.bin/bash.origin BO install
fi

# Source https://github.com/bash-origin/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"


	if [ -z "$WORKSPACE_DIRECTORY" ]; then
		WORKSPACE_DIRECTORY="$PWD"
	fi


	# If being installed as a dependency we do not expand ourselves.
	if [ "$(basename $WORKSPACE_DIRECTORY)" == "0.workspace" ]; then
		if [ "$(basename $(dirname $WORKSPACE_DIRECTORY))" == "node_modules" ]; then
			echo "Skip expansion of '0.workspace' itself as it is being installed as a dependency."
			exit 0;
		fi
	fi


	"$__BO_DIR__/expand.sh"

}
init $@