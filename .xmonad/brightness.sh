#!/bin/bash

location=`head -n 1 ~/.location`
values=`redshift -l "$location" -p`

temp=`echo "$values" | grep "Color temperature:" | cut -f 3 -d " "`
brightness=$1

redshift -P -m randr -O "$temp" -b "$brightness"
