#!/bin/bash
export DISPLAY=:0
acpi=`acpi -b`
batteries_level=`echo "$acpi" | grep -P -o '[0-9]+(?=%)'`
is_charging=`echo "$acpi" | grep Charging`
count="1"
for nb in $batteries_level; do
    battery_level="$battery_level$op$nb"
    op="+"
    count="$count+1"
done
battery_level=`echo "($battery_level)/($count)" | bc`
if [ -z "$is_charging" ] && [ "$battery_level" -le 15 ]
then
#    sudo systemctl suspend
    notify-send 'Battery low' "Battery level is ${battery_level}% !"
fi
