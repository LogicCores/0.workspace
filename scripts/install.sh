#!/bin/bash -e
if [ -z "$npm_config_argv" ]; then
	echo "ERROR: Must run with 'npm install'!"
	exit 1
fi
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
	if [ -z "$Z0_REPOSITORY_COMMIT_ISH" ]; then
		Z0_REPOSITORY_COMMIT_ISH="master"
	fi
	if [ -z "$Z0_REPOSITORY_URL" ]; then
		Z0_REPOSITORY_URL="git://github.com/LogicCores/0.git"
	fi
	if [ -z "$Z0_HOME" ]; then
		Z0_HOME="$HOME/.Z0"
	fi

	BO_log "$VERBOSE" "WORKSPACE_DIRECTORY: $WORKSPACE_DIRECTORY"

	MANIPULATE_Z0_ROOT="0"
	if [ -z "$Z0_ROOT" ]; then
		if [ -e "$WORKSPACE_DIRECTORY/.0.lock" ]; then
			BO_realpath "Z0_ROOT" "$WORKSPACE_DIRECTORY/.0.lock"
		elif [ -e "$WORKSPACE_DIRECTORY/../.0.lock" ]; then
			BO_realpath "Z0_ROOT" "$WORKSPACE_DIRECTORY/../.0.lock"
		elif [ -e "$__BO_DIR__/../0" ]; then
			BO_realpath "Z0_ROOT" "$__BO_DIR__/../0"
		elif [ -e "$__BO_DIR__/../0.dev" ]; then
			BO_realpath "Z0_ROOT" "$__BO_DIR__/../0.dev"
		else
			MANIPULATE_Z0_ROOT="1"
			Z0_ROOT="$Z0_HOME/.0~commit-ish~$Z0_REPOSITORY_COMMIT_ISH"
		fi
	fi

	BO_log "$VERBOSE" "Z0_ROOT: $Z0_ROOT"


	function Install {
		BO_format "$VERBOSE" "HEADER" "Installing Zero System ..."

		pushd "$WORKSPACE_DIRECTORY" > /dev/null

			if [ ! -e ".0" ]; then

				if [ "$MANIPULATE_Z0_ROOT" == "1" ]; then

					BO_log "$VERBOSE" "Ensure repo '$Z0_REPOSITORY_URL' is cloned to '$Z0_ROOT' for commit-ish '$Z0_REPOSITORY_COMMIT_ISH'"
					
					function cloneAndInstall {

					    if [ ! -e "$Z0_ROOT" ]; then
						    if [ ! -e "$(dirname $Z0_ROOT)" ]; then
						        mkdir -p "$(dirname $Z0_ROOT)"
					        fi
					        git clone $Z0_REPOSITORY_URL $Z0_ROOT
					    fi

						pushd "$Z0_ROOT" > /dev/null
				    		BO_log "$VERBOSE" "Checkout commit-ish: $Z0_REPOSITORY_COMMIT_ISH"
	
						    git reset --hard
						    git checkout -b "$Z0_REPOSITORY_COMMIT_ISH" || git checkout "$Z0_REPOSITORY_COMMIT_ISH"
						    git fetch origin "$Z0_REPOSITORY_COMMIT_ISH" || true
						    git pull origin "$Z0_REPOSITORY_COMMIT_ISH" || true
						    git clean -df
				
				    		BO_log "$VERBOSE" "Ensure installed '$Z0_ROOT'"
							npm install
	
							touch ".done"
						popd > /dev/null
					}

				    if [ -e "$Z0_ROOT" ]; then
			    		if [ ! -e "$Z0_ROOT/.done" ]; then
			    			FAILED_DIR="$Z0_ROOT.failed.$(date +"%Y-%m-%d_%H-%M-%S")"
				    		BO_log "$VERBOSE" "'.done' not found in '$Z0_ROOT' so we move everything to '$FAILED_DIR'"
				    		mv "$Z0_ROOT" "$FAILED_DIR"
							cloneAndInstall
						else
				    		BO_log "$VERBOSE" "Found installed zero system implementation at '$Z0_ROOT'"
						fi
					else
						cloneAndInstall
			    	fi
				fi

	    		BO_log "$VERBOSE" "Using zero system implementation from '$Z0_ROOT' for '$WORKSPACE_DIRECTORY/.0'"
				ln -s "$Z0_ROOT" ".0"
			fi

			BO_sourcePrototype ".0/0.CloudIDE.Genesis/scripts/expand.sh" $@

		popd > /dev/null

		BO_format "$VERBOSE" "FOOTER"
	}

	Install $@

}
init $@