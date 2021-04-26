#!/bin/bash

enterprise_flag=
skip_deps_flag=

while getopts "es" flag; do
    case "${flag}" in
        s) skip_deps_flag=1;;
        e) enterprise_flag=1;;
    esac
done

command="./skybuild"

if [ ! -z $skip_deps_flag ]; then
    command="${command} --skip-deps"
fi

command="${command} AndroidGradle clean,@installNoSymbols"

if [ ! -z $enterprise_flag ]; then
    command="${command}EnterpriseDebug"
else
    command="${command}ConsumerDebug"
fi

echo $command
$command
