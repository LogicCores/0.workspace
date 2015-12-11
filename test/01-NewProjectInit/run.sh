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


    function Test {
		BO_format "$VERBOSE" "HEADER" "Test: 01-NewProjectInit"

        pushd "$__BO_DIR__" > /dev/null
            rm -Rf "tmp."* > /dev/null || true
            mkdir "tmp.new-project"
            pushd "tmp.new-project" > /dev/null

            "$__BO_DIR__/../../bin/0.workspace" init "$__BO_DIR__/../../0" -y --commit --verbose

            "$__BO_DIR__/../../bin/0.workspace" test --verbose
#            "$__BO_DIR__/../../bin/0.workspace" dev --verbose

            popd > /dev/null
            rm -Rf "tmp."* > /dev/null || true
        popd > /dev/null

		BO_format "$VERBOSE" "FOOTER"
	}

    Test $@
}
init $@