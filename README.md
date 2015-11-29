0.workspace
===========

The Zero System base workspace which you can deploy and add your stacks to.

You can have a complete *Web Software System* deployed in less than 5 minutes. After everything is confirmed running you can make incremental changes to shape it to your needs.

Install
-------

### Requirements

  * [NodeJS 4+](https://nodejs.org/)
  * [git](https://git-scm.com/)
  * [Heroku](http://heroku.com/) Account
  * OSX (only for now)

### Commands

		nvm use 4
		npm install -g 0.workspace


Use-Cases
=========

Create new project
------------------

Start with Zero System as the foundation for your application.

		mkdir myNewProject
		cd myNewProject

		0.workspace init [--inject-scripts]
		git add .
		git commit -m "Initialized 0.workspace"
		npm install
		0.workspace deploy
		# See https://github.com/0system/0system.0#commands for more commands

Wrap an existing project
------------------------

Wrap an existing project with Zero System to enhance your development workflow.

		cd myExistingProject

		0.workspace init [--inject-scripts]
		git add .
		git commit -m "Initialized 0.workspace"
		npm install
		0.workspace deploy
		# See https://github.com/0system/0system.0#commands for more commands

Work on a Zero System project
-----------------------------

		cd myZeroSystemProject

### On the command line

		# If initialized with `0.workspace init --inject-scripts`
		npm run <script>
		# See https://github.com/0system/0system.0#commands for commands

		# Otherwise or anyway
		0.workspace <command>
		0w <command>
		# Where commands are the same 'npm run' scripts as from https://github.com/0system/0system.0#commands

		source scripts/activate.sh
		# You now have the root context of your system loaded into your environment

### In an IDE

		0.workspace edit

Work against a different Zero System clone
------------------------------------------

		0.workspace --help

Show the current version of Zero System used by your project:

		0.workspace current

List installed versions:

		0.workspace ls

List available versions:

		0.workspace ls-remote

Install a new version:

		0.workspace install <version>

Switch to a different version:

		0.workspace use <version>
		# NOTE: When switching to a different version this command makes changes
		        to your workspace which need to be committed to git afterwards!

Best practices
--------------

  1. Use the **latest** Zero System version when **starting** or wrapping a project.
  2. **Update to the latest** pre-built Zero System release version and test/fix your system for compatibility **at least once per week**.
    * **Ideally:** Use a **continuous integration instance** to run your *whole system test suite* against any updates in realtime and configure your system to *send anonymized failure reports upstream*. This will ensure **you know immediately** when there is a *breaking change coming* and can collaborate on the design or an adapter/workaround to **bring your system into compatibility** as soon as possible as you see fit.
  3. Run your *whole system test suite* **before and after any changes**.
  4. Ensure you **write tests to go along** with your business logic and library/service APIs as well as all your other interfaces and add then to the *whole system test suite*.
  5. Focus the *whole system test suite* on testing the **final user flows and API contracts first** as everything else may change frequently. Focus on continuously testing the code, user interaction and service paths that your organization uses to fulfill its purpose every second of the day.
  6. **Provision and configure** all your code components and modules via `ccjson` **declarations** and write & publish to the community the necessary adapters to do so if missing.
  7. Switch to a clone of the [github.com/0system/0system.0](https://github.com/0system/0system.0) inlined source release of Zero System if you need or want to patch Zero System. We encourage you to contribute your changes back to the community so everyone can benefit. *note: Point 2 from above equally applies*
  8. Run the *whole system test suite* against any **new deployment** and ensure *all new unique paths are test covered*.
  9. Attempt to *integrate every new feature* into the foundation that Zero System provides to the greatest extent possible and *seek guidance from others* where needed. Share your contributions with others whenever you can. Build your own ideas into your clone and give others the space to build their own ideas into their own clones. Agree as a community to learn from each other to build a meta platform that can accomodate everyones' unique way of thinking and working in a non-restrictive and whole-enhancing way.
  10. Welcome every new user equally and know that condensed diversity to accomplish a common goal and satify a common need in a whole-enhancing way is an incredible force.


Governance
==========

This project is governed by [Christoph Dorn](http://christophdorn.com) who is the original author and self-elected as the [Benevolent Dictator For Life](https://en.wikipedia.org/wiki/Benevolent_dictator_for_life) to continuously steer this project onto its originally intended goal of providing an **Open Source** and **Free Foundation** to build **Web Software Systems** on. **Every software user in the world** must be able to obtain a copy of Zero System and *deploy a customized instance* of it for **free; forever.**


Provenance
==========

Original source logic under [Free Public License](https://lists.opensource.org/pipermail/license-review/2015-October/001254.html) by [Christoph Dorn](http://christophdorn.com)

