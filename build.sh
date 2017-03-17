#!/bin/bash

set -xe

NODEJS_VER=7.7.3
NODEJS_PKG_URL_PREFIX=https://nodejs.org/dist/v$NODEJS_VER
NODEJS_DIR_LINUX_x64=node-v$NODEJS_VER-linux-x64
NODEJS_DIR_WIN_x64=node-v$NODEJS_VER-win-x64

LUA_URL=https://github.com/muzuiget/mirror-lua.git
LUA_TAG=v5.3.4
LSOCKET_URL=https://github.com/cloudwu/lsocket.git
LSOCKET_BRANCH=master
MSGPACK_URL=https://github.com/fperrad/lua-MessagePack.git
MSGPACK_TAG=0.5.0

MARE_URL=https://github.com/muzuiget/mare.git
MARE_BRANCH=master
REMOTEDEBUG_URL=https://github.com/muzuiget/mare-remotedebug.git
REMOTEDEBUG_BRANCH=master
DEVTOOLS_URL=https://github.com/muzuiget/mare-devtools-frontend.git
DEVTOOLS_BRANCH=master

BUILD_DIR=build
DIST_DIR=dist

rm -rf $DIST_DIR
mkdir -p $DIST_DIR
mkdir -p $BUILD_DIR

# prepare vendor binary
(
    cd $BUILD_DIR

    # nodejs linux-x64
    nodejs_pkg=$NODEJS_DIR_LINUX_x64.tar.xz
    nodejs_pkg_url=$NODEJS_PKG_URL_PREFIX/$nodejs_pkg
    if [ ! -d $NODEJS_DIR_LINUX_x64 ]; then
        if [ ! -f $nodejs_pkg ]; then
            wget $nodejs_pkg_url -O $nodejs_pkg
        fi
        tar -xvf $nodejs_pkg
    fi

    # nodejs win-x64
    nodejs_pkg=$NODEJS_DIR_WIN_x64.zip
    nodejs_pkg_url=$NODEJS_PKG_URL_PREFIX/$nodejs_pkg
    if [ ! -d $NODEJS_DIR_WIN_x64 ]; then
        if [ ! -f $nodejs_pkg ]; then
            wget $nodejs_pkg_url -O $nodejs_pkg
        fi
        unzip $nodejs_pkg
    fi
)

# prepare vendor source
(
    cd $BUILD_DIR

    # lua
    if [ ! -d lua ]; then
        git clone --depth 1 --single-branch \
            --branch $LUA_TAG \
            $LUA_URL lua
    else
        cd lua
        git fetch && git reset --hard $LUA_TAG
        cd ..
    fi

    # lsocket
    if [ ! -d lsocket ]; then
        git clone --depth 1 --single-branch \
            --branch $LSOCKET_BRANCH \
            $LSOCKET_URL lsocket
    else
        cd lsocket
        git fetch && git reset --hard origin/$LSOCKET_BRANCH
        cd ..
    fi

    # msgpack
    if [ ! -d msgpack ]; then
        git clone --depth 1 --single-branch \
            --branch $MSGPACK_TAG \
            $MSGPACK_URL msgpack
    else
        cd msgpack
        git fetch && git reset --hard $MSGPACK_TAG
        cd ..
    fi
)

# prepare mare source
(
    cd $BUILD_DIR

    # mare
    if [ ! -d mare ]; then
        git clone --depth 1 --single-branch \
            --branch $MARE_BRANCH \
            $MARE_URL mare
    else
        cd mare
        git fetch && git reset --hard origin/$MARE_BRANCH
        cd ..
    fi

    # remotedebug
    if [ ! -d remotedebug ]; then
        git clone --depth 1 --single-branch \
            --branch $REMOTEDEBUG_BRANCH \
            $REMOTEDEBUG_URL remotedebug
    else
        cd remotedebug
        git fetch && git reset --hard origin/$REMOTEDEBUG_BRANCH
        cd ..
    fi

    # devtools
    if [ ! -d devtools ]; then
        git clone --depth 1 --single-branch \
            --branch $DEVTOOLS_BRANCH \
            $DEVTOOLS_URL devtools
    else
        cd devtools
        git fetch && git reset --hard origin/$DEVTOOLS_BRANCH
        cd ..
    fi
)

# prepare node_modules
(
    if [ ! -d node_modules ]; then
        npm install --loglevel=info
    fi
)

# build script
(
    cd $BUILD_DIR

    cd mare/server
    git co .
    npm install --loglevel=info
    npm run build
    cd ../..

    cd mare/web
    git co .
    npm install --loglevel=info
    npm run build
    cd ../..

    cd devtools
    git co .
    ./build.sh
    cd ..
)

# build linux-x64
(
    cd $BUILD_DIR

    cd lua/src
    git co .&& git clean -dfx .
    make linux
    cd ../..

    cd lsocket
    git co .&& git clean -dfx .
    gcc -O2 -shared -fPIC -o lsocket.so lsocket.c
    cd ..

    cd remotedebug
    git co .&& git clean -dfx .
    gcc -O2 -shared -fPIC -D_GNU_SOURCE \
        -o remotedebug.so debugvar.h remotedebug.c
    cd ..
)
mkdir -p $DIST_DIR/linux-x64/dbdata
cp -r $BUILD_DIR/mare/server/dist $DIST_DIR/linux-x64/server
cp -r $BUILD_DIR/mare/web/dist $DIST_DIR/linux-x64/web
cp -r $BUILD_DIR/mare/lua-example $DIST_DIR/linux-x64/example
cp -r $BUILD_DIR/mare/lua-libs/mare $DIST_DIR/linux-x64/example/mare
cp -r $BUILD_DIR/devtools/dist/front_end $DIST_DIR/linux-x64/web/webroot/devtools
cp $BUILD_DIR/lua/src/lua $DIST_DIR/linux-x64/example
cp $BUILD_DIR/lsocket/lsocket.so $DIST_DIR/linux-x64/example
cp $BUILD_DIR/remotedebug/remotedebug.so $DIST_DIR/linux-x64/example
cp $BUILD_DIR/msgpack/src5.3/MessagePack.lua $DIST_DIR/linux-x64/example
cp $BUILD_DIR/$NODEJS_DIR_LINUX_x64/bin/node $DIST_DIR/linux-x64
cp index.js $DIST_DIR/linux-x64
cp -r node_modules $DIST_DIR/linux-x64/node_modules
rm $DIST_DIR/linux-x64/example/.gitignore
rm $DIST_DIR/linux-x64/example/.luacheckrc

# build win-x64
(
    cd $BUILD_DIR

    cd lua/src
    git co .&& git clean -dfx .
    sed -i 's/^\(CC\|AR\|RANLIB\)= /\0x86_64-w64-mingw32-/g' Makefile
    make mingw
    cd ../..

    cd lsocket
    git co .&& git clean -dfx .
    sed -i 's/Iphlpapi.h/iphlpapi.h/' win_compat.c
    x86_64-w64-mingw32-gcc -O2 -shared \
        -I../lua/src \
        -o lsocket.dll lsocket.c win_compat.c \
        -L../lua/src -llua53 \
        -lws2_32
    cd ..

    cd remotedebug
    git co .&& git clean -dfx .
    x86_64-w64-mingw32-gcc -O2 -shared \
        -I../lua/src \
        -o remotedebug.dll debugvar.h remotedebug.c \
        -L../lua/src -llua53
    cd ..
)
mkdir -p $DIST_DIR/win-x64/dbdata
cp -r $BUILD_DIR/mare/server/dist $DIST_DIR/win-x64/server
cp -r $BUILD_DIR/mare/web/dist $DIST_DIR/win-x64/web
cp -r $BUILD_DIR/mare/lua-example $DIST_DIR/win-x64/example
cp -r $BUILD_DIR/mare/lua-libs/mare $DIST_DIR/win-x64/example/mare
cp -r $BUILD_DIR/devtools/dist/front_end $DIST_DIR/win-x64/web/webroot/devtools
cp $BUILD_DIR/lua/src/{lua53.dll,lua.exe} $DIST_DIR/win-x64/example
cp $BUILD_DIR/lsocket/lsocket.dll $DIST_DIR/win-x64/example
cp $BUILD_DIR/remotedebug/remotedebug.dll $DIST_DIR/win-x64/example
cp $BUILD_DIR/msgpack/src5.3/MessagePack.lua $DIST_DIR/win-x64/example
cp $BUILD_DIR/$NODEJS_DIR_WIN_x64/node.exe $DIST_DIR/win-x64
cp index.js $DIST_DIR/win-x64
cp -r node_modules $DIST_DIR/win-x64/node_modules
rm $DIST_DIR/win-x64/example/.gitignore
rm $DIST_DIR/win-x64/example/.luacheckrc
echo 'node.exe index.js' > $DIST_DIR/win-x64/run.bat
echo 'cmd.exe' > $DIST_DIR/win-x64/example/cmd-here.bat

# make archive
(
    cd $DIST_DIR
    suffix=nightly-`date +%Y%m%d_%H%M%S`
    tar -cJvf linux-x64.tar.xz linux-x64
    zip -r win-x64.zip win-x64
    mkdir -p archives
    mv linux-x64.tar.xz archives/linux-x64-$suffix.tar.xz
    mv win-x64.zip archives/win-x64-$suffix.zip
)

echo 'Done.'
