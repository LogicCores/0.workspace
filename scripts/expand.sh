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


	BO_sourcePrototype "$__BO_DIR__/../bin/0.workspace.proto.sh"
	source.0.workspace


	BO_log "$VERBOSE" "WORKSPACE_DIRECTORY: $WORKSPACE_DIRECTORY"
	BO_log "$VERBOSE" "'WORKSPACE_DIRECTORY': $(ls -al $WORKSPACE_DIRECTORY)"
	BO_log "$VERBOSE" "'WORKSPACE_DIRECTORY/../..': $(ls -al $WORKSPACE_DIRECTORY/../..)"


	function EnsureZeroSystem {
		BO_format "$VERBOSE" "HEADER" "Ensuring Zero System is installed and linked to '$WORKSPACE_DIRECTORY/.0' ..."

		pushd "$WORKSPACE_DIRECTORY" > /dev/null

			# Link dependencies for which we have sources
			if [ -e "0" ]; then
				rm -Rf "node_modules/bash.origin"
				ln -s "../0/lib/bash.origin" "node_modules/bash.origin"
				rm -Rf "node_modules/node.pack"
				ln -s "../0/lib/node.pack" "node_modules/node.pack"
			fi

			# We only link Zero System on expansion if not already linked.
			if [ ! -e ".0" ]; then
				0.workspace.install "$Z0_REPOSITORY_COMMIT_ISH"
				0.workspace.use "$Z0_REPOSITORY_COMMIT_ISH"
			fi

		popd > /dev/null

		BO_format "$VERBOSE" "FOOTER"
	}

	function ExpandWorkspace {
		if [ -e "$WORKSPACE_DIRECTORY/.git" ]; then
			BO_format "$VERBOSE" "HEADER" "Expanding Workspace ..."

			pushd "$WORKSPACE_DIRECTORY" > /dev/null

				# If we are cloned in source mode we expand ourselves otherwise we don't care as we are not being run directly
	    		BO_log "$VERBOSE" "Expanding source repo '$WORKSPACE_DIRECTORY' ..."
				".0/0.CloudIDE.Genesis/scripts/expand.sh"

			popd > /dev/null

			BO_format "$VERBOSE" "FOOTER"
		fi
	}

	EnsureZeroSystem $@
	ExpandWorkspace $@

}
init $@