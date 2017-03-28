mare-runner
===========

[![Build Status](https://travis-ci.org/muzuiget/mare-runner.svg?branch=master)](https://travis-ci.org/muzuiget/mare-runner)

This project build a standalone [mare](https://github.com/muzuiget/mare) distribution, it can run without install any dependencies.

Intro
-----

It bundle all the runtime dependencies:

* compile Lua executable binary file
* compile [remotedebug.so][remotedebug]
* compile [lsocket.so][lsocket]
* pack [MessagePack.lua][msgpack]
* pack mare lua library
* pack mare lua example files
* pack NodeJS executable binary file
* pack all NodeJS modules
* a simple NodeJS server

[remotedebug]: https://github.com/muzuiget/mare-remotedebug
[lsocket]: https://github.com/cloudwu/lsocket
[msgpack]: https://github.com/fperrad/lua-MessagePack

Support
-------

* Linux x64
* Windows x64, cross compile with mingw.

Require
-------

below programs should in your `$PATH`

* gcc
* x86_64-w64-mingw32-gcc
* zip
* git
* tar
* wget
* sed

Build
-----

run `./build.sh`, if no errors occur, archive files in ./dist/archives folder

FAQ
----

**build options?**

No options, just happy path so far.



