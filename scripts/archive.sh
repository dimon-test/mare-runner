#!/bin/bash

set -e

build_dir=$MARE_RUNNER_BUILD_DIR
dist_dir=$MARE_RUNNER_DIST_DIR
pwd_dir=$PWD

cd $build_dir
for dir in ./*; do
    cp -r $dir/output $dist_dir/$dir
done

cd $dist_dir
for name in *; do
    zip -qr mare-runner-${name}.zip ./$name
done
cd $pwd_dir
