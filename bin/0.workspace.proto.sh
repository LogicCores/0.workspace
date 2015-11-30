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


    function source.0.workspace {
        if [ -z "$BO_SYSTEM_CACHE_DIR" ]; then
        	export BO_SYSTEM_CACHE_DIR="$HOME/.Z0/.bash.origin.cache"
        fi
    	if [ -z "$Z0_HOME" ]; then
    		export Z0_HOME="$HOME/.Z0"
    	fi
        if [ -z "$Z0_REPOSITORY_COMMIT_ISH" ]; then
        	if [ ! -z "$npm_package_config_Z0_REPOSITORY_COMMIT_ISH" ]; then
        		Z0_REPOSITORY_COMMIT_ISH="$npm_package_config_Z0_REPOSITORY_COMMIT_ISH"
        	else
        		Z0_REPOSITORY_COMMIT_ISH="master"
        	fi
        fi
        if [ -z "$Z0_REPOSITORY_URL" ]; then
        	if [ ! -z "$npm_package_config_Z0_REPOSITORY_URL" ]; then
        		Z0_REPOSITORY_URL="$npm_package_config_Z0_REPOSITORY_URL"
        	else
        		Z0_REPOSITORY_URL="git://github.com/0system/0system.0.git"
        	fi
        fi
#    	MANIPULATE_Z0_ROOT="0"
    	if [ -z "$Z0_ROOT" ]; then
    		if [ -e "$__BO_DIR__/../0" ]; then
    			BO_realpath "Z0_ROOT" "$__BO_DIR__/../0"
    		# Used when called via 'npm install 0.workspace' as '0' submodule is not present
    		elif [ -e "../../.0" ]; then
    			BO_realpath "Z0_ROOT" "../../.0"
    		else
#    			MANIPULATE_Z0_ROOT="1"
				# We assume that this path will be provisioned before it is used.
    			BO_realpath "Z0_ROOT" "../../.0"
#    			Z0_ROOT="$Z0_INSTALLS_DIRPATH/$Z0_REPOSITORY_COMMIT_ISH"
    		fi
    	fi
    	BO_log "$VERBOSE" "Z0_HOME: $Z0_HOME"
    	BO_log "$VERBOSE" "Z0_ROOT: $Z0_ROOT"
    }

    function 0.workspace.install.path {
        source.0.workspace
		BO_systemCachePath "$1" \
			`echo "$Z0_REPOSITORY_URL" | perl -pe 's/^git:\/\/|\.git$//g'` \
			"$2"
	}

    function 0.workspace.install {
        source.0.workspace
		BO_format "$VERBOSE" "HEADER" "Installing ZeroSystem ..."

		Z0_REPOSITORY_COMMIT_ISH="$1"
		BO_log "$VERBOSE" "Z0_REPOSITORY_COMMIT_ISH: $Z0_REPOSITORY_COMMIT_ISH"
		
		0.workspace.install.path "ZO_INSTALL_PATH" "$Z0_REPOSITORY_COMMIT_ISH"
		BO_log "$VERBOSE" "ZO_INSTALL_PATH: $ZO_INSTALL_PATH"

        BO_log "$VERBOSE" "Ensure repo '$Z0_REPOSITORY_URL' is cloned to '$ZO_INSTALL_PATH' for commit-ish '$Z0_REPOSITORY_COMMIT_ISH'"
					
		function cloneAndInstall {

		    if [ ! -e "$ZO_INSTALL_PATH" ]; then
			    if [ ! -e "$(dirname $ZO_INSTALL_PATH)" ]; then
			        mkdir -p "$(dirname $ZO_INSTALL_PATH)"
		        fi
		        git clone "$Z0_REPOSITORY_URL" "$ZO_INSTALL_PATH"
		    fi

			pushd "$ZO_INSTALL_PATH" > /dev/null
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

	    if [ -e "$ZO_INSTALL_PATH" ]; then
    		if [ ! -e "$ZO_INSTALL_PATH/.done" ]; then
    			FAILED_DIR="$ZO_INSTALL_PATH.failed.$(date +"%Y-%m-%d_%H-%M-%S")"
	    		BO_log "$VERBOSE" "'.done' not found in '$ZO_INSTALL_PATH' so we move everything to '$FAILED_DIR'"
	    		mv "$ZO_INSTALL_PATH" "$FAILED_DIR"
				cloneAndInstall
			else
	    		BO_log "$VERBOSE" "Found installed zero system implementation at '$ZO_INSTALL_PATH'"
			fi
		else
			cloneAndInstall
    	fi

		BO_format "$VERBOSE" "FOOTER"
    }

    function 0.workspace.use {
        source.0.workspace
		BO_format "$VERBOSE" "HEADER" "Using ZeroSystem ..."

		Z0_REPOSITORY_COMMIT_ISH="$1"
		BO_log "$VERBOSE" "Z0_REPOSITORY_COMMIT_ISH: $Z0_REPOSITORY_COMMIT_ISH"

		0.workspace.install.path "ZO_INSTALL_PATH" "$Z0_REPOSITORY_COMMIT_ISH"
		BO_log "$VERBOSE" "ZO_INSTALL_PATH: $ZO_INSTALL_PATH"

		# TODO: If we have a submodule we need to remove it after confirmation.

		BO_log "$VERBOSE" "Using zero system implementation from '$ZO_INSTALL_PATH' for '$PWD/.0'"
		rm -f ".0" || true
		ln -s "$ZO_INSTALL_PATH" ".0"
	}
}
init $@