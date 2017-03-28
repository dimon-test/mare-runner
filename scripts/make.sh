#!/bin/bash

set -e

download_dir=$MARE_RUNNER_DOWNLOAD_DIR
build_dir=$MARE_RUNNER_BUILD_DIR
archs=$MARE_RUNNER_MAKE_ARCHS
pwd_dir=$PWD

function create_arch_dir() {
    dir=$1
    rm -rf $dir
    mkdir $dir
    ln -s $download_dir/mare $dir/mare
    mkdir $dir/output
}

function copy_files() {
    dir=$1
    cd $dir
    cp $pwd_dir/index.js output
    cp -r $pwd_dir/node_modules output/node_modules
    cp -r mare/server/dist output/server
    cp -r mare/web/dist output/web
    cp -r mare/lua-example output/example
    cp -r mare/lua-libs/mare output/example/mare
    cp $download_dir/lua-bin-dirs/$dir/* output/example
    rm output/example/.gitignore
    rm output/example/.luacheckrc
    mkdir output/dbdata
    cd ..
}

function make_arch_linux_x64() {
    dir=$1
    create_arch_dir $dir
    copy_files $dir
    cp $download_dir/node-bin-dirs/$dir/bin/node $dir/output
}

function make_arch_win_x64() {
    dir=$1
    create_arch_dir $dir
    copy_files $dir
    cp $download_dir/node-bin-dirs/$dir/node.exe $dir/output
    echo 'node.exe index.js' > $dir/output/run.bat
    echo 'cmd.exe' > $dir/output/example/cmd-here.bat
}

function make_arch_mac_x64() {
    dir=$1
    create_arch_dir $dir
    copy_files $dir
    cp $download_dir/node-bin-dirs/$dir/bin/node $dir/output
}

cd $build_dir
for name in $archs; do
    make_arch_$name $name
done
cd $pwd_dir
