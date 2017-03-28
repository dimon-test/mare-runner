#!/bin/bash

set -e

if [ -z $MARE_RUNNER_DOWNLOAD_DIR ]; then
    export MARE_RUNNER_DOWNLOAD_DIR=$PWD/download
fi
if [ -z $MARE_RUNNER_BUILD_DIR ]; then
    export MARE_RUNNER_BUILD_DIR=$PWD/build
fi
if [ -z $MARE_RUNNER_DIST_DIR ]; then
    export MARE_RUNNER_DIST_DIR=$PWD/dist
fi
if [ -z $MARE_RUNNER_MAKE_ARCHS ]; then
    export MARE_RUNNER_MAKE_ARCHS='linux_x64 win_x64 mac_x64'
fi

echo "MARE_RUNNER_DOWNLOAD_DIR=$MARE_RUNNER_DOWNLOAD_DIR"
echo "MARE_RUNNER_BUILD_DIR=$MARE_RUNNER_BUILD_DIR"
echo "MARE_RUNNER_DIST_DIR=$MARE_RUNNER_DIST_DIR"
echo "MARE_RUNNER_MAKE_ARCHS=$MARE_RUNNER_MAKE_ARCHS"

rm -rf $MARE_RUNNER_DIST_DIR
mkdir -p $MARE_RUNNER_DOWNLOAD_DIR
mkdir -p $MARE_RUNNER_BUILD_DIR
mkdir -p $MARE_RUNNER_DIST_DIR

./scripts/download.sh
./scripts/make.sh
./scripts/archive.sh

ls -lh $MARE_RUNNER_DIST_DIR
