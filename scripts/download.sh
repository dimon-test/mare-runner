#!/bin/bash

set -e

download_dir=$MARE_RUNNER_DOWNLOAD_DIR
pwd_dir=$PWD

function download_node_bin() {
    ver=7.7.4
    tpl=https://nodejs.org/dist/v$ver
    mkdir -p node-bin-dirs

    src=node-v$ver-linux-x64
    dst=linux_x64
    dir=node-bin-dirs/$dst
    pkg=$src.tar.xz
    url=$tpl/$pkg
    if [ ! -d $dir ]; then
        if [ ! -f $pkg ]; then
            wget $url -O $pkg
        fi
        cd node-bin-dirs
        tar -xf ../$pkg
        mv $src $dst
        cd ..
    fi

    src=node-v$ver-win-x64
    dst=win_x64
    dir=node-bin-dirs/$dst
    pkg=$src.zip
    url=$tpl/$pkg
    if [ ! -d $dir ]; then
        if [ ! -f $pkg ]; then
            wget $url -O $pkg
        fi
        cd node-bin-dirs
        unzip -q ../$pkg
        mv $src $dst
        cd ..
    fi

    src=node-v$ver-darwin-x64
    dst=mac_x64
    dir=node-bin-dirs/$dst
    pkg=$src.tar.gz
    url=$tpl/$pkg
    if [ ! -d $dir ]; then
        if [ ! -f $pkg ]; then
            wget $url -O $pkg
        fi
        cd node-bin-dirs
        tar -xf ../$pkg
        mv $src $dst
        cd ..
    fi
}

function download_lua_bin() {
    tag=v0.1.2
    tpl=https://github.com/muzuiget/lua-bin/releases/download/${tag}
    mkdir -p lua-bin-dirs

    dir=lua-bin-dirs/linux_x64
    pkg=lua-bin-linux_all.zip
    url=$tpl/$pkg
    if [ ! -d $dir ]; then
        if [ ! -f $pkg ]; then
            wget $url -O $pkg
        fi
        cd lua-bin-dirs
        unzip ../$pkg
        cd ..
    fi

    dir=lua-bin-dirs/win_x64
    pkg=lua-bin-win_all.zip
    url=$tpl/$pkg
    if [ ! -d $dir ]; then
        if [ ! -f $pkg ]; then
            wget $url -O $pkg
        fi
        cd lua-bin-dirs
        unzip ../$pkg
        cd ..
    fi

    dir=lua-bin-dirs/mac_x64
    pkg=lua-bin-mac_all.zip
    url=$tpl/$pkg
    if [ ! -d $dir ]; then
        if [ ! -f $pkg ]; then
            wget $url -O $pkg
        fi
        cd lua-bin-dirs
        unzip ../$pkg
        cd ..
    fi
}

function download_mare_src() {
    url=https://github.com/muzuiget/mare.git
    tag=v0.2.0
    if [ -d mare ]; then
        cd mare
        git checkout . && git clean -df .
        cd ..
        return
    fi

    git clone --depth 1 --single-branch -b $tag $url mare
    git -C mare checkout -b $tag
}

function download_node_modules() {
    if [[ $OSTYPE == linux* ]]; then
        node_path=$download_dir/node-bin-dirs/linux_x64
        export PATH=$node_path/bin:$PATH
    elif [[ $OSTYPE == darwin* ]]; then
        node_path=$download_dir/node-bin-dirs/mac_x64
        export PATH=$node_path/bin:$PATH
    fi

    if [ ! -d node_modules ]; then
        npm install --loglevel=warn
    fi

    cd mare/server
    if [ ! -d node_modules ]; then
        npm install --loglevel=warn
    fi
    if [ ! -d dist ]; then
        npm run build
    fi
    cd ../..

    cd mare/web
    if [ ! -d node_modules ]; then
        npm install --loglevel=warn
    fi
    if [ ! -d dist ]; then
        npm run build
    fi
    cd ../..
}

cd $download_dir
download_node_bin
download_lua_bin
download_mare_src
download_node_modules
cd $pwd_dir
