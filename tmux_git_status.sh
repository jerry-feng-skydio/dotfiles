#!/bin/bash

FILE=~/.iwanttmuxgitstatus
if ! test -f "$FILE"; then
    echo " Skymux git off. 'toggle_skymux_git' to re-enable. "
    exit 1
fi
echo " Skymux git on. 'toggle_skymux_git' to disable. "
