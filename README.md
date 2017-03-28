mare-runner
===========

[![Build Status](https://travis-ci.org/muzuiget/mare-runner.svg?branch=master)](https://travis-ci.org/muzuiget/mare-runner)

This project build a standalone [mare](https://github.com/muzuiget/mare) distribution, it can run out-of-box, without install any dependencies.

Intro
-----

It bundle all the runtime dependencies:

* pack Lua binary files from [lua-bin](https://github.com/muzuiget/lua-bin)
* pack NodeJS executable binary file
* pack mare lua library and example files
* pack all NodeJS modules
* provide  a simple standalone server

Download
--------

Checkout [Github Release](https://github.com/muzuiget/lua-bin/releases) page, which are built by [Travis CI](https://travis-ci.org/), Download the zip for your OS.

Usage
-----

Unzip the archive file, run `./node index.js`, then a server will startup.

Open another terminal, go into `exmaple/` folder, run `./lua -i test.lua` to play around.

Build
-----

run `./build.sh`, if no errors occur, archive files in `./dist/` folder

FAQ
----

**build options?**

No options, just happy path so far.



