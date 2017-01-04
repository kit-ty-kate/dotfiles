#!/bin/bash

location=`cat ~/.location`
values=`redshift -l "$location" -p`

temp=`echo "$values" | grep "Color temperature:" | cut -f 3 -d " "`
brightness=$1

redshift -O "$temp" -b "$brightness"
