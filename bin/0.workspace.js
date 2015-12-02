
var LIB = {
    VERBOSE: (!!process.env.VERBOSE) || false,
    assert: require("assert"),
    path: require("path"),
    fs: require("fs-extra"),
    minimist: require("minimist"),
    request: require("request"),
    semver: require("semver"),
    inquirer: require("inquirer"),
    "cli-table": require("cli-table"),
    Promise: require("bluebird"),
    _: require("lodash"),
    colors: require("colors"),
    child_process: require("child_process")
};
LIB.Promise.promisifyAll(LIB.fs);
LIB.fs.existsAsync = function (path) {
    return new LIB.Promise(function (resolve, reject) {
        return LIB.fs.exists(path, resolve);
    });
}
LIB.Promise.promisifyAll(LIB.request);

function runCommands (commands, options) {
	return LIB.Promise.promisify(function (callback) {
	    options = options || {}
	    options.verbose = options.verbose || LIB.VERBOSE;
	    var env = {};
	    LIB._.assign(env, process.env);
	    LIB._.assign(env, options.env || {});
		if (options.verbose) {
			console.log("Running commands:", commands);
			env.VERBOSE = "1";
		}
		options.env = env;
	    var proc = LIB.child_process.spawn("bash", [
	        "-s"
	    ], options);
	    proc.on("error", function(err) {
	    	return callback(err);
	    });
	    var stdout = [];
	    var stderr = [];
	    proc.stdout.on('data', function (data) {
	    	stdout.push(data.toString());
			if (options.verbose || options.progress) process.stdout.write(data);
	    });
	    proc.stderr.on('data', function (data) {
	    	stderr.push(data.toString());
			if (options.verbose || options.progress) process.stderr.write(data);
	    });
	    proc.stdin.write(commands.join("\n"));
	    proc.stdin.end();
	    proc.on('close', function (code) {
	    	if (code) {
	    		var err = new Error("Commands exited with code: " + code);
	    		err.code = code;
	    		err.stdout = stdout;
	    		err.stderr = stderr;
	    		console.error("err", err);
	    		return callback(err);
	    	}
	        return callback(null, stdout.join(""));
	    });
	})();
}


function runCommand (command, args, options) {
	return LIB.Promise.promisify(function (callback) {
	    options = options || {}
	    options.verbose = options.verbose || LIB.VERBOSE;
	    var env = {};
	    LIB._.assign(env, process.env);
	    LIB._.assign(env, options.env || {});
		if (options.verbose) {
			console.log("Running command:", command, args);
			env.VERBOSE = "1";
		}
		options.env = env;
		options.stdio = "inherit";
	    var proc = LIB.child_process.spawn(command, args, options);
	    proc.on("error", function(err) {
	    	return callback(err);
	    });
	    var stdout = [];
	    var stderr = [];
	    proc.on('close', function (code) {
	    	if (code) {
	    		var err = new Error("Commands exited with code: " + code);
	    		err.code = code;
	    		err.stdout = stdout;
	    		err.stderr = stderr;
	    		console.error("err", err);
	    		return callback(err);
	    	}
	        return callback(null, stdout.join(""));
	    });
	})();
}


exports.main = function (argv) {

    var Z0_WORKSPACE_DIRPATH = process.env.Z0_WORKSPACE_DIRPATH;
    if (!Z0_WORKSPACE_DIRPATH) {
        return LIB.Promise.reject(new Error("'Z0_WORKSPACE_DIRPATH' environment variable must be set!"));
    }

    // TODO: Use generic git url parser
    var Z0_REPOSITORY_URL = process.env.Z0_REPOSITORY_URL;
    if (!Z0_REPOSITORY_URL) {
        return LIB.Promise.reject(new Error("'Z0_REPOSITORY_URL' environment variable must be set!"));
    }

    // 'git@github.com:LogicCores/0.git' or 'git://github.com/LogicCores/0.git'
    var m = Z0_REPOSITORY_URL.match(/^git(?:@|:\/\/)github\.com(?::|\/)([^\/]+\/[^\/]+)\.git$/);
    if (!m) {
        return LIB.Promise.reject(new Error("Error parsing 'Z0_REPOSITORY_URL' (" + Z0_REPOSITORY_URL + ")!"));
    }
    const REMOTE_SOURCE_REVISIONS_URL = "https://api.github.com/repos/" + m[1] + "/tags";
    const LOCAL_INSTALLS_PATH = LIB.path.join(process.env.BO_SYSTEM_CACHE_DIR, "github.com~" + m[1].replace(/\//g, "~") + "~/source/snapshot");


    function showUsage () {
        var lines = [];
        lines.push("");
        lines.push("Workspace Manager:".bold + " https://github.com/LogicCores/0.workspace".blue);
        lines.push("for Zero System:".bold + " https://github.com/0system".blue);
        lines.push("");
        lines.push("Usage: ");
        lines.push("");
        lines.push("  0w init [version/uri] [--commit]");
        lines.push("                              Add Zero System to a new or existing git project");
        lines.push("                              '--commit' will commit changes to git");
        lines.push("");
        lines.push("  0w current                  Display currently activated version");
        lines.push("  0w ls                       List installed versions");
        lines.push("  0w ls-remote                List remote versions available for install");
        lines.push("  0w install <version/uri>    Download and install a <version/uri>");
        lines.push("                              Special versions: 'latest', 'latest-build'");
        lines.push("  0w use <version/path>       Modify 'package.json' and './.0' to use <version/path>");
        lines.push("");
        lines.push("  0w update                   Pull changes, checkout submodules and re-install");
        lines.push("  0w edit                     Launch an editor");
        lines.push("  0w dev                      Run system in development mode using development profile");
        lines.push("  0w dev --production         Run system in production mode using production profile");
        lines.push("  0w dev -- --profile ./Deployments/<name>.proto.profile.ccjson");
        lines.push("                              Run system in development mode using custom profile overlay");
        lines.push("  0w encrypt                  Encrypt raw profile data using workspace secret");
        lines.push("  0w test                     Run whole system test suite");
        lines.push("");
        lines.push("  0w bundle                   Freeze everything for consistent distribution");
        lines.push("  0w deploy [--production] [--commit] [--bundle]");
        lines.push("                              Deploy latest commit to staging or production");
        lines.push("                              '--commit' will commit configuration changes to git");
        lines.push("                              '--bundle' will cause the remote deployment be be bundled after installation");
        lines.push("  0w publish                  Publish latest commit");
        lines.push("");
        lines.push("  0w start                    Run system in production mode using production profile");
        lines.push("");
        process.stdout.write(lines.join("\n") + "\n");
        return LIB.Promise.resolve();
    }

    // TODO: Move this into a '0.workspace.proto.sh' function
    function loadCurrentStatus () {
        function lookup (path) {
            path = LIB.path.join(path, ".0");
            return LIB.fs.existsAsync(path).then(function (exists) {
                if (!exists) {
                    return null;
                };
                return LIB.fs.lstatAsync(path).then(function (stat) {
                    if (!stat.isSymbolicLink()) {
                        if (stat.isDirectory()) {
                            return lookup(path);
                        }
                        return LIB.fs.readFileAsync(path, "utf8").then(function (data) {
                            if (data === ".") {
                                return LIB.fs.realpathAsync(path);
                            }
                            return lookup(data);
                        });
                    }
                    return LIB.fs.readlinkAsync(path).then(lookup);
                });
            });
        }
        return lookup(
            process.cwd()
        ).then(function (path) {
            var status = {
                path: null,
                version: null
            };
            if (!path) {
                return status;
            }
            status.path = LIB.path.dirname(path);
    		return runCommands([
    		   'echo "tag: $(git describe --tags)"'
    		], {
    		    cwd: status.path,
    		    verbose: LIB.VERBOSE
    		}).then(function (stdout) {
    		    status.version = stdout.match(/^tag: (.+)$/m)[1];
                return status;
    		});
        });
    }

    // TODO: Move this into a '0.workspace.proto.sh' function
    function isRemoteTagEqualToLocalTag (remoteTag, localTag) {
        if (!remoteTag || !localTag) return false;
        if (remoteTag === localTag) return true;
        var remote = remoteTag.match(/^(v\d+\.\d+\.\d+)-([^\.]+)(\.\d+\.(.+))?$/);
        var local = localTag.match(/^(v\d+\.\d+\.\d+)(-\d+-(.+))?$/);
        if (local) {
            if (
                remote[4] &&
                local[3] &&
                remote[4] === local[3]
            ) {
                return true;
            }
            if (
                remote[1] === local[1] &&
                remote[2] === "inline" &&
                !local[2]
            ) {
                return true;
            }
        } else {
            local = localTag.match(/^(v\d+\.\d+\.\d+)-([^\.]+)(\.\d+\.(.+))?$/);
            if (
                remote[4] &&
                local[4] &&
                remote[4] === local[4]
            ) {
                return true;
            }
        }
        return false;
    }

    // TODO: Move this into a '0.workspace.proto.sh' function
    function loadRemote () {
        return LIB.request.getAsync(REMOTE_SOURCE_REVISIONS_URL, {
            headers: {
                "User-Agent": "github.com/LogicCores/0.workspace using npm/request"
            },
            json: true
        }).then(function (response) {
            var tags = [];
            response.body.forEach(function (tag) {
                tags.push(tag.name);
            });
            tags = LIB.semver.sort(tags);
            tags.reverse();
            tags = tags.map(function (tag) {
                var m = tag.match(/^v\d+\.\d+\.\d+-(inline|build)\.?/);
                tag = {
                    tag: tag,
                    isUsing: function (status) {
                        if (!status.version) return "";
                        if (isRemoteTagEqualToLocalTag(tag.tag, status.version)) {
                            return "  *";
                        }
                        return "";
                    }
                };
                if (m) {
                    tag.stream = m[1];
                }
                if (tag.stream === "inline") {
                    tag.stability = "preview";
                } else {
                    tag.stability = tag.stream;
                }
                return tag;
            }).filter(function (tag) {
                return !!tag.stream;
            });
            return tags;
        });
    }

    // TODO: Move this into a '0.workspace.proto.sh' function
    function loadInstalled () {
        var installs = [];
        if (LIB.VERBOSE) console.log("Looking for installs in:", LOCAL_INSTALLS_PATH);
        return LIB.fs.existsAsync(LOCAL_INSTALLS_PATH).then(function (exists) {
            if (!exists) {
                return installs;
            }
            return LIB.fs.readdirAsync(LOCAL_INSTALLS_PATH).then(function (paths) {
                paths = LIB.semver.sort(paths);
                paths.reverse();
                paths.forEach(function (filename) {
                    installs.push({
                        tag: filename,
                        isUsing: function (status) {
                            if (!status.version) return "";
                            if (isRemoteTagEqualToLocalTag(filename, status.version)) {
                                return "  *";
                            }
                            return "";
                        }
                    });
                });
                return null;
            });
        }).then(function () {
            return installs;
        });
    }

    var command = argv["_"].shift() || "";
    
    if (argv["help"] || argv["h"]) {
        return showUsage();
    }

    if (argv["verbose"] || argv["v"]) {
        LIB.VERBOSE = true;
    }

    if (argv["commit"]) {
        process.env.Z0_PROJECT_AUTO_COMMIT_CHANGES="1";
    }

    function runDefault () {
        function getScriptPathForCommand (command) {
            var path = LIB.path.join(process.env.Z0_WORKSPACE_IMPLEMENTATION_PATH, "scripts", command + ".sh");
            return LIB.fs.existsAsync(path).then(function (exists) {
                if (!exists) return null;
                return path;
            });
        }
        return getScriptPathForCommand(command).then(function (path) {
            if (!path) {
                process.stdout.write(("\nError: Command '" + command + "' not found!\n").red);
                return showUsage();
            }
    		return runCommand(path, process.argv.slice(2), {
    		    cwd: process.cwd(),
    		    verbose: LIB.VERBOSE
    		});
        });
    }

    // TODO: Move this into a '0.workspace.proto.sh' function
    function resolveVersion (version) {
        if (/^\./.test(version)) {
            return LIB.Promise.resolve(version);
        }
        return loadCurrentStatus().then(function (status) {
            if (
                version === "latest" ||
                version === "latest-build" ||
                /^\d+$/.test(version)
            ) {
                return loadRemote().then(function (tags) {
                    var tag = null;
                    if (version === "latest-build") {
                        tag = tags.shift();
                    } else
                    if (version === "latest") {
                        while ( (tag = tags.shift()) ) {
                            if (tag.stream === "inline") {
                                break;
                            }
                        };
                    } else {
                        tag = tags.splice(parseInt(version), 1)[0];
                    }
                    if (!tag) {
                        throw new Error("No tag found for version '" + version + "'!");
                    }
                    if (tag.isUsing(status)) {
                        throw new Error("Already using this version!");
                    }
                    return tag.tag;
                });
            }
            if (isRemoteTagEqualToLocalTag(version, status.version)) {
                throw new Error("Already using this version!");
            }
            return version;
        });
    }

    function installVersion (version) {
        return resolveVersion(version).then(function (version) {
    		return runCommands([
    		    '. ' + LIB.path.join(__dirname, "./0.workspace.proto.sh"),
    		    '0.workspace.install "' + version + '"'
    		], {
    		    cwd: process.cwd(),
    		    verbose: LIB.VERBOSE
    		});
        });
    }

    function useVersion (version, forceInit) {
        return resolveVersion(version).then(function (version) {
            var commands = [
                '. ' + LIB.path.join(__dirname, "./0.workspace.proto.sh")
            ];
            if (forceInit) {
                commands.push('source.0.workspace "force"');
            }
            commands.push('0.workspace.use "' + version + '"');
    		return runCommands(commands, {
    		    cwd: process.cwd(),
    		    verbose: LIB.VERBOSE
    		});
        });
    }

    function initProject () {

        function ensureEnvironmentVariables () {
            function reverse (string) {
                string = string.split(".");
                string.reverse();
                return string.join(".");
            }
            return new LIB.Promise(function (resolve, reject) {
                var questions = [];
                if (!process.env.Z0_WORKSPACE_HOSTNAME) {
                    if (process.env.Z0_WORKSPACE_NAMESPACE) {
                        process.env.Z0_WORKSPACE_HOSTNAME = reverse(process.env.Z0_WORKSPACE_NAMESPACE);
                    } else {
                        questions.push({
                            type: "input",
                            name: "Z0_WORKSPACE_HOSTNAME",
                            message: "Please enter the project hostname",
                            default: reverse(LIB.path.basename(Z0_WORKSPACE_DIRPATH))
                        });
                    }
                }
                if (questions.length === 0) {
                    return resolve();
                }
                return LIB.inquirer.prompt(questions, function (answers) {
                    process.env.Z0_WORKSPACE_HOSTNAME = answers.Z0_WORKSPACE_HOSTNAME;
                    return resolve();
                });
            }).then(function () {
                if (!process.env.Z0_WORKSPACE_NAMESPACE) {
                    process.env.Z0_WORKSPACE_NAMESPACE = reverse(process.env.Z0_WORKSPACE_HOSTNAME);
                }
                return null;
            });
        }
        
        return ensureEnvironmentVariables().then(function () {

            var commands = [
                '. ' + LIB.path.join(__dirname, "./0.workspace.proto.sh")
            ];
            // We ALWAYS force init the environment before initializing!
            commands.push('source.0.workspace "force"');
            commands.push('0.workspace.init');
    		return runCommands(commands, {
    		    cwd: process.cwd(),
    		    verbose: LIB.VERBOSE
    		});
        });
    }

    switch (command) {

        case "init":
            return LIB.Promise.try(function () {
                function isInitialized () {
                    var initialized = false;
                    return LIB.Promise.all([
                        ".0",
                        "PINF.Genesis.ccjson",
                        "0.workspace/.0",
                        "0.workspace/PINF.Genesis.ccjson"
                    ].map(function (path) {
                        return LIB.fs.existsAsync(
                            LIB.path.join(Z0_WORKSPACE_DIRPATH, path)
                        ).then(function (exists) {
                            if (exists) {
                                initialized = true;
                            }
                            return null;
                        });
                    })).then(function () {
                        return initialized;
                    });
                }
                function determineInstallMode () {
                    return LIB.fs.readdirAsync(process.cwd()).then(function (filenames) {
                        if (filenames.length === 0) {
                            return "new";
                        }
                        return "wrap";
                    });
                }
                return isInitialized().then(function (initialized) {
                    if (initialized) {
                        throw new Error("Project is already setup to be a Zero System workspace!");
                    }
                    return determineInstallMode().then(function (mode) {
                        if (LIB.VERBOSE) console.log("mode:", mode);
    
                        // In wrap mode we install everything into the `0.workspace` subdirectory
                        if (mode === "wrap") {
                            if (LIB.fs.existsSync(LIB.path.join(Z0_WORKSPACE_DIRPATH, "0.workspace"))) {
                                throw new Error("Cannot wrap project as it already contains a '0.workspace' directory!");
                            }
                            LIB.fs.mkdirsSync(LIB.path.join(Z0_WORKSPACE_DIRPATH, "0.workspace"));
                        }
                        var version = argv["_"].shift() || "latest";
                        return installVersion(version).then(function () {
                            return useVersion(version, true).then(function () {
                                return initProject();
                            });
                        });
                    });
                });
            });

        case "current":
            return loadCurrentStatus().then(function (status) {
                if (!status.version) {
                    throw new Error("No release linked!");
                }
                process.stdout.write(status.version + " (" + status.path + ")\n");
                return null;
            });

        case "ls":
            return loadCurrentStatus().then(function (status) {
                return loadInstalled().then(function (tags) {
                    process.stdout.write(("Installs from: " + LOCAL_INSTALLS_PATH).bold + "\n");
                    if (Object.keys(tags).length === 0) {
                        throw new Error("No installs found!");
                    }
                    var table = new (LIB["cli-table"])({
                        head: [
                            'Using', 'Tag'
                        ],
                        chars: {'mid': '', 'left-mid': '', 'mid-mid': '', 'right-mid': ''}
                    });
                    tags.forEach(function (tag) {
                        table.push(
                            [
                                tag.isUsing(status),
                                tag.tag
                            ]
                        );
                    });
                    process.stdout.write(table.toString() + "\n");
                    return null;
                });
            });

        case "ls-remote":
            return loadCurrentStatus().then(function (status) {
                return loadRemote().then(function (tags) {
                    var table = new (LIB["cli-table"])({
                        head: [
                            'Using', 'Tag', 'Stability'
                        ],
                        chars: {'mid': '', 'left-mid': '', 'mid-mid': '', 'right-mid': ''}
                    });
                    tags.forEach(function (tag) {
                        table.push(
                            [
                                tag.isUsing(status),
                                tag.tag,
                                tag.stability
                            ]
                        );
                    });
                    process.stdout.write(("Tags from: " + Z0_REPOSITORY_URL).bold + "\n");
                    process.stdout.write(table.toString() + "\n");
                    return null;
                });
            });

        case "install":
            return LIB.Promise.try(function () {
                // If no version specified we run the workspace install script.
                if (argv["_"].length === 0) {
                    return runDefault();
                }
                return installVersion(argv["_"].shift());
            });

        case "use":
            return LIB.Promise.try(function () {
                // If no version specified we run the workspace install script.
                if (argv["_"].length === 0) {
                    throw new Error("No version to use specified!");
                }
                return useVersion(argv["_"].shift());
            });

        default:
            return runDefault();
    }
}


if (require.main === module) {
    exports.main(
        LIB.minimist(process.argv.slice(2))
    ).then(function () {
        process.exit(0);
        return null;
    }).catch(function (err) {
        if (LIB.VERBOSE) {
            console.error(("" + err.stack).red);
        } else {
            var msg = "Error: " + err.message;
            if (err.stdout) {
                msg += " (stdout: " + err.stdout.join("\n").replace(/\n$/, "") + ")";
            }
            console.error(msg.red);
        }
        process.exit(1);
        return null;
    });
}

