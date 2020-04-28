#!/bin/bash

pa="`pactl list sinks`"
mute="`echo "$pa" | perl -000ne 'if(/#0/){/(Mute:.*)/; print "$1\n"}' | awk '{ print $2 }'`"
left="`echo "$pa" | perl -000ne 'if(/#0/){/(Volume:.*)/; print "$1\n"}' | awk '{ print $5 }'`"
right="`echo "$pa" | perl -000ne 'if(/#0/){/(Volume:.*)/; print "$1\n"}' | awk '{ print $12 }'`"

if [ "$mute" = "yes" ]; then
    echo "Vol: mute"
elif [ "$left" = "$right" ]; then
    echo "Vol: $left"
else
    echo "Vol: $left | $right"
fi
