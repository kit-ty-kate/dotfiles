#!/bin/bash

pa="`pactl list sinks`"
mute="`echo "$pa" | awk '/^\tMute:/ { print $2 }'`"
left="`echo "$pa" | awk '/^\tVolume:/ { print $5 }'`"
right="`echo "$pa" | awk '/^\tVolume:/ { print $12 }'`"

if [ "$mute" = "yes" ]; then
    echo "Vol: mute"
elif [ "$left" = "$right" ]; then
    echo "Vol: $left"
else
    echo "Vol: $left | $right"
fi
