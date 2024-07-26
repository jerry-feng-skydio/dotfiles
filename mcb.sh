#!/bin/bash
#
# quickly rebuilding/redeploying user_camera_front from stevemo
TARGET=isp

BAZEL_TARGET=//launch/vehicle_deploy:aircam_r47_qcu_lu.2.0.aircam_process
BAZEL_BINARY=__aircam_r47_qcu_lu.2.0.static_aircam_process.cc_binary
BAZEL_BINARY_PATH=build/bazel-out/k8-fastbuild/bin/launch/vehicle_deploy/aircam_r47_qcu_lu.2.0.runfiles/aircam/launch/vehicle_deploy
TARGET_PATH=/home/skydio/bazel/aircam_r47_qcu_lu.2.0.runfiles/aircam/launch/vehicle_deploy
if [[ $1 != "" ]]
then
    TARGET=$1
fi
set -e
bazel --unsafe build $BAZEL_TARGET --remote_download_outputs=all
set +e
ssh $TARGET sudo rm -f /tmp/$BAZEL_BINARY
scp $BAZEL_BINARY_PATH/$BAZEL_BINARY $TARGET:/tmp
ssh $TARGET sudo cp -f /tmp/$BAZEL_BINARY $TARGET_PATH
