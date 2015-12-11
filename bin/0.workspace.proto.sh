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

	__BO_DIR__0_WORKSPACE__="$__BO_DIR__"

	BO_sourcePrototype "$__BO_DIR__/../node_modules/node.pack/packers/git/packer.proto.sh"


    function source.0.workspace {

		if [ -z "$Z0_PROJECT_DIRPATH" ] || [ "$1" == "force" ]; then
			export Z0_PROJECT_DIRPATH="$PWD"
		fi
    	BO_log "$VERBOSE" "Z0_PROJECT_DIRPATH: $Z0_PROJECT_DIRPATH"

		if [ -z "$Z0_WORKSPACE_DIRPATH" ] || [ "$1" == "force" ]; then
			export Z0_WORKSPACE_DIRPATH="$Z0_PROJECT_DIRPATH"
	    	# If '$PWD' is not a Zero System workspace and it contains a `0.workspace` directory
	    	# we use the `0.workspace` directory as workspace root. (which is the 'wrapped' project layout)
	    	if [ ! -e "$Z0_WORKSPACE_DIRPATH/PINF.Genesis.ccjson" ] && [ -e "$Z0_WORKSPACE_DIRPATH/0.workspace" ]; then 
		    	export Z0_WORKSPACE_DIRPATH="$Z0_WORKSPACE_DIRPATH/0.workspace"
			fi
		fi
    	BO_log "$VERBOSE" "Z0_WORKSPACE_DIRPATH: $Z0_WORKSPACE_DIRPATH"

		eval `node --eval '
			var descriptorPath = "'$Z0_WORKSPACE_DIRPATH'/package.json";
			if (!require("fs").existsSync(descriptorPath)) process.exit(0);
			var descriptor = require(descriptorPath);
			if (descriptor.config) {
				if (descriptor.config.Z0_REPOSITORY_URL) {
					process.stdout.write("DESCRIPTOR_Z0_REPOSITORY_URL=\"" + descriptor.config.Z0_REPOSITORY_URL + "\"\n");
				}
				if (descriptor.config.Z0_REPOSITORY_COMMIT_ISH) {
					process.stdout.write("DESCRIPTOR_Z0_REPOSITORY_COMMIT_ISH=\"" + descriptor.config.Z0_REPOSITORY_COMMIT_ISH + "\"\n");
				}
			}
		'`
        if [ -z "$Z0_REPOSITORY_COMMIT_ISH" ] || [ "$1" == "force" ]; then
        	if [ ! -z "$DESCRIPTOR_Z0_REPOSITORY_COMMIT_ISH" ]; then
        		export Z0_REPOSITORY_COMMIT_ISH="$DESCRIPTOR_Z0_REPOSITORY_COMMIT_ISH"
        	fi
        fi
        if [ -z "$Z0_REPOSITORY_URL" ] || [ "$1" == "force" ]; then
        	if [ ! -z "$DESCRIPTOR_Z0_REPOSITORY_URL" ]; then
        		export Z0_REPOSITORY_URL="$DESCRIPTOR_Z0_REPOSITORY_URL"
        	else
        		export Z0_REPOSITORY_URL="git://github.com/0system/0system.0.git"
        	fi
        fi
        DESCRIPTOR_Z0_REPOSITORY_URL=""
        DESCRIPTOR_Z0_REPOSITORY_COMMIT_ISH=""
    	BO_log "$VERBOSE" "Z0_REPOSITORY_URL: $Z0_REPOSITORY_URL"
    	BO_log "$VERBOSE" "Z0_REPOSITORY_COMMIT_ISH: $Z0_REPOSITORY_COMMIT_ISH"

    	if [ -z "$Z0_POINTER_PATH" ] || [ "$1" == "force" ]; then
			export Z0_POINTER_PATH="$Z0_WORKSPACE_DIRPATH/.0"
    	fi
    	BO_log "$VERBOSE" "Z0_POINTER_PATH: $Z0_POINTER_PATH"

		if [ -z "$Z0_ROOT" ] || [ "$1" == "force" ]; then
			if [ -e "$Z0_POINTER_PATH" ]; then
				BO_followPointer "Z0_ROOT" "$(dirname $Z0_POINTER_PATH)" "$(basename $Z0_POINTER_PATH)"
				export Z0_ROOT
			fi
		fi
    	BO_log "$VERBOSE" "Z0_ROOT: $Z0_ROOT"

    	if [ -z "$Z0_WORKSPACE_IMPLEMENTATION_PATH" ] || [ "$1" == "force" ]; then
    		export Z0_WORKSPACE_IMPLEMENTATION_PATH="$Z0_ROOT/0.CloudIDE.Genesis"
    	fi
    	BO_log "$VERBOSE" "Z0_WORKSPACE_IMPLEMENTATION_PATH: $Z0_WORKSPACE_IMPLEMENTATION_PATH"
    }

    function 0.workspace.install.path {
        source.0.workspace
		if [[ $2 == .* ]] || [[ $2 == /* ]]; then
			if [ ! -e "$2" ]; then
				echo "ERROR: Path '$2' does not exist!"
				exit 1
			fi
			BO_setResult "$1" "$2"
		else
			BO_systemCachePath "$1" \
				`echo "$Z0_REPOSITORY_URL" | perl -pe 's/^git:\/\/|\.git$//g'` \
				"$2"
		fi
	}

    function 0.workspace.install {
        source.0.workspace
		BO_format "$VERBOSE" "HEADER" "Installing ZeroSystem ..."

		Z0_REPOSITORY_COMMIT_ISH="$1"
		BO_log "$VERBOSE" "Z0_REPOSITORY_COMMIT_ISH: $Z0_REPOSITORY_COMMIT_ISH"
		
		0.workspace.install.path "Z0_INSTALL_PATH" "$Z0_REPOSITORY_COMMIT_ISH"
		BO_log "$VERBOSE" "Z0_INSTALL_PATH: $Z0_INSTALL_PATH"

        BO_log "$VERBOSE" "Ensure repo '$Z0_REPOSITORY_URL' is cloned to '$Z0_INSTALL_PATH' for commit-ish '$Z0_REPOSITORY_COMMIT_ISH'"
					
		function cloneAndInstall {

		    if [ ! -e "$Z0_INSTALL_PATH" ]; then
			    if [ ! -e "$(dirname $Z0_INSTALL_PATH)" ]; then
			        mkdir -p "$(dirname $Z0_INSTALL_PATH)"
		        fi
		        git clone "$Z0_REPOSITORY_URL" "$Z0_INSTALL_PATH"
		    fi

			pushd "$Z0_INSTALL_PATH" > /dev/null
	    		BO_log "$VERBOSE" "Checkout commit-ish: $Z0_REPOSITORY_COMMIT_ISH"

			    git reset --hard
			    git checkout -b "$Z0_REPOSITORY_COMMIT_ISH" || git checkout "$Z0_REPOSITORY_COMMIT_ISH"
			    git fetch origin "$Z0_REPOSITORY_COMMIT_ISH" || true
			    git pull origin "$Z0_REPOSITORY_COMMIT_ISH" || true
			    git clean -df

	    		BO_log "$VERBOSE" "Ensure installed '$Z0_POINTER_PATH'"
				npm install

				touch ".installed"
			popd > /dev/null
		}

	    if [ -e "$Z0_INSTALL_PATH" ]; then
    		if [ ! -e "$Z0_INSTALL_PATH/.installed" ]; then
    			FAILED_DIR="$Z0_INSTALL_PATH.failed.$(date +"%Y-%m-%d_%H-%M-%S")"
	    		BO_log "$VERBOSE" "'.installed' not found in '$Z0_INSTALL_PATH' so we move everything to '$FAILED_DIR'"
	    		mv "$Z0_INSTALL_PATH" "$FAILED_DIR"
				cloneAndInstall
			else
	    		BO_log "$VERBOSE" "Found installed zero system implementation at '$Z0_INSTALL_PATH'"
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

		0.workspace.install.path "Z0_INSTALL_PATH" "$Z0_REPOSITORY_COMMIT_ISH"
		BO_log "$VERBOSE" "Z0_INSTALL_PATH: $Z0_INSTALL_PATH"
		
		if [ -L "$Z0_POINTER_PATH" ]; then
			if [ -h "$Z0_POINTER_PATH" ] && [ "$(readlink $Z0_POINTER_PATH)" == "$Z0_INSTALL_PATH" ]; then
				echo "Warning: Already using package '$Z0_REPOSITORY_COMMIT_ISH'"
				exit 0;
			fi
		elif [ -d "$Z0_POINTER_PATH" ] ; then
			echo "ERROR: We found a directory at '$Z0_POINTER_PATH' which should never happen! It must be a symlink or file containing a path."
			exit 1
		fi

		if [ ! -e "$Z0_INSTALL_PATH" ]; then
			echo "ERROR: No install found for version '$Z0_REPOSITORY_COMMIT_ISH' at path '$Z0_INSTALL_PATH'!"
			exit 1
		fi

		# Remove old link
		rm -Rf "$Z0_POINTER_PATH" 2> /dev/null || true

		# Create new link
		BO_log "$VERBOSE" "Using zero system implementation from '$Z0_INSTALL_PATH' for '$Z0_POINTER_PATH'"
		ln -s "$Z0_INSTALL_PATH" "$Z0_POINTER_PATH"

		# Update package descriptor
		pushd "$Z0_INSTALL_PATH" > /dev/null
			git_getRemoteUrl "REMOTE_URL" "origin"
			git_getTag "COMMIT_ISH"
		popd > /dev/null

		BO_log "$VERBOSE" "Updating package descriptor at '$Z0_WORKSPACE_DIRPATH/package.json'"
		node --eval '
			var descriptorPath = "'$Z0_WORKSPACE_DIRPATH'/package.json";
			// If file does not exist we ignore writing it.
			if (!require("fs").existsSync(descriptorPath)) process.exit(0);
			var descriptor = require(descriptorPath);
			var before = JSON.stringify(descriptor, null, 4);
			if (!descriptor.config) descriptor.config = {};
			descriptor.config.Z0_REPOSITORY_URL = "'$REMOTE_URL'";
			descriptor.config.Z0_REPOSITORY_COMMIT_ISH = "'$COMMIT_ISH'";
			var after = JSON.stringify(descriptor, null, 4);
			if (after !== before) {
				require("fs").writeFileSync(descriptorPath, after, "utf8");
			}
		'

		BO_format "$VERBOSE" "FOOTER"
	}

    function 0.workspace.init {
        source.0.workspace
		BO_format "$VERBOSE" "HEADER" "Initializing ZeroSystem workspace ..."

		# We determine the Zero System uri and commit based on what is linked into the project.
		pushd "$Z0_ROOT" > /dev/null
		    git_getRemoteUrl "Z0_REPOSITORY_URL" "origin"
		    # TODO: Use generic git url normalization lib here
		    Z0_REPOSITORY_URL=`echo "$Z0_REPOSITORY_URL" | perl -pe 's/^git@([^:]+):(.+?)\.git$/git:\/\/$1\/$2.git/g'`
		    export Z0_REPOSITORY_URL
		    git_getTag "Z0_REPOSITORY_COMMIT_ISH"
		    export Z0_REPOSITORY_COMMIT_ISH
		popd > /dev/null

		# TODO: Check '$Z0_WORKSPACE_IMPLEMENTATION_PATH/package.json' to find location of 'provision' aspect.
		BO_sourcePrototype "$Z0_WORKSPACE_IMPLEMENTATION_PATH/Aspects/provision/server.plugin.proto.sh"

		# We use the workspace implementation to provision the workspace.
		z0.aspect.provision $@

		# Now we enhance the workspace by configuring it from a higher level
		# TODO: Move this into '0.PING.Genesis'

		# If in source mode we link the `0.workspace` package in the project to ourselves.
		if [ -e "$__BO_DIR__0_WORKSPACE__/../0" ]; then
			BO_log "$VERBOSE" "Linking '0.workspace' into project as we are in source mode"
			mkdir "$Z0_WORKSPACE_DIRPATH/node_modules"
			ln -s "$(dirname $__BO_DIR__0_WORKSPACE__)" "$Z0_WORKSPACE_DIRPATH/node_modules/0.workspace"
		fi

		# Create profile seed file
		if [ ! -e "$Z0_WORKSPACE_DIRPATH.profile.seed.sh" ]; then
			BO_log "$VERBOSE" "Writing project seed file to '$Z0_WORKSPACE_DIRPATH.profile.seed.sh'"
			if [ -e "$(dirname $Z0_WORKSPACE_DIRPATH)/.secret/profile.seed.sh" ]; then
				# We can write a seed pointer file
				echo '#!/bin/bash
# Source https://github.com/bash-origin/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"


    BO_sourcePrototype "$__BO_DIR__/.secret/profile.seed.sh"

}
init $@' > "$Z0_WORKSPACE_DIRPATH.profile.seed.sh"
			else
				# We generate our own seed keys
				echo '#!/bin/bash
# Source https://github.com/bash-origin/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"


	export PIO_PROFILE_KEY="'$(uuidgen)'"

	# This is SUPER SECRET! Keep it safe!
	export PIO_PROFILE_SECRET="'$(uuidgen)'"

}
init $@' > "$Z0_WORKSPACE_DIRPATH.profile.seed.sh"
			fi
		fi

		BO_format "$VERBOSE" "FOOTER"
	}

}
init $@
