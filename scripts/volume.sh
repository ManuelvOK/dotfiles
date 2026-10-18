#!/usr/bin/env bash
# usage: volume.sh up|down|mute
sink=@DEFAULT_SINK@
step=5%

case "$1" in
	up)   pactl set-sink-mute "$sink" 0 && pactl set-sink-volume "$sink" "+$step" ;;
	down) pactl set-sink-volume "$sink" "-$step" ;;
	mute) pactl set-sink-mute "$sink" toggle ;;
	*)    echo "usage: ${0##*/} up|down|mute" >&2; exit 1 ;;
esac

# refresh the volume block of dwmblocks (signal 2 in its config.h)
pkill -RTMIN+2 -x dwmblocks
exit 0
