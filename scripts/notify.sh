#! /usr/bin/env bash
export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME dwm)/environ)
notify-send "



$1





    " -u critical -t 60000

