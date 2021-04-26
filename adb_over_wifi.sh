#!/bin/bash

adb disconnect

device_ip=$(adb shell "ip addr show wlan0 | grep -e wlan0$ | cut -d\" \" -f 6 | cut -d/ -f 1")
echo "Got device IP address: ${device_ip}"

if [ ! -z $device_ip ]; then
    adb tcpip 5555
    sleep 1
    adb connect "${device_ip}:5555"
    sleep 1
    adb devices
else
    echo "Could not get ip?"
fi


