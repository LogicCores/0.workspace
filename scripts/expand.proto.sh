#!/bin/bash -e
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


    local OUR_BASE_PATH="$__BO_DIR__/.."


	function InstallConcreteWorkspace {
	    echo "YOU NEED TO RE_DECLARE THIS FUNCTION!"
	}

	function 0.workspace.ensure.abstract {
		BO_format "$VERBOSE" "HEADER" "Ensuring abstract workspace ..."
		export WORKSPACE_DIRECTORY="$PWD"
		BO_log "$VERBOSE" "WORKSPACE_DIR: $WORKSPACE_DIR"
		pushd "$WORKSPACE_DIR" > /dev/null

			BO_sourcePrototype "$OUR_BASE_PATH/scripts/expand.sh" $@

			# We use the ZeroSystem activate script as the workspace is not required at runtime
			# and should not be required to install dependencies.
			BO_sourcePrototype ".0/scripts/activate.sh" $@

    		BO_format "$VERBOSE" "HEADER" "Installing concrete workspace ..."
    		BO_log "$VERBOSE" "PWD: $PWD"

			InstallConcreteWorkspace $@

    		BO_format "$VERBOSE" "FOOTER"

		popd > /dev/null
		BO_format "$VERBOSE" "FOOTER"
	}
}
init $@